class HomepageController < ApplicationController
  def index
    @categories = Category.limit(4)
  end
  def about
  end
  def feedback
    if request.post?
      Mailer.mail_webmaster(current_user, params[:feedback])
      render :json => { :ok => true }
    else
      render :partial => "feedback"
    end
  end
end