require 'spec_helper'

class GitWorkflow
  attr_reader :local_branch_convention
end

describe GitWorkflow do
  describe '#load_configuration' do
    it_should_behave_like 'it needs configuration'

    it 'gets the workflow.localbranchconvention setting' do
      described_class.new('story_id').local_branch_convention.should == 'convention'
    end
  end
end
