Given /^my Pivotal Tracker configuration is setup as normal$/ do
  Given %Q{my Pivotal Tracker username is "Matthew Denner"}
  Given %Q{my Pivotal Tracker project ID is 93630}
  Given %Q{my Pivotal Tracker token is 1234567890}
  Given %Q{my local branch naming convention is "${number}_${name}"}
  Given %Q{my remote branch naming convention is "${number}_${name}"}
end

Given /^my git username is "([^\"]+)"$/ do |username|
  git_configure('user.name', username)
end

Given /^my Pivotal Tracker username is "([^\"]+)"$/ do |username|
  git_configure('pt.username', username)
end

Given /^my Pivotal Tracker project ID is (\d+)$/ do |id|
  git_configure('pt.projectid', id.to_i)
  mock_service.project_id = id.to_i
end

Given /^my Pivotal Tracker token is ([a-zA-Z0-9]+)$/ do |token|
  git_configure('pt.token', token)
end

Given /^my (local|remote) branch naming convention is "((?:(?:(?:\$\{[a-z][a-z_]+\})|[a-zA-Z0-9_]+)+))"$/ do |branch,convention|
  git_configure("workflow.#{ branch }branchconvention", convention)
end

Given /^I have "([^\"]+)" callbacks enabled$/ do |callbacks|
  git_configure("workflow.callbacks", callbacks)
end

def git_configure(key, value)
  in_current_dir do
    %x{git config '#{ key }' '#{ value }'}
  end
end
