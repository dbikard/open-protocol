class HomepageController < ApplicationController
  def index
    @categories = Category.limit(4)
  end
  def about
  end
end