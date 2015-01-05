#!/usr/bin/env ruby
# 
# Usage: update.rb http://localhost:8080/solr/my-collection file1.json [file2.json...]
#
# XXX: Does NOT work with stored=false fields
#
require 'rsolr'
require 'nokogiri'

if ARGV.size < 2
  puts 'Usage: update.rb http://localhost:8080/solr/my-collection file1.json [file2.json...]'
  puts 'where JSON data has [["slug1", 0.1], ["slug2", 0.9] ...]'
  puts 'supports environment variable UPDATE_BY_FIELD=true for field-level atomic updates in Solr 4'
  exit -1
end

STOP_ON_ERROR = ENV['STOP_ON_ERROR'] == 'true' || false
UPDATE_BY_FIELD = ENV['UPDATE_BY_FIELD'] == 'true' || false
SCORE_FIELD = 'layer_availability_score_f'

solr = RSolr.connect :url => ARGV.delete_at(0) 

ARGV.each do |fn|
  puts "Processing #{fn}"
  begin
    n = 0
    if fn =~ /.json$/
      data = JSON.parse(File.open(fn, 'rb').read)
      data.each do |slug, score|
        puts "Processing #{n} #{slug} #{score}"
        q = "layer_slug_s:\"#{slug}\""
        res = solr.get 'select', :params => { :q=>q, :start=>0, :rows=>1 }
        doc = res['response']['docs'].first # assumes that we got a single hit using rows=1
        unless doc.nil?
          doc.delete('_version_')
          doc.delete('timestamp')
          doc.delete('score')
          doc[SCORE_FIELD] = score
          
          unless UPDATE_BY_FIELD
            solr.add doc
          else
            # Build raw XML document so that we can do partial update of the SCORE_FIELD
            # There are numerous caveats here: https://wiki.apache.org/solr/Atomic_Updates
            doc = {
              'uuid' => doc['uuid'],
              SCORE_FIELD => doc[SCORE_FIELD]
            }
            add_xml = solr.xml.add(doc) do |solr_xml_doc|
              solr_xml_doc.field_by_name(SCORE_FIELD).attrs[:update] = 'set'
            end
            solr.update :data => add_xml
          end
          
          n = n + 1
          if n % 100 == 0
            puts "Committing..."
            solr.commit
          end
        else
          puts "WARNING: Missing #{slug} in Solr index"
        end
      end
    else
      raise RuntimeError, "Unknown file type: #{fn}"
    end
  rescue => e
    puts "ERROR: #{e}: #{e.backtrace}"
    raise e if STOP_ON_ERROR
  end
end

puts "Committing"
solr.commit
puts "Done"
