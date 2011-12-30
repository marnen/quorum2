Feature: Register as new user
  In order to gain access to the Quorum system
  anyone should be able to
  create an account if not already logged in.
  
  Scenario Outline: Create an account when not logged in
    Given I am not logged in
    And there is no user account for "<email>"
    And I am on the login page
    When I follow "register"
    And I fill in the following:
      | E-mail address | <email>    |
      | Password       | <password> |
      | Password again | <password> |
    And I press "Sign up"
    Then I should have a user account for "<email>"
    
    Examples:
      | email               | password |
      | quentin@example.com | passw0rd |

  Scenario Outline: Do not create account if e-mail or password is missing, or if password confirmation is incorrect
    Given I am not logged in
    And there is no user account for "<email>"
    And I am on the register page
    When I fill in the following:
      | E-mail address | <email>     |
      | Password       | <password>  |
      | Password again | <password2> |
    And I press "Sign up"
    Then I should not have a user account for "<email>"

    Examples:
      | email               | password | password2 |
      |                     | passw0rd | passw0rd  |
      | quentin@example.com |          |           |
      | quentin@example.com |          | passw0rd  |
      | quentin@example.com | passw0rd |           |
      | quentin@example.com | passw0rd | dr0wssap  |
