require 'bundler'
Bundler::GemHelper.install_tasks

$:.unshift 'lib'

require 'rspec/core/rake_task'
desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/spec_helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end

desc "Run all remote examples"
RSpec::Core::RakeTask.new(:remote) do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/remote/spec_helper.rb"]
  t.pattern = 'spec/remote/*_spec.rb'
end

task :default => :spec