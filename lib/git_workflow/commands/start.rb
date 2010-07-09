require 'git_workflow/commands/base'

module GitWorkflow
  module Commands
    class Start < Base
      def initialize(command_line_arguments)
        super(command_line_arguments) do |remaining_arguments|
          @story_id, @parent_branch = remaining_arguments
          raise InvalidCommandLine, 'The command line is invalid' if @story_id.nil?
        end
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
        checkout_or_create_branch(story.branch_name, source)
      end

      def start_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as started") do
          story.service! do |xml|
            xml.current_state(story.start_state)
          end
        end
      end

      def usage_info(options)
        options.banner = 'Usage: git start <PT story number> [<parent branch>]'
      end
    end
  end
end
