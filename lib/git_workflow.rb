require 'rest_client'
require 'nokogiri'
require 'builder'
require 'singleton'

module Execution
  def execute_command(command)
    %x{#{ command }}
  end
end

class Class
  def delegates_to_class(method)
    class_eval do
      linenumber = __LINE__ + 1
      eval(%Q{
        def #{ method }(*args, &block)
          self.class.#{ method }(*args, &block)
        end
      }, binding, __FILE__, linenumber)
    end
  end
end

class GitWorkflow
  extend Execution

  def self.story(id, &block)
    GitWorkflow.new(id).execute(&block)
  end

  def self.story_or_current_branch(id, &block)
    self.story(id || extract_story_from_branch(determine_current_branch), &block)
  end

  def initialize(id)
    @story_id = id or raise StandardError, "You have not specified a story ID"
    load_configuration
  end

  def execute(&block)
    yield(load_story_from_pivotal_tracker)
  end

private

  class Configuration
    include Singleton
    extend Execution

    class Convention
      REGEXP_STORY_ID   = /\$\{\s*story\.story_id\s*\}/
      REGEXP_EVALUATION = /\$\{([^\}]+)\}/

      def initialize(convention)
        raise StandardError, "Convention '#{ convention }' has no story ID" unless convention =~ REGEXP_STORY_ID
        @to_convention   = convention.gsub(REGEXP_EVALUATION, '#{\1}')
        @from_convention = Regexp.new(convention.sub(REGEXP_STORY_ID, '(\d+)').gsub(REGEXP_EVALUATION, '.+'))
      end

      def to(story)
        eval(%Q{"#{ @to_convention }"}, binding).downcase.gsub(/[^a-z0-9]+/, '_').sub(/_+$/, '')
      end

      def from(branch)
        match = branch.match(@from_convention)
        raise StandardError, "Branch '#{ branch }' does not appear to conform to local convention" if match.nil?
        match[ 1 ].to_i
      end
    end

    def username
      @username ||= get_config_value_for('pt.username') || get_config_value_for!('user.name')
    end

    def local_branch_convention
      @local_branch_convention ||= Convention.new(get_config_value_for!('workflow.localbranchconvention'))
    end

    def project_id
      @project_id ||= get_config_value_for!('pt.projectid')
    end

    def api_token
      @api_token ||= get_config_value_for!('pt.token')
    end

  private

    class << self
      def get_config_value_for(key)
        value = execute_command("git config #{ key }").strip
        value.empty? ? nil : value
      end

      def get_config_value_for!(key)
        get_config_value_for(key) or raise StandardError, "Required configuration setting '#{ key }' is unset"
      end
    end
    delegates_to_class(:get_config_value_for)
    delegates_to_class(:get_config_value_for!)
  end

  def self.determine_current_branch
    matches = execute_command('git branch').split("\n").grep(/^\* ([^\s]+)$/) { |branch| branch[2..-1] }
    raise StandardError, 'You do not appear to be on a working branch' if matches.empty?
    matches.first
  end

  def self.extract_story_from_branch(branch)
    Configuration.instance.local_branch_convention.from(branch)
  end

  def load_configuration
    @username                = Configuration.instance.username
    @project_id              = Configuration.instance.project_id
    @api_token               = Configuration.instance.api_token
    @local_branch_convention = Configuration.instance.local_branch_convention
  end

  def load_story_from_pivotal_tracker
    Story.new(StorySupportInterface.new(self), pivotal_tracker_service)
  end

  def pivotal_tracker_service
    self.class.enable_http_proxy_if_present
    RestClient::Resource.new(
      self.class.pivotal_tracker_url_for(@project_id, @story_id),
      :headers => { 'X-TrackerToken' => @api_token }
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

  class StorySupportInterface
    def self.attr_reader_in_workflow(name)
      define_method(:"#{ name }") { @workflow.instance_variable_get("@#{ name }") }
    end

    def initialize(workflow)
      @workflow = workflow
    end

    attr_reader_in_workflow(:username)
    attr_reader_in_workflow(:project_id)

    def branch_name_for(story)
      GitWorkflow::Configuration.instance.local_branch_convention.to(story)
    end
  end
  
  class Story
    include Execution

    attr_reader :story_id
    attr_reader :name

    def initialize(owner, service)
      @owner, @service = owner, service
      load_story!
    end

    def branch_name
      GitWorkflow::Configuration.instance.local_branch_convention.to(self)
    end
    
    def create_branch!
      execute_command("git checkout -b #{ self.branch_name }")
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
        xml.owned_by(@owner.username)
        yield(xml) if block_given?
      }
      @service.put(xml.target!, :content_type => 'application/xml')
    end
  end
end
