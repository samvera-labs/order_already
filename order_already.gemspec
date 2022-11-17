# frozen_string_literal: true

require_relative "lib/order_already/version"

Gem::Specification.new do |spec|
  spec.name = "order_already"
  spec.version = OrderAlready::VERSION
  spec.authors = ["Jeremy Friesen", "Rob Kaufman"]
  spec.email = ["jeremy.n.friesen@gmail.com", "rob@notch8.com"]

  spec.summary = "A tiny gem to provide naive sorting for Fedora Commons objects."
  spec.description = "A tiny gem to provide naive sorting for Fedora Commons objects."
  spec.homepage = "https://github.com/scientist-softserv/order_already"
  spec.required_ruby_version = ">= 2.6.0"

  spec.licenses = ["Apache-2.0"]
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = File.join(spec.homepage, "CHANGELOG.md")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "rails-html-sanitizer", "~> 1.4"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'bixby', '~> 5.0', '>= 5.0.2' # bixby 5 briefly dropped Ruby 2.5
end
