require 'spec_helper'

describe GitWorkflow do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:username).and_return('username')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#service!' do
    it 'generates valid XML' do
      @service.should_receive(:put).with('<story><owned_by>username</owned_by></story>', anything)
      @story.service!
    end
  end
end
