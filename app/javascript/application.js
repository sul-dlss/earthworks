// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "bootstrap";
import "@github/auto-complete-element";
import "blacklight";
import "controllers/application";
import "geoblacklight";
import "controllers";
import basemaps from "geoblacklight/leaflet/basemaps";
basemaps['positron']['noWrap'] = true;
basemaps['positron']['worldCopyJump'] = false;
basemaps['positron']['minZoom'] = .5;
