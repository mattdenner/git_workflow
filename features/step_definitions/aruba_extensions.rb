# NOTE: only here because installed Aruba doesn't have this for some reason
Then /^the output should not contain "([^\"]+)"$/ do |content|
  Then %Q{the stdout should not contain "#{ content }"}
  Then %Q{the stderr should not contain "#{ content }"}
end
