module Tradesman
  module ClassMethods
    attr_reader :store

    def adapter
      Tradesman.adapter.new(store)
    end

    def go(obj, params, *context, &block)
      run_and_convert_exceptions { run(tzu_params(obj, params), *context, &block) }
    end

    def go!(obj, params, *context)
      run_and_convert_exceptions { run!(tzu_params(obj, params), *context) }
    end

    def tzu_params(obj, params)
      { id: prepare_ids(obj) }.merge(prepare_params(params))
    end

    def prepare_ids(obj)
      return id_from_obj(obj) unless obj.is_a? Array
      obj.map { |object| id_from_obj(object) }
    end

    def id_from_obj(obj)
      return obj.id if obj.respond_to? :id
      raise Tradesman::InvalidId.new('ID must be an integer') unless obj.is_a? Integer
      obj
    end

    def prepare_params(params)
      return params unless params.is_a? Array
      { params: params }
    end
  end
end
