Then /^fail now$/ do
  raise StandardError, 'Failing as requested'
end
