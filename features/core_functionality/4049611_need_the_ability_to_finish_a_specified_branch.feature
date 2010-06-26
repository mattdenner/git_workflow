# rake features FEATURE=features/core_functionality/4049611_need_the_ability_to_finish_a_specified_branch.feature
@core_functionality @needs_service
Feature: Need the ability to finish a specified branch
  Scenario: Finishing an existing branch
    Given my Pivotal Tracker email address is "matt.denner@gmail.com"
    And my Pivotal Tracker project ID is 93630
    And my Pivotal Tracker token is 1234567890
    And my local branch naming convention is "#{story.id}_#{story.title}"

    Given the story 4049611 exists
    And the name of story 4049611 is "Need the ability to start a new branch"

    Given the local branch "4049611_need_the_ability_to_start_a_new_branch" exists
    And the default rake task will succeed

    When I successfully run "git finish 4049611"

    Then the branch "4049611_need_the_ability_to_start_a_new_branch" should be merged into master
    And story 4049611 should be finished
