require 'spec_helper'

describe GitWorkflow::Commands::Base do
  describe '.value_of_environment_variable' do
    before(:each) do
      ENV['somevariable'] = 'this is the value'
    end

    after(:each) do
      ENV['somevariable'] = nil
    end

    it 'returns the value of the environment variable' do
      described_class.value_of_environment_variable('somevariable').should == 'this is the value'
    end
  end

  describe '.enable_http_proxy_if_present' do
    after(:each) do
      described_class.enable_http_proxy_if_present
    end

    it 'uses the $http_proxy environment variable first' do
      described_class.stub!(:value_of_environment_variable).with('http_proxy').and_return('http_proxy value')
      RestClient.should_receive(:proxy=).with('http_proxy value')
    end

    it 'falls back to $HTTP_PROXY' do
      described_class.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      described_class.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return('HTTP_PROXY value')
      RestClient.should_receive(:proxy=).with('HTTP_PROXY value')
    end

    it 'does not set the HTTP proxy if neither is set' do
      described_class.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      described_class.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return(nil)
      RestClient.should_receive(:proxy=).with(anything).never
    end
  end

  describe '#pivotal_tracker_service' do
    it_should_behave_like 'it needs configuration'

    before(:each) do
      @command = described_class.new([]) { |*args| }
    end

    it 'enables the HTTP proxy' do
      described_class.should_receive(:enable_http_proxy_if_present).once
      RestClient::Resource.stub!(:new).with(any_args).and_return(:ok)
      @command.pivotal_tracker_service_for('story_id')
    end
  end
end
