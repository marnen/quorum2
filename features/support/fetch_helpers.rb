module FetchHelpers
  def fetch_calendar(name)
    Calendar.find_by_name(name) || Factory(:calendar, :name => name)
  end

  def fetch_event(options)
    calendar = options.delete :calendar
    calendar.events.find_by_name(options[:name]) || Factory(:event, calendar: calendar)
  end
end

World FetchHelpers
