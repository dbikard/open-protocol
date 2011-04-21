class SearchController < ApplicationController
  RESULTS_PER_PAGE = 20
  def new
    if params[:search].blank?
      @results = nil
    else
      classes = if params[:protocols_only]
        [Protocol]
      elsif params[:collections_only]
        [Collection]
      else
        [Protocol, Collection]
      end
      @results = ThinkingSphinx.search(params[:search], {
        :classes  => classes,
        :page     => params[:page],
        :per_page => RESULTS_PER_PAGE
      })
    end
  end
end