require 'rest_client'
require 'builder'

# On MacOSX systems you can have a dodgy LibXML2 which Nokogiri warns about.  Hide this warning
# by setting the following constant:
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true
require 'nokogiri'

class GitWorkflow
  include Logging

  def load_story_from_pivotal_tracker
    Story.new(pivotal_tracker_service)
  end

  def pivotal_tracker_service
    self.class.enable_http_proxy_if_present
    url = self.class.pivotal_tracker_url_for(Configuration.instance.project_id, @story_id)

    debug("Using PT URL '#{ url }'")
    RestClient::Resource.new(
      url,
      :headers => { 'X-TrackerToken' => Configuration.instance.api_token }
    )
  end

  def self.value_of_environment_variable(key)
    ENV[key]
  end

  def self.enable_http_proxy_if_present
    proxy   = value_of_environment_variable('http_proxy')
    proxy ||= value_of_environment_variable('HTTP_PROXY')
    unless proxy.nil?
      debug("Enabling HTTP proxy '#{ proxy }'")
      RestClient.proxy = proxy 
    end
  end

  def self.pivotal_tracker_url_for(project_id, story_id)
    "http://www.pivotaltracker.com/services/v3/projects/#{ project_id }/stories/#{ story_id }"
  end
  
  class Story
    include Execution
    include Logging

    attr_reader :story_id
    attr_reader :name
    attr_reader :description

    def initialize(service)
      @service = service
      load_story!
    end

    def branch_name
      @branch_name ||= GitWorkflow::Configuration.instance.local_branch_convention.to(self)
    end
    
    def create_branch!(source = nil)
      info("Creating branch '#{ self.branch_name }'") do
        command = 'git checkout'
        command << ' -b' unless branch_already_exists?
        command << " #{ self.branch_name }"
        command << " #{ source }" unless source.nil?
        execute_command(command)
      end
    end

    def branch_already_exists?
      GitWorkflow::Configuration.instance.branches.find { |name,_| name == self.branch_name }
    end

    def merge_into!(branch)
      info("Merging '#{ self.branch_name }' into '#{ branch }'") do
        execute_command("git checkout #{ branch }")
        execute_command("git merge #{ self.branch_name }")
      end
    end

    def started!
      info("Marking story #{ self.story_id } as started") do
        service! do |xml|
          xml.current_state('started')
        end
      end
    end

    def finished!
      info("Marking story #{ self.story_id } as finished") do
        service! do |xml|
          xml.current_state(@story_type == 'chore' ? 'accepted' : 'finished')
        end
      end
    end

  private

    def load_story!
      info("Retrieving story information") do
        xml          = Nokogiri::XML(@service.get)
        @story_type  = xml.xpath('/story/story_type/text()').to_s
        @name        = xml.xpath('/story/name/text()').to_s
        @story_id    = xml.xpath('/story/id/text()').to_s.to_i
        @description = xml.xpath('/story/description/text()').to_s
      end
    end

    def service!(&block)
      xml = Builder::XmlMarkup.new
      xml.story {
        xml.owned_by(GitWorkflow::Configuration.instance.username)
        yield(xml) if block_given?
      }
      @service.put(xml.target!, :content_type => 'application/xml')
    rescue RestClient::ExceptionWithResponse => exception
      error('Cannot seem to perform operation with PT:')
      error(exception.response)
      raise
    end
  end
end
