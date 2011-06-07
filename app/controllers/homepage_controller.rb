class HomepageController < ApplicationController
  def index
    @categories = Category.limit(4)
  end
  def about
  end
  def feedback
    if request.post?
      if params[:feedback].blank?
        render :json => { :ok => false, :error => "Please fill out the feedback form." }
      else
        Mailer.mail_webmaster(current_user, params[:ref], params[:feedback])
        render :json => { :ok => true }
      end
    else
      render :partial => "feedback"
    end
  end
end