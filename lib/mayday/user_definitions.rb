module Mayday
  class UserDefinitions
    
    def initialize(mayday_file_path)
      @mayday_file = File.open(mayday_file_path)
    end

    def up
      Reader.new(@mayday_file).to_target_integrator.integrate
    end

    def down
      Reader.new(@mayday_file).to_target_integrator.deintegrate
    end

    def benchmark
      Reader.new(@mayday_file).to_target_integrator.benchmark
    end

  end 
end