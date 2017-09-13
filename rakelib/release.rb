require './rakelib/repository'
require './rakelib/changelog'

class Release

  GEM_NAME = 'csv_fast_importer'
  VERSION_FILE = 'lib/csv_fast_importer/version.rb'
  GEMFILE_LOCK = 'Gemfile.lock'

  def initialize(type)
    @type = type
  end

  def last_version
    CSVFastImporter::VERSION
  end

  def version
    @version ||= bump(last_version, @type)
  end

  def apply!
    sub_file_content VERSION_FILE, last_version, version
    sub_file_content GEMFILE_LOCK, "#{GEM_NAME} (#{last_version})", "#{GEM_NAME} (#{version})"
  end

  def changelog
    @changelog ||= Changelog.parse(Repository.log_from("v#{last_version}"))
  end

  def git_commit
    `git add #{VERSION_FILE} #{GEMFILE_LOCK}`
    `git commit -m 'Chore / Change version to #{version}'`
  end

private

  def bump(version, bump_type)
    major, minor, patch = version.split(".").map(&:to_i)
    if bump_type == 'major'
      major += 1
      minor = 0
      patch = 0
    elsif bump_type == 'minor'
      minor += 1
      patch = 0
    else
      patch += 1
    end
    [major, minor, patch].join(".")
  end

  def sub_file_content(file_path, from, to)
    current_content = File.read(file_path)
    modified_content = current_content.sub(from, to)
    raise "Cannot find regexp #{from} in file #{file_path}" if modified_content == current_content
    File.open(file_path, "w") { |file| file << modified_content }
  end

end
