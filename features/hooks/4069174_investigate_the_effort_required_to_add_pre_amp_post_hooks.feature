# rake features FEATURE=features/hooks/4069174_investigate_the_effort_required_to_add_pre_amp_post_hooks.feature
@hooks @needs_service
Feature: Adding pre-and-post hooks
  Background:
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4069174 exists
    And the name of story 4069174 is "Investigate the effort required to add pre & post hooks"

    Given I have "debug" callbacks enabled

  Scenario: Hooked into start
    When I successfully execute "git start 4069174"

    Then the stdout should contain "start"
    And the stderr should contain "start_story_on_pivotal_tracker!"

  Scenario: Hooked into finish
    Given the local branch "4069174_investigate_the_effort_required_to_add_pre_amp_post_hooks" exists

    When I successfully execute "git finish 4069174"

    Then the stdout should contain "finish"
    And the stderr should contain "finish_story_on_pivotal_tracker!"
