require File.join(File.dirname(__FILE__), 'lib', 'version')

Gem::Specification.new do |gem|
  # Required attributes
  gem.name = 'html-hierarchy-extractor'
  gem.summary = 'Extract HTML hierarchy (headings and content) '\
    'into a list of items'
  gem.version = HTMLHierarchyExtractorVersion.to_s

  # Recommended attributes
  gem.authors = ['Tim Carry']
  gem.description = 'Take any arbitrary HTML as input and extract its '\
    'hierarchy as a list of items, including parents and contents. It is '\
    'primarily intended to be used along with Algolia, to improve the '\
    'relevance of searching into huge chunks of text'
  gem.email = 'tim@pixelastic.com'
  gem.homepage = 'https://github.com/pixelastic/html-hierarchy-extractor'
  gem.licenses = ['MIT']

  # Dependencies
  gem.add_runtime_dependency 'awesome_print', '~> 1.6'
  gem.add_runtime_dependency 'json', '~> 2.0'
  gem.add_runtime_dependency 'nokogiri', '~> 1.8'

  gem.add_development_dependency 'coveralls', '~> 0.8.21'
  gem.add_development_dependency 'flay', '~> 2.6'
  gem.add_development_dependency 'flog', '~> 4.3'
  gem.add_development_dependency 'guard', '~> 2.14'
  gem.add_development_dependency 'guard-rake', '~> 1.0'
  gem.add_development_dependency 'guard-rspec', '~> 4.6'
  gem.add_development_dependency 'jeweler', '~> 2.0'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop', '~> 0.51'
  gem.add_development_dependency 'simplecov', '~> 0.14.1'

  # Files
  gem.files = Dir[
    'lib/**/*',
    'README.md',
    'CONTRIBUTING.md',
    'LICENSE.txt',
  ]
end
