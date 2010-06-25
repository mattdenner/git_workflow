require 'rubygems'
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
  t.cucumber_opts = "features --format pretty"
end
