xml.instruct! :xml, :version => "1.0"
xml.rss :version => '2.0', %s{xmlns:atom} => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.tag! 'atom:link', :href => formatted_feed_events_url(:format => :rss, :key => @key), :rel => :self
    xml.title _("%{Quorum} Events") % {:Quorum => SITE_TITLE}
    xml.link events_url
    xml.description do
      if !params[:feed_user].blank?
        xml.text!(_("The latest events from %{Quorum}, generated for %{user}.") % {:Quorum => SITE_TITLE, :user => params[:feed_user].fullname})
      end
    end
    if !params[:feed_user].blank?
      current_objects.each do |e|
        xml.item do
          xml.title e.name
          xml.description do
            xml.text!(['<p>', e.date.to_s(:rfc822), '<br/>', e.address_for_geocoding, '</p>'].join)
            xml.text!(['<p>', markdown(h(e.description.to_s)), '</p>'].join)
          end
          xml.link event_url(e)
          xml.guid event_url(e)
          xml.pubDate e.created_at.to_s(:rfc822)
        end
      end
    end
  end
end

