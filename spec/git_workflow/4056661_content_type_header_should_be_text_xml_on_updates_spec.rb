require 'spec_helper'

class GitWorkflow::Story
  public :service!
end

describe GitWorkflow::Story do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
  end

  context 'after initialization' do
    before(:each) do
      @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    end

    describe '#service!' do
      before(:each) do
        @owner.stub!(:owner_email).and_return('owner email')
        @story = GitWorkflow::Story.new(@owner, @service)
      end

      it 'sets the "Content-Type" header to "text/xml"' do
        @service.should_receive(:put).with(anything, hash_including(:content_type => 'text/xml'))
        @story.service!
      end
    end
  end
end
