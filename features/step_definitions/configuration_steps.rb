Given /^my Pivotal Tracker email address is "([^\"]+)"$/ do |email|
  git_configure('pt.email', email)
end

Given /^my Pivotal Tracker project ID is (\d+)$/ do |id|
  git_configure('pt.projectid', id.to_i)
  mock_service.project_id = id.to_i
end

Given /^my Pivotal Tracker token is ([a-zA-Z0-9]+)$/ do |token|
  git_configure('pt.token', token)
end

Given /^my (local|remote) branch naming convention is "((?:(?:(?:#\{[a-z][a-z_]+\.[a-z][a-z_]+\})|[a-zA-Z0-9_]+)+))"$/ do |branch,convention|
  git_configure("workflow.#{ branch }namingconvention", convention)
end

def git_configure(key, value)
  in_current_dir do
    %x{git config '#{ key }' '#{ value }'}
  end
end
