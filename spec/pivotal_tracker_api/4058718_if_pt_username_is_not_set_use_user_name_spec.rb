require 'spec_helper'

class GitWorkflow
  attr_reader :username
end

describe GitWorkflow do
  describe '#load_configuration' do
    before(:each) do
      GitWorkflow.stub!(:get_config_value_for).with('pt.projectid').and_return('project_id')
      GitWorkflow.stub!(:get_config_value_for).with('pt.token').and_return('token')
      GitWorkflow.stub!(:get_config_value_for).with('workflow.localbranchconvention').and_return('convention')
    end

    context 'when pt.username is set' do
      before(:each) do
        GitWorkflow.should_receive(:get_config_value_for).with('pt.username').and_return('PT username')
      end

      it 'uses the configured value' do
        GitWorkflow.new('story_id').username.should == 'PT username'
      end
    end

    context 'when pt.username is not set' do
      before(:each) do
        GitWorkflow.should_receive(:get_config_value_for).with('pt.username').and_return(nil)
        GitWorkflow.should_receive(:get_config_value_for).with('user.name').and_return('global username')
      end

      it 'uses user.name instead' do
        GitWorkflow.new('story_id').username.should == 'global username'
      end
    end
  end
end
