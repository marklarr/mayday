require 'sourcify'

module Mayday
  class AbstractFlag

    @@function_names = []
    
    def initialize(block, options={})
      @block = block

      @include_file_globs = Array(options[:files])
      @exclude_file_globs = Array(options[:exclude])

      if options[:language]
        language = options[:language].to_s
        if language == "swift"
          @include_file_globs << "*.swift"
        elsif language == "objective-c"
          @include_file_globs << "*.{h,m}"
        else
          puts "Unrecognized language '#{language}'".red
          abort
        end
      end

      @exclude_file_globs << "*Pods/*"
    end

    def message_prefix
      ""
    end

    def block_string
      case @block
      when String
        @block
      when Proc
        @block.to_source
      else
        raise TypeError, "#{self.class}'s block has invalid type of #{@block.class}"
      end
    end

    def function_def_string
      <<-CODE
def #{function_name}(file_path, file_contents)
  #{file_fn_match_lines("file_path")}

  line_number_to_warning_hash = lambda do 
    #{block_string}.call(file_contents)
  end.call

  if line_number_to_warning_hash && line_number_to_warning_hash.keys.count > 0
    final_warning_array = []
    line_number_to_warning_hash.map do |line_number, warning_str|
      final_warning_array << "\#{file_path}:\#{line_number}: #{message_prefix}\#{warning_str} [Wmayday]"  
    end
    final_warning_array.join("\n")
  else
    false
  end
end
CODE
    end

    def file_fn_match_lines(file_path_var_name)
      @file_fn_match_lines ||= begin
        includes_chunk = @include_file_globs.map do |file_glob|
          "return unless File.fnmatch(\"#{file_glob}\", #{file_path_var_name})"
        end.join("\n")

        excludes_chunk = @exclude_file_globs.map do |file_glob|
          "return if File.fnmatch(\"#{file_glob}\", #{file_path_var_name})"
        end.join("\n")

        includes_chunk + "\n" + excludes_chunk
      end
    end
    private :file_fn_match_lines

    def function_name
      @function_name ||= begin
        # Enforce uniqueness 
        candidate_function_name = "abstract_flag_matcher_#{rand(10000)}"
        @@function_names.include?(candidate_function_name) ? function_name : candidate_function_name
      end
    end

  end
end