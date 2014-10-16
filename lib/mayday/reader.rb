require 'mayday/target_integrator'
require 'mayday/build_phase_generator'
require 'mayday/abstract_flag/warning'
require 'mayday/abstract_flag/error'

module Mayday
  class Reader

    def initialize(mayday_file)
      @mayday_file = mayday_file
      @build_phase_generators = {}
    end

    def read
      instance_eval(@mayday_file.read)
      @build_phase_generators.each do |target_name, build_phase_generator|
        # TODO: No project
        # TODO: Use all targets key in TargetIntegrator
        target_name = nil if target_name == mayday_all_targets_key
        TargetIntegrator.new(@xcode_proj, target_name).integrate(build_phase_generator)
      end
    end

    def xcode_proj(xcode_proj_path)
      # TODO: Invalid path
      @xcode_proj = Xcodeproj::Project.open(xcode_proj_path)
    end

    def warning(message, &block)
      @current.target.flags << Warning.new(message, block)
    end
    private :warning

    def error(message, &block)
      @current.target.flags << Error.new(message, block)
    end
    private :error

    def target(target_name)
      set_current_target(target_name)
      yield
      do_default_target
    end
    private :target

    def do_default_target
      set_current_target(mayday_all_targets_key)
    end
    private :do_default_target

    def set_current_target(target_name)
      @build_phase_generators[target_name] ||= BuildPhaseGenerator.new
      @current_target = @build_phase_generators[target_name]
    end
    private :set_current_target

    def mayday_all_targets_key
      :mayday_all_targets
    end
    private :mayday_all_targets_key

  end
end