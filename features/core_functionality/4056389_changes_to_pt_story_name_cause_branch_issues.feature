# rake features FEATURE=features/core_functionality/4056389_changes_to_pt_story_name_cause_branch_issues.feature
@core_functionality @needs_service
Feature: Changing the name of a story
  Background:
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"

    Given the story 4056389 exists
    And the name of story 4056389 is "PT story name changes screws with branches"

    Given the local branch "4056389_changes_to_pt_story_name_cause_branch_issues" exists

  Scenario: Name changed after the story has started
    When I successfully execute "git finish 4056389"

    Then the branch "4056389_changes_to_pt_story_name_cause_branch_issues" should be merged into master
    And the owner of story 4056389 should be "Matthew Denner"
    And story 4056389 should be finished

  Scenario: Name changed and trying to start it
    When I successfully execute "git start 4056389"

    Then the branch "4056389_changes_to_pt_story_name_cause_branch_issues" should be active
    And the owner of story 4056389 should be "Matthew Denner"
    And story 4056389 should be started

