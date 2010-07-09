Gem::Specification.new do |s|
  s.rubygems_version          = %q{1.3.6}
  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6")
  s.specification_version     = 3

  s.name    = %q{git_workflow}
  s.version = '0.0.3'
  
  # Get the dependencies from Bundler ...
  s.add_dependency('rest-client', [ '>= 1.5.1' ])
  s.add_dependency('nokogiri',    [ '>= 1.4.2' ])
  s.add_dependency('builder',     [ '>= 2.1.2' ])
  s.add_dependency('POpen4',      [ '>= 0.1.4' ])

  s.authors     = ["Matthew Denner"]
  s.date        = %q{2010-07-01}
  s.summary     = %q{git extensions to support Pivotal Tracker}
  s.description = %q{Extends git with some scripts that support a tie up with Pivotal Tracker}
  s.email       = %q{matt.denner@gmail.com}
  s.homepage    = %q{http://github.com/mattdenner/git_workflow}

  s.has_rdoc         = %q{yard}
  s.rdoc_options     = ["--charset=UTF-8"]
  s.extra_rdoc_files = [ "README.markdown" ]

  s.add_bindir('bin')
  s.executables   = [ 'git-start', 'git-finish' ]
  s.require_paths = [ 'lib' ]
  s.test_files    = [ 'spec/**/*.rb', 'features/**/*.feature', 'features/**/*.rb' ].map { |p| Dir[ p ] }.flatten
  s.files         = [ "README.markdown", "Rakefile" ] + [ 'lib/**/*.rb', 'bin/**' ].map { |p| Dir[ p ] }.flatten
end
