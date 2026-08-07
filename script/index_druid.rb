require_relative '../config/environment'

# read a druid from the command line
druid = ARGV[0]
if druid.nil?
  puts 'Provide a druid as an argument'
  exit 1
end

# fetch the cocina record from PURL
cocina_record = CocinaService.fetch_record(druid)
if cocina_record.blank?
  puts "No public cocina record found for #{druid}"
  exit 1
end

# update and issue a commit to ensure the update is live
SolrService.update(cocina_record)
SolrService.connection.commit
puts "Updated #{druid}"
