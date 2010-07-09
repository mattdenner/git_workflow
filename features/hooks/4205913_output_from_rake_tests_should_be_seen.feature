# rake features FEATURE=features/hooks/4205913_output_from_rake_tests_should_be_seen.feature
@hooks @needs_service
Feature: Output from rake tests should be seen
  Scenario: The output should be appearing
    Given my Pivotal Tracker username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"
    And I have "mine" callbacks enabled

    Given the story 4205913 exists
    And the name of story 4205913 is "Output from rake tests should be seen"

    Given the local branch "4205913_output_from_rake_tests_should_be_seen" exists
    And the local branch "4205913_output_from_rake_tests_should_be_seen" is active
    And the rake task "spec" will fail
    And the rake task "features" will fail

    When I execute "git finish"

    Then the stdout should contain "Running spec"
    And the stdout should contain "Failing spec"