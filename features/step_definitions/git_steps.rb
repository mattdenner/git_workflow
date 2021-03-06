def execute_silently(command)
  %x{#{ command } > /dev/null 2>&1}
end

Given /^the local branch "([^\"]+)" exists$/ do |branch|
  in_current_dir do
    execute_silently(%Q{git checkout -b #{ branch } master})
    execute_silently(%Q{git checkout master})
  end
end

Given /^the local branch "([^\"]+)" has been pushed remotely$/ do |branch|
  in_current_dir do
    execute_silently(%Q{git push origin #{ branch }})
  end
end

Given /^the local branch "([^\"]+)" does not exist$/ do |branch|
  in_current_dir do
    execute_silently(%Q{git branch -D #{ branch }})
  end
end

Given /^the remote reference to "([^"]*)" does not exist$/ do |branch|
  in_current_dir do
    execute_silently(%Q{git branch -rD origin/#{ branch }})
  end
end

Given /^the local branch "([^\"]+)" is active$/ do |branch|
  in_current_dir do
    execute_silently(%Q{git checkout #{ branch }})
  end
end

Then /^the branch "([^\"]*)" should be active$/ do |name|
  in_current_dir do
    %x{git branch}.split("\n").map(&:strip).should include("* #{ name }")
  end
end

Then /^the branch "([^\"]*)" should be merged into master$/ do |name|
  in_current_dir do
    execute_silently(%Q{git checkout master})
    %x{git branch --no-merge}.split("\n").map(&:strip).should_not include(name)
  end
end

Then /^the branch "([^\"]+)" should not be merged into master$/ do |name|
  in_current_dir do
    execute_silently(%Q{git checkout master})
    %x{git branch --no-merge}.split("\n").map(&:strip).should include(name)
  end
end

When /^I( successfully)? execute "git (start|finish)([^\"]*)"$/ do |success,command,arguments|
  root_path    = File.expand_path(File.join(File.dirname(__FILE__), '..', '..'))
  real_command = File.join(root_path, 'bin', "git-#{ command }")
  lib_path     = File.join(root_path, 'lib')
  When %Q{I#{ success } run "IGNORE_GIT_GLOBAL=true ruby -I#{ lib_path } -rrubygems #{ real_command } #{ arguments }"}
end

Given /^I commit "([^\"]+)"$/ do |filename|
  in_current_dir do
    execute_silently(%Q{git add '#{ filename }'})
    execute_silently(%Q{git commit -m 'Committing "#{ filename }"' '#{ filename }'})
  end
end

Then /^the parent of branch "([^\"]+)" should be "([^\"]+)"$/ do |child,parent|
  in_current_dir do 
    # This is probably the most hacky piece of shit I've written so far!
    execute_silently("git checkout #{ child }")
    output = %x{git show-branch --topo-order --current}
    lines  = output.split("\n")

    # Determine the branches that are matching and their offset in the output lines.
    matchers = []
    until lines.empty?
      line = lines.shift
      break if line =~ /^---.*$/

      if line =~ /^(\s*)\*\s+\[#{ child }\]/
        matchers[ $1.length ] = '\*'
      elsif line =~ /^(\s*)!\s\[#{ parent }\]/
        matchers[ $1.length ] = '\+'
      end
    end
    raise StandardError, "Cannot find branches in list:\n#{ output }" unless [ '\*', '\+' ].all? { |m| matchers.include?(m) }
    
    # Find a line that matches the appropriate commit.  Basically when the two branches
    # share a commit.  This doesn't work if the branches are intermerging.
    regexp       = Regexp.new("^#{ matchers.map { |m| m || ' ' }.join }.+")

    matched_line = nil
    until lines.empty?
      line = lines.shift
      next unless line =~ regexp
      matched_line = line
      break
    end
    raise StandardError, "#{ child } appears not to be related to #{ parent }" if matched_line.nil?
  end
end

Then /^the local and remote "([^\"]+)" branches should agree$/ do |branch|
  Then %Q{the local branch "#{ branch }" and remote branch "#{ branch }" should agree}
end

Then /^the local branch "([^\"]+)" and remote branch "([^\"]+)" should agree$/ do |local,remote|
  in_current_dir do
    ref_to_sha = %x{git show-ref}.split("\n").inject({}) do |ref_to_sha, line|
      match = line.match(%r{^([a-f0-9]+)\s+refs/(.+)$}) or raise StandardError, "Cannot parse ref line '#{ line }'"
      ref_to_sha[ match[ 2 ] ] = match[ 1 ]
      ref_to_sha
    end

    ref_to_sha[ "heads/#{ local }" ].should == ref_to_sha[ "remotes/origin/#{ remote }" ]
  end
end
