require 'horza'
require 'tzu'
require 'tradesman/mixins/existing_records_multiple_execute'
require 'tradesman/mixins/new_records_multiple_execute'
require 'tradesman/builders'
require 'tradesman/builders/base'
require 'tradesman/builders/create'
require 'tradesman/builders/create_for_parent'
require 'tradesman/builders/delete'
require 'tradesman/builders/update'
require 'tradesman/class_methods'
require 'tradesman/configuration'
require 'tradesman/errors'
require 'tradesman/error_handling'
require 'tradesman/parser'
require 'tradesman/template'
require 'tradesman/version'

module Tradesman
  extend Configuration

  class << self
    attr_writer :configuration

    def const_missing(class_name)
      parser = ::Tradesman::Parser.new(class_name)
      return super(class_name) unless parser.match?
      Builders.generate_class(parser)
    end
  end
end
