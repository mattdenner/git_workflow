# rake features FEATURE=features/release/4132264_fix_the_libxml_warnings_from_nokogiri.feature
@release @needs_service
Feature: Fix the LibXML warnings from Nokogiri
  Background:
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4132264 exists
    And the name of story 4132264 is "Fix the LibXML warnings from Nokogiri"

  Scenario: Starting a branch
    When I successfully execute "git start 4132264"

    Then the output should not contain "I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2"

  Scenario: Finishing a branch
    Given the local branch "4132264_fix_the_libxml_warnings_from_nokogiri" exists

    When I successfully execute "git finish 4132264"

    Then the output should not contain "I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2"
