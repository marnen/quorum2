Feature: Manage subscriptions
  In order to control what content ey sees
  any registered user should be able to
  subscribe to and unsubscribe from any calendar of which ey is not an admin.
  
  Scenario: Anyone can subscribe to a calendar
    Given I am logged in
    And someone else has a calendar called "Someone else's calendar"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should see the word "subscribe"
    
  Scenario: Non-admin users can unsubscribe from their calendars
    Given I am logged in
    And I am subscribed to "My calendar"
    And I am on the homepage
    When I follow "Subscriptions"
    Then I should see the word "unsubscribe"

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
    Then I should see /\bunsubscribe\W+Someone else's calendar/
    