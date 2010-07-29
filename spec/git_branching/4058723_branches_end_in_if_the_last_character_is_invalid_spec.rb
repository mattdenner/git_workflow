require 'spec_helper'

class GitWorkflow::Story
  attr_writer :name
end

describe GitWorkflow::Story do
  describe '#branch_name' do
    it_should_behave_like 'it needs a working Story'

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
      @convention = described_class.new('${number}_${name}')
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
