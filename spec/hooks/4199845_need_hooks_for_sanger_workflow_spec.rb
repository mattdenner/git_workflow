require 'spec_helper'
require 'git_workflow/callbacks/styles/sanger'

describe GitWorkflow::Callbacks::Styles::Sanger::StartBehaviour do
  before(:each) do
    @behaviour = Class.new
    @behaviour.extend(GitWorkflow::Callbacks::Styles::Sanger::StartBehaviour)
  end

  describe '#start' do
    after(:each) do
      repository = mock('Git Repository')
      @behaviour.stub(:repository).and_return(repository)

      story = mock('Story')
      story.should_receive(:checkout).with(repository, @expected_branch_point)

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
