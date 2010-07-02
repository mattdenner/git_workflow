require 'logger'
require 'net/http'
require 'sinatra'
require 'ostruct'
require 'builder'

# Nokogiri doesn't like buggy LibXML2
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true
require 'nokogiri'

# This is a fix-up for sinatra so that we can silence the output.  It allows us to
# pass a Hash of options for webrick in the options passed to the #run! method.
class Sinatra::Base
  class << self
    def run!(options={})
      set options
      handler      = detect_rack_handler
      handler_name = handler.name.gsub(/.*::/, '')
      handler.run(self, { :Host => bind, :Port => port }.merge(options.fetch(:webrick, {}))) do |server|
        trap(:INT) do
          ## Use thins' hard #stop! if available, otherwise just #stop
          server.respond_to?(:stop!) ? server.stop! : server.stop
        end
        set :running, true
      end
    rescue Errno::EADDRINUSE => e
      puts "== Someone is already performing on port #{port}!"
    end
  end
end

class PivotalTrackerService 
  class MockService < Sinatra::Base
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

  attr_writer :project_id

  def initialize(host, port)
    @host, @port = host, port.to_i
  end

  def run!
    kill_previous_instance
    start_sinatra
    wait_for_sinatra_to_startup! 
  end

private

  def kill_previous_instance
    Thread.list.first.kill if Thread.list.size > 2
  end

  def start_sinatra
    Thread.new do
      # The effort you have to go through to silence Sinatra/WEBrick!
      logger       = Logger.new(STDERR)
      logger.level = Logger::FATAL

      MockService.run!(:host => @host, :port => @port, :webrick => { :Logger => logger, :AccessLog => [] })
    end
  end

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

mock_service = PivotalTrackerService.new('localhost', 7000)
mock_service.run!
self.class.instance_eval do
  define_method(:mock_service) { mock_service }
end
eval <<-END_OF_WORLD_HOOKS
  def create_story(id)
    PivotalTrackerService::MockService.create_story(id)
  end

  def for_story(id, &block)
    PivotalTrackerService::MockService.for_story(id, &block)
  end
END_OF_WORLD_HOOKS

# This ensures that we have a behaviour similar to that of Pivotal Tracker.
Before('@needs_service') do
  @_http_proxy_before = ENV['http_proxy']
  ENV['http_proxy']   = 'http://localhost:7000/'
end

After('@needs_service') do
  ENV['http_proxy'] = @_http_proxy_before

  PivotalTrackerService::MockService.reset_stories!
end

