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
