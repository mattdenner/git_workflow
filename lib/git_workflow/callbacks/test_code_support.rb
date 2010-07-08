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
        execute_command_with_output_handling([ 'rake', *rake_test_tasks ].join(' ')) do |stdout, stderr, _|
          $stdout.print(stdout.read(1)) until stdout.eof?
          $stderr.print(stderr.read(1)) until stderr.eof?
        end
        return true
      rescue Execution::CommandFailure => exception
        return false
      end

      def spawn_shell_for_recovery
        # TODO: spawn a shell with a message
        # TODO: if the exit is complete failure return false
        return false
      end
    end
  end
end
