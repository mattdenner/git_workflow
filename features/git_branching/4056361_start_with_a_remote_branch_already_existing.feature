# rake features FEATURE=features/git_branching/4056361_start_with_a_remote_branch_already_existing.feature
@git_branching @needs_service @needs_remote_repository
Feature: Remote branch exists already
  Background:
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4056361 exists
    And the name of story 4056361 is "Start with a remote branch already existing"

    # This sets up a file in a remote branch, ensuring that the remote branch is at least one
    # commit ahead of our local master.
    Given the local branch "4056361_start_with_a_remote_branch_already_existing" exists
    And an empty file named "a simple file"
    And I commit "a simple file"
    And the local branch "4056361_start_with_a_remote_branch_already_existing" has been pushed remotely
    And the local branch "4056361_start_with_a_remote_branch_already_existing" does not exist
    And the remote reference to "4056361_start_with_a_remote_branch_already_existing" does not exist

  Scenario: User starts the story
    When I successfully execute "git start 4056361"

    Then the branch "4056361_start_with_a_remote_branch_already_existing" should be active
    And the local branch "4056361_start_with_a_remote_branch_already_existing" and remote branch "4056361_start_with_a_remote_branch_already_existing" should agree
