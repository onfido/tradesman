module Tradesman
  module Builders
    class Create < Base
      private

      def class_args
      end

      def template_class(args)
        Class.new(::Get::Db) do
          include Tzu
          include Tzu::Validations

          def call(params)
            store = Horza.adapter(self.class.subject) # Could be class level
            store.create!(params)
          rescue Horza::Error::Base => e
            invalid! e
          end
        end
      end
    end
  end
end
