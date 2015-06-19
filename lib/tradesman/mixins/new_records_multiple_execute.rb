module Tradesman
  module NewRecordsMultipleExecute
    private

    def execute_multiple(params_array)
      params_array.map do |params|
        begin
          execute_single(params)
        rescue *self.class.expected_errors_map.keys => e
          Horza::Entities::Single.new(id: nil, valid: false, message: e.message)
        end
      end
    end
  end
end
