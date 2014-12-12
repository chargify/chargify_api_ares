require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = FileList['spec/**/*_spec.rb'].exclude('spec/remote/**/*')
end

namespace :spec do
  desc "Run remote specs"
  RSpec::Core::RakeTask.new(:remote) do |t|
    t.pattern = FileList['spec/remote/**/*_spec.rb']
  end
end

task :test    => :spec
task :default => :spec
