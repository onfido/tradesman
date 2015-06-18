module Tradesman
  module Builders
    class CreateForParent < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          @store = Tradesman.adapter.context_for_entity(args[:subject])
          @parent_store = Tradesman.adapter.context_for_entity(args[:parent])
          @parent_key = args[:parent]

          class << self
            attr_reader :parent_store, :parent_key

            def parent_adapter
              Tradesman.adapter.new(parent_store)
            end
          end

          private

          def execute(params)
            parent = self.class.parent_adapter.get!(params[:id])
            self.class.adapter.create!(params.except(:id).merge(relation_id => parent.id))
          end

          def relation_id
            "#{self.class.parent_key}_id"
          end
        end
      end
    end
  end
end
