# rake features FEATURE=features/core_functionality/4056363_finish_the_current_branch.feature
@core_functionality @needs_service
Feature: Finish the current branch
  Scenario: When executed on the branch
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4056363 exists
    And the name of story 4056363 is "Finish the current branch"

    Given the local branch "4056363_finish_the_current_branch" exists
    And the local branch "4056363_finish_the_current_branch" is active

    When I successfully execute "git finish"

    Then the branch "4056363_finish_the_current_branch" should be merged into master
    And the owner of story 4056363 should be "Matthew Denner"
    And story 4056363 should be finished
