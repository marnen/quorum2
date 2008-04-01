module EventHelper  
  def attendance_status(event, user)
    if event.find_committed(:yes).include? user then
      status = :yes
    elsif event.find_committed(:no).include? user then
      status = :no
    else
      status = :maybe
    end
  end
  
  def date_element(event)
    # generate a microformat HTML date element
    ical_date = h event.date.to_formatted_s(:ical)
    full_date = h event.date.to_formatted_s(:rfc822)
    content_tag :abbr, full_date, :class => :dtstart, :title => ical_date
  end
  
  def delete_link(event)
    # generate an edit link
    link_to h(_("delete")), url_for(:controller => 'event', :action => 'delete', :id => event.id)
  end
  
  def distance_string(event, user)
    begin
      meters = event.coords.ellipsoidal_distance(user.coords)
      miles = meters / 1609.344
      
      content_tag(:span, h(_("%.1f miles" % miles)), :class => :distance) << h(' •')
    rescue
      content_tag(:span, h(_("%.1f miles" % 0)), :class => :distance) << h(' •')
    end
  end
  
  def edit_link(event)
    # generate an edit link
    link_to h(_("edit")), url_for(:controller => 'event', :action => 'edit', :id => event.id)
  end
  
  def event_map(event, host)
    # put together a map div from an event
    return nil if event.nil?
    
    map = GMap.new(:map)
    latlng = [event.coords.lat, event.coords.lng]
    map.center_zoom_init(latlng, 14)
    map.overlay_init(GMarker.new(latlng, :info_window => info(event)))
    map.control_init :large_map => true, :map_type => true
    @extra_headers = @extra_headers.to_s 
    @extra_headers << GMap.header(:host => host).to_s << map.to_html.to_s

    map.div :width => 500, :height => 400
=begin
    @map = GMap.new(:map)
    @map.center_zoom_init(latlng, 14)
    @map.overlay_init(GMarker.new(latlng, :info_window => @event.site || @event.street ))
    @map.control_init(:large_map => true, :scale => true)
    @page_title = _("Map for %s" % @event.name)

=end
  end
  
  def ical_escape(string)
    string.gsub(%r{[\\,;]}) {|c| '\\' + c}.gsub("\n", '\\n')
  end

  def ical_link(event)
    # generate an iCal export link
    link_to h(_("iCal")), url_for(:controller => 'event', :action => 'export', :id => event.id), :class => 'ical'
  end

  def ical_uid(event)
    # generate an iCal unique event ID
    "event-" << event.id.to_s << "@" << DOMAIN
  end
  
  def info(event)
    # text for info window on Google maps
    return nil if (event.nil? or !event.kind_of?(Event))
    result = ""
    result << content_tag(:h3, h(event.site || event.name))
    city = [h(event.city), h(event.state.code), h(event.state.country.code)].compact.join(', ')
    result << content_tag(:p, [h(event.street), h(event.street2), city].compact.join(tag(:br)))
    result
  end
  
  def list_names(users)
    # users is an Array (or similar) of users
    return '' if users.nil? or users.size == 0
    users.compact.collect {|u| u.fullname}.join(', ')
  end

  def map_link(event)
    # generate a map link
    link_to h(_("map")), url_for(:controller => 'event', :action => 'map', :id => event.id), :target => 'map'
  end

  def sort_link(title, field, direction = :asc, options = {})
    # generate a sort link
    my_class = options[:class]
    my_class ||= 'sort'
    link_to h(_(title)), url_for(:controller => 'event', :action => 'list', :order => field, :direction => direction), :class => my_class
  end
end
