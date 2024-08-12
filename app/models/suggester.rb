class Suggester
  def self.suggest(search_service, query)
    new(search_service, query).suggestions
  end

  def initialize(search_service, query, max_results: 50)
    @query = query
    @search_service = search_service
    @max_results = max_results
  end

  def suggestions
    make_suggestions(search)
  end

  private

  def search
    solr_q = "dct_title_ti:#{@query}* OR dct_spatial_tmi:#{@query}*"
    @search_service.repository.search(
      q: solr_q,
      rows: @max_results,
      fl: %w[id dct_title_s dct_spatial_sm gbl_resourceClass_sm]
    )
  end

  def make_suggestions(response)
    suggestions = Suggestions.new(query: @query)

    response['response']['docs'].each do |solr_doc|
      suggestions.add(solr_doc)
    end

    suggestions
  end
end

class Suggestions
  def initialize(query:)
    @query = query
    @items = Set.new
  end

  def add(solr_doc)
    @items.add(Suggestion.from_solr_doc(solr_doc: solr_doc, query: @query))
    locations = solr_doc['dct_spatial_sm'] || []
    locations.each do |loc|
      @items.add(Suggestion.new(name: loc, types: ['Location'], query: @query))
    end
  end

  def locations
    @locations ||= @items.filter(&:location?)
  end

  def datasets
    @datasets ||= @items.filter(&:dataset?)
  end

  def maps
    @maps ||= @items.filter(&:map?)
  end
end

class Suggestion
  attr_reader :name, :id, :types

  def self.from_solr_doc(solr_doc:, query:)
    name = solr_doc['dct_title_s']
    types = solr_doc['gbl_resourceClass_sm']
    id = solr_doc['id']

    Suggestion.new(name: name, types: types, query: query, id: id)
  end

  def initialize(name:, types:, query:, id: nil)
    @name = name
    @types = types
    @query = query
    @id = id
  end

  def dataset?
    @types.include?('Datasets') && match?(@name)
  end

  def map?
    @types.include?('Maps') && match?(@name)
  end

  def location?
    @types.include?('Location') && match?(@name)
  end

  def match?(str)
    str.match?(/\b#{@query}/i)
  end

  def highlighted_name
    @name.gsub(/\b(#{@query})/i, '<b>\1</b>')
  end

  def eql?(other)
    @name == other.name && @types == other.types
  end

  def hash
    [@name, @types].hash
  end
end
