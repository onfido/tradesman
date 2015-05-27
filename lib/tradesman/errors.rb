module Tradesman
  module Errors
    class Base < StandardError
    end

    class MethodNotImplemented < StandardError
    end

    class RecordNotFound < StandardError
    end
  end
end
