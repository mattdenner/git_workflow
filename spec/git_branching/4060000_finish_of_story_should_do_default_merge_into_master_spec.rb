require 'spec_helper'

describe GitWorkflow::Story do
  describe '#merge_into!' do
    it_should_behave_like 'it needs a working Story'

    it 'does the default merge into the branch' do
      @story.stub!(:branch_name).and_return('my_branch')
      @story.should_receive(:execute_command).with('git checkout master')
      @story.should_receive(:execute_command).with('git merge my_branch')

      @story.merge_into!('master')
    end
  end
end
