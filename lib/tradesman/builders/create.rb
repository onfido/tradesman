module Tradesman
  module Builders
    class Create < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          @store = Tradesman.adapter.context_for_entity(args[:subject])

          private

          def execute(params)
            self.class.adapter.create!(params)
          end
        end
      end
    end
  end
end
