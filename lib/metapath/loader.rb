# frozen_string_literal: true

require "dry/monads"
require "refinements/hash"
require "yaml"

module Metapath
  # Load directory metadata.
  class Loader
    include Dry::Monads[:result]

    using Refinements::Hash

    def initialize yaml: YAML
      @yaml = yaml
    end

    def call path
      load path
    rescue Errno::ENOENT,
           NoMethodError,
           Psych::AliasesNotEnabled,
           Psych::DisallowedClass,
           Psych::SyntaxError => error

      Failure error.message
    end

    private

    attr_reader :yaml

    def load path
      yaml.safe_load_file(path).then do |content|
        case content
          in Hash then Success content.symbolize_keys
          in String then Failure "Invalid content: #{content}."
          else Success Hash.new
        end
      end
    end
  end
end
