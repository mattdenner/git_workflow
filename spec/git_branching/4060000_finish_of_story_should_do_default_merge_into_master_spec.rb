require 'spec_helper'

class GitWorkflow::Commands::Finish
  public :merge_story_into!
end

describe GitWorkflow::Commands::Finish do
  before(:each) do
    @command = described_class.new([ 'story_id', 'target_branch' ])
  end

  describe '#merge_story_into!' do
    it_should_behave_like 'it needs a working Story'

    it 'does the default merge into the branch' do
      @story.stub!(:branch_name).and_return('my_branch')
      @command.should_receive(:merge_branch).with('my_branch', 'master')

      @command.merge_story_into!(@story, 'master')
    end
  end
end
