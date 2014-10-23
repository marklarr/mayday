require 'spec_helper'

describe Mayday::UserDefinitions do

  def parse_build_output(opts={})
    extra_test_flags = opts[:test] ? "test" : ""
    output =`xcodebuild -project spec/test_fixtures/Fixtures/Fixtures.xcodeproj/ -scheme Fixtures -sdk iphonesimulator #{extra_test_flags}`
    exitstatus = $?.exitstatus
    files_to_lines_to_warnings_hash = {}
    output.split("\n").each do |line|
      matches = line.match(/((.+):([0-9]+):\s(.+))/)
      if matches
        # Get path relative to spec/test_fixtures
        file_path = matches[2].split("/spec/").last
        line_number = matches[3]
        flag_message = matches[4]          

        files_to_lines_to_warnings_hash[file_path] ||= {}
        files_to_lines_to_warnings_hash[file_path][line_number] ||= []
        files_to_lines_to_warnings_hash[file_path][line_number] << flag_message
      end
    end
    { :exitstatus => exitstatus, :files_to_lines_to_warnings_hash => files_to_lines_to_warnings_hash }
  end

  def create_mayday_file(&block)
    string = block.to_source
    file = File.open("Maydayfile_rspec_generated", "w")
    file.write(block.to_source + ".call")
    file
  end

  def with_captured_stdout
    begin
      old_stdout = $stdout
      $stdout = StringIO.new('','w')
      yield
      $stdout.string
    ensure
      $stdout = old_stdout
    end
  end

  let(:files_to_lines_to_warnings_hash) { @parsed_build_output[:files_to_lines_to_warnings_hash] }

  describe "#up" do
    before(:all) do
      user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
      user_definitions.up
    end

    [{}, {:test => true}].each do |options|

      describe "after running xcodebuild on the main target with #{options}" do 
        before(:all) { @parsed_build_output = parse_build_output(options) }

        it "should have failed the build" do
          expect(@parsed_build_output[:exitstatus]).to_not eq(0)
        end

        it "should have output all files with warnings or errors in them" do
          expect(files_to_lines_to_warnings_hash.count).to eq(4)
        end

        it "should have, for every file, output all of the warnings or errors in them" do
          some_object_h_flags = files_to_lines_to_warnings_hash['test_fixtures/Fixtures/Fixtures/SomeDir/SomeObject.h']
          app_delegate_swift_flags = files_to_lines_to_warnings_hash['test_fixtures/Fixtures/Fixtures/AppDelegate.swift']
          long_file_m_flags = files_to_lines_to_warnings_hash['test_fixtures/Fixtures/Fixtures/SomeDir/LongFile.m']

          expect(some_object_h_flags.count).to eq(1)
          expect(app_delegate_swift_flags.count).to eq(9)
          expect(long_file_m_flags.count).to eq(1)
        end
      end

      describe "when using a Maydayfile containing Ruby errors" do
        it "should raise the exception to the user when they try to 'up'" do
          user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_RUBY_ERROR_PATH)
          expect { user_definitions.up }.to raise_error("error")
        end
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

  describe "#init" do
    describe "Maydayfile doesn't exist" do
      before(:all) do
        @mayday_file_doesnt_exist_path = "Maydayfile_doesnt_exist"
        FileUtils.rm_rf(@mayday_file_doesnt_exist_path)
        user_definitions = Mayday::UserDefinitions.new(@mayday_file_doesnt_exist_path)
        user_definitions.init
      end

      after(:all) do
        FileUtils.rm_rf(@mayday_file_doesnt_exist_path)
      end

      it "should create a valid Maydayfile prefilled with the nearest xcodeproject" do
        user_definitions = Mayday::UserDefinitions.new(@mayday_file_doesnt_exist_path)
        user_definitions.up
        user_definitions.down
      end
    end

    describe "Maydayfile already exists" do
      it "should keep the Maydayfile as-is and abort" do
        before_file_contents = File.open(FIXTURES_TEST_MAYDAY_FILE_PATH) { |file| file.read }
        user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
        lambda { user_definitions.init }.should raise_error SystemExit
        after_file_contents = File.open(FIXTURES_TEST_MAYDAY_FILE_PATH) { |file| file.read }
        expect(before_file_contents).to eq(after_file_contents)
      end
    end
  end

  describe "#benchmark" do
    it "should show benchmark data for the mayday build phase" do
      user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
      output = with_captured_stdout { user_definitions.benchmark }
      matches = output.match /\s+user\s+system\s+total\s+real\nMayday\s+([0-9]+\.[0-9]+)\s+([0-9]+\.[0-9]+)\s+([0-9]+\.[0-9]+).+([0-9]+\.[0-9]+)/
    
      expect(matches.size).to eq(5)

      real_time = matches[4].to_f
      real_time.should be > 0.0
    end

    describe "after running xcodebuild" do 
    before(:all) do
        user_definitions = Mayday::UserDefinitions.new(FIXTURES_TEST_MAYDAY_FILE_PATH)
        user_definitions.benchmark
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

  describe "when the Maydayfile has no xcode_proj defined" do
    it "should abort" do
      mayday_file = create_mayday_file do
        warning { |line| return nil }
        error { |line| return "ERROR!" }
      end

      lambda { Mayday::UserDefinitions.new(mayday_file.path).up }.should raise_error SystemExit
    end
  end

  describe "when the Maydayfile cannot find the xcode_proj defined" do
    it "should abort" do
      mayday_file = create_mayday_file do
        xcode_proj "Hi.xcodeproj"

        warning { |line| return nil }
        error { |line| return "ERROR!" }
      end

      lambda { Mayday::UserDefinitions.new(mayday_file.path).up }.should raise_error SystemExit
    end
  end

end
