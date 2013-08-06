Feature: User list for calendar
  As a calendar administrator
  I can see a list of users subscribed to my calendar
  So that I can find out who can see my events

  Background:
    Given I am logged in
    And I am an admin of "My calendar"
    And "John Smith" is subscribed to "My calendar"

  Scenario: Admin users should be able to see user lists for calendars they control
    Given I am on the admin page
    When I follow "users"
    Then I should be on the user list for "My calendar"
    And I should see "Smith, John"

  Scenario Outline: Show address for users unless they've decided to hide it
    Given user "John Smith" has the following address:
      | street  | <street>  |
      | street2 | <street2> |
      | city    | <city>    |
      | state   | <state>   |
      | zip     | <zip>     |
    And user "John Smith" <does_or_not> hide his address
    When I go to the user list for "My calendar"
    Then I <should_or_not> see "<street>"
    And I <should_or_not> see "<street2>"
    And I <should_or_not> see "<city>"
    And I <should_or_not> see "<state>"
    And I <should_or_not> see "<zip>"

    Examples:
      | street          | street2 | city      | state | zip   | does_or_not | should_or_not |
      | 123 Main Street | Apt. 1  | Anytown   | NY    | 12345 | does not    | should        |
      | 456 2nd Avenue  | #8C     | Someville | CA    | 90123 | does        | should not    |

  Scenario: Show role of users
    Given "Mary Wilson" is an admin of "My calendar"
    When I go to the user list for "My calendar"
    Then I should see "user" within user "Smith, John"
    Then I should see "admin" within user "Wilson, Mary"