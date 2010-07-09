module GitWorkflow
  module Callbacks
    module RemoteGitBranchSupport
      def push_current_branch_to(remote_branch_name)
        repository.push(remote_branch_name)
      end
    end
  end
end
