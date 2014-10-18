require 'spec_helper'

describe Mayday::UserDefinitions do

  def parse_build_output
    output =`xcodebuild -project spec/test_fixtures/Fixtures/Fixtures.xcodeproj/ -scheme Fixtures -configuration Debug`
    exitstatus = $?.exitstatus
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

    { :exitstatus => exitstatus, :files_to_lines_to_warnings_hash => files_to_lines_to_warnings_hash }
  end

  let(:files_to_lines_to_warnings_hash) { @parsed_build_output[:files_to_lines_to_warnings_hash] }

  describe "#up" do
    describe "after running xcodebuild" do 
      before(:all) do
          user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
          user_definitions.up
          @parsed_build_output = parse_build_output
      end

      it "should have failed the build" do
        expect(@parsed_build_output[:exitstatus]).to_not eq(0)
      end

      it "should have output all files with warnings or errors in them" do
        expect(files_to_lines_to_warnings_hash.count).to eq(2)
      end

      it "should have, for every file, output all of the warnings or errors in them" do
        some_object_h_flags = files_to_lines_to_warnings_hash['/Users/marklarsen/github.com/mayday/spec/test_fixtures/Fixtures/Fixtures/SomeDir/SomeObject.h']
        app_delegate_swift_flags = files_to_lines_to_warnings_hash['/Users/marklarsen/github.com/mayday/spec/test_fixtures/Fixtures/Fixtures/AppDelegate.swift']

        expect(some_object_h_flags.count).to eq(1)
        expect(app_delegate_swift_flags.count).to eq(9)
      end
    end
  end

  describe "#down" do
    describe "after running xcodebuild" do 
      before(:all) do
          user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
          user_definitions.up
          user_definitions.down
          @parsed_build_output = parse_build_output
      end

      it "should have passed the build" do
        expect(@parsed_build_output[:exitstatus]).to eq(0)
      end

      it "should have no warnings or errors from Mayday" do
        expect(files_to_lines_to_warnings_hash.count).to eq(0)
      end
    end
  end

end
