# coding: utf-8

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rising_dragon/version"

Gem::Specification.new do |spec|
  spec.name          = "rising_dragon"
  spec.version       = RisingDragon::VERSION
  spec.authors       = ["ota42y"]
  spec.email         = ["ota42y@gmail.com"]

  spec.summary       = "Event driven architecture library for AWS SNS/SQS"
  spec.homepage      = "https://github.com/ota42y/rising_dragon"
  spec.description   = "Event driven architecture library for AWS SNS/SQS include SQS worker and SNS publisher"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    # allow push to any host
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "shoryuken", "~> 3.1.7"

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "rspec", "~> 3"

  spec.add_development_dependency "rubocop", "~> 0.49.1"
  spec.add_development_dependency "onkcop", "~> 0.49.1"
  spec.add_development_dependency "pry", "~> 0.10"
  spec.add_development_dependency "pry-byebug", "~> 3.4"
end
