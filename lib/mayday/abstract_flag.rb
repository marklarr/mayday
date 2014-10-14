require 'sourcify'

module Mayday
  class AbstractFlag

    attr_accessor :message
    
    def initialize(message, &block)
      @block = block
      @message = message
    end

    def message_prefix
      ""
    end

    def full_message
      message_prefix + @message
    end

    def function_def_string
      <<-CODE

def #{function_name}(file)
  line_number = lambda { #{@block.to_source}.call(file.read) }.call
  if line_number
    "\#{file.path}:\#{line_number}: #{full_message} -[Wmayday]"
  else
    false
  end
end
CODE
    end

    def function_name
      @function_name ||= message.gsub(/\s/, "").gsub(/[^a-zA-Z]/, "") + "_#{rand(10000)}"
    end

  end
end