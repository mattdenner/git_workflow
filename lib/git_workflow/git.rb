require 'singleton'
require 'git_workflow/core_ext'

module GitWorkflow
  module Git
    class Repository
      include Singleton
      include Execution

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
            execute_command("git checkout #{ branch }")
          rescue Execution::CommandFailure => exception
            raise CheckoutError, "Unable to checkout branch '#{ branch }'"
          end
        end
      end

      def create(branch, source = nil)
        maintain_current_branch(branch) do
          begin
            command = "git checkout -b #{ branch }"
            command << " #{ source }" unless source.nil?
            execute_command(command)
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
      repository.checkout(target_branch) unless target_branch == current_branch
      yield
      repository.checkout(current_branch) unless target_branch == current_branch
    end

    def merge_branch(source_branch, target_branch)
      repository.checkout(target_branch)
      repository.merge(source_branch)
    end

    def checkout_or_create_branch(branch, source = nil)
      if repository.does_branch_exist?(branch)
        repository.checkout(branch)
      else
        repository.create(branch, source)
      end
    end

    def get_config_value_for(key)
      repository.config_get(key)
    rescue Repository::ConfigError => exception
      nil
    end

    def get_config_value_for!(key)
      get_config_value_for(key) or raise StandardError, "Required configuration setting '#{ key }' is unset"
    end
  end
end
