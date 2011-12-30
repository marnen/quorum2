# coding: UTF-8

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

Then /^I should see the following in order:$/ do |table|
  # table is a Cucumber::Ast::Table
  regexp = %r{#{table.raw.flatten.collect {|x| Regexp.escape x }.join '.*'}}m
  
  page.should have_xpath('//*', :text => regexp)
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  current_path.should_not == path_to(page_name)
end
