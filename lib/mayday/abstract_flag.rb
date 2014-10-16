require 'sourcify'

module Mayday
  class AbstractFlag

    @@function_names = []
    
    def initialize(block)
      @block = block
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
  line_number_to_warning_hash = lambda do 
    #{block_string}.call(file_contents)
  end.call

  if line_number_to_warning_hash.keys.count > 0
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

    def function_name
      @function_name ||= begin
        # Enforce uniqueness 
        candidate_function_name = "abstract_flag_matcher_#{rand(10000)}"
        @@function_names.include?(candidate_function_name) ? function_name : candidate_function_name
      end
    end

  end
end