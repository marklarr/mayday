require 'xcodeproj'

module Mayday
  class TargetIntegrator

    def initialize(project, script_generator, target_name)
      @project = project
      @script_generator = script_generator
      @target_name = target_name
    end

    def integrate
      if runs_successfully?
        phase = existing_mayday_build_phase_for_native_target(native_target_to_integrate) || native_target_to_integrate.new_shell_script_build_phase(mayday_build_phase_name)
        phase.shell_path = "/usr/bin/ruby"
        phase.shell_script = @script_generator.to_ruby
        phase.show_env_vars_in_log = '0'
        @project.save
      end
    end

    def deintegrate
      phase = existing_mayday_build_phase_for_native_target(native_target_to_integrate)
      phase.remove_from_project if phase
      @project.save
    end

    def runs_successfully?
      ENV["SRCROOT"] = @project.path.parent.to_s
      eval(@script_generator.to_ruby(:exit_after => false, :output => false))
      true
    end

    def benchmark
      ENV["SRCROOT"] = @project.path.parent.to_s

      require 'benchmark'
      Benchmark.bm(7) do |benchmarker| 
        benchmarker.report('Mayday') { eval(@script_generator.to_ruby(:exit_after => false, :output => false)) }
      end
    end

    def native_target_to_integrate
      native_target = @project.targets.detect do |target|
        target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) && target.name == @target_name
      end

      if native_target
        native_target
      else
        valid_target_names = @project.targets.select { |target| target.is_a?(Xcodeproj::Project::Object::PBXNativeTarget) }.map(&:name)
        puts "Could not find a target named #{@target_name} in #{@project.path}. Available targets: #{valid_target_names.join(",")}".red
        abort
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