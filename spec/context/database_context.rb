shared_context 'test_kaamelott table with columns row_index, id and label' do
  include DatabaseHelper

  before do
    db.execute 'DROP TABLE IF EXISTS test_kaamelott'
    # TODO Replace by database_helper.rb / Schema.define
    case DB_TYPE
      when :mysql
        db.execute 'CREATE TABLE test_kaamelott ( row_index INT NULL, id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, label varchar(32) NOT NULL )'
      when :postgres
        db.execute 'CREATE TABLE test_kaamelott ( row_index int4 NULL, id serial NOT NULL, label varchar(32) NOT NULL )'
      else
        raise "Unknown database type: #{DB_TYPE}"
    end
  end

  let(:csv_writer) { CSVWriter.new 'test_kaamelott.csv' }

  def row_count
    db.query('SELECT COUNT(*) FROM test_kaamelott').to_i
  end

  def table_empty?
    row_count == 0
  end

  def insert_one_row
    db.execute("INSERT INTO test_kaamelott (id, label) VALUES (1, 'libelle')")
  end

  def write_file(content, options = {})
    csv_writer.create content, options
  end
end
