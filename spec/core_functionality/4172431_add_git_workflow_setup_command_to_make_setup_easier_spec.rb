require 'spec_helper'

class GitWorkflow::Commands::Setup
  public :ask
  public :choose
  public :enquire_about_name
  public :enquire_about_token
  public :enquire_about_project_id
  public :enquire_about_workflow
  public :enquire_about_branches
  public :choose_branch_convention

  public :get_config_value_for
  public :set_config_value
end

describe GitWorkflow::Commands::Setup do
  before(:each) do
    @command, @highline = described_class.new([]), mock('HighLine')
    @command.stub(:highline).and_return(@highline)
  end

  describe '#execute' do
    it 'asks the right questions' do
      [ :name, :token, :project_id, :workflow, :branches ].each do |query|
        @command.should_receive(:"enquire_about_#{ query }").ordered
      end
      @command.execute
    end
  end

  [ :ask, :choose ].each do |delegating_method|
    describe "##{ delegating_method }" do
      it 'prompts through highline and sets the setting' do
        callback = mock('callback')
        callback.should_receive(:called)

        @highline.should_receive(delegating_method).with(:question).and_yield.and_return(:result)
        @command.should_receive(:set_config_value).with(:setting, :result)
        @command.send(delegating_method, :setting, :question) { callback.called }
      end
    end
  end

  describe '#enquire_about_name' do
    context 'asks for pt.username' do
      after(:each) do
        @command.should_receive(:ask).with('pt.username', anything)
        @command.enquire_about_name
      end

      it 'if the user.name is empty' do
        @command.should_receive(:get_config_value_for).with('user.name').and_return(nil)
      end

      it 'if the user wants to enter it' do
        @command.should_receive(:get_config_value_for).with('user.name').and_return('John Smith')
        @highline.should_receive(:agree).with(anything).and_return(false)
      end
    end

    it 'does not prompt for pt.username if the user wants to use user.name' do
      @command.should_receive(:get_config_value_for).with('user.name').and_return('John Smith')
      @highline.should_receive(:agree).with(/'John Smith'/).and_return(true)
      @command.enquire_about_name
    end
  end

  describe '#enquire_about_token' do
    it 'prompts for the pt.token' do
      question = mock('Question')
      question.should_receive(:validate=).with(/^[A-Fa-f0-9]+$/)

      @command.should_receive(:ask).with('pt.token', anything).and_yield(question)
      @command.enquire_about_token
    end
  end

  describe '#enquire_about_project_id' do
    it 'prompts for the pt.projectid numeric' do
      @command.should_receive(:ask).with('pt.projectid', anything, Integer)
      @command.enquire_about_project_id
    end
  end

  describe '#enquire_about_workflow' do
    it 'prompts for the workflow.callbacks value' do
      @command.should_receive(:ask).with('workflow.callbacks', anything)
      @command.enquire_about_workflow
    end
  end

  describe '#enquire_about_branches' do
    it 'prompts for branch conventions' do
      @command.should_receive(:choose_branch_convention).with(:local)
      @command.should_receive(:choose_branch_convention).with(:remote)

      @command.enquire_about_branches
    end
  end

  describe '#choose_branch_convention' do
    it 'works with the correct setting' do
      @command.should_receive(:choose).with('workflow.foobarbranchconvention')
      @command.choose_branch_convention(:foobar)
    end

    it 'sets up the menu correctly' do
      menu = mock('menu')
      menu.should_receive(:prompt=).with(/\bfoobar\b/)
      menu.should_receive(:menu_option).with(/number\b.+title/, '${story.story_id}_${story.name}')
      menu.should_receive(:menu_option).with(/title\b.+number/, '${story.name}_${story.story_id}')
      @command.should_receive(:choose).with(anything).and_yield(menu)

      @command.choose_branch_convention(:foobar)
    end
  end
end
