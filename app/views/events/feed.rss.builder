xml.instruct! :xml, :version => "1.0"
xml.rss :version => '2.0', :"xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag! 'atom:link', :href => formatted_feed_events_url(:rss), :rel => :self
    xml.title _("%s Events") % SITE_TITLE
    xml.link events_url
    xml.description _("The latest events from %s.") % SITE_TITLE
    current_objects.each do |e|
      xml.item do
        xml.title e.name
        xml.link event_url(e)
      end
    end
  end
end
