require 'git_workflow/core_ext'
require 'git_workflow/logging'
require 'git_workflow/configuration'
require 'git_workflow/git'
require 'git_workflow/story'
require 'rest_client'

module GitWorkflow
  module Commands
    class Base
      include Execution
      include GitWorkflow::Logging
      include GitWorkflow::Git

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
    end
  end
end
