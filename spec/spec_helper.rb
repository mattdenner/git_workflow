require 'rubygems'
require 'git_workflow'

require 'shared_examples/configuration'
require 'shared_examples/story'

# Disable the logging output during tests
GitWorkflow::Logging.logger = logger = Logger.new(STDOUT)
logger.level = Logger::FATAL

# Just so that the test code doesn't fail
class GitWorkflow::Commands::Base
  def usage_info(options)
    options.banner = 'Usage: git something'
  end
end
