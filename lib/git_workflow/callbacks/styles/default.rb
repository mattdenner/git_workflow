require 'git_workflow/callbacks/pivotal_tracker_support'
require 'git_workflow/commands/start'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Default
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
            story.checkout(self.repository, source)
          end
        end

        module FinishBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
            end
          end

          def finish(story, branch_name)
            in_git_branch(branch_name) do
              merge_branch(story.branch_name, branch_name)
            end
          end
        end
      end
    end
  end
end

