require 'git_workflow/commands/start'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Debug
        def self.setup(start_command = GitWorkflow::Commands::Start, finish_command = GitWorkflow::Commands::Finish)
          start_command.instance_eval do
            extend GitWorkflow::Callbacks::Styles::Debug
            debug_method(:create_branch_for_story!)
            debug_method(:start_story_on_pivotal_tracker!)
          end

          finish_command.instance_eval do
            extend GitWorkflow::Callbacks::Styles::Debug
            debug_method(:merge_story_into!)
            debug_method(:finish_story_on_pivotal_tracker!)
          end

          require 'git_workflow/logging'
          GitWorkflow::Logging.logger.level = Logger::DEBUG
        end

        def debug_method(method)
          chain_methods(method, :debug) do |with_chain_method, without_chain_method|
            class_eval <<-END_OF_DEBUG_METHOD
              def #{ with_chain_method }(*args, &block)
                debug("#{ method }(\#{ args.map(&:inspect).join(',') })") do
                  #{ without_chain_method }(*args, &block)
                end
              end
            END_OF_DEBUG_METHOD
          end
          alias_method_chain(method, :debug)
        end
      end
    end
  end
end
