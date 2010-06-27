require 'spec_helper'

describe GitWorkflow::Story do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:username).and_return('username')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#merge_into!' do
    it 'does the default merge into the branch' do
      @story.stub!(:branch_name).and_return('my_branch')
      @story.should_receive(:execute_command).with('git checkout master')
      @story.should_receive(:execute_command).with('git merge my_branch')

      @story.merge_into!('master')
    end
  end
end
