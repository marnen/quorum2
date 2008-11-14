module EventsHelper 
  # Returns #User's commitment status for #Event as a symbol -- :yes, :no, :or maybe.
  def attendance_status(event, user)
    if event.find_committed(:yes).include? user then
      status = :yes
    elsif event.find_committed(:no).include? user then
      status = :no
    else
      status = :maybe
    end
  end
  
  # Generates an HTML date element for #Event, including hCalendar[http://microformats.org/wiki/hcalendar] annotation.
  #
  # Usage:
  #
  # <tt>@event.date = today</tt>
  #
  # <tt>date_element(@event) # -> something like '<abbr class="dtstart" title="20080924">24 Sep 2008</abbr>'</tt>
  def date_element(event)
    # generate a microformat HTML date element
    ical_date = h event.date.to_formatted_s(:ical)
    full_date = h event.date.to_formatted_s(:rfc822)
    content_tag :abbr, full_date, :class => :dtstart, :title => ical_date
  end
  
  # Generates a delete link for #Event.
  def delete_link(event)
    link_to h(_("delete")), url_for(:controller => 'events', :action => 'delete', :id => event.id)
  end
  
  # Returns the distance from #Event to #User's address, in a #String of the form <tt>"35.2 miles"</tt>.
  # If something goes wrong, returns <tt>"0.0 miles"</tt>.
  def distance_string(event, user)
    begin
      meters = event.coords.ellipsoidal_distance(user.coords)
      miles = meters / 1609.344
      
      content_tag(:span, h(_("%.1f miles" % miles)), :class => :distance) << h(' •')
    rescue
      content_tag(:span, h(_("%.1f miles" % 0)), :class => :distance) << h(' •')
    end
  end
  
  # Generates an edit link for #Event.
  def edit_link(event)
    link_to h(_("edit")), url_for(:controller => 'events', :action => 'edit', :id => event.id)
  end
  
  # Generates a <div> element with a map for #Event, using the Google API key for <em>host</em>.
  def event_map(event, host)
    return nil if event.nil?
    
    map = GMap.new(:map)
    latlng = [event.coords.lat, event.coords.lng]
    map.center_zoom_init(latlng, 14)
    marker = GMarker.new(latlng)
    html = StringVar.new(info(event).dump)
    map.record_init html.declare('html')
    map.declare_init(marker, 'marker')
    # map.record_init html.declare('foo')
    map.record_init marker.bind_info_window_html(html)
    map.overlay_init(marker)
    map.control_init :large_map => true, :map_type => true
    map.record_init marker.open_info_window_html(html)
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
  
  # Escapes characters in <em>string</em> that would be illegal in iCalendar format.
  def ical_escape(string)
    string.gsub(%r{[\\,;]}) {|c| '\\' + c}.gsub("\n", '\\n')
  end

  # Generates an iCal export link for #Event.
  def ical_link(event)
    link_to h(_("iCal")), url_for(:controller => 'events', :action => 'export', :id => event.id), :class => 'ical'
  end

  # Generates an iCal unique ID for #Event.
  def ical_uid(event)
    "event-" << event.id.to_s << "@" << DOMAIN
  end
  
  # Generates text for the info window on Google map of #Event.
  #
  # TODO: this should probably become a partial.
  def info(event)
    return nil if (event.nil? or !event.kind_of?(Event))
    result = ""
    result << content_tag(:h3, h(event.site || event.name))
    city = [h(event.city), h(event.state.code), h(event.state.country.code)].compact.join(', ')
    result << content_tag(:p, [h(event.street), h(event.street2), city].compact.join(tag(:br)))
    
    url = 'http://maps.google.com'
    from = User.current_user.address_for_geocoding.nil? ? nil : "saddr=#{u User.current_user.address_for_geocoding}"
    to = event.address_for_geocoding.nil? ? nil : "daddr=#{u event.address_for_geocoding}"
    params = [from, to].compact.join('&')
    result << content_tag(:p, link_to(_('Get directions'), 'http://maps.google.com?' + params.to_s))
    result
  end
  
  # Given an #Array (or similar) of #User objects, returns an #Array of their full names as #Strings.
  def list_names(users)
    return '' if users.nil? or users.size == 0
    users.compact.join(', ')
  end

  # Generates a link to a map of #Event.
  def map_link(event)
    link_to h(_("map")), url_for(:controller => 'events', :action => 'map', :id => event.id), :target => 'map'
  end
  
  # Generates a hint to use Markdown for formatting.
  def markdown_hint
    content_tag(:span, h(_('(use %{Markdown} for formatting)')) % {:Markdown => link_to(h(_('Markdown')), 'http://daringfireball.net/projects/markdown/basics', :target => 'markdown')}, :class => :hint)
  end
  
  # Generates an RSS URL for the current user's events feed.
  def rss_url
    if User.current_user
      formatted_feed_events_url(:format => :rss, :key => User.current_user.feed_key)
    else
      nil
    end
  end

  # Generates a sort link (e.g., for a table header).
  # _title_:: Display text for the link (will be treated as a gettext key).
  # _field_:: Field name that the link will sort on.
  # _direction_:: Direction to sort. May be <tt>:asc</tt> (default if not supplied) or <tt>:desc</tt>.
  # _options_:: Hash of options. At the moment, only <tt>:class</tt> is supported; this specifies the class name for the resulting HTML element (default is <tt>"sort"</tt>).
  def sort_link(title, field, direction = :asc, options = {})
    # generate a sort link
    my_class = options[:class]
    my_class ||= 'sort'
    link_to h(_(title)), url_for(:overwrite_params => {:order => field, :direction => direction}), :class => my_class
  end
  
  class StringVar < Ym4r::GmPlugin::Variable
    def declare(name)
      result = "var #{name} = #{to_javascript};"
      @variable = name
      return result
    end
  end
end
