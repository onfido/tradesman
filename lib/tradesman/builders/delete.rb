module Tradesman
  module Builders
    class Delete < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          @store = Tradesman.adapter.context_for_entity(args[:subject])

          private

          def execute(params)
            self.class.adapter.delete!(params[:id])
          end
        end
      end
    end
  end
end
