require ROOT_DIR.join('spec/support/database_helper')

shared_context 'knights table with columns row_index, id and name' do
  include DatabaseHelper

  before do
    db.execute 'DROP TABLE IF EXISTS knights'
    # TODO Replace by database_helper.rb / Schema.define
    case TEST_DATABASE.type
      when :mysql
        db.execute 'CREATE TABLE knights ( row_index INT NULL, id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, name varchar(32) NOT NULL )'
      when :postgres
        db.execute 'CREATE TABLE knights ( row_index int4 NULL, id serial NOT NULL, name varchar(32) NOT NULL )'
      else
        raise "Unknown database type: #{TEST_DATABASE.type}"
    end
  end

  let(:csv_writer) { CSVWriter.new 'knights.csv' }

  def row_count
    db.query('SELECT COUNT(*) FROM knights').to_i
  end

  def table_empty?
    row_count == 0
  end

  def insert_one_row
    db.execute("INSERT INTO knights (id, name) VALUES (1, 'night knight')")
  end

  def write_file(content, options = {})
    csv_writer.create content, options
  end
end
