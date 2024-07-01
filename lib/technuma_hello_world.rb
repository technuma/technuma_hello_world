# frozen_string_literal: true

require_relative "technuma_hello_world/version"
require "active_record"

module TechnumaHelloWorld
  class Error < StandardError; end

  def self.hello
    "Hello World"
  end
end
