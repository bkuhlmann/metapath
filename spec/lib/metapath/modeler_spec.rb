# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metapath::Modeler do
  using Refinements::Pathname

  subject(:modeler) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    it "answers empty array when root path is empty" do
      expect(modeler.call(temp_dir)).to be_success([])
    end

    it "answers records without metadata" do
      path = temp_dir.join("test.txt").touch

      expect(modeler.call(temp_dir)).to be_success(
        [Metapath::Model[name: "test", label: "test", path:]]
      )
    end

    it "answers records with all attributes" do
      path = temp_dir.join("01-test+one,kind=test.txt").touch

      expect(modeler.call(temp_dir)).to be_success(
        [
          Metapath::Model[
            name: "test",
            label: "test",
            path:,
            position: 1,
            tags: ["one"],
            attributes: {"kind" => "test"}
          ]
        ]
      )
    end

    it "answers errors" do
      record = {
        name: "test",
        label: "test",
        path: temp_dir,
        position: nil,
        tags: nil,
        attributes: nil,
        replacements: nil
      }

      enricher = instance_double Metapath::Enricher, call: Success([record])
      modeler = described_class.new(enricher:)

      expect(modeler.call(temp_dir)).to be_success(
        [
          Metapath::Model[
            name: "test",
            label: "test",
            path: temp_dir,
            errors: {
              position: ["must be filled"],
              tags: ["must be filled"],
              attributes: ["must be filled"]
            }
          ]
        ]
      )
    end
  end

  describe "#inspect" do
    it "includes the enricher" do
      expect(modeler.inspect).to include("@enricher")
    end

    it "includes the model" do
      expect(modeler.inspect).to include("@model")
    end

    it "ignores the schema" do
      expect(modeler.inspect).not_to include("@schema")
    end
  end
end
