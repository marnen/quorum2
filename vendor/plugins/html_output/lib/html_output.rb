require 'active_support'

module ActionView::Helpers::TagHelper
  # Forces the "open" param to always be true so it never self-closes
  def tag_with_non_self_closing(name, options = nil, open = false, *args)
    tag_without_non_self_closing name, options, true
  end
  
  alias_method_chain :tag, :non_self_closing
end

class ActionView::Helpers::InstanceTag
  # We have to re-alias tag_without_error_wrapping because it is previously
  # aliased to the old version of tag, which self-closes
  alias_method :tag_without_error_wrapping, :tag_with_non_self_closing
end
