Feature: Administer calendars
  In order to keep calendars properly organized
  any administrator should be able to
  administer the calendars ey controls.

  Scenario: Non-admin users should not see "Admin tools" link
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And I am on the homepage
    Then I should not see "Admin tools"

  Scenario Outline: Non-admin users should not be able to get to calendar admin pages
    Given I am logged in
    And I am subscribed to "<calendar>"
    When I go to the <page> for "<calendar>"
    Then I should not be on the <page> for "<calendar>"

    Examples:
      | calendar   | page               |
      | Calendar 1 | user list          |
      | Calendar 2 | calendar edit page |

  Scenario: Admin users should see "Admin tools" link
    Given I am logged in
    And I am an admin of "Calendar 1"
    And I am on the homepage
    Then I should see "Admin tools"

  Scenario: Admin users should only be able to administer calendars they control
    Given I am logged in
    And I am an admin of "My calendar"
    And I am subscribed to "Someone else's calendar"
    And I am on the homepage
    When I follow "Admin tools"
    Then I should be on the admin page
    And I should see "My calendar"
    And I should not see "Someone else's calendar"

  Scenario: Admin users should be able to change the name of calendars they control
    Given I am logged in
    And I am an admin of "My calendar"
    And I am on the admin page
    When I follow "properties"
    And I fill in "Name" with "New name"
    And I press "Save"
    Then I should be on the admin page
    And I should not see /My calendar\s*\(properties \| users\)/
    And I should see /New name\s*\(properties \| users\)/

  Scenario: Admin users should be able to see user lists for calendars they control
    Given I am logged in
    And I am an admin of "My calendar"
    And "John Smith" is subscribed to "My calendar"
    And I am on the admin page
    When I follow "users"
    Then I should be on the user list for "My calendar"
    And I should see "Smith, John"