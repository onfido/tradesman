module Tradesman
  module Builders
    class Create < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          include ::Tradesman::NewRecordsMultipleExecute
          @store = Tradesman.adapter.context_for_entity(args[:subject])

          class << self
            def go(params, *context, &block)
              run_and_convert_exceptions { run(params, *context, &block) }
            end

            def go!(params, *context)
              run_and_convert_exceptions { run!(params, *context) }
            end
          end

          private

          def execute_single(params)
            self.class.adapter.create!(params)
          end
        end
      end
    end
  end
end
