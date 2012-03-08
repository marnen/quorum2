module FetchHelpers
  def fetch_calendar(name)
    Calendar.find_by_name(calendar) || Factory(:calendar, :name => calendar)
  end
end

World FetchHelpers
