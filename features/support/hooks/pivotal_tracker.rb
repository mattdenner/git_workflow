require 'sinatra'
require 'sinatra_webservice'
require 'ostruct'
require 'nokogiri'
require 'builder'

class SinatraWebService::SinatraStem
  get '/services/v3/projects/:project_id/stories/:story_id' do |_, story_id|
    handle_story(story_id) do |story|
      xml = Builder::XmlMarkup.new(:indent => 2)
      xml.instruct!
      xml.story {
        xml.id(story.story_id, :type => 'integer')
        [ :story_type, :current_state, :name, :owned_by, :description ].each do |element|
          xml.tag!(element, story.send(element))
        end
      }
      xml.to_s
    end
  end

  put '/services/v3/projects/:project_id/stories/:story_id' do |_, story_id|
    handle_story(story_id) do |story|
      Nokogiri::XML(request.body.read).xpath('/story/*').each do |element|
        story.send(:"#{ element.name }=", element.content)
      end
    end
  end

  def handle_story(id, &block)
    self.class.handle_story(id, &block)
  end

  class << self
    def stories
      @stories ||= {}
    end

    def handle_story(id, &block)
      story = stories[ id ] or raise StandardError, "Story #{ id } does not appear to exist"
      yield(story)
    end

    def reset_stories!
      @stories = {}
    end

    def create_story(id)
      raise StandardError, "Story #{ id } already exists" unless stories[ id ].nil?
      stories[ id ] = story = OpenStruct.new(
        :story_id       => id, 
        :story_type     => 'feature', 
        :current_state  => 'not yet started', 
        :owned_by       => '',
        :name           => ''
      )
    end

    def for_story(id, &block)
      story = stories[ id ] or raise StandardError, "Story #{ id } is undefined"
      yield(story)
    end
  end
end

class PivotalTrackerService < SinatraWebService
  attr_writer :project_id

  def initialize(*args, &block)
    super
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

mock_service = PivotalTrackerService.new(:host => 'localhost', :port => 7000)
mock_service.run!
self.class.instance_eval do
  define_method(:mock_service) { mock_service }
end
eval <<-END_OF_WORLD_HOOKS
  def create_story(id)
    SinatraWebService::SinatraStem.create_story(id)
  end

  def for_story(id, &block)
    SinatraWebService::SinatraStem.for_story(id, &block)
  end
END_OF_WORLD_HOOKS

# This ensures that we have a behaviour similar to that of Pivotal Tracker.
Before('@needs_service') do
  @_http_proxy_before = ENV['http_proxy']
  ENV['http_proxy']   = 'http://localhost:7000/'
end

After('@needs_service') do
  ENV['http_proxy'] = @_http_proxy_before

  SinatraWebService::SinatraStem.reset_stories!
end

