require 'spec_helper'

describe GitWorkflow::Logging::ClassMethods do
  before(:each) do
    @object = Class.new(Object).new
    @object.class.send(:include, GitWorkflow::Logging::ClassMethods)

    @logger        = mock('Logger')
    @object.logger = @logger
  end

  describe '#log' do
    it 'displays just the message and the level if no block given' do
      @logger.should_receive(:debug).with('my message')
      @object.log(:debug, 'my message')
    end

    it 'displays messages around the given block' do
      @logger.should_receive(:debug).with('(start): my message').once
      @logger.should_receive(:debug).with('(finish): my message').once

      callback = mock('callback')
      callback.should_receive(:called).and_return(:ok)
      
      @object.log(:debug, 'my message') do
        callback.called
      end.should == :ok
    end

    it 'displays errors when block raises' do
      @logger.should_receive(:debug).with('(start): my message').once
      @logger.should_receive(:error).with('my message (Broken)').once

      lambda do
        @object.log(:debug, 'my message') do
          raise StandardError, 'Broken'
        end
      end.should raise_error(StandardError)
    end
  end
end
