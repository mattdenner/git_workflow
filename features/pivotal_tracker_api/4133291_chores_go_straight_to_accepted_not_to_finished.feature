# rake features FEATURE=features/pivotal_tracker_api/4133291_chores_go_straight_to_accepted_not_to_finished.feature
@pivotal_tracker_api @needs_service
Feature: Finishing a chore means accepting it
  Scenario: Finishing a chore
    Given my Pivotal Tracker configuration is setup as normal

    Given the story 4133291 exists
    And story 4133291 is a chore
    And the name of story 4133291 is "Chores go straight to 'accepted' not to 'finished'"

    Given the local branch "4133291_chores_go_straight_to_accepted_not_to_finished" exists

    When I successfully execute "git finish 4133291"

    Then story 4133291 should be accepted
