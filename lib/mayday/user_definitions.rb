require 'mayday/reader'
require 'colored'

module Mayday
  class UserDefinitions

    def initialize(mayday_file_path)
      @mayday_file_path = mayday_file_path
    end

    def up
      mayday_file do |file|
        Reader.new(file).to_target_integrator.integrate
      end
    end

    def down
      mayday_file do |file|
        Reader.new(file).to_target_integrator.deintegrate
      end
    end

    def benchmark
      mayday_file do |file|
        Reader.new(file).to_target_integrator.benchmark
      end
    end

    def mayday_file
      unless File.exist?(@mayday_file_path)
        puts "No file found at path ./#{@mayday_file_path}".red
        abort
      end

      file = File.open(@mayday_file_path)
      yield file
      file.close
    end
    private :mayday_file

  end 
end