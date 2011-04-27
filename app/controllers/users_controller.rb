class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def forgot_password
    
  end

  def new
    if request.xhr?
      render :partial => "homepage/register_login"
    end
  end
  
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      format.json do
        render :json => { :ok => verify_recaptcha && @user.save }
      end
      format.html do
        if @user.save
          redirect_back_or_default root_url
        else
          render :action => :new
        end
      end
    end
  end
end
