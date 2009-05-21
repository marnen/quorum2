Feature: Create calendars
  In order to organize events appropriately
  any registered user should be able to
  create new calendars at any time.

  Scenario: Non-admin users can create new calendars and will have admin rights to them.
    Given I am logged in
    And I am subscribed to "Old calendar"
    And I am on the homepage
    When I follow "Create calendar"
    And I fill in "calendar[name]" with "New calendar"
    And I press "Save"
    Then I should have a calendar called "New calendar"
    And I should be an admin of "New calendar"
