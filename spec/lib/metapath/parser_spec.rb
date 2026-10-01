# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metapath::Parser do
  subject(:parser) { described_class.new }

  describe "#call" do
    it "answers label with numbers only" do
      expect(parser.call("123")).to eq(name: "123", label: "123")
    end

    it "answers label with letters only" do
      expect(parser.call("abc")).to eq(name: "abc", label: "abc")
    end

    it "answers label with Unicode letters only" do
      expect(parser.call("Yōtei")).to eq(name: "Yōtei", label: "Yōtei")
    end

    it "answers label with alphanumeric characters" do
      expect(parser.call("123abc")).to eq(name: "123abc", label: "123abc")
    end

    it "answers label and position when delimited by a dash" do
      expect(parser.call("1-test")).to eq(name: "test", label: "test", position: "1")
    end

    it "answers label and position (leading zeros) when delimited by a dash" do
      expect(parser.call("01-test")).to eq(name: "test", label: "test", position: "01")
    end

    it "answers label with dash expanded with leading spaces" do
      expect(parser.call("test-a")).to eq(name: "test-a", label: "test - a")
    end

    it "answers label with dashes expanded with leading spaces" do
      expect(parser.call("test-a-b-c")).to eq(name: "test-a-b-c", label: "test - a - b - c")
    end

    it "answers label with underscore transformed as a space" do
      expect(parser.call("test_a")).to eq(name: "test_a", label: "test a")
    end

    it "answers label with underscores transformed as spaces" do
      expect(parser.call("test_a_b_c")).to eq(name: "test_a_b_c", label: "test a b c")
    end

    it "answers tags and attributes with Unicode characters" do
      expect(parser.call("test+déjà_vu,kind=déjà_vu")).to eq(
        name: "test",
        label: "test",
        tags: ["déjà_vu"],
        attributes: {"kind" => "déjà_vu"}
      )
    end

    it "answers single tag" do
      expect(parser.call("test+a")).to eq(name: "test", label: "test", tags: ["a"])
    end

    it "answers multiple tags" do
      expect(parser.call("test+a,b,c")).to eq(name: "test", label: "test", tags: %w[a b c])
    end

    it "answers single attribute" do
      expect(parser.call("test+a=1")).to eq(name: "test", label: "test", attributes: {"a" => "1"})
    end

    it "answers multiple attributes" do
      expect(parser.call("test+a=1,b=2,c=3")).to eq(
        name: "test",
        label: "test",
        attributes: {"a" => "1", "b" => "2", "c" => "3"}
      )
    end
  end

  describe "#inspect" do
    it "includes no instance veriables" do
      expect(parser.inspect).not_to include("@")
    end
  end
end
