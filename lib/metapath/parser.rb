# frozen_string_literal: true

require "refinements/hash"

module Metapath
  # Parses path metadata.
  class Parser
    using Refinements::Hash

    PATTERN = /
      (?:                       # Start non-capture group.
      (?<position>[0-9]+)       # Position capture group, numbers only.
      -                         # Dash.
      )?                        # End non-capture group and make it optional.
      (?<name>[[:word:]-]+)     # Name capture group, required.
      (?:                       # Non-capture group start.
      \+                        # Plus.
      (?<meta>[[:word:]\-,=]+)  # Meta capture group, required.
      )?                        # End non-capture group and make it optional.
    /x

    SPACERS = {dash: ["-", " - "], underscore: ["_", " "]}.freeze
    DELIMITERS = {array: ",", hash: "="}.freeze

    def initialize pattern: PATTERN, spacers: SPACERS, delimiters: DELIMITERS
      @pattern = pattern
      @spacers = spacers
      @delimiters = delimiters
    end

    def call path
      captures = path.to_s.match(pattern).named_captures
      meta = parse_metadata captures["meta"]
      name = captures["name"]

      {name:, label: parse_label(name), position: captures["position"], **meta}.compress
    end

    private

    attr_reader :pattern, :spacers, :delimiters

    def instance_variables_to_inspect = []

    def parse_label(value) = value.gsub(*spacers.fetch(:dash)).tr(*spacers.fetch(:underscore))

    def parse_metadata value
      return {} unless value

      value.split(delimiters.fetch(:array))
           .each
           .with_object({tags: [], attributes: {}}) { |item, all| add_metadata item, all }
    end

    def add_metadata item, bag
      if item.include? hash_delimiter
        key, value = item.split hash_delimiter
        bag[:attributes][key] = value
      else
        bag[:tags].append item
      end
    end

    def hash_delimiter
      @hash_delimiter ||= delimiters.fetch :hash
    end
  end
end
