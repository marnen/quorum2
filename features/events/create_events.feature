Feature: Create events
  In order to share events with other users
  any registered user should be able to
  create events on any subscribed calendar.

  Scenario: Can't create event if not logged in
    Given I am not logged in
    When I go to the new event page
    Then I should be on the login page

  Scenario: Create events on subscribed calendar when there's only one subscription
    Given I am logged in
    And there are no events
    And I am on the homepage
    And I am subscribed to "Calendar 1"
    When I follow "Add event"
    And I fill in "event[name]" with "My event"
    And I press "Save changes"
    Then I should have an event called "My event" in "Calendar 1"

  Scenario: Create events on subscribed calendar when there are multiple subscriptions
    Given I am logged in
    And there are no events
    And I am on the homepage
    And I am subscribed to "Calendar 1"
    And I am subscribed to "Calendar 2"
    When I follow "Add event"
    And I select "Calendar 2" from "event[calendar_id]"
    And I fill in "event[name]" with "My event"
    And I press "Save changes"
    Then I should have an event called "My event" in "Calendar 2"