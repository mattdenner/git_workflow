# rake features FEATURE=features/git_branching/4135501_allow_branch_start_point_to_be_specified_from_command_line.feature
@git_branching @needs_service
Feature: Branching from a branch
  Background:
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4135501 exists
    And the name of story 4135501 is "Allow branch start point to be specified from command line"

    Given the local branch "parent_branch" exists
    And the local branch "parent_branch" is active
    And an empty file named "I am empty"
    And I commit "I am empty"

  Scenario: When the user is on master and specifies the branch
    And the local branch "master" is active

    When I successfully execute "git start 4135501 parent_branch"

    Then the branch "4135501_allow_branch_start_point_to_be_specified_from_command_line" should be active
    And the parent of branch "4135501_allow_branch_start_point_to_be_specified_from_command_line" should be "parent_branch"

  Scenario: When the user is on the parent branch and doesn't specify one
    When I successfully execute "git start 4135501"

    Then the branch "4135501_allow_branch_start_point_to_be_specified_from_command_line" should be active
    And the parent of branch "4135501_allow_branch_start_point_to_be_specified_from_command_line" should be "parent_branch"
