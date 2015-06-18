require 'horza'
require 'tzu'
require 'tradesman/builders'
require 'tradesman/builders/base'
require 'tradesman/builders/create'
require 'tradesman/builders/create_for_parent'
require 'tradesman/builders/delete'
require 'tradesman/builders/update'
require 'tradesman/class_methods'
require 'tradesman/configuration'
require 'tradesman/errors'
require 'tradesman/parser'
require 'tradesman/template'

module Tradesman
  extend Tradesman::Configuration

  class << self
    attr_writer :configuration

    def included(base)
      base.class_eval do
        extend ::Tradesman::RunMethods
      end
    end

    def const_missing(class_name)
      parser = ::Tradesman::Parser.new(class_name)
      return super(class_name) unless parser.match?
      Builders.generate_class(parser)
    end
  end
end
