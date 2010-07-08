require 'git_workflow/commands/base'

module GitWorkflow
  module Commands
    class Start < Base
      def initialize(command_line_arguments)
        @story_id, @parent_branch = command_line_arguments
        raise StandardError, "Usage: git-start <STORY> [<PARENT>]" if @story_id.nil?
      end

      def execute
        story(@story_id) do |story|
          create_branch_for_story!(story, @parent_branch)
          start_story_on_pivotal_tracker!(story)
  
          $stdout.puts "Story #{ story.story_id }: #{ story.name }"
          $stdout.puts story.description
        end
      end

    private

      def create_branch_for_story!(story, source = nil)
        info("Creating branch '#{ story.branch_name }'") do
          command = 'git checkout'
          command << ' -b' unless branch_already_exists?(story)
          command << " #{ story.branch_name }"
          command << " #{ source }" unless source.nil?
          execute_command(command)
        end
      end

      def branch_already_exists?(story)
        GitWorkflow::Configuration.instance.branches.find { |name,_| name == story.branch_name }
      end

      def start_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as started") do
          story.service! do |xml|
            xml.current_state(story.start_state)
          end
        end
      end
    end
  end
end
