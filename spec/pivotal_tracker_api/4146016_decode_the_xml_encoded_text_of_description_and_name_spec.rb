require 'spec_helper'

class GitWorkflow::Story
  attr_reader :story_type
end

describe GitWorkflow::Story do
  describe '#load_story!' do
    context 'basic behaviour' do
      before(:each) do
        @elements = {
          :story_type  => 'Story Type',
          :name        => 'Name',
          :id          => 10,
          :description => 'Story Description'
        }

        xml = Builder::XmlMarkup.new
        xml.story { @elements.each { |e,v| xml.tag!(e, v.to_s) } }

        service = mock('PT Service')
        service.should_receive(:get).and_return(xml.target)

        @story = described_class.new(service)
      end

      it 'properly sets story_id' do
        @story.story_id.should == @elements[ :id ]
      end

      [ :story_type, :name, :description ].each do |attribute|
        it "properly sets #{ attribute }" do
          @story.send(attribute).should == @elements[ attribute ]
        end
      end
    end

    context 'encoded characters' do
      before(:each) do
        xml = Builder::XmlMarkup.new
        xml.story {
          xml.story_type('something')
          xml.id('10')
          xml.name('The name & something important')
          xml.description('The description & something important')
        }

        service = mock('PT Service')
        service.should_receive(:get).and_return(xml.target)

        @story = described_class.new(service)
      end

      it 'decodes the name' do
        @story.name.should == 'The name & something important'
      end

      it 'decodes the description' do
        @story.description.should == 'The description & something important'
      end
    end
  end
end
