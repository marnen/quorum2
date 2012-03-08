Feature: Add comment to commitment
  As a user
  I can add comments to events
  So I can qualify my commitment status

  Scenario Outline: Add comment to commitment
    Given a user named "<name>" exists with email "<email>"
    And I am logged in as "<email>"
    And I am subscribed to "Calendar 1"
    And someone else has an event called "Event" in "Calendar 1"
    And I am on the event list
    When I fill in "comment" with "<comment>"
    And I press "Change status"
    Then I should see "<name>: <comment>"

    Examples:
      | email          | name       | comment                  |
      | john@smith.com | John Smith | This is my comment text. |
