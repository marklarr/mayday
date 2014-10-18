module Mayday
  class TargetIntegrator

    def initialize(project, target_name=nil)
      @project = project
      @target_name = target_name
    end

    def integrate(script_generator)
      native_targets_to_integrate.each do |native_target|
        phase = mayday_build_phase_for_native_target(native_target) || native_target.new_shell_script_build_phase(mayday_build_phase_name)
        phase.shell_path = "/usr/bin/ruby"
        phase.shell_script = script_generator.to_ruby
        phase.show_env_vars_in_log = '0'
      end
    end

    def deintegrate(script_generator)
      native_targets_to_integrate.each do |native_target|
        phase = mayday_build_phase_for_native_target(native_target)
        native_target.shell_script_build_phases.delete(phase) if phase
      end
    end

    def runs_successfully?(script_generator)
      ENV["SRCROOT"] = @project.path.parent.to_s
      eval(script_generator.to_ruby(:exit_after => false))
    end

    def benchmark(script_generator)
      ENV["SRCROOT"] = @project.path.parent.to_s
      eval("require 'benchmark'; Benchmark.bm(7) do |benchmarker| benchmarker.report('Mayday') do \n" + script_generator.to_ruby(:exit_after => false, :output => false) + "\nend \n end")
    end

    def native_targets_to_integrate
      @native_targets_to_integrate ||= @project.targets.select do |target|
        target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) && (!@target_name || target.name == @target_name)
      end
    end
    private :native_targets_to_integrate

    def mayday_build_phase_for_native_target(native_target)
      native_target.shell_script_build_phases.select { |bp| bp.name == mayday_build_phase_name }.first
    end
    private :mayday_build_phase_for_native_target

    def mayday_build_phase_name
      'Generate Mayday Flags'
    end
    private :mayday_build_phase_name

  end
end