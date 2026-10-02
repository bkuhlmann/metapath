# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metapath::Loader do
  using Refinements::Pathname

  subject(:loader) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    it "loads YAML" do
      content = <<~CONTENT
        tags:
          - one
          - two
        attributes:
          a: 1
          b: 2
        replacements:
          name: test
      CONTENT

      path = temp_dir.join("meta.yml").write content

      expect(loader.call(path)).to be_success(
        tags: %w[one two],
        attributes: {"a" => 1, "b" => 2},
        replacements: {"name" => "test"}
      )
    end

    it "answers empty hash with no content" do
      path = temp_dir.join("meta.yml").touch
      expect(loader.call(path)).to be_success({})
    end

    it "answers failure when file doesn't exist" do
      path = temp_dir.join "meta.yml"
      expect(loader.call(path)).to be_failure
    end

    it "answers failure with invalid content" do
      path = temp_dir.join("meta.yml").write "Danger"
      expect(loader.call(path)).to be_failure("Invalid content: Danger.")
    end

    it "answers faliure with invalid alias" do
      path = temp_dir.join("meta.yml").write <<~CONTENT
        &danger
        - *danger
      CONTENT

      expect(loader.call(path)).to be_failure
    end

    it "answers failure with invalid type" do
      path = temp_dir.join("meta.yml").write ":name: danger"
      expect(loader.call(path)).to be_failure("Tried to load unspecified class: Symbol")
    end

    it "answers failure with invalid syntax" do
      path = temp_dir.join("meta.yml").write "danger: %<value>s is invalid"
      expect(loader.call(path)).to be_failure
    end
  end
end
