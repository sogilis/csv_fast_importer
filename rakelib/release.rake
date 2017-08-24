require './rakelib/repository'
require './rakelib/release'

namespace :release do

  desc "Build new release.\n\t- bump_type (mandatory): [major|minor|patch|x.y.z]\n\t- dry_run (optional): skip commit, tag and publishing"
  task :make, [:bump_type, :dry_run] do |_, args|
    release = Release.new args[:bump_type]
    #raise "You can only release new version from master branch" unless Repository.current_branch == 'master'

    puts "Bump version from #{release.last_version} to #{release.version}"
    release.apply!

    puts
    puts "Changelog from #{release.last_version} to #{release.version}:"
    puts release.changelog
    puts "(Chores ignored)"

    next if args[:dry_run]

    release.git_commit

    puts
    puts "Release built."
    puts
    puts "Run following commands to publish version #{release.version}:"
    puts "$ git push && git push --tags"
    puts "$ Rake::Task['release'].invoke"
    puts
    puts "After that, do not forget to report changelog in Github Release."
  end
end

