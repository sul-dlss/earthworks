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
  exit -1
end

STOP_ON_ERROR = false
SCORE_FIELD = 'layer_availability_score_f'

solr = RSolr.connect :url => ARGV.delete_at(0) 

ARGV.each do |fn|
  puts "Processing #{fn}"
  begin
    n = 0
    if fn =~ /.json$/
      data = JSON.parse(File.open(fn, 'rb').read)
      data.each do |slug, score|
        puts "Processing #{slug} #{score}"
        q = "layer_slug_s:\"#{slug}\""
        res = solr.get 'select', :params => { :q=>q, :start=>0, :rows=>1 }
        doc = res['response']['docs'][0]
        unless doc.nil?
          doc.delete('_version_')
          doc.delete('timestamp')
          doc.delete('score')
          doc[SCORE_FIELD] = score
          solr.add doc
          
          n = n + 1
          if n % 100 == 0
            puts "Committing..."
            solr.commit
          end
        else
          puts "WARNING: Missing #{slug}"
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
