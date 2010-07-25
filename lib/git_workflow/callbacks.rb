# Automatically load the callbacks associated with the current settings
module GitWorkflow
  module Callbacks
    module Loader
      extend GitWorkflow::Git

      callbacks     = get_config_value_for('workflow.callbacks', 'default')
      callback_name = "git_workflow/callbacks/styles/#{ callbacks }"
      require callback_name
      callback_name.constantize.setup
    end
  end
end
