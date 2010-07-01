Given /^the local branch "([^\"]+)" exists$/ do |branch|
  in_current_dir do
    %x{git checkout -b #{ branch } master}
    %x{git checkout master}
  end
end

Given /^the local branch "([^\"]+)" is active$/ do |branch|
  in_current_dir do
    %x{git checkout #{ branch }}
  end
end

Then /^the branch "([^\"]*)" should be active$/ do |name|
  in_current_dir do
    %x{git branch}.split("\n").map(&:strip).should include("* #{ name }")
  end
end

Then /^the branch "([^\"]*)" should be merged into master$/ do |name|
  in_current_dir do
    %x{git checkout master}
    %x{git branch --no-merge}.split("\n").map(&:strip).should_not include(name)
  end
end

When /^I successfully execute "git (start|finish)([^\"]*)"$/ do |command,arguments|
  root_path    = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  real_command = File.join(root_path, 'bin', "git-#{ command }")
  lib_path     = File.join(root_path, 'lib')
  When %Q{I successfully run "ruby -I#{ lib_path } #{ real_command }#{ arguments }"}
end
