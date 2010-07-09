require 'spec_helper'

describe GitWorkflow::Git do
  before(:each) do
    @git, @repository = Class.new, mock('Repository')
    @git.send(:extend, GitWorkflow::Git)
    @git.stub(:repository).and_return(@repository)
  end

  describe '.get_config_value_for!' do
    it 'returns the value if set' do
      @git.should_receive(:get_config_value_for).with('key').and_return('value')
      @git.get_config_value_for!('key').should == 'value'
    end

    it 'raises an exception if the value is not set' do
      @git.should_receive(:get_config_value_for).with('key').and_return(nil)
      lambda { @git.get_config_value_for!('key') }.should raise_error(StandardError)
    end
  end
end
