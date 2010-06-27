require 'spec_helper'

class GitWorkflow::Story
  public :service!
end

describe GitWorkflow::Story do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:username).and_return('username')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#service!' do
    it 'sets the "Content-Type" header to "text/xml"' do
      @service.should_receive(:put).with(anything, hash_including(:content_type => 'application/xml'))
      @story.service!
    end
  end
end
