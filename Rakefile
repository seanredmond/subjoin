require "bundler/gem_tasks"
require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = "**/inheritable*_spec.rb"
end

RSpec::Core::RakeTask.new(:inheritance) do |t|
  t.pattern = "**/inheritable*_spec.rb"
end
task :default => :spec
