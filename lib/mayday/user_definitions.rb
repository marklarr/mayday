require 'mayday/reader'
require 'colored'

module Mayday
  class UserDefinitions

    def initialize(mayday_file_path)
      @mayday_file_path = mayday_file_path
    end

    def init
      if File.exist?(@mayday_file_path)
        puts "#{@mayday_file_path} already exists".red
        abort
      else
        File.open(@mayday_file_path, 'w') do |file|
          file.write <<-CODE
xcode_proj '#{nearby_xcodeproj}'

warning_regex 'TODO:', /\\s+\\/\\/\\s?TODO:/
          CODE
          puts "#{@mayday_file_path} created".green
        end
      end
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
        puts "No #{@mayday_file_path} found".yellow
        init
        abort
      end

      file = File.open(@mayday_file_path)
      yield file
      file.close
    end
    private :mayday_file

    def nearby_xcodeproj
      nearby = Dir["**/*.xcodeproj"].reject { |xcodeproj_path| xcodeproj_path =~ /Pods\//}.first
      puts "Xcodeproj couldn't be found".yellow unless nearby
      nearby
    end
    private :nearby_xcodeproj

  end 
end