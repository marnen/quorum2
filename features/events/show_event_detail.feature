Feature: Show event detail
  As a registered user
  I can view detail about an event on a calendar I have access to
  So I can get more information about events than the list view shows

  Background:
    Given I am logged in

  Scenario: Show detail for event on my calendar
    Given I am subscribed to "Calendar 1"
    And I have an event called "My event" in "Calendar 1"
    When I go to the event's page
    Then I should see "My event"

  Scenario: Don't show detail if I don't have access
    Given I am not subscribed to "Calendar 1"
    And an event exists with name: "My event", calendar: the calendar
    Then I should not be able to go to the event's page