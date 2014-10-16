require 'spec_helper'

describe Mayday::Reader do

  describe "read" do
    it "should add a build phase run script to the project" do
      reader = Mayday::Reader.new(FIXTURES_TEST_MAYDAY_FILE)
      reader.read
    end
  end

end
