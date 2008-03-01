module EventHelper

  def ical_uid(event)
    "event-" << event.id.to_s << "@" << DOMAIN
  end

end
