# frozen_string_literal: true

require "dry/monads"

module Metapath
  # Validates and models metadata.
  class Modeler
    include Dry::Monads[:result]

    def initialize enricher: Enricher.new, schema: Schema, model: Model
      @enricher = enricher
      @schema = schema
      @model = model
    end

    def call(root) = enricher.call(root).fmap { build_models it }

    private

    attr_reader :enricher, :schema, :model

    def instance_variables_to_inspect = %i[@enricher @model]

    def build_models(data) = data.map { build_model it }

    def build_model data
      case schema.call(data).to_monad
        in Success(result)
          model[**result.to_h]
        in Failure(result)
          model[**data.slice(:name, :label, :path), errors: result.errors.to_h]
      end
    end
  end
end
