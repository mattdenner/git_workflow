# Ensures that the environment is setup appropriately for all scenarios
Before do
  # Modify the PATH so that the bin directory is available
  @path_before = ENV['PATH']
  ENV['PATH'] = "#{ File.expand_path(File.join(File.dirname(__FILE__), %w{.. .. .. bin})) }:#{ ENV['PATH'] }"

  # We always need a local repository
  Given %Q{a directory named "local_repository"}
end

Before('@needs_remote_repository') do
  # Sets up the remote repository
  Given %Q{a directory named "remote_repository"}
  Given %Q{I cd to "remote_repository"}
  Given %Q{I successfully run "git init --bare ."}

  # Creates the local one by cloning the remote repository
  Given %Q{I cd to the root}
  Given %Q{I successfully run "git clone remote_repository local_repository"}

  # This then sets up the master branch, both locally and remotely
  Given %Q{I cd to "local_repository"}
  Given %Q{an empty file named "basic-file"}
  Given %Q{I successfully run "git add basic-file"}
  Given %Q{I successfully run "git commit -a -m 'Initial project'"}
  Given %Q{I successfully run "git push origin master"}
end

Before('~@needs_remote_repository') do
  Given %Q{I cd to "local_repository"}
  Given %Q{I successfully run "git init ."}
  Given %Q{an empty file named "basic-file"}
  Given %Q{I successfully run "git add basic-file"}
  Given %Q{I successfully run "git commit -a -m 'Initial project'"}
end

Before do
  Given %Q{I cd to the root}
  Given %Q{I cd to "local_repository"}
end

# Tidy up the environmental setup
After do
  ENV['PATH'] = @path_before
end

def project_root
  File.join(File.dirname(__FILE__), %w{.. .. ..})
end
