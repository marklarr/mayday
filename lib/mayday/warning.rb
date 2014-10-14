require "mayday/error"

module Mayday
  class Warning < Error

    def message_prefix
      "warning: "
    end

  end
end