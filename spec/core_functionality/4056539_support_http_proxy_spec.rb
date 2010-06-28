require 'spec_helper'

describe GitWorkflow do
  describe '.value_of_environment_variable' do
    before(:each) do
      ENV['somevariable'] = 'this is the value'
    end

    after(:each) do
      ENV['somevariable'] = nil
    end

    it 'returns the value of the environment variable' do
      GitWorkflow.value_of_environment_variable('somevariable').should == 'this is the value'
    end
  end

  describe '.enable_http_proxy_if_present' do
    it 'uses the $http_proxy environment variable first' do
      GitWorkflow.stub!(:value_of_environment_variable).with('http_proxy').and_return('http_proxy value')
      RestClient.should_receive(:proxy=).with('http_proxy value')
      GitWorkflow.enable_http_proxy_if_present
    end

    it 'falls back to $HTTP_PROXY' do
      GitWorkflow.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      GitWorkflow.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return('HTTP_PROXY value')
      RestClient.should_receive(:proxy=).with('HTTP_PROXY value')
      GitWorkflow.enable_http_proxy_if_present
    end

    it 'does not set the HTTP proxy if neither is set' do
      GitWorkflow.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      GitWorkflow.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return(nil)
      RestClient.should_receive(:proxy=).with(anything).never
      GitWorkflow.enable_http_proxy_if_present
    end
  end

  describe '#pivotal_tracker_service' do
    it_should_behave_like 'it needs configuration'

    before(:each) do
      @workflow = GitWorkflow.new('story_id')
    end

    it 'enables the HTTP proxy' do
      GitWorkflow.should_receive(:enable_http_proxy_if_present).once
      RestClient::Resource.stub!(:new).with(any_args).and_return(:ok)
      @workflow.pivotal_tracker_service
    end
  end
end
