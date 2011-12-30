Feature: Update commitment status
  In order to share commitment status with other users
  any registered user should be able to
  change his commitment status to any event on any subscribed calendar.
  
  Scenario: Start out as uncommitted
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And someone else has an event called "Event" in "Calendar 1"
    And I am on the event list
    Then I should see "You are currently uncommitted."
    
  Scenario Outline: Change commitment status
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And someone else has an event called "Event" in "Calendar 1"
    And I am on the event list
    When I select "<status>" from "status"
    And I press "Change status"
    Then I should see "You are currently <status>."
    
    Examples:
      | status        |
      | attending     |
      | not attending |