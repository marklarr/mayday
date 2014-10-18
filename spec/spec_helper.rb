require 'bundler/setup'
require 'mayday'
require 'pry'
require 'xcodeproj'

PROJECT_FIXTURES_PATH = File.expand_path('../fixtures', __FILE__)
PROJECT_FIXTURES_TEST_PATH = File.expand_path('../test_fixtures', __FILE__)
PROJECT_FIXTURES_TEST_PROJECT_PATH= File.join(PROJECT_FIXTURES_TEST_PATH, 'fixtures/Fixtures.xcodeproj')
FileUtils.rm_rf(PROJECT_FIXTURES_TEST_PATH)
FileUtils.cp_r(PROJECT_FIXTURES_PATH, PROJECT_FIXTURES_TEST_PATH)
PROJECT_FIXTURES_TEST_PROJECT = Xcodeproj::Project.open(PROJECT_FIXTURES_TEST_PROJECT_PATH)
FIXTURES_TEST_MAYDAY_FILE_PATH = File.join(PROJECT_FIXTURES_TEST_PATH, 'Maydayfile')
FIXTURES_TEST_MAYDAY_FILE_RUBY_ERROR_PATH = File.join(PROJECT_FIXTURES_TEST_PATH, 'Maydayfile_ruby_error')

RSpec.configure do |config|
end
