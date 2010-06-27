require 'spec_helper'

class GitWorkflow
  public :pivotal_tracker_service
end

describe GitWorkflow do
  describe '#pivotal_tracker_service' do
    before(:each) do
      GitWorkflow.stub!(:get_config_value_for).with('pt.username').and_return('user name')
      GitWorkflow.stub!(:get_config_value_for).with('pt.projectid').and_return('project_id')
      GitWorkflow.stub!(:get_config_value_for).with('pt.token').and_return('token')
      GitWorkflow.stub!(:get_config_value_for).with('workflow.localbranchconvention').and_return('convention')

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
      @expectation = @expectation.with(anything, hash_including(:headers => hash_including('X-TrackerToken' => 'token')))
    end
  end
end
