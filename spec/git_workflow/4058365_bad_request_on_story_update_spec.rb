require 'spec_helper'

describe GitWorkflow do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:owner_email).and_return('owner email')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#service!' do
    it 'generates valid XML' do
      @service.should_receive(:put).with('<story><owned_by>owner email</owned_by></story>', anything)
      @story.service!
    end
  end
end
