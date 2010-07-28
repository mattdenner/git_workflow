# Automatically load the callbacks associated with the current settings
module GitWorkflow
  module Callbacks
    module Loader
      extend GitWorkflow::Git
      extend GitWorkflow::Logging::ClassMethods

      callbacks = get_config_value_for('workflow.callbacks', 'default')
      log(:info, "Loading the '#{ callbacks }' hooks") do
        callback_name = "git_workflow/callbacks/styles/#{ callbacks }"
        require callback_name
        callback_name.constantize.setup
      end
    end
  end
end
