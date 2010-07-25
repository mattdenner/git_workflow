require 'spec_helper'
require 'git_workflow/callbacks/pivotal_tracker_support'

describe GitWorkflow::Callbacks::PivotalTrackerSupport::ClassMethods do
  before(:each) do
    @class_methods = Object.new
    @class_methods.extend(GitWorkflow::Callbacks::PivotalTrackerSupport::ClassMethods)
  end

  describe '.pivotal_tracker_url_for' do
    it 'returns an appropriate real world URL' do
      @class_methods.pivotal_tracker_url_for('project_id', 'story_id').should ==
        'http://www.pivotaltracker.com/services/v3/projects/project_id/stories/story_id'
    end
  end
end
