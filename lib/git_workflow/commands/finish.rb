require 'git_workflow/commands/base'
require 'git_workflow/configuration'

module GitWorkflow
  module Commands
    class Finish < Base
      def initialize(command_line_arguments)
        super(command_line_arguments) do |remaining_arguments|
          @story_id, @target_branch = remaining_arguments
          @target_branch ||= 'master'
        end
      end

      def execute
        story_or_current_branch(@story_id) do |story|
          merge_story_into!(story, @target_branch)
          finish_story_on_pivotal_tracker!(story)
        end
      end

    private

      def merge_story_into!(story, branch)
        merge_branch(story.branch_name, branch)
      end

      def finish_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as finished") do
          story.service! do |xml|
            xml.current_state(story.finish_state)
          end
        end
      end

      def story_or_current_branch(id, &block)
        story(id || extract_story_from_branch(repository.current_branch), &block)
      end

      def extract_story_from_branch(branch)
        GitWorkflow::Configuration.instance.local_branch_convention.from(branch)
      end

      def usage_info(options)
        options.banner = 'Usage: git finish [<PT story number> [<target branch>]]'
      end
    end
  end
end
