require 'spec_helper'

class GitWorkflow::Configuration
  def instance_for_testing
    new
  end
end

describe GitWorkflow::Configuration do
  before(:each) do
    @configuration = described_class.instance_for_testing
  end

  describe '#branches' do
    before(:each) do
      @git_branch = @configuration.should_receive(:execute_command).with('git branch')
    end

    it 'raises an error if the branch line is invalid' do
      @git_branch.and_return('this is not correct')
      lambda { @configuration.branches }.should raise_error(StandardError)
    end

    it 'returns the active branch' do
      @git_branch.and_return('* active')
      @configuration.branches.should == [ [ 'active', true ] ]
    end

    it 'returns non-active branch' do
      @git_branch.and_return('  non-active')
      @configuration.branches.should == [ [ 'non-active', false ] ]
    end

    it 'handles multiple lines' do
      @git_branch.and_return("  branch_1\n  branch_2")
      @configuration.branches.size.should == 2
    end
  end

  describe '#active_branch' do
    it 'returns the current branch' do
      @configuration.should_receive(:branches).and_return([
        [ 'some_branch',       false ],
        [ 'some_other_branch', true  ]
      ])
      @configuration.active_branch.should == 'some_other_branch'
    end

    it 'errors if there is no working branch' do
      @configuration.should_receive(:branches).and_return([])
      lambda { @configuration.active_branch }.should raise_error(StandardError)
    end
  end
end
