# rake features FEATURE=4424828_git_start_is_missing_pt_integration_for_my_hooks
@hooks @needs_service @my_workflow
Feature: 'git start' should integrate with PT for my workflow
  Scenario: Starting a new branch with my workflow
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"
    And I have "mine" callbacks enabled

    Given the story 4424828 exists
    And the name of story 4424828 is "'git start' is missing PT integration for my hooks"

    When I successfully execute "git start 4424828"

    Then the branch "4424828_git_start_is_missing_pt_integration_for_my_hooks" should be active
    And the owner of story 4424828 should be "Matthew Denner"
    And story 4424828 should be started
