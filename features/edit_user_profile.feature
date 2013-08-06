Feature: Edit user profile
  As a registered user
  I can edit my user profile
  So that I can keep my user information current

  Background:
    Given a user named "John Smith" exists with email "jsmith@aol.com"
    And I am logged in as "jsmith@aol.com"
    And I am on the user profile page

  Scenario: Edit profile information
    When I fill in the following:
      | First name | Иван     |
      | Last name  | Кузнецов |
    And I save
    Then I should not see "John Smith"
    But I should see "Иван Кузнецов"

  Scenario: Don't validate password if both fields are blank
    When I fill in the following:
      | First name     | Jack |
      | Password       |      |
      | Password again |      |
    And I save
    Then I should see "Jack Smith"

  Scenario Outline: Validate password if at least one field is not blank
    When I fill in the following:
      | First name     | Jack           |
      | Password       | <password>     |
      | Password again | <confirmation> |
    And I save
    Then I should see "Password" within the form errors

    Examples:
      | password | confirmation |
      | passw0rd |              |
      |          | passw0rd     |
      | passw0rd | s3kr1t       |
      | a        | a            |

  Scenario: Save password if both fields are identical and acceptable
    When I fill in the following:
      | Password       | passw0rd |
      | Password again | passw0rd |
    And I save
    Then the form errors should be blank
