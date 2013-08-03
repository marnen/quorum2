module FetchHelpers
  def fetch_calendar(name)
    fields = {name: name}
    args = [:calendar, fields]
    find_model(*args) || create_model(*args)
  end

  def fetch_event(options)
    calendar = options.delete :calendar
    calendar.events.find_by_name(options[:name]) || Factory(:event, calendar: calendar)
  end
end

World FetchHelpers
