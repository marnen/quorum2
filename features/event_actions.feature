Feature: Map and iCal links
  In order to get directions to events and export them to external calendars
  any registered user should be able to
  see map and iCal links for any event on any subscribed calendar.

  Scenario Outline: Nonadmin users can see action links on all events
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And someone else has an event called "Someone else's event" in "Calendar 1"
    When I am on the event list
    Then I should see the word "<action>"
    
    Examples:
    | action |
    | map    |
    | iCal   |