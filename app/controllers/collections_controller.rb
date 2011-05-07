class CollectionsController < ApplicationController
  before_filter :require_user, :except => [:show]

  #
  # The collections administrated by and created by the current user.
  #
  def my
    if current_user.administrated_collections.one?
      return redirect_to :action => :show, :id => current_user.administrated_collections.first.id
    end
    @collections = current_user.administrated_collections
  end

  #
  # Build a new collection owned by the current user.
  #
  def new
  end

  #
  # Save a new collection built by the current user.
  #
  def create
    Collection.transaction do
      collection = current_user.collections.create!(params)
      # Add the invited admins.
      collection.add_emails_as_admins!(params[:admins]) unless params[:admins].blank?

      render(:json => {:ok => true, :id => collection.id})
    end
  rescue => e
    render(:json => {:ok => false, :error => e.message})
  end

  #
  # View a single collection.
  #
  def show
    @collection = Collection.includes(:categories => {:category_protocols => :protocol}).find(params[:id])
    @categories = @collection.categories.reject{|c| c.category_protocols.empty? }
  end

  #
  # Delete a collection created by the current user. Only creators can destroy
  # a collection.
  #
  def delete
    @collection = current_user.collections.find(params[:id])
    if request.post?
      @collection.destroy
      redirect_to "/"
    else
      render :partial => "delete"
    end
  end

  #
  # Remove a protocol from a category of a collection that the current user
  # administrates.
  #
  def remove_protocol
    category_protocol = CategoryProtocol.includes(:category => {:collection => :admins}).find(params[:id])
    unless  category_protocol.category.collection.admins.include?(current_user)
      raise "You cannot modify this collection, since you are not an administrator."
    end
    category_protocol.destroy
    render(:json => {:ok => true})
  rescue => e
    render(:json => {:ok => false, :error => e.message})
  end

  #
  # Rename a category of a collection that the current user administrates.
  #
  def rename_category
    category = Category.find(params[:category_id])
    unless category.collection.admins.include?(current_user)
      raise "You cannot modify this category, since you are not an administrator of the collection."
    end
    category.name = params[:name]
    category.save!
    render :json => { :ok => true }
  rescue => e
    render :json => { :ok => false, :error => e.message }
  end

  #
  # Update the attributes of a collection administrated by the current user.
  #
  def inline_edit
    unless current_user.administrated_collections.find(params[:id])
      raise "You cannot modify this collection, since you are not an administrator."
    end
    @collection = Collection.find(params[:id])
    @collection.update_attributes(params.slice(:name, :contact, :homepage, :description))
    render :json => { :ok => true }
  rescue => e
    logger.debug(e.message)
    render :json => { :ok => false, :error => e.message }
  end

  #
  # Provides a jQuery-UI Autocomplete widget-compatible list of autocomplete
  # suggestions for a category name.
  #
  def category_autocomplete
    @collection = current_user.collections.find(params[:id])
    categories = @collection.categories.where(["name LIKE ?", "%#{params[:term]}%"])
    render :json => categories.map{|c| { :id => c.name, :value => c.name }}
  end
end
