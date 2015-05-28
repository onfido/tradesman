module Tradesman
  module Builders
    class Create < Base
      private

      def template_class(args)
        Class.new do
          include ::Tzu
          include ::Tzu::Validation

          class << self
            attr_reader :store

            def adapter
              Tradesman.adapter.new(store)
            end
          end

          @store = Tradesman.adapter.context_for_entity(args[:subject])

          def call(params)
            self.class.adapter.create!(params)
          rescue Horza::Errors::RecordInvalid => e
            invalid! e
          end
        end
      end
    end
  end
end
