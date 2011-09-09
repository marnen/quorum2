Then /^I should see the word "([^\"]*)"$/ do |word|
  Then %Q{I should see /\\b#{word}\\b/}
end

Then /^I should not see the word "([^\"]*)"$/ do |word|
  Then %Q{I should not see /\\b#{word}\\b/}
end

Then /^I should see an element matching "([^\"]*)"$/ do |selector|
  page.should have_selector(selector) or response.should have_xpath(selector)
end

Then /^I should not see an element matching "([^\"]*)"$/ do |selector|
  page.should_not have_selector(selector) and response.should_not have_xpath(selector)
end
