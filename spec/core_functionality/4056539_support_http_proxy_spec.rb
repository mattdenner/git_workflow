require 'spec_helper'
require 'git_workflow/callbacks/pivotal_tracker_support'

describe GitWorkflow::Callbacks::PivotalTrackerSupport::ClassMethods do
  before(:each) do
    @command = Object.new
    @command.stub!(:debug).with(any_args)
    @command.extend(GitWorkflow::Callbacks::PivotalTrackerSupport::ClassMethods)
  end

  describe '.value_of_environment_variable' do
    before(:each) do
      ENV['somevariable'] = 'this is the value'
    end

    after(:each) do
      ENV['somevariable'] = nil
    end

    it 'returns the value of the environment variable' do
      @command.value_of_environment_variable('somevariable').should == 'this is the value'
    end
  end

  describe '.enable_http_proxy_if_present' do
    after(:each) do
      @command.enable_http_proxy_if_present
    end

    it 'uses the $http_proxy environment variable first' do
      @command.stub!(:value_of_environment_variable).with('http_proxy').and_return('http_proxy value')
      RestClient.should_receive(:proxy=).with('http_proxy value')
    end

    it 'falls back to $HTTP_PROXY' do
      @command.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      @command.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return('HTTP_PROXY value')
      RestClient.should_receive(:proxy=).with('HTTP_PROXY value')
    end

    it 'does not set the HTTP proxy if neither is set' do
      @command.stub!(:value_of_environment_variable).with('http_proxy').and_return(nil)
      @command.stub!(:value_of_environment_variable).with('HTTP_PROXY').and_return(nil)
      RestClient.should_receive(:proxy=).with(anything).never
    end
  end
end

describe GitWorkflow::Callbacks::PivotalTrackerSupport do
  before(:each) do
    @command = Class.new.new
    @command.stub!(:debug).with(any_args)
    @command.extend(GitWorkflow::Callbacks::PivotalTrackerSupport)
  end

  describe '#pivotal_tracker_service' do
    it_should_behave_like 'it needs configuration'

    it 'enables the HTTP proxy' do
      @command.class.instance_eval do
        should_receive(:enable_http_proxy_if_present).once
        should_receive(:pivotal_tracker_url_for).with('project_id', 'story_id').and_return('url')
      end
      RestClient::Resource.stub!(:new).with(any_args).and_return(:ok)
      @command.pivotal_tracker_service_for('story_id')
    end
  end
end
