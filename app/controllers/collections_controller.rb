class CollectionsController < ApplicationController
  before_filter :require_user, :except => [:show]
  def new
  end
  def create
    Collection.transaction do
      collection = current_user.collections.create!(params)
      if params[:admins]
        admins = User.where(:email => params[:admins])
        admins.each do |admin|
          collection_admin = collection.collection_admins.build
          collection_admin.user = admin
          collection_admin.save!
        end
      end
      self_admin = collection.collection_admins.build
      self_admin.user = current_user
      self_admin.save!
      render(:json => {:ok => true, :id => collection.id})
    end
  rescue => e
    render(:json => {:ok => false, :error => e.message})
  end
  def show
    @collection = Collection.includes(:categories => {:category_protocols => :protocol}).find(params[:id])
    @categories = @collection.categories.reject{|c| c.category_protocols.empty? }
  end
  def delete
    @collection = current_user.collections.find(params[:id])
    if request.post?
      @collection.destroy
      redirect_to "/"
    else
      render :partial => "delete"
    end
  end
  def remove_protocol
    category_protocol = CategoryProtocol.includes(:protocol => :user).find(params[:id])
    if category_protocol.protocol.user != current_user
      raise "Cannot delete other users' CategoryProtocols."
    end
    category_protocol.destroy
    render(:json => {:ok => true})
  rescue => e
    render(:json => {:ok => false, :error => e.message})
  end
  def rename_category
    category = Category.includes(:collection => :user).find(params[:category_id])
    if category.collection.user != current_user
      raise "Cannot change other users' Categories."
    end
    category.name = params[:name]
    category.save!
    render :json => { :ok => true }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end
  def inline_edit
    @collection = current_user.collections.find(params[:id])
    @collection.update_attributes(params.slice(:name, :contact, :homepage, :description))
    render :json => { :ok => true }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  def category_autocomplete
    @collection = current_user.collections.find(params[:id])
    categories = @collection.categories.where(["name LIKE ?", "%#{params[:term]}%"])
    render :json => categories.map{|c| { :id => c.name, :value => c.name }}
  end
end
