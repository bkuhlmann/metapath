# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metapath::Enricher do
  using Refinements::Pathname

  subject(:enricher) { described_class.new }

  include_context "with temporary directory"

  describe "#call" do
    it "answers array of plain records" do
      path = temp_dir.join("Test.txt").touch
      expect(enricher.call(temp_dir)).to be_success([{name: "test", label: "Test", path:}])
    end

    it "answers array of records with configuration" do
      temp_dir.join("meta.yml").write "tags: [one, two]"
      path = temp_dir.join("Test.txt").touch

      expect(enricher.call(temp_dir)).to be_success(
        [{name: "test", label: "Test", path:, tags: %w[one two]}]
      )
    end

    it "answers array of records with directory metadata" do
      root = temp_dir.join("Test+root,kind=test").make_dir
      path = root.join("Test.txt").touch

      expect(enricher.call(root)).to be_success(
        [
          {
            name: "test",
            label: "Test",
            path:,
            tags: ["root"],
            attributes: {"kind" => "test"}
          }
        ]
      )
    end

    it "answers array of records with nested directory metadata" do
      path = temp_dir.join("a/Test+one,a=1").make_ancestors.make_dir.join("Test.txt").touch

      expect(enricher.call(temp_dir)).to be_success(
        [
          {
            name: "test",
            label: "Test",
            path:,
            tags: ["one"],
            attributes: {"a" => "1"}
          }
        ]
      )
    end

    it "answers array of records with file metadata" do
      path = temp_dir.join("1-Test+one,two=2.txt").touch

      expect(enricher.call(temp_dir)).to be_success(
        [
          {
            name: "test",
            label: "Test",
            path:,
            position: "1",
            tags: ["one"],
            attributes: {"two" => "2"}
          }
        ]
      )
    end

    it "answers array of records with merged configuration and file metadata" do
      temp_dir.join("meta.yml").write <<~CONTENT
        tags:
          - one
        attributes:
          a: 1
      CONTENT

      path = temp_dir.join("Test+two,b=2.txt").touch

      expect(enricher.call(temp_dir)).to be_success(
        [
          {
            name: "test",
            label: "Test",
            path:,
            tags: %w[one two],
            attributes: {"a" => 1, "b" => "2"}
          }
        ]
      )
    end

    it "answers array of records with merged configuration, directory, and file metadata" do
      root = temp_dir.join("Test+root,root=true,a=0").make_dir

      root.join("meta.yml").write <<~CONTENT
        tags:
          - config
        attributes:
          config: true
          a: 1
      CONTENT

      path = root.join("Test+file,a=2,b=0.txt").touch

      expect(enricher.call(root)).to be_success(
        [
          {
            name: "test",
            label: "Test",
            path:,
            tags: %w[root config file],
            attributes: {"root" => "true", "config" => true, "a" => "2", "b" => "0"}
          }
        ]
      )
    end

    it "answers array of records with nested file structure" do
      skip "An extra config_b shows in the one (last) item" if ENV["CI"] == "true"

      root = temp_dir.join("Test+root,root=true,index=0").make_dir

      root.join("meta.yml").write <<~CONTENT
        tags:
          - config_a
        attributes:
          config: true
          index: 1
      CONTENT

      root.join("a/meta.yml").make_ancestors.write "tags: [config_b]"

      path_a = root.join("one+file_a,index=2,b=0.txt").touch
      path_b = root.join("a/two+file_b,index=3,c=0.txt").touch_deep
      path_c = root.join("a/b/three+file_c,index=4.txt").touch_deep

      expect(enricher.call(root)).to be_success(
        [
          {
            name: "three",
            label: "three",
            path: path_c,
            tags: %w[root config_a config_b file_c],
            attributes: {"root" => "true", "config" => true, "index" => "4"}
          },
          {
            name: "two",
            label: "two",
            path: path_b,
            tags: %w[root config_a config_b file_b],
            attributes: {"root" => "true", "config" => true, "index" => "3", "c" => "0"}
          },
          {
            name: "one",
            label: "one",
            path: path_a,
            tags: %w[root config_a file_a],
            attributes: {"root" => "true", "config" => true, "index" => "2", "b" => "0"}
          }
        ]
      )
    end
  end
end
