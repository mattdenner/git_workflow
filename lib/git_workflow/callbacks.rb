require 'git_workflow/callbacks/test_code_support'
require 'git_workflow/callbacks/remote_git_branch_support'

# Automatically load the callbacks associated with the current settings
require 'git_workflow/configuration'
callbacks = GitWorkflow::Configuration.get_config_value_for('workflow.callbacks')
require "git_workflow/callbacks/styles/#{ callbacks }" unless callbacks.blank?
