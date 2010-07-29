# rake features FEATURE=features/core_functionality/4468313_get_config_value_for_is_producing_an_error_log.feature
@core_functionality @needs_service
Feature: Separate the various logging information
  Background:
    # Note that this background does not set pt.username and uses user.name instead.
    # Notice that this means that this will be reported with verbosity enable, but not
    # without it.
    Given my git username is "Matthew Denner"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "${story.story_id}_${story.name}"

    Given the story 4468313 exists
    And the name of story 4468313 is "'get_config_value_for' is producing an error log"

  Scenario: Starting a branch
    When I successfully execute "git start 4468313"

    Then the output should not contain "pt.username"
    And the output should not contain "DEBUG"

  Scenario: Finishing a branch
    Given the local branch "4468313_get_config_value_for_is_producing_an_error_log" exists

    When I successfully execute "git finish 4468313"

    Then the output should not contain "pt.username"
    And the output should not contain "DEBUG"

  Scenario: Starting a branch with verbosity
    When I successfully execute "git start --verbose 4468313"

    Then the stderr should contain "pt.username"
    And the stdout should not contain "pt.username"

  Scenario: Finishing a branch with verbosity
    Given the local branch "4468313_get_config_value_for_is_producing_an_error_log" exists

    When I successfully execute "git finish --verbose 4468313"

    Then the stderr should contain "pt.username"
    And the stdout should not contain "pt.username"
