module GitWorkflow
  module Callbacks
    module PivotalTrackerSupport
      def self.included(base)
        base.extend(ClassMethods)
      end

    protected

      def story(id, &block)
        yield(GitWorkflow::Story.new(pivotal_tracker_service_for(id)))
      end

    private

      def pivotal_tracker_service_for(story_id)
        self.class.enable_http_proxy_if_present
        url = self.class.pivotal_tracker_url_for(Configuration.instance.project_id, story_id)

        debug("Using PT URL '#{ url }'")
        RestClient::Resource.new(
          url,
          :headers => { 'X-TrackerToken' => Configuration.instance.api_token }
        )
      end

      def start_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as started") do
          story.service! do |xml|
            xml.current_state(story.start_state)
          end
        end
      end

      def finish_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as finished") do
          story.service! do |xml|
            xml.current_state(story.finish_state)
          end
        end
      end

      module ClassMethods
        def value_of_environment_variable(key)
          ENV[key]
        end

        def enable_http_proxy_if_present
          proxy   = value_of_environment_variable('http_proxy')
          proxy ||= value_of_environment_variable('HTTP_PROXY')
          unless proxy.nil?
            debug("Enabling HTTP proxy '#{ proxy }'")
            RestClient.proxy = proxy 
          end
        end

        def pivotal_tracker_url_for(project_id, story_id)
          "http://www.pivotaltracker.com/services/v3/projects/#{ project_id }/stories/#{ story_id }"
        end
      end

    end
  end
end
