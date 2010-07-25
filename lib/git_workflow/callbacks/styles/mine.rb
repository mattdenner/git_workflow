require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'
require 'git_workflow/callbacks/pivotal_tracker_support'
require 'git_workflow/commands/start'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Mine
        def self.setup(start_class = GitWorkflow::Commands::Start, finish_class = GitWorkflow::Commands::Finish)
          start_class.send(:include, StartBehaviour)
          finish_class.send(:include, FinishBehaviour)
        end

        module StartBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
            end
          end

          def start(story, source)
            checkout_or_create_branch(story.branch_name, source)
          end
        end

        module FinishBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
              include GitWorkflow::Callbacks::TestCodeSupport
              include GitWorkflow::Callbacks::RemoteGitBranchSupport
            end
          end

          def finish(story, branch_name)
            in_git_branch(story.branch_name) do
              run_tests!(:spec, :features)
            end
            in_git_branch(branch_name) do
              merge_branch(story.branch_name, branch_name)
              run_tests_with_recovery!(:spec, :features)
              push_current_branch_to(branch_name) if branch_name == 'master'
            end
          end
        end
      end
    end
  end
end

