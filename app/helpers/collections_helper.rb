module CollectionsHelper
  def current_user_is_admin?
    return false unless current_user
    !@collection.collection_admins.where(:user_id => current_user.id).first.nil? || \
    @collection.user == current_user
  end
  def admin_edit_link(id, extra_classes="")
    if current_user_is_admin?
      link_to("Edit", "javascript:void(0)", :class => "edit_button #{extra_classes}", :id => id)
    else
      ""
    end
  end
end