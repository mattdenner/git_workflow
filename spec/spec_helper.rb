require 'rubygems'
require 'git_workflow'

require 'shared_examples/configuration'
require 'shared_examples/story'

# Disable the logging output during tests
require 'log4r'
GitWorkflow::Logging.logger = logger = Log4r::Logger.new('test logger')
logger.outputters = Log4r::Outputter.stdout
logger.level      = Log4r::FATAL

# Just so that the test code doesn't fail
class GitWorkflow::Commands::Base
  def usage_info(options)
    options.banner = 'Usage: git something'
  end
end
