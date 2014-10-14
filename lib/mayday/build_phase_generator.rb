require "mayday/error"
require "mayday/warning"

module Mayday
  class BuildPhaseGenerator

    def initialize(flags)
      @flags = flags || []
    end

    def to_ruby
      function_defs = @flags.map(&:function_def_string).join

      <<-CODE
# encoding: utf-8
Encoding.default_external = "utf-8"

#{function_defs}

Dir[ENV["SRCROOT"] + "/**/*.{m,h,swift}"].each do |filename|
  # Could be a dir with .m, like Underscore.m's dir
  if (File.file?(filename))
    file = File.open(filename, 'r')
    #{call_flag_functions_string("file")}
  end
end

exit
CODE
    end

    def call_flag_functions_string(file_var_name)
      @flags.map do |flag|
        "abstract_flag_output = #{flag.function_name}(#{file_var_name}); puts abstract_flag_output if abstract_flag_output;"
      end.join("\\n")
    end

  end
end