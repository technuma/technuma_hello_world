# frozen_string_literal: true

require_relative "technuma_hello_world/version"

require "technuma_hello_world/version"
require "active_support"
require "active_record"

module TechnumaHelloWorld
  class Error < StandardError; end

  module PredicateBuilderExtension
    def [](attr_name, value, operator = nil)
      if !operator && attr_name.end_with?(">", ">=", "<", "<=")
        /\A(?<attr_name>.+?)\s*(?<operator>>|>=|<|<=)\z/ =~ attr_name
        operator = OPERATORS[operator]
      end

      super
    end

    OPERATORS = { ">" => :gt, ">=" => :gteq, "<" => :lt, "<=" => :lteq }.freeze
  end
end

ActiveSupport.on_load(:active_record) do
  ActiveRecord::PredicateBuilder.prepend TechnumaHelloWorld::PredicateBuilderExtension
end
