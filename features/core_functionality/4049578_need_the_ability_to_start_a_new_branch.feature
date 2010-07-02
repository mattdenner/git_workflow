# rake features FEATURE=features/core_functionality/4049578_need_the_ability_to_start_a_branch.feature
@core_functionality @needs_service
Feature: Need the ability to start a new branch

  Scenario: Starting a new branch
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"

    Given the story 4049578 exists
    And the name of story 4049578 is "Need the ability to start a new branch"

    When I successfully execute "git start 4049578"

    Then the branch "4049578_need_the_ability_to_start_a_new_branch" should be active
    And the owner of story 4049578 should be "Matthew Denner"
    And story 4049578 should be started
