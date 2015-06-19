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

      def template_class(class_args)
        raise Tradesman::MethodNotImplemented.new('You must implement template_class in a child class')
      end

      private

      def class_args
        {
          subject: @subject,
          parent: @parent
        }
      end
    end
  end
end
