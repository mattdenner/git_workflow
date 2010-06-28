require 'spec_helper'

class GitWorkflow::Configuration
  def self.instance_for_testing
    new
  end
end

describe GitWorkflow::Configuration do
  describe '#username' do
    before(:each) do
      @configuration = described_class.instance_for_testing
    end

    it 'uses pt.username first' do
      @configuration.should_receive(:get_config_value_for).with('pt.username').and_return('pt.username')
      @configuration.username.should == 'pt.username'
    end

    it 'falls back to user.name otherwise' do
      @configuration.should_receive(:get_config_value_for).with('pt.username').and_return(nil)
      @configuration.should_receive(:get_config_value_for!).with('user.name').and_return('user.name')
      @configuration.username.should == 'user.name'
    end
  end
end
