# frozen_string_literal: true

require "dry/schema"

module Metapath
  # Validates metadata information.
  Schema = Dry::Schema.Params do
    required(:name).filled :string
    required(:label).filled :string
    required(:path).filled
    optional(:position).filled :integer
    optional(:tags).filled(:array).each(:string)
    optional(:attributes).filled :hash
  end
end
