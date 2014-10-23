require 'mayday/target_integrator'
require 'mayday/script_generator'
require 'mayday/abstract_flag/warning'
require 'mayday/abstract_flag/error'

require 'pathname'

module Mayday
  class Reader

    def initialize(mayday_file)
      @mayday_file = mayday_file
      @script_generator = ScriptGenerator.new
    end

    def require(lib_name)
      super
      @script_generator.libs_to_require << lib_name
    end

    def to_target_integrator
      instance_eval(@mayday_file.read, @mayday_file.path, 0)
      validate_xcode_proj
      TargetIntegrator.new(@xcode_proj, @script_generator)
    end

    def xcode_proj(xcode_proj_path)
      real_xcodeproj_path = File.join(Pathname.new(@mayday_file.path).realpath.parent, xcode_proj_path)
      @xcode_proj = Xcodeproj::Project.open(real_xcodeproj_path)
    end
    private :xcode_proj

    def warning_regex(message, regex, options={})
      abstract_flag_regex(Warning, message, regex, options)
    end
    private :warning_regex

    def error_regex(message, regex, options={})
      abstract_flag_regex(Error, message, regex, options)
    end
    private :error_regex

    def validate_xcode_proj
      unless @xcode_proj
        puts "No Xcode project specified in #{@mayday_file.path}. Specify one using xcode_proj 'Path/To/MyProject.xcodeproj'".red
        abort
      end
    end
    private :validate_xcode_proj

    def abstract_flag_regex(klass, message, regex, options={})
      block = <<-CODE
lambda do |line|
  line =~ Regexp.new('#{regex}') ? "#{message}" : nil
end
      CODE
      abstract_flag(klass, :line, block, options)
    end
    private :abstract_flag_regex

    def warning(type, options={}, &block)
      abstract_flag(Warning, type, block, options)
    end
    private :warning

    def error(type, options={}, &block)
      abstract_flag(Error, type, block, options)
    end
    private :error

    def abstract_flag(klass, type, block, options={})
      block_str = case block
      when String
        block
      when Proc
        block.to_source
      else
        raise TypeError, "#{klass}'s block has invalid type of #{@block.class}"
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

      @script_generator.flags << klass.new(final_block, options)
    end
    private :abstract_flag

  end
end