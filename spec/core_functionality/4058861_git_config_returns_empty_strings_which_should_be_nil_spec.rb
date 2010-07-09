require 'spec_helper'

class GitWorkflow::Git::Repository
  def self.for_testing
    new
  end
end

describe GitWorkflow::Git::Repository do
  before(:each) do
    @repository = described_class.for_testing
  end

  describe '#config_get' do
    it 'raises ConfigError on command failure' do
      @repository.should_receive(:execute_command).with(anything).and_raise(Execution::CommandFailure.new('command', :failure))
      lambda { @repository.config_get('key') }.should raise_error(GitWorkflow::Git::Repository::ConfigError)
    end

    context 'when command succeeds' do
      after(:each) do
        @repository.should_receive(:execute_command).with('git config key').and_return(@value)
        @repository.config_get('key').should == @expected
      end

      it 'returns the value that is set' do
        @value = @expected = 'value'
      end

      it 'strips whitespace from the value' do
        @value, @expected = ' value ', 'value'
      end

      it 'returns nil if value is empty' do
        @value, @expected = '', nil
      end
    end
  end
end

describe GitWorkflow::Git do
  before(:each) do
    @git, @repository = Class.new, mock('Repository')
    @git.send(:extend, GitWorkflow::Git)
    @git.stub(:repository).and_return(@repository)
  end

  describe '#get_config_value_for' do
    it 'returns whatever is set' do
      @repository.should_receive(:config_get).with('key').and_return(:ok)
      @git.get_config_value_for('key').should == :ok
    end

    it 'returns nil for failure' do
      @repository.should_receive(:config_get).with('key').and_raise(GitWorkflow::Git::Repository::ConfigError)
      @git.get_config_value_for('key').should == nil
    end
  end
end
