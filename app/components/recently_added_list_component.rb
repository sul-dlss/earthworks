# frozen_string_literal: true

class RecentlyAddedListComponent < ViewComponent::Base
  attr_reader :count, :docs, :type, :field, :term

  def initialize(term:, additional_fq: '', rows: 4, field: 'gbl_resourceClass_sm')
    super()
    @fq = ["#{field}:#{term}"] + [additional_fq]
    @field = field
    @rows = rows
    @sort = 'gbl_mdModified_dt desc'
    response = results['response']
    @docs = response['docs']
    @count = response['numFound']
    @term = term
    @type = term.downcase
  end

  def search_params
    {
      'fq' => @fq,
      'sort' => @sort,
      'rows' => @rows,
      'fl' => [Settings.FIELDS.TITLE, Settings.FIELDS.ID, Settings.FIELDS.RESOURCE_TYPE]
    }
  end

  def results
    solr = RSolr.connect url: Blacklight.connection_config[:url]
    @results = solr.get 'select', params: search_params
  end
end
