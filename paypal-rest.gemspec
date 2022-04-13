# frozen_string_literal: true

require_relative "lib/paypal/rest/version"

Gem::Specification.new do |spec|
  spec.name          = "paypal-rest"
  spec.version       = Paypal::REST::VERSION
  spec.authors       = ["Elliot Crosby-McCullough"]
  spec.email         = ["elliot.cm@gmail.com"]

  spec.summary       = "Unofficial Ruby wrapper for the PayPal REST API"
  spec.homepage      = "https://github.com/SmartCasual/paypal-rest"
  spec.required_ruby_version = Gem::Requirement.new(">= 3.1.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/SmartCasual/paypal-rest/blob/#{spec.version}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) {
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_runtime_dependency "faraday", "~> 2.2"
  spec.add_runtime_dependency "faraday-retry", "~> 1.0"
end
