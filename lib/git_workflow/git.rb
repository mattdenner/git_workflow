require 'singleton'
require 'git_workflow/core_ext'

module GitWorkflow
  module Git
    class Repository
      include Singleton
      include Execution
      include GitWorkflow::Logging

      RepositoryError = Class.new(StandardError)
      BranchError     = Class.new(RepositoryError)
      CheckoutError   = Class.new(RepositoryError)
      ConfigError     = Class.new(RepositoryError)

      def current_branch
        return @current_branch unless @current_branch.nil?

        match = execute_command('git branch').match(/\*\s+([^\s]+)/)
        raise BranchError, 'Could not determine current branch' if match.nil?
        @current_branch = match[ 1 ]
      end

      def checkout(branch)
        maintain_current_branch(branch) do
          begin
            info("Checking out branch '#{ branch }'") do
              execute_command("git checkout #{ branch }")
            end
          rescue Execution::CommandFailure => exception
            raise CheckoutError, "Unable to checkout branch '#{ branch }'"
          end
        end
      end

      def create(branch, source = nil)
        maintain_current_branch(branch) do
          begin
            info("Creating branch '#{ branch }'") do
              command = "git checkout -b #{ branch }"
              command << " #{ source }" unless source.nil?
              execute_command(command)
            end
          rescue Execution::CommandFailure => exception
            raise CheckoutError, "Unable to create branch '#{ branch }'"
          end
        end
      end

      def merge(branch)
        execute_command("git merge #{ branch }")
      rescue Execution::CommandFailure => exception
        raise BranchError, "Could not merge #{ branch } into current branch"
      end

      def branches
        execute_command('git branch').split("\n").map { |b| b.sub(/^(\*)?\s+/, '') }
      end

      def does_branch_exist?(branch)
        execute_command('git branch') =~ /\s+#{ branch }(\s+|$)/
      end

      def config_get(key)
        value = execute_command("git config #{ key }").strip
        value.empty? ? nil : value
      rescue Execution::CommandFailure => exception
        raise ConfigError, "Could not retrieve '#{ key }' configuration setting"
      end

      def config_set(key, value)
        raise ConfigError, 'No key has been specified for configuration setting' if key.blank?
        execute_command(%Q{git config '#{ key }' "#{ value }"})
      rescue Execution::CommandFailure => exception
        raise ConfigError, "Could not set '#{ key }' configuration setting (value: #{ value })"
      end

      def push(branch)
        execute_command("git push origin #{ branch }")
      rescue Execution::CommandFailure => exception
        raise BranchError, "Unable to push branch '#{ branch }'"
      end

    private

      def maintain_current_branch(branch, &block)
        yield
        @current_branch = branch
      end
    end

    def repository
      Repository.instance
    end

    def in_git_branch(target_branch, &block)
      current_branch = repository.current_branch
      if current_branch == target_branch
        yield
      else
        info("Temporarily switching to branch '#{ target_branch }'")

        repository.checkout(target_branch)
        yield
        repository.checkout(current_branch)

        info("Switched back to '#{ current_branch }'")
      end
    end

    def merge_branch(source_branch, target_branch)
      info("Merging branch '#{ source_branch }' into '#{ target_branch }'") do
        repository.checkout(target_branch)
        repository.merge(source_branch)
      end
    end

    def checkout_or_create_branch(branch, source = nil)
      if repository.does_branch_exist?(branch)
        repository.checkout(branch)
      else
        repository.create(branch, source)
      end
    end

    def get_config_value_for(key, default = nil)
      repository.config_get(key)
    rescue Repository::ConfigError => exception
      default
    end

    def get_config_value_for!(key)
      get_config_value_for(key) or raise StandardError, "Required configuration setting '#{ key }' is unset"
    end

    def set_config_value(key, value)
      repository.config_set(key, value)
    end
  end
end
