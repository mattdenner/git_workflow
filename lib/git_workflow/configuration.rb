require 'singleton'
require 'git_workflow/git'

module GitWorkflow
  class Configuration
    include Singleton
    include GitWorkflow::Git

    class Convention
      include GitWorkflow::Git

      REGEXP_STORY_ID   = /\$\{\s*number\s*\}/
      REGEXP_EVALUATION = /\$\{(number|name)\}/

      def initialize(convention)
        raise StandardError, "Convention '#{ convention }' has no story ID" unless convention =~ REGEXP_STORY_ID
        @to_convention   = convention.gsub(REGEXP_EVALUATION, '#{\1}')
        @from_convention = Regexp.new(convention.sub(REGEXP_STORY_ID, '(\d+)').gsub(REGEXP_EVALUATION, '.+'))
      end

      def to(story)
        use_existing_branch_for(story) || generate_new_branch_name_for(story)
      end

      def from(branch)
        match = branch.match(@from_convention)
        raise StandardError, "Branch '#{ branch }' does not appear to conform to local convention" if match.nil?
        match[ 1 ].to_i
      end

    private

      def use_existing_branch_for(story)
        repository.branches.detect do |branch|
          begin
            from(branch) == story.story_id
          rescue StandardError => exception
            # Ignore, as this is definitely not the branch!
            false
          end
        end
      end

      def generate_new_branch_name_for(story)
        StoryWrapper.new(story).__instance_eval__(%Q{"#{ @to_convention }"}).downcase.gsub(/[^a-z0-9]+/, '_').sub(/_+$/, '')
      end

      class StoryWrapper
        alias_method :__instance_eval__, :instance_eval
        instance_methods.each do |method|
          undef_method(method) unless method.to_s =~ /^__(send|id|instance_eval)__$/
        end

        def initialize(story)
          @story = story
        end

        def number
          @story.story_id
        end

        def name
          @story.name
        end
      end

    end

    def username
      @username ||= get_config_value_for('pt.username') || get_config_value_for!('user.name')
    end

    def local_branch_convention
      @local_branch_convention ||= Convention.new(get_config_value_for!('workflow.localbranchconvention'))
    end

    def remote_branch_convention
      @remote_branch_convention ||= Convention.new(get_config_value_for!('workflow.remotebranchconvention'))
    end

    def project_id
      @project_id ||= get_config_value_for!('pt.projectid')
    end

    def api_token
      @api_token ||= get_config_value_for!('pt.token')
    end

    def ignore_git_global?
      ENV['IGNORE_GIT_GLOBAL']
    end
  end
end
