Feature: Reset password
  As a registered user
  I can reset my password
  So I can regain access to the system if I forget my password

  Scenario: Link from homepage
    Given I am not logged in
    And I am on the homepage
    When I follow "Forgot your password?"
    Then I should be on the password reset page

  Scenario Outline: Reset password on valid e-mail address
    Given a user exists with email: "<email>"
    And I am on the password reset page
    When I fill in "email" with "<email>"
    And I press "Reset password"
    Then "<email>" should receive an e-mail message
    And the e-mail message should contain "your new password is:"

    Examples:
      | email           |
      | bob@example.com |

  Scenario Outline: Don't reset password on invalid e-mail address
    Given a user exists with email: "<email>"
    And I am on the password reset page
    When I fill in "email" with "<bogus>"
    And I press "Reset password"
    Then "<email>" should not receive an e-mail message
    And "<bogus>" should not receive an e-mail message

    Examples:
      | email           | bogus       |
      | bob@example.com | jim@aol.com |
