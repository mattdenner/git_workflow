require 'rest_client'
require 'nokogiri'
require 'builder'

class GitWorkflow
  def self.story(id, &block)
    GitWorkflow.new(id).execute(&block)
  end

  def initialize(id)
    @story_id = id
    load_configuration
  end

  def execute(&block)
    yield(load_story_from_pivotal_tracker)
  end

private

  def load_configuration
    @owner_email = %x{git config 'pt.email'}.strip
    @project_id  = %x{git config 'pt.projectid'}.strip
  end

  def load_story_from_pivotal_tracker
    Story.new(
      StorySupportInterface.new(self),
      RestClient::Resource.new("http://localhost:7000/services/v3/projects/#{ @project_id }/stories/#{ @story_id }")
    )
  end

  class StorySupportInterface
    def self.attr_reader_in_workflow(name)
      define_method(:"#{ name }") { @workflow.instance_variable_get("@#{ name }") }
    end

    def initialize(workflow)
      @workflow = workflow
    end

    attr_reader_in_workflow(:owner_email)
    attr_reader_in_workflow(:project_id)
  end
  
  class Story
    def initialize(owner, service)
      @owner, @service = owner, service
      load_story!
    end

    def branch_name
      "#{ @story_id }_#{ @name.downcase.gsub(/[^a-z0-9]+/, '_') }"
    end
    
    def create_branch!
      %x{git checkout -b #{ self.branch_name }}
    end

    def merge_into!(branch)
      %x{git checkout #{ branch }}
      %x{git merge --no-ff #{ self.branch_name }}
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
        xml.owned_by(@owner.owner_email)
        yield(xml)
      }
      @service.put(xml.to_s)
    end
  end
end
