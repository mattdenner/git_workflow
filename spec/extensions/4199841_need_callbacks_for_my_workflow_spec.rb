require 'spec_helper'
require 'git_workflow/callbacks/styles/mine'

describe String do
  describe '#camelize' do
    it 'camelizes an underscored word' do
      'foo_bar_baz'.camelize.should == 'FooBarBaz'
    end

    it 'modularizes a path' do
      'foo/bar/baz'.camelize.should == 'Foo::Bar::Baz'
    end
  end

  describe '#underscore' do
    it 'underscores a modular string' do
      'Foo::Bar::Baz'.underscore.should == 'foo/bar/baz'
    end

    it 'underscores a camelized word' do
      'FooBarBaz'.underscore.should == 'foo_bar_baz'
    end
  end
end

describe GitWorkflow::Callbacks::Styles::Mine do
  before(:each) do
    @callbacks = Class.new
    @callbacks.send(:extend, GitWorkflow::Callbacks::Styles::Mine)
  end

  describe '#merge_story_into_with_my_callbacks' do
    before(:each) do
      @callbacks.should_receive(:run_tests!).with(:spec, :features).ordered
      @callbacks.should_receive(:merge_story_into_without_my_callbacks!).with(:story, anything).ordered
      @callbacks.should_receive(:run_tests_with_recovery!).with(:spec, :features).ordered
    end

    it 'runs the tests but not the push if non-master branch' do
      @callbacks.should_not_receive(:push_current_branch_to).with('non-master')
      @callbacks.merge_story_into_with_my_callbacks!(:story, 'non-master')
    end

    it 'runs the tests and the push if master branch' do
      @callbacks.should_receive(:push_current_branch_to).with('master').ordered
      @callbacks.merge_story_into_with_my_callbacks!(:story, 'master')
    end
  end

  describe '.setup' do
    before(:each) do
      @target = Class.new
      @target.instance_eval { define_method(:merge_story_into!) { } }
      @target.should_receive(:alias_method_chain).with(:merge_story_into!, :my_callbacks)

      GitWorkflow::Callbacks::Styles::Mine.setup(@target)
    end

    it 'has the test code support' do
      @target.included_modules.should include(GitWorkflow::Callbacks::TestCodeSupport)
    end

    it 'has the remote git branch support' do
      @target.included_modules.should include(GitWorkflow::Callbacks::RemoteGitBranchSupport)
    end

    it 'has my callbacks installed' do
      @target.included_modules.should include(GitWorkflow::Callbacks::Styles::Mine)
    end
  end
end

describe GitWorkflow::Callbacks::TestCodeSupport do
  before(:each) do
    @callbacks = Class.new
    @callbacks.send(:extend, GitWorkflow::Callbacks::TestCodeSupport)
  end

  describe '#run_tests!' do
    it 'does nothing if the tests pass' do
      @callbacks.should_receive(:run_tests).with(:task1, :task2).once.and_return(true)

      @callbacks.run_tests!(:task1, :task2)
    end

    it 'raises if the tests fail' do
      @callbacks.should_receive(:run_tests).with(:task1, :task2).once.and_return(false)

      lambda { @callbacks.run_tests!(:task1, :task2) }.should raise_error(GitWorkflow::Callbacks::TestCodeSupport::Failure)
    end
  end

  describe '#run_tests_with_recovery!' do
    it 'does nothing if the tests pass' do
      @callbacks.should_receive(:run_tests).with(:task1, :task2).once.and_return(true)

      @callbacks.run_tests_with_recovery!(:task1, :task2)
    end

    it 'tries to recover from failing tests' do
      @callbacks.should_receive(:run_tests).with(:task1, :task2).twice.and_return(false, true)
      @callbacks.should_receive(:spawn_shell_for_recovery).once.and_return(true)

      @callbacks.run_tests_with_recovery!(:task1, :task2)
    end

    it 'raises if the recovery is not possible' do
      @callbacks.should_receive(:run_tests).with(:task1, :task2).once.and_return(false)
      @callbacks.should_receive(:spawn_shell_for_recovery).once.and_return(false)

      lambda { @callbacks.run_tests_with_recovery!(:task1, :task2) }.should raise_error(GitWorkflow::Callbacks::TestCodeSupport::Failure)
    end
  end

  describe '#run_tests' do
    it 'executes the given rake tasks' do
      @callbacks.should_receive(:execute_command).with('rake task1 task2').and_return(:ok)
      @callbacks.send(:run_tests, :task1, :task2).should == :ok
    end

    it 'raises if the command fails' do
      @callbacks.should_receive(:execute_command).with(anything).and_raise(Execution::CommandFailure.new('foo', :failure))
      @callbacks.send(:run_tests).should == false
    end
  end

  describe '#spawn_shell_for_recovery' do
  end
end

describe GitWorkflow::Callbacks::RemoteGitBranchSupport do
  before(:each) do
    @callbacks = Class.new
    @callbacks.send(:extend, GitWorkflow::Callbacks::RemoteGitBranchSupport)
  end

  describe '#push_current_branch_to' do
  end
end
