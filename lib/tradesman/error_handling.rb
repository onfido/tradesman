module Tradesman
  module ErrorHandling
    def run_and_convert_exceptions(&block)
      block.call
    rescue *expected_errors_map.keys => e
      raise tradesman_error_from_gem_error(e.class)
    end

    def tradesman_error_from_gem_error(gem_error)
      expected_errors_map[gem_error]
    end

    def expected_errors_map
      expected_tzu_errors_map.merge(expected_horza_errors_map)
    end

    def expected_tzu_errors_map
      {
        Tzu::Invalid => Tradesman::Invalid,
        Tzu::Failure => Tradesman::Failure,
      }
    end

    def expected_horza_errors_map
      {
        Horza::Errors::RecordNotFound => Tradesman::RecordNotFound,
        Horza::Errors::RecordInvalid => Tradesman::RecordInvalid,
        Horza::Errors::UnknownAttributeError => Tradesman::UnknownAttributeError
      }
    end
  end
end
