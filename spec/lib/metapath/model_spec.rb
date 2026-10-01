# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metapath::Model do
  subject(:model) { described_class[name: "test", path: Pathname("0-a.txt")] }

  describe "#fetch" do
    it "answers value for key (string)" do
      model.attributes["test"] = "here"
      expect(model.fetch("test")).to eq("here")
    end

    it "answers value for key (symbol)" do
      model.attributes["test"] = "here"
      expect(model.fetch(:test)).to eq("here")
    end

    it "answers fallback when given fallback" do
      value = model.fetch "test", "safe"
      expect(value).to eq("safe")
    end

    it "answers fallback when given a block" do
      value = model.fetch("test") { "safe" }
      expect(value).to eq("safe")
    end

    it "fails when key isn't found" do
      expectation = proc { model.fetch "test" }
      expect(&expectation).to raise_error(KeyError, /test/)
    end
  end

  describe "#tag?" do
    it "answers true when found" do
      model.tags.append "test", "other"
      expect(model.tag?("test")).to be(true)
    end

    it "answers false when not found" do
      expect(model.tag?("test")).to be(false)
    end
  end

  describe "#key?" do
    it "answers true when key exists" do
      model.attributes["test"] = true
      expect(model.key?("test")).to be(true)
    end

    it "answers false when key doesn't exist" do
      expect(model.key?("test")).to be(false)
    end
  end

  describe "#partial?" do
    it "answers true when file is a partial" do
      model = described_class[name: "test", path: Pathname("_test.txt")]
      expect(model.partial?).to be(true)
    end

    it "answers false when file isn't a partial" do
      model = described_class[name: "test", path: Pathname("test.txt")]
      expect(model.partial?).to be(false)
    end
  end

  describe "#errors?" do
    it "answers true when not empty" do
      model.errors[:test] = "danger"
      expect(model.errors?).to be(true)
    end

    it "answers false when empty" do
      expect(model.errors?).to be(false)
    end
  end
end
