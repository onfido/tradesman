module Tradesman
  module Builders
    class CreateForParent < Base
      private

      def class_args
      end

      def template_class(args)
        Class.new(::Get::Db) do
          include Tzu
        end
      end
    end
  end
end
