# rake features FEATURE=features/core_functionality/4056359_start_with_local_branch_already_present.feature
@core_functionality @needs_service
Feature: Start with local branch already present
  Scenario: The branch already exists
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4056359 exists
    And the name of story 4056359 is "Start with local branch already present"

    Given the local branch "4056359_start_with_local_branch_already_present" exists
    
    When I successfully execute "git start 4056359"

    Then the branch "4056359_start_with_local_branch_already_present" should be active
    And the owner of story 4056359 should be "Matthew Denner"
    And story 4056359 should be started
