module Tradesman
  module Builders
    class Base
      def initialize(class_name)
        parser = ::Tradesman::Parser.new(class_name)
        @subject = parser.subject
        @parent = parser.parent
      end

      def class
        template_class(class_args)
      end

      private

      def class_args
      end
    end
  end
end
