require 'git_workflow/core_ext'
require 'git_workflow/logging'
require 'git_workflow/configuration'
require 'git_workflow/git'
require 'git_workflow/story'
require 'git_workflow/command_line'
require 'rest_client'

module GitWorkflow
  module Commands
    class Base
      include Execution
      include GitWorkflow::Logging
      include GitWorkflow::Git
      include GitWorkflow::CommandLine

      def initialize(command_line_arguments, &block)
        parse_command_line(command_line_arguments, &block)
      end

      def command_specific_options(options)
        options.separator '    This command has no specific options'
      end
    end
  end
end
