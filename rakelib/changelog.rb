class Changelog
  attr_reader :changelog

  def initialize(changelog)
    @changelog = changelog
  end

  def self.parse(git_log)
    changelog = {}
    git_log.sort.uniq.each do |commit_message|
      type, message = commit_message.split('/', 2).map(&:strip)
      next if type == 'Chore'
      if message.nil?
        message = type
        type = 'Other'
      end
      changelog[type] = [] unless changelog.has_key?(type)
      changelog[type] << message
    end
    Changelog.new changelog
  end

  def to_s
    @changelog.map do |type, messages|
      "# #{type}\n" + messages.map { |message| "- #{message}\n" }.join + "\n"
    end.join
  end
end
