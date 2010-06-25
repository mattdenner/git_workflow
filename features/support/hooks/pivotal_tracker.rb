require 'sinatra'
require 'sinatra_webservice'

class PivotalTrackerService < SinatraWebService
  attr_accessor :project_id

  def initialize(*args, &block)
    super
    @project_id = 'XXXX'
  end

  def run!
    super
    wait_for_sinatra_to_startup! 
  end

private

  # We have to pause execution until Sinatra has come up.  This makes a number of attempts to
  # retrieve the root document.  If it runs out of attempts it raises an exception
  def wait_for_sinatra_to_startup!
    (1..10).each do |_|
      begin
        Net::HTTP.get(URI.parse('http://localhost:7000/'))
        return
      rescue Errno::ECONNREFUSED => exception
        sleep(1)
      end
    end

    raise StandardError, "Our dummy webservice did not start up in time!"
  end
end

# This ensures that we have a behaviour similar to that of Pivotal Tracker.
Before('@needs_service') do
  @stories = {}
  @service = PivotalTrackerService.new(:host => 'localhost', :port => 7000)
  @service.run!
end

def mock_service
  @service
end

require 'ostruct'
require 'nokogiri'
require 'builder'

def create_story(id)
  raise StandardError, "Story #{ id } already exists" unless @stories[ id ].nil?
  @stories[ id ] = story = OpenStruct.new(
    :story_id       => id, 
    :story_type     => 'feature', 
    :current_state  => 'not yet started', 
    :owned_by       => '',
    :name           => ''
  )
  @service.get "/services/v3/projects/#{ @service.project_id }/stories/#{ id }" do
    xml = Builder::XmlMarkup.new(:indent => 2)
    xml.instruct!
    xml.story {
      xml.id(story.story_id, :type => 'integer')
      [ :story_type, :current_state, :name, :owned_by ].each do |element|
        xml.tag!(element, story.send(element))
      end
    }
    xml.to_s
  end
  @service.put "/services/v3/projects/#{ @service.project_id }/stories/#{ id }" do
    Nokogiri::XML(request.body.read).xpath('/story/*').each do |element|
      story.send(:"#{ element.name }=", element.content)
    end
  end
end

def for_story(id, &block)
  story = @stories[ id ] or raise StandardError, "Story #{ id } is undefined"
  yield(story)
end
