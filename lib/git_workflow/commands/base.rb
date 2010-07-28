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
        
        # Such a hack!  This effectively the callbacks to only be loaded after the
        # command line arguments have been processed, injecting them into an already
        # instantiated command.  Really should refactor that!
        require 'git_workflow/callbacks'
      end

      def command_specific_options(options)
        options.separator '    This command has no specific options'
      end
    end
  end
end
