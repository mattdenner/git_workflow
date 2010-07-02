require 'logger'

class GitWorkflow
  module Logging
    def self.included(base)
      base.instance_eval do
        extend ClassMethods

        [ :debug, :info ].each do |level|
          class_eval <<-END_OF_LOGGING_METHOD
            def #{ level }(message, &block)
              self.class.#{ level }(message, &block)
            end

            def self.#{ level }(message, &block)
              self.log(#{ level.inspect }, message, &block)
            end
          END_OF_LOGGING_METHOD
        end
      end
    end

    module ClassMethods
      def logger=(logger)
        @logger = logger
      end

      def logger
        @logger ||= default_logger
      end

      def default_logger
        logger = Logger.new(STDOUT)
        logger.level = Logger::INFO
        logger
      end

      def log(level, message, &block)
        if block_given?
          begin
            logger.send(level, "(start): #{ message }")
            rc = yield
            logger.send(level, "(finish): #{ message }")
            rc
          rescue => exception
            logger.error("#{ message } (#{ exception.message })")
            raise
          end
        else
          logger.send(level, message)
        end
      end
    end
  end
end
