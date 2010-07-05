require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Sanger
        def self.included(base)
          base.alias_method_chain(:merge_story_into!, :sanger_callbacks)
        end

        def merge_story_into_with_sanger_callbacks!(story, branch_name, &block)
          run_tests!(:test, :features)
          push_current_branch_to(story.remote_branch_name)
          merge_story_into_without_sanger_callbacks!(story, branch_name, &block)
          run_tests_with_recovery!(:test, :features)
          push_current_branch_to(branch_name)
        end
      end
    end
  end

  module Commands
    class Finish
      include GitWorkflow::Callbacks::TestCodeSupport
      include GitWorkflow::Callbacks::RemoteGitBranchSupport
      include GitWorkflow::Callbacks::Styles::Sanger
    end
  end
end
