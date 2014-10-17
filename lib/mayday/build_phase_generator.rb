require "mayday/abstract_flag/error"
require "mayday/abstract_flag/warning"

module Mayday
  class BuildPhaseGenerator

    attr_accessor :flags

    def initialize
      self.flags = []
    end

    def to_ruby
      function_defs = flags.map(&:function_def_string).join

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

if #{any_errors_variable_name}
  exit(1)
else
  exit
end
CODE
    end

    def call_flag_functions_string(file_var_name)
      # TODO: Is there a better way to check is_a without parent hitting it?
      "file_contents = file.read\n" + flags.map do |flag|
        any_errors_line = flag.class == Mayday::Error ? "#{any_errors_variable_name} = true" : ""
        <<-CODE
abstract_flag_output = #{flag.function_name}(#{file_var_name}.path, file_contents)
if abstract_flag_output
  puts abstract_flag_output
  #{any_errors_line}
end
           CODE
      end.join("\n")
    end

    def any_errors_variable_name
      "@any_errors"
    end

  end
end