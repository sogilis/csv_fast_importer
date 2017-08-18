require 'csv_fast_importer'

desc 'Test csv_fast_importer gem in a rails application context'
task :csv_fast_importer => :environment do
  file = File.new 'knights.csv'
  imported_lines_count = CsvFastImporter.import(file)

  puts "#{imported_lines_count} knights imported."
end
