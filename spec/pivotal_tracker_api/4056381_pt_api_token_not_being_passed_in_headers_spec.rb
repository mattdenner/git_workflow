require 'spec_helper'

class GitWorkflow
  public :pivotal_tracker_service
end

describe GitWorkflow do
  describe '#pivotal_tracker_service' do
    it_should_behave_like 'it needs configuration'

    before(:each) do
      @workflow    = GitWorkflow.new('story_id')
      @expectation = RestClient::Resource.should_receive(:new)
    end

    after(:each) do
      @expectation.and_return(:ok)
      @workflow.pivotal_tracker_service.should == :ok
    end

    it 'uses the correct PT URL' do
      @expectation = @expectation.with('http://www.pivotaltracker.com/services/v3/projects/project_id/stories/story_id', anything)
    end

    it 'uses the users PT API token' do
      @expectation = @expectation.with(anything, hash_including(:headers => hash_including('X-TrackerToken' => 'api_token')))
    end
  end
end
