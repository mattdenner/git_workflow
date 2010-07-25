require 'rubygems'
require 'bundler'
Bundler.setup(:build, :test)

require 'rake'

require 'yard'

YARD::Rake::YardocTask.new do |rd|
  rd.files   = [ 'README.markdown', 'lib/**/*.rb' ]
  rd.options = [ '-o', 'doc' ]
end

require 'spec/rake/spectask'

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList[ 'spec/**/*_spec.rb' ]
end

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  options, features = [ '--format pretty' ], 'features'
  options << "--tags '#{ ENV['tags'] }'" unless ENV['tags'].nil? or ENV['tags'].empty?
  features = ENV['FEATURE'] unless ENV['FEATURE'].nil? or ENV['FEATURE'].empty?

  t.cucumber_opts = "#{ options.join(' ') } '#{ features }'"
end
