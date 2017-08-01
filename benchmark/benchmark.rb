require 'active_record'
require_relative './tools'

class Dataset < ActiveRecord::Base
end

db = database_connect
build_dataset(db, 'datasets', ENV['DATASET_SIZE'] || 10_000) do |file|
  lines_count = count(file)
  puts "Start benchmark with a #{lines_count} lines file."

  puts "Running benchmark..."
  require_relative './strategies'
  STRATEGIES.each do |label, strategy|
    db.execute 'TRUNCATE TABLE datasets'
    printf "%-35s: ", label

    duration = measure_duration { strategy.call(file) }

    warning_message = '(file partially imported)' if Dataset.count < lines_count - 1 # Header
    printf "%20d ms %s\n", duration, warning_message
  end
end

puts
puts "Benchmark finished."
