# rake features FEATURE=features/extensions/4069174_investigate_the_effort_required_to_add_pre_amp_post_hooks.feature
@extensions @needs_service
Feature: Adding pre-and-post hooks
  Background:
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"

    Given the story 4069174 exists
    And the name of story 4069174 is "Investigate the effort required to add pre & post hooks"

    Given I have "debug" callbacks enabled

  Scenario: Hooked into start
    When I successfully execute "git start 4069174"

    Then the stdout should contain "create_branch_for_story!"
    And the stdout should contain "start_story_on_pivotal_tracker!"

  Scenario: Hooked into finish
    Given the local branch "4069174_investigate_the_effort_required_to_add_pre_amp_post_hooks" exists
    And the default rake task will succeed

    When I successfully execute "git finish 4069174"

    Then the stdout should contain "merge_story_into!"
    And the stdout should contain "finish_story_on_pivotal_tracker!"
