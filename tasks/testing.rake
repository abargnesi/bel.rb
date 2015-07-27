require 'rake/testtask'
require 'rspec/core'
require 'rspec/core/rake_task'

# Tests using a classical xunit-style.
TEST_UNIT_TESTS        = FileList['test/unit/**/test_*.rb']
TEST_INTEGRATION_TESTS = FileList['test/integration/**/test_*.rb']

# Tests using a specification style.
SPEC_UNIT_TESTS        = FileList['spec/unit/**/*_spec.rb']
SPEC_INTEGRATION_TESTS = FileList['spec/integration/**/*_spec.rb']

task :unit => [:spec_unit, :test_unit]

# unit tests
RSpec::Core::RakeTask.new(:spec_unit) do |r|
  r.ruby_opts = '-Ilib/'
  r.rspec_opts = "--format documentation"
  r.pattern = (not SPEC_UNIT_TESTS.empty? and SPEC_UNIT_TESTS) or fail "No unit tests"
end

Rake::TestTask.new(:test_unit) do |t|
  t.test_files = TEST_UNIT_TESTS
  t.verbose = true
end

# integration tests
RSpec::Core::RakeTask.new(:rspec_integration) do |r|
  r.ruby_opts = '-Ilib/'
  r.rspec_opts = "--format documentation"
  r.pattern = (not SPEC_INTEGRATION_TESTS.empty? and SPEC_INTEGRATION_TESTS) or fail "No integration tests"
end
