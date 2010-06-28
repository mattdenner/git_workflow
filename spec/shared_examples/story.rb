shared_examples_for 'it needs a working Story' do
  before(:each) do
    @service = mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')

    @story = GitWorkflow::Story.new(@service)
  end
end

