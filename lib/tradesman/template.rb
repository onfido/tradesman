module Tradesman
  class Template
    include ::Tzu
    include ::Tzu::Validation

    class << self
      attr_reader :store

      def adapter
        Tradesman.adapter.new(store)
      end
    end

    def call(params)
      execute(params)
    rescue Horza::Errors::RecordInvalid, Horza::Errors::RecordNotFound => e
      invalid! e
    end

    private

    def execute(params)
      raise Tradesman::Errors::MethodNotImplemented.new
    end
  end
end
