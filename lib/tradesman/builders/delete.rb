module Tradesman
  module Builders
    class Delete < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          @store = Tradesman.adapter.context_for_entity(args[:subject])

          class << self
            def go(obj, *context, &block)
              run_and_convert_exceptions { run(tzu_params(obj, {}), *context, &block) }
            end

            def go!(obj, *context)
              run_and_convert_exceptions { run!(tzu_params(obj, {}), *context) }
            end
          end

          private

          def execute_single(params)
            self.class.adapter.delete!(params[:id])
          end
        end
      end
    end
  end
end
