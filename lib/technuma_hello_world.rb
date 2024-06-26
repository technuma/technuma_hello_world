# frozen_string_literal: true

require_relative "technuma_hello_world/version"

# module TechnumaHelloWorld
#   class Error < StandardError; end
#   def self.hello
#     "Hello World"
#   end
# end
module TechnumaHelloWorld
  class Railtie < Rails::Railtie
    initializer 'predicate_builder_extension.configure_rails_initialization' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::PredicateBuilder.prepend Module.new {
          def [](attr_name, value, operator = nil)
            if !operator && attr_name.end_with?(">", ">=", "<", "<=")
              /\A(?<attr_name>.+?)\s*(?<operator>>|>=|<|<=)\z/ =~ attr_name
              operator = OPERATORS[operator]
            end

            super
          end

          OPERATORS = { ">" => :gt, ">=" => :gteq, "<" => :lt, "<=" => :lteq }.freeze
        }
      end
    end
  end
end
