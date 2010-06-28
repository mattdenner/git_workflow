require 'spec_helper'

class GitWorkflow::Story
  attr_writer :name
end

describe GitWorkflow::Story do
  before(:each) do
    @owner, @service = mock('owner'), mock('service')
    @service.stub!(:get).and_return('<story><name>name</name><id type="integer">1</id></story>')
    @owner.stub!(:username).and_return('username')

    @story = GitWorkflow::Story.new(@owner, @service)
  end

  describe '#branch_name' do
    it 'delegates to the local branch convention' do
      configuration, convention = mock('configuration'), mock('convention')
      configuration.should_receive(:local_branch_convention).and_return(convention)
      convention.should_receive(:to).with(@story).and_return(:ok)
      GitWorkflow::Configuration.stub!(:instance).and_return(configuration)

      @story.branch_name.should == :ok
    end
  end
end

describe GitWorkflow::Configuration::Convention do 
  describe '#to' do
    before(:each) do
      @convention = described_class.new('${story.story_id}_${story.story_name}')
    end

    after(:each) do
      @convention.to(OpenStruct.new(:story_id => 12345, :name => @name)).should_not match(/_+$/)
    end

    it 'does not end in underscore with invalid character at the end' do
      @name = 'ends in invalid character!'
    end

    it 'does not end in multiple underscores' do
      @name = 'ends in invalid characters!!!!!!!'
    end
  end
end
