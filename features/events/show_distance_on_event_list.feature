Feature: Show distance on event list
  As a registered user
  I can see event distance from my registered home address
  So that I can figure out if an event is close enough for me to get to

  Scenario Outline:
    Given a country exists with code: "<country>"
    And a state exists with code: "<state>", country: the country
    And the address "<user_street>, <user_city>, <state>, <user_zip>, <country>" has latitude: 1.0, longitude, 10.0
    And the address "<event_street>, <event_city>, <state>, <event_zip>, <country>" has latitude: 2.0, longitude, 10.0
    And the following users exist:
      | firstname | lastname | email          | street        | city        | state     | zip        |
      | John      | Jones    | john@jones.com | <user_street> | <user_city> | the state | <user_zip> |
    # TODO: rewrite this step so it can take an e-mail address, or rewrite the login step so it can take a name
    And "John Jones" is subscribed to "John's Calendar"
    And the following events exist:
      | name         | street         | city         | state     | zip         | calendar     |
      | <event_name> | <event_street> | <event_city> | the state | <event_zip> | the calendar |
    And I am logged in as "john@jones.com"
    When I go to the event list
    Then I should see "69.2 miles"

    Examples:
      | country | state | user_street  | user_city | user_zip | event_name | event_street   | event_city | event_zip |
      | US      | ST    | 123 Main St. | Anytown   | 12345    | My Event   | 456 Maple Ave. | Someplace  | 45678     |
