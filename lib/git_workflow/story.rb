require 'rest_client'
require 'nokogiri'
require 'builder'

class GitWorkflow
  def load_story_from_pivotal_tracker
    Story.new(pivotal_tracker_service)
  end

  def pivotal_tracker_service
    self.class.enable_http_proxy_if_present
    RestClient::Resource.new(
      self.class.pivotal_tracker_url_for(Configuration.instance.project_id, @story_id),
      :headers => { 'X-TrackerToken' => Configuration.instance.api_token }
    )
  end

  def self.value_of_environment_variable(key)
    ENV[key]
  end

  def self.enable_http_proxy_if_present
    proxy   = value_of_environment_variable('http_proxy')
    proxy ||= value_of_environment_variable('HTTP_PROXY')
    RestClient.proxy = proxy unless proxy.nil?
  end

  def self.pivotal_tracker_url_for(project_id, story_id)
    "http://www.pivotaltracker.com/services/v3/projects/#{ project_id }/stories/#{ story_id }"
  end
  
  class Story
    include Execution

    attr_reader :story_id
    attr_reader :name

    def initialize(service)
      @service = service
      load_story!
    end

    def branch_name
      @branch_name ||= GitWorkflow::Configuration.instance.local_branch_convention.to(self)
    end
    
    def create_branch!
      command = 'git checkout '
      command << '-b ' unless branch_already_exists?
      command << self.branch_name
      execute_command(command)
    end

    def branch_already_exists?
      GitWorkflow::Configuration.instance.branches.find { |name,_| name == self.branch_name }
    end

    def merge_into!(branch)
      execute_command("git checkout #{ branch }")
      execute_command("git merge #{ self.branch_name }")
    end

    def started!
      service! do |xml|
        xml.current_state('started')
      end
    end

    def finished!
      service! do |xml|
        xml.current_state('finished')
      end
    end

  private

    def load_story!
      xml       = Nokogiri::XML(@service.get)
      @name     = xml.xpath('/story/name/text()').to_s
      @story_id = xml.xpath('/story/id/text()').to_s.to_i
    end

    def service!(&block)
      xml = Builder::XmlMarkup.new
      xml.story {
        xml.owned_by(GitWorkflow::Configuration.instance.username)
        yield(xml) if block_given?
      }
      @service.put(xml.target!, :content_type => 'application/xml')
    end
  end
end
