module Tradesman
  class Template
    include ::Tzu
    include ::Tzu::Validation
    extend ::Tradesman::ClassMethods
    extend ::Tradesman::ErrorHandling

    def call(params)
      params = query_for_ids(params) if (params.is_a?(Hash) && params[:id] && params[:id].is_a?(Hash))
      return execute_single(params) unless (params.is_a?(Array) || params[:id].is_a?(Array) || params[:params].is_a?(Array))
      execute_multiple(params)
    rescue *self.class.expected_horza_errors_map.keys => e
      invalid! e
    end

    private

    def query_for_ids(params)
      raise Tradesman::MethodNotImplemented.new('You must implement query_for_ids in a child class')
    end

    def execute_single(params)
      raise Tradesman::MethodNotImplemented.new('You must implement execute_single in a child class')
    end

    def execute_multiple(params_hash)
      raise Tradesman::MethodNotImplemented.new('You must implement execute_multiple in a child class')
    end
  end
end
