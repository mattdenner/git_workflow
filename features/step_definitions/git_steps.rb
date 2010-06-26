Then /^the branch "([^\"]*)" should be active$/ do |name|
  in_current_dir do
    %x{git branch}.split("\n").should include("* #{ name }")
  end
end

Then /^the branch "([^\"]*)" should be merged into master$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
