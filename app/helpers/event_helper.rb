module EventHelper
  def attendance_control(event, user)
    # generate a <td> with attendance controls
    if event.find_committed(:yes).include? user then
      status = :yes
    elsif event.find_committed(:no).include? user then
      status = :no
    else
      status = :maybe
    end
    # refactor into a partial?
    status_strings = { :yes => _('attending'), :no => _('not attending'), :maybe => _('uncommitted') }
    content = ''
    content << content_tag(:p, _("You are currently %s." % content_tag(:span, h(status_strings[status]), :class => status)))
    content << select_tag(nil, options_for_select(status_strings.invert, status), :class => :commit)
    content << tag(:br)
    content << submit_tag(h(_("Change status")))
    content = content_tag :form, content, :action => url_for(:controller => :event, :action => :change_status, :id => event.id), :name => 'e' << event.id.to_s
    content_tag :td, content, :class => status
  end
  
  def date_element(event)
    # generate a microformat HTML date element
    ical_date = h event.date.to_formatted_s(:ical)
    full_date = h event.date.to_formatted_s(:rfc822)
    content_tag :abbr, full_date, :class => :dtstart, :title => ical_date
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
  
  def list_names(users)
    # users is an Array (or similar) of users
    users.collect {|u| u.fullname}.join(', ')
  end

  def map_link(event)
    # generate a map link
    link_to h(_("map")), url_for(:controller => 'event', :action => 'map', :id => event.id), :target => 'map'
  end

end
