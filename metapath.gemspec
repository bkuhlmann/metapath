# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "metapath"
  spec.version = "0.0.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://alchemists.io/projects/metapath"
  spec.summary = "A parser of enriched file path metadata."
  spec.license = "Hippocratic-2.1"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/bkuhlmann/metapath/issues",
    "changelog_uri" => "https://alchemists.io/projects/metapath/versions",
    "homepage_uri" => "https://alchemists.io/projects/metapath",
    "funding_uri" => "https://github.com/sponsors/bkuhlmann",
    "label" => "Metapath",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/bkuhlmann/metapath"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = ">= 4.0"

  spec.add_dependency "dry-monads", "~> 1.11"
  spec.add_dependency "dry-schema", "~> 1.16"
  spec.add_dependency "refinements", "~> 14.0"
  spec.add_dependency "zeitwerk", "~> 2.8"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
