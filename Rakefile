# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'rubygems'
require 'bundler/setup'
require 'rational_nested_set/version'

task :default => :spec

task :spec do
  puts "\n" + (cmd = "bundle exec rspec spec")
#   %w(3.0 3.1 3.2).each do |rails_version|
#     puts "\n" + (cmd = "BUNDLE_GEMFILE='gemfiles/Gemfile.rails-#{rails_version}.rb' bundle exec rspec spec")
     system cmd
#   end
end

task :build do
  system "gem build rational_nested_set.gemspec"
end

task :release => :build do
  system "gem push rational_nested_set-#{RationalNestedSet::VERSION}.gem"
end

require 'rdoc/task'
desc 'Generate documentation for the rational_nested_set plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'RationalNestedSet'
  rdoc.options  << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
