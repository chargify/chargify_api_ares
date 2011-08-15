require 'rake'
require 'rspec/core/rake_task'

desc 'Run the spec suite'
RSpec::Core::RakeTask.new('spec') {|t|
  t.rspec_opts = ['--colour', '--format Fuubar']
}

task :default => :spec
