# frozen_string_literal: true
require 'rspec/core/rake_task'

# Get rid of rspec background noise.
task(:spec).clear
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end
task default: :spec

load 'lib/tasks/mutant.rake'
load 'lib/tasks/rubocop.rake'
