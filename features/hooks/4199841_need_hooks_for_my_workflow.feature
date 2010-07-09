# rake features FEATURE=features/hooks/4199841_need_hooks_for_my_workflow.feature
@hooks @needs_service @needs_remote_repository @my_workflow
Feature: Need hooks for my workflow
  Background:
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"
    And I have "mine" callbacks enabled

    Given the story 4199841 exists
    And the name of story 4199841 is "Need the ability to start a new branch"

    Given the local branch "4199841_need_hooks_for_my_workflow" exists

  Scenario: Fails to merge when tests fail before merge
    Given the local branch "4199841_need_hooks_for_my_workflow" is active
    And the rake task "spec" will fail
    And the rake task "features" will fail

    When I execute "git finish"

    Then the stderr should contain "The tests failed, please fix and try again"
    And the branch "4199841_need_hooks_for_my_workflow" should be active
    And the branch "4199841_need_hooks_for_my_workflow" should not be merged into master

  Scenario: Leaves the branch being merged as active
    Given the local branch "4199841_need_hooks_for_my_workflow" is active
    And the rake task "spec" will fail
    And the rake task "features" will fail
    And the local branch "master" is active

    When I execute "git finish 4199841"

    Then the stderr should contain "The tests failed, please fix and try again"
    And the branch "4199841_need_hooks_for_my_workflow" should be active
    And the branch "4199841_need_hooks_for_my_workflow" should not be merged into master


#  @wip
#  Scenario: Drops into shell if tests fail after merge

  Scenario: Completely successful pushes master to the remote repository
    Given the local branch "4199841_need_hooks_for_my_workflow" is active
    And the rake task "spec" will succeed
    And the rake task "features" will succeed

    When I execute "git finish"

    Then the stderr should not contain "The tests failed, please fix and try again"
    And the stderr should not contain "Unable to push branch 'master'"
    And the branch "4199841_need_hooks_for_my_workflow" should be merged into master
    And story 4199841 should be finished
    And the local and remote "master" branches should agree
