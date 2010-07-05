require 'git_workflow/commands/base'
require 'git_workflow/configuration'

module GitWorkflow
  module Commands
    class Finish < Base
      def initialize(command_line_arguments)
        @story_id, @target_branch = command_line_arguments
        @target_branch ||= 'master'
      end

      def execute
        story_or_current_branch(@story_id) do |story|
          merge_story_into!(story, @target_branch)
          finish_story_on_pivotal_tracker!(story)
        end
      end

    private

      def merge_story_into!(story, branch)
        info("Merging '#{ story.branch_name }' into '#{ branch }'") do
          execute_command("git checkout #{ branch }")
          execute_command("git merge #{ story.branch_name }")
        end
      end

      def finish_story_on_pivotal_tracker!(story)
        info("Marking story #{ story.story_id } as finished") do
          story.service! do |xml|
            xml.current_state(story.finish_state)
          end
        end
      end

      def story_or_current_branch(id, &block)
        story(id || extract_story_from_branch(determine_current_branch), &block)
      end

      def determine_current_branch
        GitWorkflow::Configuration.instance.active_branch
      end

      def extract_story_from_branch(branch)
        GitWorkflow::Configuration.instance.local_branch_convention.from(branch)
      end
    end
  end
end
