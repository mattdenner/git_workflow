require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Mine
        def self.setup(into_class = GitWorkflow::Commands::Finish)
          into_class.instance_eval do
            include GitWorkflow::Callbacks::TestCodeSupport
            include GitWorkflow::Callbacks::RemoteGitBranchSupport
            include GitWorkflow::Callbacks::Styles::Mine
          end
        end

        def self.included(base)
          base.alias_method_chain(:merge_story_into!, :my_callbacks)
        end

        def merge_story_into_with_my_callbacks!(story, branch_name, &block)
          in_git_branch(story.branch_name) do
            run_tests!(:spec, :features)
          end
          in_git_branch(branch_name) do
            merge_story_into_without_my_callbacks!(story, branch_name, &block)
            run_tests_with_recovery!(:spec, :features)
            push_current_branch_to(branch_name) if branch_name == 'master'
          end
        end
      end
    end
  end
end
