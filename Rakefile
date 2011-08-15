require 'rake'
require 'rspec/core/rake_task'

desc 'Run the spec suite'
RSpec::Core::RakeTask.new('spec') {|t|
  t.rspec_opts = ['--colour', '--format Fuubar']
}

task :default => :spec

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "chargify_api_ares"
    gemspec.summary = "A Chargify API wrapper for Ruby using ActiveResource"
    gemspec.description = ""
    gemspec.email = "mklett@grasshopper.com"
    gemspec.homepage = "http://github.com/grasshopperlabs/chargify_api_ares"
    gemspec.authors = ["Michael Klett", "The Lab Rats @ Phase Two Labs", "Brian Rose","Nathan Verni"]
    Jeweler::GemcutterTasks.new
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end