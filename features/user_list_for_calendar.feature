Feature: User list for calendar
  As a calendar administrator
  I can see a list of users subscribed to my calendar
  So that I can find out who can see my events

  Scenario: Admin users should be able to see user lists for calendars they control
    Given I am logged in
    And I am an admin of "My calendar"
    And "John Smith" is subscribed to "My calendar"
    And I am on the admin page
    When I follow "users"
    Then I should be on the user list for "My calendar"
    And I should see "Smith, John"