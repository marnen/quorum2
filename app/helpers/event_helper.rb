module EventHelper
  def date_element(event)
    # generate a microformat HTML date element
    ical_date = h event.date.to_formatted_s(:ical)
    full_date = h event.date.to_formatted_s(:rfc822)
    %{<abbr class="dtstart" title="#{ical_date}">#{full_date}</abbr>}
  end
  
  def edit_link(event)
    # generate an edit link
    link_to h(_("edit")), url_for(:controller => 'event', :action => 'edit', :id => event.id)
  end

  def ical_link(event)
    # generate an iCal export link
    link_to h(_("iCal")), url_for(:controller => 'event', :action => 'export', :id => event.id), :class => 'ical'
  end

  def ical_uid(event)
    # generate an iCal unique event ID
    "event-" << event.id.to_s << "@" << DOMAIN
  end
  
  def map_link(event)
    # generate a map link
    link_to h(_("map")), url_for(:controller => 'event', :action => 'map', :id => event.id), :target => 'map'
  end

end
