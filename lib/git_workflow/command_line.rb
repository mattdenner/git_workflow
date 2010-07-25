require 'optparse'

module GitWorkflow
  module CommandLine
    InvalidCommandLine = Class.new(StandardError)

  private

    def parse_command_line(command_line_arguments, &block)
      parser = create_parser
      parser.parse!(command_line_arguments)
      yield(command_line_arguments)
    rescue InvalidCommandLine => exception
      puts parser
      exit 1
    end

    def create_parser
      ::OptionParser.new do |options|
        usage_info(options)

        options.separator ''
        options.separator 'Common options:'

        options.on('-V', '--verbose') do
          GitWorkflow::Logging.logger.level = Logger::DEBUG
        end
        options.on('-h', '--help') do
          puts options
          exit
        end
        options.on('-v', '--version') do
          # TODO: get the version from the gem?
          exit
        end

        options.separator ''
        options.separator 'Command options:'

        command_specific_options(options)
      end
    end
  end
end
