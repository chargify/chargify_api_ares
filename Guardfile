# Run me with:
#
#   $ bundle exec guard

begin
  require 'rb-inotify'
  require 'libnotify'
rescue LoadError
end

guard 'rspec', :all_on_start => false, :all_after_pass => false do
  watch(%r{^spec/.+_spec\.rb})
  watch(%r{^lib/(.+)\.rb})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch(%r{^spec/.+_spec\.rb})
end
