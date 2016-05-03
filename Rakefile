# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'rake'

require 'jeweler'
require_relative 'lib/version'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification...
  # see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = 'html-hierarchy-extractor'
  gem.version = HTMLHierarchyExtractorVersion.to_s
  gem.homepage = 'http://github.com/pixelastic/html-hierarchy-extractor'
  gem.license = 'MIT'
  gem.summary = 'Extract HTML hierarchy (headings and content) into a' \
                ' list of items'
  gem.description = 'Take any arbitrary HTML as input and extract its' \
                    ' hierarchy as a list of items, including parents and' \
                    ' contents.' \
                    'It is primarily intended to be used along with Algolia,' \
                    ' to improve the relevance of searching into huge chunks' \
                    ' of text'
  gem.email = 'tim@pixelastic.com'
  gem.authors = ['Tim Carry']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.rspec_opts = '--color --format documentation'
  spec.pattern = FileList['spec/**/*_spec.rb']
end
task test: :spec

desc 'Code coverage detail'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: :test
