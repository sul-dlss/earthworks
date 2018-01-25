#
# Generates sitemaps/sitemap*.xml.gz files from all of the slugs in the Solr index
#
require 'blacklight'
require 'sitemap_generator'

# fetch all the slugs and their last modified (indexed) date
solr = Blacklight.default_index.connection
response = solr.get 'select', :params => {
  :q => '*:*',
  :facet => 'false',
  :rows => 1000000, # keep this very large
  :fl => 'layer_slug_s,timestamp'
}
raise RuntimeError, "Solr #{solr} returned no results" if response.nil? || response['response'].nil?

# iterate through the slugs to generate hash for slug=>lastmod
# puts "Found #{response['response']['docs'].length} slugs"
slugs = {}
response['response']['docs'].each do |doc|
  slugs[doc['layer_slug_s']] = doc['timestamp'] unless doc['layer_slug_s'].nil?
end

# generate sitemaps/sitemap*.xml.gz for all slugs
SitemapGenerator::Sitemap.default_host = Settings.HOST_URL
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'
SitemapGenerator::Sitemap.create_index = :auto
SitemapGenerator::Sitemap.create do
  slugs.each_pair do |slug,lastmod|
    add "/catalog/#{slug}", :changefreq => 'monthly', :lastmod => lastmod
  end
end
