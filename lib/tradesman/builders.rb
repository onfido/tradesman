module Tradesman
  module Builders
    class << self
      def generate_class(parser)
        Tradesman.const_set(parser.class_name, builder_for_action(parser.action, parser.parent).new(name).class)
      end

      def builder_for_method(action, parent)
        case action
        when :create
          parent ? CreateForParent : Create
        when :update
          Update
        when :delete
          Delete
        end
      end
    end
  end
end
