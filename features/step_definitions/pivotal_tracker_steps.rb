Transform /^story (\d+)$/ do |id|
  id.to_i
end

Given /^the story (\d+) exists$/ do |id|
  create_story(id)
end

Given /^story (\d+) is a (feature|bug|chore)$/ do |id, type|
  for_story(id) do |story|
    story.story_type = type
  end
end


Given /^the name of story (\d+) is "([^\"]+)"$/ do |id,name|
  for_story(id) do |story|
    story.name = name
  end
end

Given /^the description of story (\d+) is "([^\"]+)"$/ do |id,description|
  for_story(id) do |story|
    story.description = description
  end
end

Then /^story (\d+) should be (started|finished|delivered|rejected|accepted)$/ do |id,state|
  for_story(id) do |story|
    story.current_state.should == state
  end
end

Then /^the owner of story (\d+) should be "([^\"]+)"$/ do |id,owner|
  for_story(id) do |story|
    story.owned_by.should == owner
  end
end
