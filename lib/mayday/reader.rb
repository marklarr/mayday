require 'mayday/target_integrator'
require 'mayday/build_phase_generator'
require 'mayday/abstract_flag/warning'
require 'mayday/abstract_flag/error'

require 'pathname'

module Mayday
  class Reader

    def initialize(mayday_file)
      @mayday_file = mayday_file
      @build_phase_generator = BuildPhaseGenerator.new
    end

    def read
      instance_eval(@mayday_file.read, @mayday_file.path, 0)
      # TODO: No project
      # TODO: No main target name
      TargetIntegrator.new(@xcode_proj, @main_target_name).integrate(@build_phase_generator)
      @xcode_proj.save
    end

    def main_target(main_target_name)
      @main_target_name = main_target_name
    end

    def xcode_proj(xcode_proj_path)
      # TODO: Invalid path
      # TODO: absolute vs relative path
      real_xcodeproj_path = File.join(Pathname.new(@mayday_file.path).realpath.parent, xcode_proj_path)
      @xcode_proj = Xcodeproj::Project.open(real_xcodeproj_path)
    end

    def warning(&block)
      @build_phase_generator.flags << Warning.new(block)
    end
    private :warning

    def error(&block)
      @build_phase_generator.flags << Error.new(block)
    end
    private :error

  end
end