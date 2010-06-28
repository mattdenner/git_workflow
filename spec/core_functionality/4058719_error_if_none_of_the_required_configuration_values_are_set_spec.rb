require 'spec_helper'

describe GitWorkflow::Configuration do
  describe '.get_config_value_for!' do
    it 'returns the value if set' do
      described_class.should_receive(:get_config_value_for).with('key').and_return('value')
      described_class.get_config_value_for!('key').should == 'value'
    end

    it 'raises an exception if the value is not set' do
      described_class.should_receive(:get_config_value_for).with('key').and_return(nil)
      lambda { described_class.get_config_value_for!('key') }.should raise_error(StandardError)
    end
  end
end

describe GitWorkflow do
  describe '#load_configuration' do
    it 'gets the configuration values correctly' do
      configuration = mock('configuration')
      configuration.should_receive(:username).and_return('username')
      configuration.should_receive(:project_id).and_return('project_id')
      configuration.should_receive(:api_token).and_return('api_token')
      configuration.should_receive(:local_branch_convention).and_return('convention')
      GitWorkflow::Configuration.stub!(:instance).and_return(configuration)

      described_class.new('story_id')
    end
  end
end
