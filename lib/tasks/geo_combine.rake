spec = Gem::Specification.find_by_name 'geo_combine'
load "#{spec.gem_dir}/lib/tasks/geo_combine.rake"
