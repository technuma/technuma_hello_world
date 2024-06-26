# frozen_string_literal: true

require_relative "technuma_hello_world/version"

module TechnumaHelloWorld
  class Error < StandardError; end
  def self.hello
    "Hello World"
  end
end
