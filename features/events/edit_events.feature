Feature: Edit events
  In order to keep content current
  any administrator OR the author of an event should be able to
  edit events already created.
  
  Scenario: Non-admin subscribers can edit their own events
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And I have an event called "My event" in "Calendar 1"
    When I am on the event list
    Then I should see something matching "\bedit\b"
    
  Scenario: Non-admin subscribers cannot edit others' events
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And someone else has an event called "Someone else's event" in "Calendar 1"
    When I am on the event list
    Then I should not see something matching "\bedit\b"
    
  Scenario: Admin subscribers can edit others' events
    Given I am logged in
    And I am an admin of "Calendar 1"
    And someone else has an event called "Someone else's event" in "Calendar 1"
    When I am on the event list
    Then I should see something matching "\bedit\b"
