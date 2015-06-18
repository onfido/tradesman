module Tradesman
  class Template
    include ::Tzu
    include ::Tzu::Validation

    class << self
      attr_reader :store

      def adapter
        Tradesman.adapter.new(store)
      end

      def go(obj, params, *context, &block)
        run(tzu_params(obj, params), *context, &block)
      end

      def go!(obj, params, *context)
        run_and_convert_exceptions { run!(tzu_params(obj, params), *context) }
      end

      def tzu_params(obj, params)
        { id: id_from_obj(obj) }.merge(params)
      end

      def id_from_obj(obj)
        return obj.id if obj.respond_to? :id
        obj
      end

      # Execute the code block and convert ORM exceptions into Horza exceptions
      def run_and_convert_exceptions(&block)
        block.call
      rescue Tzu::Invalid => e
        raise Tradesman::Errors::Invalid.new(e)
      rescue Tzu::Failure => e
        raise Tradesman::Errors::Failure.new(e)
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
