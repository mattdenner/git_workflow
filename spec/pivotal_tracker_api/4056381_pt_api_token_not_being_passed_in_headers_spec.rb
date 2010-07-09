require 'spec_helper'

class GitWorkflow::Commands::Base
  public :pivotal_tracker_service_for
end

describe GitWorkflow::Commands::Base do
  describe '#pivotal_tracker_service_for' do
    it_should_behave_like 'it needs configuration'

    before(:each) do
      @command     = described_class.new([]) { |*args| }
      @expectation = RestClient::Resource.should_receive(:new)
    end

    after(:each) do
      @expectation.and_return(:ok)
      @command.pivotal_tracker_service_for('story_id').should == :ok
    end

    it 'uses the correct PT URL' do
      @expectation = @expectation.with('http://www.pivotaltracker.com/services/v3/projects/project_id/stories/story_id', anything)
    end

    it 'uses the users PT API token' do
      @expectation = @expectation.with(anything, hash_including(:headers => hash_including('X-TrackerToken' => 'api_token')))
    end
  end
end
