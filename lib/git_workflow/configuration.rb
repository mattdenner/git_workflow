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
end
