require 'spec_helper'

describe GitWorkflow::Git do
  before(:each) do
    @git, @repository = Class.new, mock('Repository')
    @git.send(:extend, GitWorkflow::Git)
    @git.stub(:repository).and_return(@repository)
  end

  describe '#in_git_branch' do
    before(:each) do
      @repository.should_receive(:current_branch).ordered.and_return('current')
    end

    it 'does not switch back if an error occurs' do
      @repository.should_receive(:checkout).with('new_branch').ordered

      lambda do
        @git.in_git_branch('new_branch') { raise StandardError, 'Failed' }
      end.should raise_error(StandardError)
    end

    context 'with a successful block' do
      before(:each) do
        @callback = mock('callback')
        @callback.should_receive(:called)
      end

      after(:each) do
        @git.in_git_branch(@target_branch) { @callback.called }
      end

      it 'simply yields if the current branch is the requested branch' do
        @target_branch = 'current'
      end

      it 'switches to the new branch and back again for success' do
        @target_branch = 'new_branch'

        @repository.should_receive(:checkout).with('new_branch').ordered
        @repository.should_receive(:checkout).with('current').ordered
      end
    end
  end
end

class GitWorkflow::Git::Repository
  def self.for_testing
    new
  end

  def internal_current_branch
    @current_branch
  end
end

describe GitWorkflow::Git::Repository do
  before(:each) do
    @repository = described_class.for_testing
  end

  describe '#current_branch' do
    it 'finds the current branch from the list' do
      @repository.should_receive(:execute_command).with('git branch').and_return([ '   branch_1', '* branch_2', '   branch_3' ].join("\n"))
      @repository.current_branch.should == 'branch_2'
    end

    it 'raises if the current branch cannot be found in the list' do
      @repository.should_receive(:execute_command).with('git branch').and_return([ '   branch_1', '  branch_2', '   branch_3' ].join("\n"))
      lambda { @repository.current_branch }.should raise_error(GitWorkflow::Git::Repository::BranchError)
    end
  end

  describe '#checkout' do
    it 'raises CheckoutError on command failure' do
      @repository.should_receive(:execute_command).with(anything).and_raise(Execution::CommandFailure.new('command', :fail))
      lambda { @repository.checkout('target') }.should raise_error(GitWorkflow::Git::Repository::CheckoutError)
    end

    context 'on successful checkout' do
      before(:each) do
        @repository.should_receive(:execute_command).with('git checkout target')
        @repository.checkout('target')
      end

      it 'checks out the requested branch' do
        # Nothing needed here
      end

      it 'maintains the current branch for performance' do
        @repository.internal_current_branch.should == 'target'
      end
    end
  end
end
