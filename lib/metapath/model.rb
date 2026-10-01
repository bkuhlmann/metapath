# frozen_string_literal: true

module Metapath
  # Stores path metadata.
  Model = Data.define :name, :path, :label, :position, :tags, :attributes, :errors do
    def initialize name:, path:, label: nil, position: 0, tags: [], attributes: {}, errors: {}
      super
    end

    def fetch(key, *default, &) = attributes.fetch(key.to_s, *default, &)

    def tag?(item) = tags.include? item

    def key?(value) = attributes.key? value

    def partial? = path.basename.fnmatch? "_*"

    def errors? = !errors.empty?
  end
end
