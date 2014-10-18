module Mayday
  class TargetIntegrator

    def initialize(project, script_generator, target_name)
      @project = project
      @script_generator = script_generator
      @target_name = target_name
    end

    def integrate
      phase = existing_mayday_build_phase_for_native_target(native_target_to_integrate) || native_target_to_integrate.new_shell_script_build_phase(mayday_build_phase_name)
      phase.shell_path = "/usr/bin/ruby"
      phase.shell_script = @script_generator.to_ruby
      phase.show_env_vars_in_log = '0'
      @project.save
    end

    def deintegrate
      phase = existing_mayday_build_phase_for_native_target(native_target_to_integrate)
      phase.remove_from_project if phase
      @project.save
    end

    def runs_successfully?
      ENV["SRCROOT"] = @project.path.parent.to_s
      eval(@script_generator.to_ruby(:exit_after => false))
    end

    def benchmark
      ENV["SRCROOT"] = @project.path.parent.to_s
      eval("require 'benchmark'; Benchmark.bm(7) do |benchmarker| benchmarker.report('Mayday') do \n" + @script_generator.to_ruby(:exit_after => false, :output => false) + "\nend \n end")
    end

    def native_target_to_integrate
      @@native_target_to_integrate ||= @native_targets_to_integrate ||= @project.targets.detect do |target|
        target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) && target.name == @target_name
      end
    end
    private :native_target_to_integrate

    def existing_mayday_build_phase_for_native_target(native_target)
      native_target.shell_script_build_phases.detect { |bp| bp.name == mayday_build_phase_name }
    end
    private :existing_mayday_build_phase_for_native_target

    def mayday_build_phase_name
      'Generate Mayday Flags'
    end
    private :mayday_build_phase_name

  end
end