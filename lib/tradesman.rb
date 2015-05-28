require 'tradesman/builders'
require 'tradesman/builders/base'
require 'tradesman/builders/create'
require 'tradesman/builders/create_for_parent'
require 'tradesman/builders/delete'
require 'tradesman/builders/update'
require 'tradesman/configuration'
require 'tradesman/errors'
require 'tradesman/parser'
require 'tradesman/run_methods'
require 'horza'
require 'tzu'

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

  def run
    run!
  rescue ::Tradesman::Errors::Base
  end

  def run!
    call
  rescue *Tradesman.adapter.expected_errors => e
    raise ::Tradesman::Errors::Base.new(e.message)
  end
end
