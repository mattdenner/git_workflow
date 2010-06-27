require 'spec_helper'

describe GitWorkflow::Story do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:username).and_return('username')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#branch_name' do
    it 'delegates to the owner' do
      @owner.should_receive(:branch_name_for).with(@story).and_return('this is the branch')
      @story.branch_name.should == 'this_is_the_branch'
    end
  end
end

describe GitWorkflow::StorySupportInterface do
  describe '#branch_name_for' do
    after(:each) do
      workflow = mock('workflow')
      workflow.should_receive(:instance_variable_get).with('@local_branch_convention').and_return(@setting)

      described_class.new(workflow).branch_name_for('story variable').should == @expected
    end

    it 'evaluates the local branch convention from the workflow' do
      @setting, @expected = '1 + 1', 2
    end

    it 'uses the local binding so story is available' do
      @setting, @expected = '${story}', 'story variable'
    end
  end
end

class GitWorkflow
  attr_reader :local_branch_convention
end

describe GitWorkflow do
  describe '#load_configuration' do
    it 'gets the workflow.localbranchconvention setting' do
      GitWorkflow.stub!(:get_config_value_for).with('pt.username').and_return('username')
      GitWorkflow.stub!(:get_config_value_for!).with('user.name').and_return('username')
      GitWorkflow.stub!(:get_config_value_for!).with('pt.projectid').and_return('project_id')
      GitWorkflow.stub!(:get_config_value_for!).with('pt.token').and_return('token')
      GitWorkflow.should_receive(:get_config_value_for!).with('workflow.localbranchconvention').and_return('convention')

      GitWorkflow.new('story_id').local_branch_convention.should == 'convention'
    end
  end
end
