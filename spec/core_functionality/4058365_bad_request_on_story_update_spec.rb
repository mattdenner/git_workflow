require 'spec_helper'

describe GitWorkflow do
  it_should_behave_like 'it needs configuration'
  it_should_behave_like 'it needs a working Story'

  describe '#service!' do
    it 'generates valid XML' do
      @service.should_receive(:put).with('<story><owned_by>username</owned_by></story>', anything)
      @story.service!
    end
  end
end
