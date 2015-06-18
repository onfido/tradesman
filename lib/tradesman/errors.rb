module Tradesman
  module Errors
    class Base < StandardError
    end

    class MethodNotImplemented < StandardError
    end

    class InvalidId < StandardError
    end

    class Invalid < StandardError
    end

    class Failure < StandardError
    end

    class RecordNotFound < StandardError
    end

    class RecordInvalid < StandardError
    end

    class UnknownAttributeError < StandardError
    end
  end
end
