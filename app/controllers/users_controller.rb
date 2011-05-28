class UsersController < ApplicationController
  before_filter :require_no_user, :only => [:new, :create]
  before_filter :require_user, :only => [:show, :edit, :update]

  def reset_password
    return if params[:id].blank? || params[:reset_token].blank?
    @user = User.where(:id => params[:id], :reset_token => params[:reset_token]).first
    return unless @user

    return unless request.post?
    if params[:password].blank? || params[:password_confirmation].blank?
      @user.errors.add(:base, "Password and password confirmation cannot be blank.")
      return
    end
    @user.password = params[:password]
    @user.password_confirmation = params[:password_confirmation]
    @user.save
    flash.now[:notice] = "Your password has been reset."
  end

  def forgot_password
    return unless request.post?
    user = User.where(:email => params[:email]).first
    if user
      user.refresh_reset_token!
      Mailer.mail_user(user,
        :subject   => 'Password Reset',
        :text_body => <<-END
  Please go to #{url_for(:controller => :users, :action => :reset_password, :id => user.id, :reset_token => user.reset_token)} to reset your OpenProtocols.net password.

  If you did not request a password reset, ignore this message. Your password has not yet been changed.
END
      )
      flash.now[:notice] = "A password reset email has been sent to #{user.email}."
    else
      flash.now[:notice] = "Invalid email address."
    end
  end

  def new
    if request.xhr?
      render :partial => "homepage/register_login"
    end
  end
  
  def create
    @user = User.new(params[:user])
    if verify_recaptcha(:model => @user, :timeout => RECAPTCHA_VERIFY_TIMEOUT) && @user.save
      respond_to do |format|
        format.json do
          render :json => { :ok => true }
        end
        format.html do
          redirect_back_or_default root_url
        end
      end
    else
      respond_to do |format|
        format.json do
          render :json => { :ok => false, :errors => @user.errors.full_messages }
        end
        format.html do
          render :action => :new
        end
      end
    end
  end
end
