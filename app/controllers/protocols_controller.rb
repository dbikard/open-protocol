class ProtocolsController < ApplicationController
  before_filter :require_user, :except => [:show]

  def new
  end

  def show
    @protocol = Protocol.find(params[:id])
  end

  def create
    protocol_params = JSON.parse(params[:protocol])
    protocol = current_user.protocols.build(protocol_params.slice(*%w[name introduction total_hours total_minutes bench_hour]))
    protocol_params["reagents"].each do |reagent_params|
      protocol.reagents.build(reagent_params.slice(*%w[name link])) unless reagent_params["name"].blank?
    end
    protocol_params["authors"].each do |author_params|
      protocol.authors.build(author_params.slice("name")) unless author_params['name'].blank?
    end
    protocol_params["steps"].each_with_index do |step_params, i|
      step = protocol.steps.build(step_params.slice(*%w[name instructions duration_hours duration_minutes duration_seconds]).merge(
        :position         => i + 1
      ))
      step.image = current_user.images.find(step_params['image_id']) unless step_params['image_id'].blank?
    end
    protocol.save!
    render :json => { :ok => true, :id => protocol.id }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def new_step
    render(:partial => "protocols/new_step.html.haml", :locals => { :step => params[:step], :allow_delete => true })
  end

  def new_author
    render(:partial => "protocols/author_row.html.haml", :locals => { :allow_delete => true })
  end

  def new_reagent
    render(:partial => "protocols/reagent_row.html.haml", :locals => { :allow_delete => true })
  end

  def upload_image
    file = if params[:qqfile].is_a?(String)
      decorate_stringio(StringIO.new(request.raw_post), params[:qqfile])
    else
      params[:qqfile]
    end

    image = current_user.images.build(:image => file)
    if image.save
      render :json => {
        :ok => true,
        :thumbnail_html => render_to_string(
          :partial => "thumbnail",
          :locals => { :image => image, :show_edit => true }
        )
      }.to_json
    else
      render :json => { :ok => false }.to_json
    end
  end

  def create_comment
    protocol = Protocol.find(params[:id])
    comment = protocol.comments.build(:body => params[:comment], :user => current_user)
    if comment.save
      render :json => {
        :ok => true,
        :comment_html => render_to_string(
          :partial => "comment",
          :locals => { :comment => comment }
        )
      }.to_json
    else
      render :json => { :ok => false }.to_json
    end
  end

  def inline_edit
    @protocol = current_user.protocols.find(params[:id])
    if params[:authors]
      Protocol.transaction do
        @protocol.authors.clear
        params[:authors].reject(&:blank?).each do |author_name|
          @protocol.authors.build(:name => author_name)
        end
        @protocol.save!
      end
      render :json => { :ok => true, :authors_html => render_to_string(:partial => "authors", :locals => { :authors => @protocol.authors }) }
    elsif params[:reagents]
      Protocol.transaction do
        @protocol.reagents.clear
        # jquery has some peculiarities about explicitly declaring the index
        # of the serialized array (to avoid ambiguity) that does not play
        # nicely will Rails' default params parsing. So, we treat it like
        # a hash masquerading as an array and simply sort by index.
        params[:reagents].sort_by{|index, reagent| index.to_i }.map(&:last).each do |reagent|
          @protocol.reagents.build(:name => reagent[:name], :external_link => reagent[:link])
        end
        @protocol.save!
      end
      render :json => { :ok => true }
    else
      @protocol.update_attributes(params)
      render :json => { :ok => true }
    end
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def edit_step
    protocol = current_user.protocols.find(params[:id])
    step = nil
    if params[:step][:id]
      step = protocol.steps.find(params[:step][:id])
      step.update_attributes(params[:step])
    elsif params[:step][:anchor_id]
      anchor_step  = protocol.steps.find(params[:step][:anchor_id])
      bumped_steps = protocol.steps.select{|s| s.position > anchor_step.position }
      Protocol.transaction do
        # we have a unique composite key on (protocol_id,position) so if you
        # don't reverse the steps, then you are going to step on an existing
        # step's position and cause a key error, when you bump the positions
        # up by one. that is, we increase the highest position first, and then
        # bump the next highest to take that place, and so on.
        bumped_steps.reverse.each{|s| s.position += 1; s.save}
        step = protocol.steps.create!(params[:step].merge(:position => anchor_step.position + 1))
      end
    end
    if params[:step][:image_id]
      step.image = current_user.images.find(params[:step][:image_id])
      step.save!
    elsif step.image
      step.image.destroy
      step.image = nil
      step.save!
    end
    render :json => { :ok => true, :step_html => render_to_string(:partial => "step", :locals => { :step => step }) }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def remove_step
    protocol = current_user.protocols.find(params[:id])
    step     = protocol.steps.find(params[:step_id])
    Protocol.transaction do
      position = step.position
      step.delete
      protocol.steps.select{|s| s.position > position }.each{|s| s.position -= 1; s.save! }
    end
    render :json => { :ok => true }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def remove_image
    image = current_user.images.find(params[:image_id])
    image.destroy if image
    render :json => { :ok => true }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def add_to_collection
    @protocol = Protocol.find(params[:id])
    if request.post?
      collection = current_user.administrated_collections.find(params[:collection])
      category   = collection.categories.where(:name => params[:category]).first
      category   ||= collection.categories.create!(:name => params[:category])
      category_protocol = category.category_protocols.build
      category_protocol.protocol = @protocol
      category_protocol.save!
      render :json => { :ok => true, :protocol_id => @protocol.id }
    else
      @collections = current_user.collections
      render(:partial => "add_to_collection")
    end
  end

  private

    def decorate_stringio(io, filename)
      metaclass = class << io; self; end 
      metaclass.send :define_method, :original_filename do
        filename
      end
      io
    end
end