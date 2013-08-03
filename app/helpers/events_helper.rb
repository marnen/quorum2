# coding: UTF-8

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

  # Returns #User's commitment comment for #Event.
  def attendance_comment(event, user)
    event.comments.find {|c| c.user == user }.try :comment
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
    link_to h(_("delete")), url_for(:controller => 'events', :action => 'delete', :id => event.id), :class => :delete
  end

  # Returns the distance from #Event to #User's address, in a #String of the form <tt>"35.2 miles"</tt>.
  # If something goes wrong, returns <tt>"0.0 miles"</tt>.
  def distance_string(event, user)
    begin
      meters = event.coords.distance(user.coords)
      miles = meters / 1609.344

      content_tag(:span, h(_("%.1f miles" % miles)), :class => :distance)
    rescue
      content_tag(:span, h(_("%.1f miles" % 0)), :class => :distance)
    end
  end

  # Generates an edit link for #Event.
  def edit_link(event)
    link_to h(_("edit")), url_for(:controller => 'events', :action => 'edit', :id => event.id), :class => :edit
  end

  # Generates a <div> element with a map for #Event, using the Google API key for <em>host</em>.
  # TODO: figure out how to make this html_safe! And fix the architecture!
  def event_map(event, hostname)
    return nil if event.nil?

    content_for(:javascript) do
      google_maps_header(hostname) + javascript_include_tag('events/map')
    end

    result = ''.html_safe
    result << info(event)
    result << content_tag(:div, event.latitude, id: :lat, class: :hidden)
    result << content_tag(:div, event.longitude, id: :lng, class: :hidden)
    result << tag(:div, id: :map)
    result
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
    # TODO: Switch this to the HTML 5 outline model.
    return nil if (event.nil? or !event.kind_of?(Event))
    result = ''.html_safe
    result << content_tag(:h3, (event.site || event.name))
    city = [event.city, event.state.code, event.state.country.code].compact.join(', ')
    result << content_tag(:p, [h(event.street), h(event.street2), h(city)].compact.join(tag :br).html_safe)

    gmaps = 'http://maps.google.com'
    from = "saddr=#{u User.current_user.address.to_s(:geo)}"
    to = "daddr=#{u event.address.to_s(:geo)}"
    params = [from, to].compact.join('&')
    result << content_tag(:p, link_to(_('Get directions'), h("#{gmaps}?#{params}")))
    content_tag(:div, result, :id => :info)
  end

  # Given an #Array (or similar) of #User objects, returns an #Array of their full names as #Strings.
  def list_names(users)
    return '' if users.nil? or users.size == 0
    users.compact.join(', ')
  end

  # Generates a link to a map of #Event.
  def map_link(event)
    link_to h(_("map")), url_for(:controller => 'events', :action => 'map', :id => event.id), :class => 'map', :target => 'map'
  end

  # Generates a hint to use Markdown for formatting.
  # TODO: make this work as html_safe properly.
  def markdown_hint
    content_tag(:span, (h(_ '(use %{Markdown} for formatting)').to_str % {:Markdown => link_to(_('Markdown'), 'http://daringfireball.net/projects/markdown/basics', :target => 'markdown')}).html_safe, :class => :hint)
  end

  # Generates an RSS URL for the current user's events feed.
  def rss_url
    if User.current_user
      feed_events_url(:format => :rss, :key => User.current_user.single_access_token)
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
    link_to h(_(title)), url_for(params.merge :order => field, :direction => direction), :class => my_class
  end

  def status_strings
    @status_strings ||= {yes: _('attending'), no: _('not attending'), maybe: _('uncommitted')}
  end

  private

  def google_maps_header(hostname)
    api_key = GMAPS_API_KEY.kind_of?(Array) ? GMAPS_API_KEY[hostname] : GMAPS_API_KEY
    javascript_include_tag "http://maps.google.com/maps?file=api&v=2&sensor=false&key=#{api_key}"
  end
end
