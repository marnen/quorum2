Feature: List events
  As a registered user
  I can see events on calendars I subscribe to
  So I can keep track of what's going on
  
  Scenario: Unregistered users can't get to event list
    Given I am not logged in
    When I go to the events page
    Then I should be on the login page
    
  Scenario Outline: It should sort events by date
    Given I am logged in
    And a calendar exists with name: "<calendar>"
    And I am subscribed to "<calendar>"
    And the following events exist:
      | calendar     | name     | date       |
      | the calendar | November | 2100-11-01 |
      | the calendar | October  | 2100-10-01 |
      | the calendar | December | 2100-12-01 |
    When I go to the events page
    Then I should see the following in order:
      | October  |
      | November |
      | December |
      
    Examples:
      | calendar            |
      | My Amazing Calendar |