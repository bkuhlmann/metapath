# frozen_string_literal: true

require "dry/schema"
require "zeitwerk"

Dry::Schema.load_extensions :monads

Zeitwerk::Loader.new.then do |loader|
  loader.inflector.inflect "cli" => "CLI"
  loader.tag = File.basename __FILE__, ".rb"
  loader.push_dir __dir__
  loader.setup
end

# Main namespace.
module Metapath
  def self.loader registry = Zeitwerk::Registry
    @loader ||= registry.loaders.each.find do |loader|
      loader.tag == File.basename(__FILE__, ".rb")
    end
  end

  def self.new = Modeler.new
end
