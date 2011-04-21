module ProtocolsHelper
  def format_duration(hours, minutes, seconds)
    parts = []
    parts << "#{hours} hr" if hours.to_i > 0
    parts << "#{minutes} min" if minutes.to_i > 0
    parts << "#{seconds} sec" if seconds.to_i > 0
    str = parts.join(" ")
    if str.blank?
      "&nbsp;".html_safe
    else
      str
    end
  end
  def current_user_is_owner?
    current_user == @protocol.try(:user)
  end
  def maybe_edit_link(id, extra_classes="")
    if current_user_is_owner?
      link_to("Edit", "javascript:void(0)", :class => "edit_button #{extra_classes}", :id => id)
    else
      ""
    end
  end
end