require 'spec_helper'

describe Mayday::Reader do

  def parse_build_output
    output =`xcodebuild -project spec/test_fixtures/Fixtures/Fixtures.xcodeproj/ -scheme Fixtures -configuration Debug`
    files_to_lines_to_warnings_hash = {}
    output.split("\n").each do |line|
      matches = line.match(/((.+):([0-9]+):\s(.+))/)
      if matches
        file_path = matches[2]
        line_number = matches[3]
        flag_message = matches[4]          

        files_to_lines_to_warnings_hash[file_path] ||= {}
        files_to_lines_to_warnings_hash[file_path][line_number] ||= []
        files_to_lines_to_warnings_hash[file_path][line_number] << flag_message
      end
    end

    return files_to_lines_to_warnings_hash
  end

  describe "read" do
    it "should add a build phase run script to the project" do
      user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
      user_definitions.up
      files_to_lines_to_warnings_hash = parse_build_output

      expect(files_to_lines_to_warnings_hash.count).to eq(2)

      some_object_h_flags = files_to_lines_to_warnings_hash['/Users/marklarsen/github.com/mayday/spec/test_fixtures/Fixtures/Fixtures/SomeDir/SomeObject.h']
      app_delegate_swift_flags = files_to_lines_to_warnings_hash['/Users/marklarsen/github.com/mayday/spec/test_fixtures/Fixtures/Fixtures/AppDelegate.swift']

      expect(some_object_h_flags.count).to eq(1)
      expect(app_delegate_swift_flags.count).to eq(9)


    end
  end

end
