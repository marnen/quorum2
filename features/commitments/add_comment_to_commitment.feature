Feature: Add comment to commitment
  As a user
  I can add comments to events
  So I can qualify my commitment status

  Background:
    Given someone else has an event called "Event" in "Calendar 1"

  Scenario Outline: Add comment to commitment
    Given a user named "<name>" exists with email "<email>"
    And I am logged in as "<email>"
    And I am subscribed to "Calendar 1"
    When I go to the event list
    And I fill in "comment" with "<comment>"
    And I press "Change status"
    Then I should see "<name>: <comment>"

    Examples:
      | email          | name       | comment                  |
      | john@smith.com | John Smith | This is my comment text. |

  Scenario Outline: View other users' comments
    Given someone else has a comment for "Event" in "Calendar 1" with text "<comment>"
    And I am logged in
    And I am subscribed to "Calendar 1"
    When I go to the event list
    Then I should see "<comment>"

    Examples:
      | comment                         |
      | This is someone else's comment. |
