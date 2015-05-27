require 'tradesman/configuration'
require 'tradesman/errors'
require 'tradesman/run_methods'
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
