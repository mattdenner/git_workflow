require 'highline'

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

      def usage_info(options)
        options.banner = 'Usage: git workflow-setup'
      end

      def highline
        @highline ||= HighLine.new
      end

      delegate :get_config_value_for, :to => 'GitWorkflow::Configuration.instance'
      delegate :set_config_value, :to => 'GitWorkflow::Configuration.instance'

      def self.set_value_helper(name)
        class_eval <<-END_OF_METHOD
          def #{ name }(setting, *args, &block)
            set_config_value(setting, highline.#{ name }(*args, &block))
          end
        END_OF_METHOD
      end

      set_value_helper(:ask)
      set_value_helper(:choose)

      def enquire_about_name
        username = get_config_value_for('user.name')
        prompt   = username.nil? || !highline.agree("Is your PT name '#{ username }' (y/n)?")
        ask('pt.username', 'Enter your PT name:') if prompt
      end

      def enquire_about_token
        ask('pt.token', 'Enter your PT token:') { |q| q.validate = /^[A-Fa-f0-9]+$/ }
      end

      def enquire_about_project_id
        ask('pt.projectid', 'Enter your PT project ID:', Integer)
      end

      def enquire_about_workflow
        ask('workflow.callbacks', 'Enter your workflow:') 
      end

      def enquire_about_branches
        choose_branch_convention(:local)
        choose_branch_convention(:remote)
      end

      def choose_branch_convention(location)
        choose("workflow.#{ location }branchconvention") do |convention|
          convention.prompt = "Choose your #{ location } branch naming convention"
          convention.menu_option('PT story number, then PT story title', '{story.story_id}_{story.name}')
          convention.menu_option('PT story title, then PT story number', '{story.name}_{story.story_id}')
        end
      end
    end
  end
end
