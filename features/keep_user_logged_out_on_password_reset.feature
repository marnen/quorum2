Feature: Keep user logged out on password reset
  As the system
  I should not log in users who request a password reset
  So that I can make sure that no one gets in without positive authentication

  Scenario Outline:
    Given a user named "<name>" exists with email "<email>"
    And I am not logged in
    And I am on the password reset page
    When I fill in "email" with "<email>"
    And I press "Reset password"
    Then I should not be logged in
    And I should not see "<name>"

    Examples:
      | name       | email          |
      | John Smith | jsmith@aol.com |
