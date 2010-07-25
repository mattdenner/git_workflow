require 'git_workflow/callbacks/styles/default'
require 'git_workflow/callbacks/pivotal_tracker_support'
require 'git_workflow/commands/start'
require 'git_workflow/commands/finish'

module GitWorkflow
  module Callbacks
    module Styles
      module Debug
        def self.setup(start_command = GitWorkflow::Commands::Start, finish_command = GitWorkflow::Commands::Finish)
          Default.setup(start_command, finish_command)

          start_command.send(:include, StartBehaviour)
          finish_command.send(:include, FinishBehaviour)

          require 'git_workflow/logging'
          GitWorkflow::Logging.logger.level = Logger::DEBUG
        end

        module StartBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
              extend GitWorkflow::Callbacks::Styles::Debug
              debug_method(:start)
              debug_method(:start_story_on_pivotal_tracker!)
            end
          end
        end

        module FinishBehaviour
          def self.included(base)
            base.instance_eval do
              include GitWorkflow::Callbacks::PivotalTrackerSupport
              extend GitWorkflow::Callbacks::Styles::Debug
              debug_method(:finish)
              debug_method(:finish_story_on_pivotal_tracker!)
            end
          end
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
