class RemoveSourceFile
  @queue = :notifications_queue

  def self.perform(path)
    # delete source file
    FileUtils.remove_file path, :verbose => true
  end

end