module Tradesman
  module Builders
    class CreateForParent < Base
      private

      def template_class(args)
        Class.new(::Tradesman::Template) do
          include ::Tradesman::ExistingRecordsMultipleExecute
          @store = Tradesman.adapter.context_for_entity(args[:subject])
          @parent_key = args[:parent]

          class << self
            attr_reader :parent_key
          end

          private

          def execute_single(params)
            self.class.adapter.create_as_child!(parent_args(params), params.except(:id))
          end

          def parent_args(params)
            { klass: self.class.parent_key, id: params[:id] }
          end

          def relation_id
            "#{self.class.parent_key}_id"
          end

          def execute_multiple(params_hash)
            params = params_hash[:params] || params_hash.except(:id)

            params.map do |params|
              begin
                execute_single({ id: params_hash[:id] }.merge(params))
              rescue *self.class.expected_errors_map.keys => e
                Horza::Entities::Single.new(id: params[:id], valid: false, message: e.message)
              end
            end
          end
        end
      end
    end
  end
end
