# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rational_nested_set/version'

Gem::Specification.new do |spec|
  spec.name          = "rational_nested_set"
  spec.version       = RationalNestedSet::VERSION
  spec.authors       = ["Lungelo Ximba"]
  spec.email         = ["lungeloximba@gmail.com"]

  spec.summary       = %q{Advanced nested set model implementation for ActiveRecord models}
  spec.description   = %q{A nested set model that uses rational numbers to tag nodes and avoid updating all nodes on inserts.}
  spec.homepage      = %q{https://github.com/sximba/rational_nested_set}

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.extra_rdoc_files = %w[README.md]
  spec.rdoc_options = ["--main", "README.md", "--inline-source", "--line_numbers"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.license       = %q{MIT}

  spec.required_ruby_version = ">= 1.9.3"

  spec.add_runtime_dependency 'activerecord', '>= 4.0.0', '< 5'

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency 'rspec-rails', '~> 3.0'
  spec.add_development_dependency 'combustion', '>= 0.5.2'
  spec.add_development_dependency 'database_cleaner'
end
