require 'spec_helper'

class GitWorkflow::Commands::Setup
  public :set_value_through
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

    @question = mock('Question')
    @question.stub(:question=).with(anything)
  end

  describe '#execute' do
    it 'asks the right questions' do
      [ :name, :token, :project_id, :workflow, :branches ].each do |query|
        @command.should_receive(:"enquire_about_#{ query }").ordered
      end
      @command.execute
    end
  end

  describe '#ask' do
    it 'calls through to set the value' do
      callback = mock('callback')
      callback.should_receive(:called)

      @command.should_receive(:set_value_through).with(:ask, :setting, 'Dummy', :options).and_yield
      @command.ask(:setting, :options) { callback.called }
    end
  end

  describe '#choose' do
    it 'calls through to set the value' do
      callback = mock('callback')
      callback.should_receive(:called)

      @command.should_receive(:set_value_through).with(:choose, :setting, :options).and_yield
      @command.choose(:setting, :options) { callback.called }
    end
  end

  describe '#set_value_through' do
    before(:each) do
      @question.should_receive(:default=).with(:default)

      @callback = mock('callback')
      @callback.should_receive(:called).with(@question)

      @command.should_receive(:get_config_value_for).with(:setting).and_return(:default)
    end

    it 'unspecified answer type sets value' do
      @highline.should_receive(:question_user).with(:arg1, :arg2).and_yield(@question).and_return(:ok)
      @command.should_receive(:set_config_value).with(:setting, :ok)
      @command.set_value_through(:question_user, :setting, :arg1, :arg2) { |question| @callback.called(question) }
    end

    context 'when answer is optional' do
      after(:each) do
        @command.set_value_through(:question_user, :setting, :arg1, :arg2, :optional => true) { |question| @callback.called(question) }
      end

      it 'does not set the value if answer is blank' do
        @highline.should_receive(:question_user).with(:arg1, :arg2).and_yield(@question).and_return('')
      end

      it 'sets the value if answer is non-blank' do
        @highline.should_receive(:question_user).with(:arg1, :arg2).and_yield(@question).and_return('OK')
        @command.should_receive(:set_config_value).with(:setting, 'OK')
      end
    end
  end

  describe '#enquire_about_name' do
    it 'optionally prompts for the user.name' do
      @command.should_receive(:get_config_value_for).with('user.name').and_return('John Smith')
      @command.should_receive(:ask).with('pt.username', hash_including(:optional => true))
      @command.enquire_about_name
    end
  end

  describe '#enquire_about_token' do
    it 'prompts for the pt.token' do
      @question.should_receive(:validate=).with(/^[A-Fa-f0-9]{32}$/)

      @command.should_receive(:ask).with('pt.token').and_yield(@question)
      @command.enquire_about_token
    end
  end

  describe '#enquire_about_project_id' do
    it 'prompts for the pt.projectid numeric' do
      @question.should_receive(:answer_type=).with(Integer)

      @command.should_receive(:ask).with('pt.projectid').and_yield(@question)
      @command.enquire_about_project_id
    end
  end

  describe '#enquire_about_workflow' do
    it 'prompts for the workflow.callbacks value' do
      @command.should_receive(:ask).with('workflow.callbacks')
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
      menu.stub(:header=).with(anything)
      menu.should_receive(:prompt=).with(/\bfoobar\b/)
      menu.should_receive(:menu_option).with(/number\b.+title/, '${number}_${name}')
      menu.should_receive(:menu_option).with(/title\b.+number/, '${name}_${number}')
      @command.should_receive(:choose).with(anything).and_yield(menu)

      @command.choose_branch_convention(:foobar)
    end
  end
end
