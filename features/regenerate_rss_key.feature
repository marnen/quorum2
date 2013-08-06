Feature: Regenerate RSS key
  As a registered user
  I can regenerate my RSS key
  So that I can disable previously granted access to my feed

  Scenario Outline:
    Given a user exists with email: "<email>", single access token: "<token>"
    And I am logged in as "<email>"
    And I am on the homepage
    Then I should see "feed.rss/<token>"
    When I follow "regenerate"
    Then I should be on the homepage
    And I should not see "feed.rss/<token>"

    Examples:
      | email           | token        |
      | example@aol.com | s3kr1t_t0k3n |
