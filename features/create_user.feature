Feature: Create user
  As an unregistered user
  I can register an account
  So that I can get access to the system

  Scenario:
    Given no users exist
    And I am not logged in
    And a state exists with name: "Somewhere", code: "SW"
    When I go to the registration page
    And I fill in the following:
      | E-mail address | john@jones.org   |
      | First name     | John             |
      | Last name      | Jones            |
      | Password       | passw0rd         |
      | Password again | passw0rd         |
      | Street address | 123 Maple Street |
      | Address line 2 | Apt. 1           |
      | City           | Middletown       |
      | ZIP code       | 13579            |
    And I check "Make my address visible in the contact list"
    And I select "Somewhere" from "State"
    And I press "Sign up"
    Then 1 user should exist