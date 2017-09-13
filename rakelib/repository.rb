class Repository

  def self.current_branch
    `git rev-parse --abbrev-ref HEAD`
  end

  def self.log_from(revision)
    `git log #{revision}..HEAD --pretty=format:"%s"`.split("\n")
  end
end
