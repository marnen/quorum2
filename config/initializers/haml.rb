# coding: UTF-8

Haml::Template.options[:format] = :xhtml
# We're still using HTML 5 for all actual HTML content, but since we need to generate XML as well, this is the easiest way.

Haml::Filters::Markdown.module_eval do
  def render(text)
    RDiscount.new(text, :autolink).to_html
  end
end
