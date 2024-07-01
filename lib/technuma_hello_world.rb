# frozen_string_literal: true

require_relative "technuma_hello_world/version"
require "active_record"
require "active_support/concern"
require "logger"

module TechnumaHelloWorld
  class Error < StandardError; end
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::PredicateBuilder.prepend(Module.new do
      def [](attr_name, value, operator = nil)
        if !operator && attr_name.end_with?(">", ">=", "<", "<=")
          /\A(?<attr_name>.+?)\s*(?<operator>>|>=|<|<=)\z/ =~ attr_name
          operator = OPERATORS[operator]
        end

        super
      end

      OPERATORS = { ">" => :gt, ">=" => :gteq, "<" => :lt, "<=" => :lteq }.freeze
    end)
  end
end
