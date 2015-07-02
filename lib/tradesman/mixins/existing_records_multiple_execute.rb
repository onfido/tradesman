module Tradesman
  module ExistingRecordsMultipleExecute
    private

    def query_for_ids(params)
      params[:id] = self.class.adapter.find_all(conditions: params[:id]).collect &:id
      params
    end

    def execute_multiple(params_hash)
      params = params_hash[:params] || params_hash.except(:id)

      params_hash[:id].to_enum.with_index.map do |id, index|
        begin
          execute_single(single_params(id, params, index))
        rescue *self.class.expected_errors_map.keys => e
          Horza::Entities::Single.new(id: id, valid: false, message: e.message)
        end
      end
    end

    def single_params(id, params, index)
      { id: id }.merge(params_at_index(params, index))
    end

    def params_at_index(params, index)
      return params unless params.is_a? Array
      params[index]
    end
  end
end
