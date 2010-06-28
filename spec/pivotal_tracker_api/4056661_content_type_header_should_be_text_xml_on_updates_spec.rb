require 'spec_helper'

class GitWorkflow::Story
  public :service!
end

describe GitWorkflow::Story do
  describe '#service!' do
    it_should_behave_like 'it needs a working Story'

    it 'sets the "Content-Type" header to "text/xml"' do
      @service.should_receive(:put).with(anything, hash_including(:content_type => 'application/xml'))
      @story.service!
    end
  end
end
