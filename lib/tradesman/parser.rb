module Tradesman
  class Parser
    attr_reader :class_name, :action_string, :subject_string, :parent_string

    PARSE_REGEX = /(Create|Update|Delete)(.+)/
    PARSE_REGEX_WITH_PARENT = /(Create|Update|Delete)(.+)4(.+)/

    def initialize(class_name)
      @class_name = class_name
      @match = class_name.to_s.match(regex)
      @action_string, @subject_string, @parent_string = @match.values_at(1, 2, 3) if @match
    end

    def match?
      !!@match
    end

    def action
      str_to_sym(@action_string)
    end

    def subject
      str_to_sym(@subject_string)
    end

    def parent
      return nil unless @parent_string
      str_to_sym(@parent_string)
    end

    private

    def regex
      /.+4.+/.match(@class_name) ? PARSE_REGEX_WITH_PARENT : PARSE_REGEX
    end

    def str_to_sym(str)
      str.underscore.symbolize
    end
  end
end
