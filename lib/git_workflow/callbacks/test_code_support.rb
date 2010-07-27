module GitWorkflow
  module Callbacks
    module TestCodeSupport
      Failure = Class.new(StandardError)

      def run_tests!(*rake_test_tasks)
        run_tests(*rake_test_tasks) or raise Failure, 'The tests failed, please fix and try again'
      end

      def run_tests_with_recovery!(*rake_test_tasks)
        until run_tests(*rake_test_tasks)
          spawn_shell_for_recovery or raise Failure, 'The tests failed. Please fix and then "git push origin master"'
        end
      end

    private

      def run_tests(*rake_test_tasks)
        system('rake', *rake_test_tasks.map(&:to_s))
      end

      def spawn_shell_for_recovery
        # TODO: spawn a shell with a message
        # TODO: if the exit is complete failure return false
        return false
      end
    end
  end
end
