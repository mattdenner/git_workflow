require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'
require 'git_workflow/callbacks/pivotal_tracker_support'
require 'git_workflow/commands/start'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Sanger
        def self.setup(start_command = GitWorkflow::Commands::Start, finish_command = GitWorkflow::Commands::Finish)
          start_command.send(:include, StartBehaviour)
          finish_command.send(:include, FinishBehaviour)
        end

        module StartBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
            end
          end

          def start(story, source)
            checkout_or_create_branch(story.branch_name, source || 'master')
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
              run_tests!(:test, :features)
              push_current_branch_to(story.remote_branch_name)
              story.comment("Fixed on #{ story.remote_branch_name }. Needs merging into master")
            end
          end
        end
      end
    end
  end
end
