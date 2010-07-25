require 'spec_helper'
require 'git_workflow/callbacks/styles/sanger'

describe GitWorkflow::Callbacks::Styles::Sanger::StartBehaviour do
  before(:each) do
    @behaviour = Class.new
    @behaviour.extend(GitWorkflow::Callbacks::Styles::Sanger::StartBehaviour)
  end

  describe '#start' do
    after(:each) do
      story = mock('Story')
      story.stub(:branch_name).and_return('story_branch')
      @behaviour.should_receive(:checkout_or_create_branch).with('story_branch', @expected_branch_point)

      @behaviour.start(story, @branch_point)
    end

    it 'creates the branch from the default start point' do
      @branch_point, @expected_branch_point = nil, 'master'
    end

    it 'creates the branch from the specified start point' do
      @branch_point = @expected_branch_point = 'foobar'
    end
  end
end
