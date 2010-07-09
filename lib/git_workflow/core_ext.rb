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

class NilClass
  def blank?
    true
  end
end

class String
  def blank?
    self =~ /^\s*$/
  end

  def underscore
    self.split('::').map { |v| v.gsub(/(.)([A-Z])/, '\1_\2') }.join('/').downcase
  end

  def camelize
    self.split('/').map { |v| v.gsub(/(?:^|_)(.)/) { $1.upcase } }.join('::')
  end

  def constantize
    self.camelize.split('::').inject(Object) do |current,constant|
      current.const_get(constant) or current.const_missing(constant)
    end
  end
end

module Execution
  class CommandFailure < StandardError
    attr_reader :result

    def initialize(command, result)
      super("Command '#{ command }' failed")
      @result = result
    end

    def raise_if_required!
      raise self unless @result.exitstatus == 0
    end
  end

  def execute_command(command)
    rc = IO.popen(command) { |pipe| pipe.read }
    CommandFailure.new(command, $?).raise_if_required!
    rc
  end
end

class Module
  def chain_methods(method, chain, &block)
    match                  = method.to_s.match(/^([^!\?]+)([!\?])?$/) or raise StandardError, "Cannot match '#{ method }' as a method"
    method_core, extension = match[ 1 ], match[ 2 ]
    with_chain_method    = :"#{ method_core }_with_#{ chain }#{ extension }"
    without_chain_method = :"#{ method_core }_without_#{ chain }#{ extension }"
    yield(with_chain_method, without_chain_method)
  end

  def alias_method_chain(method, chain)
    chain_methods(method, chain) do |with_chain_method, without_chain_method|
      alias_method(without_chain_method, method)
      alias_method(method, with_chain_method)
    end
  end

  def unalias_method_chain(method, chain)
    chain_methods(method, chain) do |with_chain_method, without_chain_method|
      alias_method(method, without_chain_method)
      undef_method(without_chain_method)
    end
  end
end
