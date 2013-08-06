module FetchHelpers
  def fetch_calendar(name)
    fields = {name: name}
    args = [:calendar, fields]
    find_model(*args) || create_model(*args)
  end

  def fetch_event(options)
    calendar = options.delete :calendar
    calendar.events.find_by_name(options[:name]) || FactoryGirl.create(:event, calendar: calendar)
  end

  def user_by_name(full_name, other_fields = {})
    first, last = full_name.split /\s+/, 2
    basic_fields = {firstname: first, lastname: last}
    args = :user, basic_fields
    user = find_model(*args) || create_model(*args)
    user.tap {|user| user.update_attributes other_fields }
  end
end

World FetchHelpers
