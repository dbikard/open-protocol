module SearchHelper
  def search_result_link(result)
    controller = case result
      when Protocol
        :protocols
      when Collection
        :collections
    end
    link_to(result.name, {:controller => controller, :action => :show, :id => result.id})
  end
end