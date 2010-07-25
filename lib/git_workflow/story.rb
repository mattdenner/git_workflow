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
      @local_branch_name ||= GitWorkflow::Configuration.instance.local_branch_convention.to(self)
    end

    def remote_branch_name
      @remote_branch_name ||= GitWorkflow::Configuration.instance.remote_branch_convention.to(self)
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

    class XmlWrapper
      def initialize(xml)
        @xml = Nokogiri::XML(xml)
      end

      def required!(element)
        value = optional(element)
        raise MissingElement, "Missing '#{ element }' in the PT XML" if value.blank?
        value
      end

      def optional(element)
        values = @xml.xpath("/story/#{ element }/text()")
        values.empty? ? nil : values.first.content
      end
    end

    def load_story!
      info("Retrieving story information") do
        xml          = XmlWrapper.new(@service.get)
        @story_id    = xml.required!(:id).to_i
        @story_type  = xml.required!(:story_type)
        @name        = xml.required!(:name)
        @description = xml.optional(:description)
      end
    end
  end
end
