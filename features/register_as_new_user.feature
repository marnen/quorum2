Feature: Register as new user
  In order to gain access to the Quorum system
  anyone should be able to
  create an account if not already logged in.
  
  Scenario: Create an account when not logged in
    Given I am not logged in
    And there is no user account for "quentin@example.com"
    And I am on the login page
    When I follow "register"
    And I fill in "user[email]" with "quentin@example.com"
    And I fill in "user[password]" with "passw0rd"
    And I fill in "user[password_confirmation]" with "passw0rd"
    And I press "Sign up"
    Then I should have a user account for "quentin@example.com"
