require 'highline'

class HighLine
  [ :ask, :choose ].each do |name|
    eval <<-END_OF_METHOD_ALIASING
      def #{ name }_with_newline(*args, &block)
        #{ name }_without_newline(*args, &block)
      ensure
        $stdout.puts
      end
      alias_method_chain(:#{ name }, :newline)
    END_OF_METHOD_ALIASING
  end
end

class HighLine::Menu
  def menu_option(menu_text, result)
    choice(menu_text) { result }
  end
end

module GitWorkflow
  module Commands
    class Setup < Base
      def execute
        [ :name, :token, :project_id, :workflow, :branches ].each do |step|
          send(:"enquire_about_#{ step }")
        end
      end

    private

      ALIGNMENT_PADDING = ' ' * 10

      def usage_info(options)
        options.banner = 'Usage: git workflow-setup'
      end

      def highline
        @highline ||= HighLine.new
      end

      delegate :get_config_value_for, :to => 'GitWorkflow::Configuration.instance'
      delegate :set_config_value, :to => 'GitWorkflow::Configuration.instance'

      def set_value_through(method, setting, *args, &block)
        options  = args.last.is_a?(Hash) ? args.pop : {}
        optional = options.delete(:optional)

        # Only update the value if it is set or is optional and blank.
        default = get_config_value_for(setting)
        value   = highline.send(method, *args) do |question|
          question.default = default
          block.call(question)
        end
        set_config_value(setting, value) unless optional and value.blank?
      end

      def ask(setting, options = {}, &block)
        set_value_through(:ask, setting, 'Dummy', options, &block)
      end

      def choose(setting, options = {}, &block)
        set_value_through(:choose, setting, options, &block)
      end

      def enquire_about_name
        username = get_config_value_for('user.name')
        ask('pt.username', :optional => true) do |question|
          text = %Q{
            When marking Pivotal Tracker (http://pivotaltracker.com/) stories as started or finished,
            this git workflow needs to know your name.  You have to enter it as it appears on 
            Pivotal Tracker and it is your name, not your email address.  For instance, I appear 
            as 'Matthew Denner'.
          }
          text << %Q{
            If the name you have on Pivotal Tracker is the same as the current git 'user.name' then
            you can leave this blank.  Your git 'user.name' is currently: #{ username }
          } unless username.blank?
          text << %Q{
            Please enter your Pivotal Tracker name:
          }

          question.question = text.align(ALIGNMENT_PADDING)
          question.default  = ''
        end
      end

      def enquire_about_token
        ask('pt.token') do |question|
          question.validate = /^[A-Fa-f0-9]{32}$/ 
          question.question = %Q{
            When the workflow starts or finishes a story it needs to be able to interact with Pivotal
            Tracker (http://pivotaltracker.com/) and to do so you must have an account.  Any updates
            this git workflow makes to Pivotal Tracker need to be done through the API and so it needs
            to know your individual API token.  This can be found under 'API Token' on your profile
            page (https://www.pivotaltracker.com/profile).

            Please enter your Pivotal Tracker API token:
          }.align(ALIGNMENT_PADDING)
        end
      end

      def enquire_about_project_id
        ask('pt.projectid') do |question|
          question.answer_type = Integer
          question.question    = %Q{
            To interact with Pivotal Tracker (http://pivotaltracker.com/) this git workflow needs to
            know the ID for your project.  This can be found in the URL you get when looking at your
            project and is the numeric valid after 'http://www.pivotaltracker.com/projects'.

            Please enter your Pivotal Tracker project ID:
          }.align(ALIGNMENT_PADDING)
        end
      end

      def enquire_about_workflow
        ask('workflow.callbacks') do |question|
          question.default  = 'default'
          question.question = %Q{
            The standard behaviour of this git workflow is to create a new branch and mark a 
            Pivotal Tracker (http://pivotaltracker.com/) story as started when you run 'git start',
            and to mark a Pivotal Tracker story as finished when you run 'git finish'.  You can alter
            this behaviour by choosing a different workflow.

            Please enter the name of your workflow:
          }.align(ALIGNMENT_PADDING)
        end
      end

      def enquire_about_branches
        choose_branch_convention(:local)
        choose_branch_convention(:remote)
      end

      def choose_branch_convention(location)
        choose("workflow.#{ location }branchconvention") do |convention|
          convention.header = %Q{
            Git branches are created locally and can be pushed remotely.  The naming convention for these
            can be different and can be setup to your personal preference.  It's easier to explain their
            format with an example:

            Imagine you have story 12345 which has a title of 'Do something useful'.  If you choose to have
            a branch convention of "PT story number, then PT story title" the branch created will be
            '12345_do_something_useful'.  If you select "PT story title, then PT story number" you will
            get the branch 'do_something_useful_12345'.
          }.align(ALIGNMENT_PADDING)

          convention.menu_option('PT story number, then PT story title', '${number}_${name}')
          convention.menu_option('PT story title, then PT story number', '${name}_${number}')

          convention.prompt = "Choose your #{ location } branch naming convention:"
        end
      end
    end
  end
end
