require 'spec_helper'

class GitWorkflow::Configuration
  def self.for_testing
    new
  end
end

describe GitWorkflow::Configuration do
  before(:each) do
    @configuration = described_class.for_testing
  end

  describe '#remote_branch_convention' do
    it 'uses the workflow.remotebranchconvention setting' do
      @configuration.should_receive(:get_config_value_for!).with('workflow.remotebranchconvention').and_return('${story.story_id}_foo')
      @configuration.remote_branch_convention
    end
  end
end

class GitWorkflow::Git::Repository
  def self.for_testing
    new
  end
end

describe GitWorkflow::Git::Repository do
  before(:each) do
    @repository = described_class.for_testing
  end

  describe '#push' do
    it 'pushes the branch to origin' do
      @repository.should_receive(:execute_command).with('git push origin foo')
      @repository.push('foo')
    end

    it 'raises BranchError if the push fails' do
      @repository.should_receive(:execute_command).with('git push origin foo').and_raise(Execution::CommandFailure.new('command', :failure))
      lambda { @repository.push('foo') }.should raise_error(GitWorkflow::Git::Repository::BranchError)
    end
  end
end
