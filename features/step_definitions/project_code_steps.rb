Given /^the default rake task will succeed$/ do
  Given %Q{an empty file named "Rakefile"}
  in_current_dir do
    %x{git add Rakefile}
    %x{git commit -m 'Passing Rakefile' Rakefile}
  end
end
