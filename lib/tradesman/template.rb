module Tradesman
  class Template
    include ::Tzu
    include ::Tzu::Validation
    extend ::Tradesman::ClassMethods

    def call(params)
      return execute_single(params) unless (params.is_a?(Array) || params[:id].is_a?(Array))
      execute_multiple(params)
    rescue Horza::Errors::RecordInvalid, Horza::Errors::RecordNotFound => e
      invalid! e
    end

    private

    def execute_single(params)
      raise Tradesman::Errors::MethodNotImplemented.new('You must implement this method in a child class')
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
