module Tradesman
  module Errors
    class Base < StandardError
    end

    class MethodNotImplemented < StandardError
    end

    class Invalid < StandardError
    end

    class Failure < StandardError
    end
  end
end
