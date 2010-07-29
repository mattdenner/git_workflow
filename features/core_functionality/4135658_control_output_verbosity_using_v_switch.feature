# rake features FEATURE=features/core_functionality/4135658_control_output_verbosity_using_v_switch.feature
@core_functionality @needs_service @command_line
Feature: Command line option parsing
  Background:
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4135658 exists
    And the name of story 4135658 is "Need the ability to start a new branch"

    Given the local branch "4135658_control_output_verbosity_using_v_switch" exists

  Scenario Outline: Usage displayed for --help
    When I execute "git <command> --help"
    Then the output should contain "Usage: git <command>"

    Examples:
      |command|
      | start |
      |finish |

  Scenario Outline: Verbose output for --verbose
    When I execute "git <command> 4135658"
    Then the output should not contain "DEBUG"

    When I execute "git <command> --verbose 4135658"
    Then the output should contain "DEBUG"

    Examples:
      |command|
      | start |
      |finish |

