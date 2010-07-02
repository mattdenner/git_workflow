# rake features FEATURE=features/extensions/4058326_display_story_description_on_start.feature
@extension @needs_service
Feature: Display the story description on start

  Scenario: Displaying the description
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"

    Given the story 4058326 exists
    And the name of story 4058326 is "Display the story description"
    And the description of story 4058326 is "Please can we display the description of a story?"

    When I successfully execute "git start 4058326"

    Then the stdout should contain "Story 4058326: Display the story description"
    And the stdout should contain "Please can we display the description of a story?"
