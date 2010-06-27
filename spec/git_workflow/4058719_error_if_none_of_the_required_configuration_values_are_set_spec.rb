require 'spec_helper'

describe GitWorkflow do
  describe '.get_config_value_for!' do
    it 'returns the value if set' do
      GitWorkflow.should_receive(:get_config_value_for).with('key').and_return('value')
      GitWorkflow.get_config_value_for!('key').should == 'value'
    end

    it 'raises an exception if the value is not set' do
      GitWorkflow.should_receive(:get_config_value_for).with('key').and_return(nil)
      lambda { GitWorkflow.get_config_value_for!('key') }.should raise_error(StandardError)
    end
  end

  describe '#load_configuration' do
    it 'gets the configuration values correctly' do
      GitWorkflow.should_receive(:get_config_value_for).with('pt.username').and_return(nil)
      GitWorkflow.should_receive(:get_config_value_for!).with('user.name').and_return('username')
      GitWorkflow.should_receive(:get_config_value_for!).with('pt.projectid').and_return('project_id')
      GitWorkflow.should_receive(:get_config_value_for!).with('pt.token').and_return('token')

      GitWorkflow.new('story_id')
    end
  end
end
