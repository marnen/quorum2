Feature: Manage subscriptions
  In order to control what content ey sees
  any registered user should be able to
  subscribe to and unsubscribe from any calendar of which ey is not an admin.

  Scenario Outline: Anyone can subscribe to a calendar
    Given I am logged in
    And someone else has a calendar called "<calendar>"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should see "<calendar>"
    And I should see the word "subscribe"
    When I follow "subscribe"
    Then I should be subscribed to "<calendar>"

    Examples:
      | calendar                |
      | Someone else's calendar |

  Scenario: Don't show the list of unsubscribed calendars if it's empty
    Given I am logged in
    And no calendars exist
    # TODO: why do we need that?
    And I am on the subscriptions page
    Then I should not see "subscribe to these calendars"

  Scenario Outline: Non-admin users can unsubscribe from their calendars
    Given I am logged in
    And I am subscribed to "<calendar>"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should see "<calendar>"
    And I should see the word "unsubscribe"
    When I follow "unsubscribe"
    Then I should not be subscribed to "<calendar>"

    Examples:
      | calendar    |
      | My calendar |

  Scenario: Admin users cannot unsubscribe from calendars they control
    Given I am logged in
    And I am an admin of "My calendar"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should not see the word "unsubscribe"

  Scenario: Admin users can unsubscribe from calendars they do not control
    Given I am logged in
    And I am an admin of "My calendar"
    And I am subscribed to "Someone else's calendar"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should see the following in order:
      | unsubscribe             |
      | Someone else's calendar |

  Scenario Outline: I should see the role for each subscribed calendar
    Given I am logged in
    And I am an admin of "<mine>"
    And I am subscribed to "<other>"
    And I am on the subscriptions page
    Then I should see the following in order:
      | <mine> |
      | admin  |
    And I should see the following in order:
      | <other> |
      | user    |

    Examples:
      | mine        | other                   |
      | My calendar | Someone Else's Calendar |
