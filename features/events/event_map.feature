Feature: Event map
  As a registered user
  I can see a map of any event on calendars I subscribe to
  So I can figure out how to get there

  Background:
    Given I am logged in
    And I am subscribed to "My Calendar"
    And an event exists with calendar: the calendar

  Scenario: Link from event list
    Given I am on the event list
    And I follow "map"
    Then I should be on the event's map page

  Scenario: Map page
    When I go to the event's map page
    Then I should see a map of the event
    And I should see "Get directions" within a link to somewhere at "http://maps.google.com"