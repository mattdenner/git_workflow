require 'spec_helper'

describe GitWorkflow do
  describe '.pivotal_tracker_url_for' do
    it 'returns an appropriate real world URL' do
      GitWorkflow.pivotal_tracker_url_for('project_id', 'story_id').should ==
        'http://www.pivotaltracker.com/services/v3/projects/project_id/stories/story_id'
    end
  end
end