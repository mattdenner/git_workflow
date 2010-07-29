# rake features FEATURE=features/hooks/4199845_need_hooks_for_sanger_workflow.feature
@hooks @needs_service @needs_remote_repository @sanger_workflow
Feature: Need hooks for WTSI workflow
  Background:
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"
    And I have "sanger" callbacks enabled

    Given the story 4199845 exists
    And the name of story 4199845 is "Need hooks for WTSI workflow"

    Given the local branch "4199845_need_hooks_for_wtsi_workflow" exists

  Scenario: Fails to push local branch if tests fail
    Given the local branch "4199845_need_hooks_for_wtsi_workflow" is active
    And the rake task "test" will fail
    And the rake task "features" will fail

    When I execute "git finish"

    Then the stderr should contain "The tests failed, please fix and try again"
    And the branch "4199845_need_hooks_for_wtsi_workflow" should be active
    And the branch "4199845_need_hooks_for_wtsi_workflow" should not be merged into master

  Scenario: Leaves the branch being merged as active
    Given the local branch "4199845_need_hooks_for_wtsi_workflow" is active
    And the rake task "test" will fail
    And the rake task "features" will fail
    And the local branch "master" is active

    When I execute "git finish 4199845"

    Then the stderr should contain "The tests failed, please fix and try again"
    And the branch "4199845_need_hooks_for_wtsi_workflow" should be active
    And the branch "4199845_need_hooks_for_wtsi_workflow" should not be merged into master

  Scenario: Completely successful pushes branch to remote repository
    Given my remote branch naming convention is "${story.story_id}_${story.name}"

    Given the local branch "4199845_need_hooks_for_wtsi_workflow" is active
    And the rake task "test" will succeed
    And the rake task "features" will succeed

    When I successfully execute "git finish"

    Then the stderr should not contain "The tests failed, please fix and try again"
    And the stderr should not contain "Unable to push branch '4199845_need_hooks_for_wtsi_workflow'"
    And the branch "4199845_need_hooks_for_wtsi_workflow" should not be merged into master
    And the local and remote "4199845_need_hooks_for_wtsi_workflow" branches should agree

    Then story 4199845 should be finished
    And story 4199845 should have a comment of "Fixed on 4199845_need_hooks_for_wtsi_workflow. Needs merging into master"

  Scenario: Pushes remote name properly
    Given my remote branch naming convention is "${story.name}_${story.story_id}"

    Given the local branch "4199845_need_hooks_for_wtsi_workflow" is active
    And the rake task "test" will succeed
    And the rake task "features" will succeed

    When I successfully execute "git finish"

    Then the stderr should not contain "The tests failed, please fix and try again"
    And the stderr should not contain "Unable to push branch '4199845_need_hooks_for_wtsi_workflow'"
    And the branch "4199845_need_hooks_for_wtsi_workflow" should not be merged into master
    And story 4199845 should be finished
    And the local branch "4199845_need_hooks_for_wtsi_workflow" and remote branch "need_hooks_for_wtsi_workflow_4199845" should agree
