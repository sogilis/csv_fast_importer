require 'pathname'
require 'csv'
require 'tmpdir'

class CSVWriter

  def initialize(basename)
    @basename = basename
  end

  def create(content, options = {})
    new_file = new_temp_folder + @basename
    CSV.open(new_file.to_s, 'wb', {col_sep: ';'}.merge(options)) do |csv|
      content.each do |line|
        csv << line
      end
    end
    File.new new_file, options
  end

  def new_temp_folder
    tmp_folder = Pathname.new(Dir.mktmpdir)
    ObjectSpace.define_finalizer(self, proc { FileUtils.rm_rf tmp_folder })
    tmp_folder
  end

end
