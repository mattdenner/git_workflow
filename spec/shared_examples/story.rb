shared_examples_for 'it needs a working Story' do
  before(:each) do
    xml = Builder::XmlMarkup.new
    xml.story {
      xml.name('name')
      xml.id('1', :type => 'integer')
      xml.description('description')
      xml.story_type('story_type')
    }

    @service = mock('service')
    @service.stub!(:get).and_return(xml.target)

    @story = GitWorkflow::Story.new(@service)
  end
end

