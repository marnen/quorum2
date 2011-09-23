Feature: Search events
  In order to quickly get to the events I want
  any registered user should be able to
  search events.
  
  Scenario: Search form is displayed
    Given I am logged in
    And I am on the event list
    Then I should see an element matching "input[@type=submit][@value=Search]"
  
