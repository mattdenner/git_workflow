require 'rest_client'
require 'nokogiri'
require 'builder'
require 'singleton'

require 'git_workflow/core_ext'
require 'git_workflow/configuration'
require 'git_workflow/story'

class GitWorkflow
  extend Execution

  def self.story(id, &block)
    GitWorkflow.new(id).execute(&block)
  end

  def self.story_or_current_branch(id, &block)
    self.story(id || extract_story_from_branch(determine_current_branch), &block)
  end

  def initialize(id)
    @story_id = id or raise StandardError, "You have not specified a story ID"
    load_configuration
  end

  def execute(&block)
    yield(load_story_from_pivotal_tracker)
  end

private

  def self.determine_current_branch
    GitWorkflow::Configuration.instance.active_branch
  end

  def self.extract_story_from_branch(branch)
    Configuration.instance.local_branch_convention.from(branch)
  end

  def load_configuration
    @username                = Configuration.instance.username
    @project_id              = Configuration.instance.project_id
    @api_token               = Configuration.instance.api_token
    @local_branch_convention = Configuration.instance.local_branch_convention
  end
end
