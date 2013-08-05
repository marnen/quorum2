Feature: Sort events
  As a registered user
  I can sort the event list
  So I can view events in whichever order is most convenient for me

  Background:
    Given I am logged in
    And I am subscribed to "My Calendar"
    And the following events exist:
      | calendar     | name     | date       |
      | the calendar | October  | 2100-10-01 |
      | the calendar | June     | 2100-06-01 |
      | the calendar | December | 2100-12-01 |
    And I am on the events page

  Scenario: Reverse chronological order
    When I follow "Date"
    Then I should see the following in order:
      | December |
      | October  |
      | June     |

  Scenario: Alphabetical order by name
    When I follow "Event"
    Then I should see the following in order:
      | December |
      | June     |
      | October  |

  Scenario: Reverse alphabetical order by name
    When I follow "Event"
    And I follow "Event"
    Then I should see the following in order:
      | October  |
      | June     |
      | December |
