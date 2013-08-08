Feature: List events
  As a registered user
  I can see events on calendars I subscribe to
  So I can keep track of what's going on

  Scenario: Unregistered users can't get to event list
    Given I am not logged in
    When I go to the events page
    Then I should be on the login page

  Scenario Outline: Sort events by date as default
    Given I am logged in
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

  Scenario Outline: Don't show deleted events
    Given I am logged in
    And I am subscribed to "<calendar>"
    And a deleted event exists with name: "<deleted>", calendar: the calendar
    When I go to the events page
    Then I should not see "<deleted>"

    Examples:
      | calendar      | deleted        |
      | Deletion test | I'm invisible! |

  Scenario Outline: Linkify URLs in event descriptions
    Given I am logged in
    And I am subscribed to "My Calendar"
    And the following events exist:
      | calendar     | description                  |
      | the calendar | I have a link to <url> here. |
    When I go to the events page
    Then I should see a link to "<url>"

    Examples:
     | url                    |
     | http://www.example.com |

  Scenario Outline: Process event descriptions with Markdown
    Given I am logged in
    And I am subscribed to "My Calendar"
    And the following events exist:
      | calendar     | description |
      | the calendar | <markdown>  |
    When I go to the events page
    Then I should see "<markdown>" as Markdown

    Examples:
     | markdown                                  |
     | Here is some really __nifty__ *Markdown*. |

  Scenario: Show calendar names if there are multiple calendars
    Given I am logged in
    And I am subscribed to "Calendar 1"
    And I am subscribed to "Calendar 2"
    And I have an event called "Event one" in "Calendar 1"
    And I have an event called "Event two" in "Calendar 2"
    When I go to the events page
    Then I should see an event with the following text:
      | Calendar 1 |
      | Event one  |
    And I should see an event with the following text:
      | Calendar 2 |
      | Event two  |