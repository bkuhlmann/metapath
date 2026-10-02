# frozen_string_literal: true

require "dry/monads"
require "refinements/hash"
require "refinements/pathname"

module Metapath
  # Enriches paths with metadata.
  class Enricher
    include Dry::Monads[:result]

    using Refinements::Hash
    using Refinements::Pathname

    def initialize parser: Parser.new, loader: Loader.new, meta_file: "meta.yml"
      @parser = parser
      @loader = loader
      @meta_file = meta_file
      @metadata = {}
    end

    def call root
      metadata.clear
      visit(Pathname(root).expand_path).fmap { it.sort_by! { it[:path] } }
    end

    private

    attr_reader :parser, :loader, :meta_file, :metadata

    def visit directory, collection: []
      merge_metadata_for(directory).fmap do
        directory.children.each.with_object collection do |path, enrichments|
          next if path.fnmatch? "*#{meta_file}"

          if path.directory?
            visit path, collection: enrichments
          else
            enrichments.append enrich(path)
          end
        end
      end
    end

    def merge_metadata_for directory
      metadata.deep_merge! parser.call(directory.name)

      configuration_path = directory.files(meta_file).first

      return Success() unless configuration_path

      loader.call(configuration_path).fmap { metadata.deep_merge! it }
    end

    def enrich path
      parser.call(path.name).then do |data|
        merged = metadata.deep_merge data.to_h
        name = merged.delete(:name).downcase

        {name:, path:, **merged}
      end
    end
  end
end
