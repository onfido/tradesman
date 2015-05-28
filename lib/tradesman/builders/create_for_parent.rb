module Tradesman
  module Builders
    class CreateForParent < Base
      private

      def template_class(args)
        Class.new do
          include ::Tzu
          include ::Tzu::Validation

          class << self
            attr_reader :store, :parent_store, :parent_key

            def adapter
              Tradesman.adapter.new(store)
            end

            def parent_adapter
              Tradesman.adapter.new(parent_store)
            end
          end

          @store = Tradesman.adapter.context_for_entity(args[:subject])
          @parent_store = Tradesman.adapter.context_for_entity(args[:parent])
          @parent_key = args[:parent]

          def call(params)
            parent = self.class.parent_adapter.get!(params[:parent_id])
            self.class.adapter.create!(params.except(:parent_id).merge(relation_id => parent.id))
          rescue Horza::Errors::RecordInvalid, Horza::Errors::RecordNotFound => e
            invalid! e
          end

          private

          def relation_id
            "#{self.class.parent_key}_id"
          end
        end
      end
    end
  end
end
