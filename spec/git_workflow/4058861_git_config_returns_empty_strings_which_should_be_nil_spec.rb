require 'spec_helper'

describe GitWorkflow do
  describe '.get_config_value_for' do
    after(:each) do
      GitWorkflow.should_receive(:execute_command).with('git config key').and_return(@value)
      GitWorkflow.get_config_value_for('key').should == @expected
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
