require 'spec_helper'
require 'git_workflow/callbacks/pivotal_tracker_support'

module GitWorkflow::Callbacks::PivotalTrackerSupport
  public :pivotal_tracker_service_for
end

describe GitWorkflow::Callbacks::PivotalTrackerSupport do
  before(:each) do
    @command = Class.new.new
    @command.stub!(:debug).with(any_args)
    @command.extend(GitWorkflow::Callbacks::PivotalTrackerSupport)
  end

  describe '#pivotal_tracker_service_for' do
    it_should_behave_like 'it needs configuration'

    before(:each) do
      @command.class.instance_eval do
        stub!(:enable_http_proxy_if_present)
        should_receive(:pivotal_tracker_url_for).with('project_id', 'story_id').and_return('url')
      end

      @expectation = RestClient::Resource.should_receive(:new)
    end

    after(:each) do
      @expectation.and_return(:ok)
      @command.pivotal_tracker_service_for('story_id').should == :ok
    end

    it 'uses the correct PT URL' do
      @expectation = @expectation.with('url', anything)
    end

    it 'uses the users PT API token' do
      @expectation = @expectation.with(anything, hash_including(:headers => hash_including('X-TrackerToken' => 'api_token')))
    end
  end
end
