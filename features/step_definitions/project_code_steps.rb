Given /^the rake task "([^\"]+)" will fail$/ do |task|
  in_current_dir do
    File.open('Rakefile', 'a+') do |file|
      file << <<-END_OF_RAKE_TASK
        task(:#{ task }) do
          $stdout.puts "Running #{ task }"
          $stderr.puts "Failing #{ task }"

          raise 'Task "#{ task }" is setup to fail'
        end
      END_OF_RAKE_TASK
    end
    
    # Add and commit the file
    %x{git add Rakefile}
    %x{git commit -m 'Upated #{ task } to fail' Rakefile}
  end
end

Given /^the rake task "([^\"]+)" will succeed$/ do |task|
  in_current_dir do
    File.open('Rakefile', 'a+') do |file|
      file << <<-END_OF_RAKE_TASK
        task(:#{ task }) do
          $stdout.puts "Running #{ task }"
          $stderr.puts "Succeeding #{ task }"
        end
      END_OF_RAKE_TASK
    end
    
    # Add and commit the file
    %x{git add Rakefile}
    %x{git commit -m 'Upated #{ task } to succeed' Rakefile}
  end
end
