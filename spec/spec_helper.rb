require 'rubygems'
require 'git_workflow'

require 'shared_examples/configuration'
require 'shared_examples/story'

# Disable the logging output during tests
GitWorkflow.logger = GitWorkflow::Story.logger = logger = Logger.new(STDOUT)
logger.level = Logger::FATAL
