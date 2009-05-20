Feature: Create events
  In order to share events with other users
  any registered user should be able to
  create events on any subscribed calendar.
  
  Scenario: Create events on subscribed calendar when there's only one subscription
    Given I am logged in
    And I am on the homepage
    And I am subscribed to "Calendar 1"
    When I follow "Add event"
    And I fill in "Event name" with "My event"
    And I press "Save changes"
    Then I should have an event called "My event" in "Calendar 1"