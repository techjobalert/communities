class SearchService

  def search query, options = {}

    default_options = { populate: true }
    options = default_options.merge options  
    result = []

    begin
      result = ThinkingSphinx.search query, options
    rescue Riddle::ConnectionError, ThinkingSphinx::SphinxError => e
      Rails.logger.error e
    end

    return result
  end
end