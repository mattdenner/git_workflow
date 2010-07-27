require 'spec_helper'

describe Execution do
  before(:each) do
    @executor = Class.new
    @executor.send(:extend, Execution)
    @executor.stub(:debug).with(anything).and_yield
  end

  before(:each) do
    @stdin, @stdout, @stderr = mock('stdin'), mock('stdout'), mock('stderr')
    @outputs = [ @stdout, @stderr, @stdin ]
  end

  describe '#execute_command' do
    it 'returns the output from the command' do
      @stdout.should_receive(:read).and_return('Hello World')
      @executor.should_receive(:execute_command_with_output_handling).with(:command).and_yield(*@outputs)
      @executor.execute_command(:command).should == 'Hello World'
    end
  end

  describe '#execute_command_with_output_handling' do
    it 'does not raise if the command succeeds' do
      @executor.execute_command_with_output_handling('sh -c "exit 0"') { |*args| }
    end

    it 'raises if the command fails' do
      lambda do
        @executor.execute_command_with_output_handling('sh -c "exit 1"') { |*args| }
      end.should raise_error(Execution::CommandFailure)
    end
  end
end
