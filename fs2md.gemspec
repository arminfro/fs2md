# frozen_string_literal: true

require_relative 'lib/fs2md/version'

Gem::Specification.new do |spec|
  spec.name          = 'fs2md'
  spec.version       = Fs2md::VERSION
  spec.authors       = ['Armin Fröhlich']
  spec.email         = ['mail@arminfroehlich.de']

  spec.summary               = "It's a file-collector and -generator for Markdown files"
  spec.description           = 'It parses a directory recursive and collects all Markdown Files to generate a single Markdown file'
  spec.homepage              = 'https://www.github.com/arminfro/fs2md'
  spec.license               = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'irb', '~> 1.2'
  spec.add_development_dependency 'pry', '~> 0.11', '>= 0.11.3'
  spec.add_development_dependency 'pry-byebug', '~> 3.8'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_dependency 'spellchecker', '>= 0.1.5'
  spec.add_dependency 'thor', '~> 0.20.3', '>= 0.20'
end
