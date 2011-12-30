Feature: Event map
  As a registered user
  I can see a map of any event on calendars I subscribe to
  So I can figure out how to get there
  
  Scenario:
    Given I am logged in
    And an event exists
    When I go to the event's map page
    Then I should see a map of the event
    And I should see "Get directions" within a link to somewhere at "http://maps.google.com"