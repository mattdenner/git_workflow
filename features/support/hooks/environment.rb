# Ensures that the environment is setup appropriately for all scenarios
Before do
  # First we modify the PATH so that the bin directory is available
  @path_before = ENV['PATH']
  ENV['PATH'] = "#{ ENV['PATH'] }:#{ File.expand_path(File.join(File.dirname(__FILE__), %w{.. .. .. bin})) }"

  # Then we initialise a git repository using Aruba!
  Given %Q{I successfully run "git init ."}
  Given %Q{an empty file named "basic-file"}
  Given %Q{I successfully run "git add basic-file"}
  Given %Q{I successfully run "git commit -a -m 'Initial project'"}
end

# Tidy up the environmental setup
After do
  ENV['PATH'] = @path_before
end

def project_root
  File.join(File.dirname(__FILE__), %w{.. .. ..})
end
