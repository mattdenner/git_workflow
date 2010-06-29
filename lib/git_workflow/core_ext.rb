class Class
  def delegates_to_class(method)
    class_eval do
      linenumber = __LINE__ + 1
      eval(%Q{
        def #{ method }(*args, &block)
          self.class.#{ method }(*args, &block)
        end
      }, binding, __FILE__, linenumber)
    end
  end
end

module Execution
  def execute_command(command)
    rc = IO.popen(command) { |pipe| pipe.read }
    raise StandardError, "Command '#{ command }' failed" unless $?.exitstatus == 0
    rc
  end
end
