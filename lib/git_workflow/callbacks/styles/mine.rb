require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Mine
        def self.included(base)
          base.alias_method_chain(:merge_story!, :my_callbacks)
        end

        def merge_story_with_my_callbacks!(story, branch_name, &block)
          run_tests!(:spec, :features)
          merge_story_without_my_callbacks!(story, branch_name, &block)
          run_tests!(:spec, :features)
          push_current_branch_to(branch_name) if branch_name == 'master'
        end
      end
    end
  end

  module Commands
    class Finish
      include GitWorkflow::Callbacks::TestCodeSupport
      include GitWorkflow::Callbacks::RemoteGitBranchSupport
      include GitWorkflow::Callbacks::Styles::Mine
    end
  end
end

