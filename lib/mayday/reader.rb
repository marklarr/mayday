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

    def warning_regex(message, regex)
      abstract_flag_regex(Warning, message, regex)
    end

    def error_regex(message, regex)
      abstract_flag_regex(Error, message, regex)
    end

    def abstract_flag_regex(klass, message, regex)
      block = <<-CODE
lambda do |line|
  line =~ Regexp.new('#{regex}') ? "#{message}" : nil
end
      CODE
      abstract_flag(klass, :line, block)
    end

    def warning(type=:line, &block)
      abstract_flag(Warning, type, block)
    end
    private :warning

    def error(type=:line, &block)
      abstract_flag(Error, type, block)
    end
    private :error

    def abstract_flag(klass, type=:line, block)
      block_str = case block
      when String
        block
      when Proc
        block.to_source
      else
        raise TypeError, "#{self.class}'s block has invalid type of #{@block.class}"
      end

      final_block = case type
                    when :line
                      <<-CODE 
lambda do |file_contents|
  hash = {}
  lines = file_contents.split("\n")
  lines.each_with_index do |line, line_number| 
    message = #{block_str}.call(line)
    hash[line_number + 1] = message if message
  end
  hash
end
                        CODE
                    when :file
                      block
                    end

      @build_phase_generator.flags << klass.new(final_block)
    end
    private :abstract_flag

  end
end