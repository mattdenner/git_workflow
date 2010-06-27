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
    after(:each) do
      @story.branch_name.should_not match(/_+$/)
    end

    it 'does not end in underscore with invalid character at the end' do
      @owner.should_receive(:branch_name_for).with(@story).and_return('ends in invalid character!')
    end

    it 'does not end in multiple underscores' do
      @owner.should_receive(:branch_name_for).with(@story).and_return('end in invalid characters!!!!!!')
    end
  end
end
