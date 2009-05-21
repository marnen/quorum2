Feature: Edit events
  In order to remove unneeded content
  any administrator should be able to
  delete events already created.

  Scenario: Non-admin subscribers cannot delete their own events
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And I have an event called "My event" in "Calendar 1"
    When I am on the event list
    Then I should not see something matching "\bdelete\b"

  Scenario: Admin subscribers can delete their own events
    Given I am logged in
    And I am an admin of "Calendar 1"
    And I have an event called "My event" in "Calendar 1"
    When I am on the event list
    Then I should see something matching "\bdelete\b"

  Scenario: Admin subscribers can delete others' events
    Given I am logged in
    And I am an admin of "Calendar 1"
    And someone else has an event called "Someone else's event" in "Calendar 1"
    When I am on the event list
    Then I should see something matching "\bdelete\b"
