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
          start(story, @parent_branch)
          start_story_on_pivotal_tracker!(story)
  
          $stdout.puts "Story #{ story.story_id }: #{ story.name }"
          $stdout.puts story.description
        end
      end

    private

      def usage_info(options)
        options.banner = 'Usage: git start <PT story number> [<parent branch>]'
      end
    end
  end
end
