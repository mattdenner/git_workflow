shared_examples_for 'it needs configuration' do
  before(:each) do
    configuration = mock('configuration')
    configuration.stub!(:username).and_return('username')
    configuration.stub!(:project_id).and_return('project_id')
    configuration.stub!(:api_token).and_return('api_token')
    configuration.stub!(:local_branch_convention).and_return('convention')
    GitWorkflow::Configuration.stub!(:instance).and_return(configuration)
  end
end
