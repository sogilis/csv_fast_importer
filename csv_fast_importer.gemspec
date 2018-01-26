# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'csv_fast_importer/version'

Gem::Specification.new do |spec|
  spec.name          = "csv_fast_importer"
  spec.version       = CSVFastImporter::VERSION
  spec.authors       = ["Sogilis"]
  spec.email         = ["sogilis@sogilis.com"]

  spec.summary       = "Fast CSV Importer"
  spec.description   = "A gem to import CSV files' content into a PostgreSQL or MySQL database. It is respectively based on PostgreSQL COPY and MySQL LOAD DATA INFILE which are designed to be as fast as possible."
  spec.homepage      = "https://github.com/sogilis/csv_fast_importer"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pg", ">= 0.18.4"
  spec.add_development_dependency "mysql2", ">= 0.3.10"
  spec.add_development_dependency "codacy-coverage"
  spec.add_development_dependency "rspec"

  # Only for benchmark
  spec.add_development_dependency "smarter_csv"
  spec.add_development_dependency "activerecord-import"
  spec.add_development_dependency "bulk_insert"
  spec.add_development_dependency "upsert"
  spec.add_development_dependency "csv-importer"
  spec.add_development_dependency "active_importer"
  spec.add_development_dependency "ferry"

  spec.add_runtime_dependency "activerecord", ["~> 4.2"]
end
