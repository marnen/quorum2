Then /^"([^"]*)" should (not )?receive an e-?mail message$/ do |recipient, negation|
  open_email recipient
  current_email.present?.should == !negation
end

Then /^the e-?mail message should contain "([^"]*)"$/ do |text|
  current_email.body.should include text
end