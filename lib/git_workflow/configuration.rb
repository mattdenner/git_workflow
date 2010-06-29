require 'singleton'

class GitWorkflow
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
        use_existing_branch_for(story) || generate_new_branch_name_for(story)
      end

      def from(branch)
        match = branch.match(@from_convention)
        raise StandardError, "Branch '#{ branch }' does not appear to conform to local convention" if match.nil?
        match[ 1 ].to_i
      end

    private

      def use_existing_branch_for(story)
        GitWorkflow::Configuration.instance.branches.each do |branch,active|
          begin
            return branch if from(branch) == story.story_id
          rescue StandardError => exception
            # Ignore, as this is definitely not the branch!
          end
        end
        nil
      end

      def generate_new_branch_name_for(story)
        eval(%Q{"#{ @to_convention }"}, binding).downcase.gsub(/[^a-z0-9]+/, '_').sub(/_+$/, '')
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

    def branches
      execute_command('git branch').split("\n").map do |branch_line|
        match = branch_line.match(/^(\*)?\s{1,2}([^\s]+)$/) or raise StandardError, "Can't match branch line '#{ branch_line }'"
        [ match[2], (match[1] && true) || false ]
      end
    end

    def active_branch
      active_details = branches.rassoc(true) or raise StandardError, 'You do not appear to be on a working branch'
      active_details.first
    end

  private

    class << self
      def get_config_value_for(key)
        value = execute_command("git config #{ key }").strip
        value.empty? ? nil : value
      rescue StandardError => exception
        nil
      end

      def get_config_value_for!(key)
        get_config_value_for(key) or raise StandardError, "Required configuration setting '#{ key }' is unset"
      end
    end
    delegates_to_class(:get_config_value_for)
    delegates_to_class(:get_config_value_for!)
    delegates_to_class(:execute_command)
  end
end
