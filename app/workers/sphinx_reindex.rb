class SphinxReindex
  @queue = :sphinx_reindex_queue

  def self.perform

  end

end

#Resque.enqueue(SphinxReindex)