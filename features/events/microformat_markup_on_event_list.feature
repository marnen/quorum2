Feature: Microformat markup on event list
  As a registered user
  I should see hCalendar microformat markup on the event list
  So I can use a microformat parser to extract calendar information


  Scenario Outline:
    Given I am logged in
    And I am subscribed to "My Calendar"
    And an event exists with calendar: the calendar, site: "<site>"
    When I go to the event list
    Then I should see "<site>"
    And I should see hCalendar markup for the event

    Examples:
      | site     |
      | My Place |
