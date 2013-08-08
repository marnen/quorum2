Then /^I should see hCalendar markup for #{capture_model}$/ do |event|
  event = model! event
  within "#event_#{event.id}" do
    {
      '.summary' => event.name,
      '.street-address' => %r{#{Regexp.escape event.street}.*#{Regexp.escape event.street2}}m,
      '.locality' => event.city,
      '.region' => event.state.code,
      '.country-name' => event.country.code,
      '.postal-code' => event.zip,
      "abbr.dtstart[title='#{event.date.to_s(:ical)}']" => event.date.to_s(:rfc822)
    }.each do |css, text|
      page.should have_selector css, text: text
    end
  end
end
