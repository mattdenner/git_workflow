require 'rest_client'
require 'builder'

# On MacOSX systems you can have a dodgy LibXML2 which Nokogiri warns about.  Hide this warning
# by setting the following constant:
I_KNOW_I_AM_USING_AN_OLD_AND_BUGGY_VERSION_OF_LIBXML2 = true
require 'nokogiri'

module GitWorkflow
  class Story
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

    def start_state
      'started'
    end

    def finish_state
      @story_type == 'chore' ? 'accepted' : 'finished'
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
  end
end
