require 'get/builders/base_builder'
require 'get/builders/ancestry_builder'
require 'get/builders/query_builder'
require 'get/core_extensions/string'
require 'get/builders'
require 'get/configuration'
require 'get/db'
require 'get/entities'
require 'get/entity_factory'
require 'get/errors'
require 'get/run_methods'
require 'horza'

module Tradesman
  extend Tradesman::Configuration

  class << self
    attr_writer :configuration

    def included(base)
      base.class_eval do
        extend ::Tradesman::RunMethods
      end
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
