require 'spec_helper'

class GitWorkflow::Configuration
  def self.instance_for_testing
    new
  end
end

describe GitWorkflow::Configuration do
  describe '#local_branch_convention' do
    before(:each) do
      @configuration = GitWorkflow::Configuration.instance_for_testing
      @configuration.should_receive(:get_config_value_for!).with('workflow.localbranchconvention').once.and_return('${number}_${name}')
    end

    it 'uses the workflow.localbranchconvention configuration value' do
      @configuration.local_branch_convention
    end

    it 'caches the value' do
      @configuration.local_branch_convention # Gets the value ...
      @configuration.local_branch_convention # ... that should now be cached
    end
  end
end

class GitWorkflow::Commands::Finish
  public :extract_story_from_branch
end

describe GitWorkflow::Commands::Finish do
  before(:each) do
    @configuration = mock('configuration')
    @configuration.stub(:ignore_git_global?).and_return(false)
    GitWorkflow::Configuration.stub!(:instance).and_return(@configuration)

    @command = described_class.new([])
  end

  describe '#extract_story_from_branch' do
    before(:each) do
      @convention = mock('convention')
      @configuration.stub!(:local_branch_convention).and_return(@convention)
    end

    it 'uses the branch convention' do
      @convention.should_receive(:from).with('12345_this_branch_matches').and_return(12345)
      @command.extract_story_from_branch('12345_this_branch_matches').should == 12345
    end
  end
end

describe GitWorkflow::Configuration::Convention do
  describe '#initialize' do
    it 'errors if the convention has no story_id' do
      lambda { described_class.new('foo') }.should raise_error(StandardError)
    end

    it 'does not error if story_id included' do
      described_class.new('${number}_foo')
    end
  end

  shared_examples_for 'branch convention behaviour' do
    before(:each) do
      @branches   = { :start => '12345_works_for_me', :end => 'works_for_me_12345' }
    end

    describe '#to' do
      before(:each) do
        @decoder = described_class.new(@convention)
        @decoder.stub!(:use_existing_for).with(anything).and_return(nil)
      end

      it 'evaluates the convention string' do
        story = OpenStruct.new(:story_id => 12345, :name => 'works for me')
        @decoder.to(story).should == @branches[ @to_result ]
      end
    end

    describe '#from' do
      before(:each) do
        @decoder = described_class.new(@convention)
      end

      it 'decodes the same branch that #to produces' do
        @decoder.from(@branches[ @to_result ]).should == 12345
      end

      it 'errors if the branch does not conform to the convention' do
        lambda { @decoder.from(@branches[ @from_mismatch ]) }.should raise_error(StandardError)
      end
    end
  end

  context 'after successful initialization' do
    context 'with ${number}_${name}' do
      it_should_behave_like 'branch convention behaviour'

      before(:each) do
        @convention                = '${number}_${name}'
        @to_result, @from_mismatch = :start, :end
      end
    end

    context 'with ${name}_${number}' do
      it_should_behave_like 'branch convention behaviour'

      before(:each) do
        @convention                = '${name}_${number}'
        @to_result, @from_mismatch = :end, :start
      end
    end
  end
end
