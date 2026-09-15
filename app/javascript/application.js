// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "bootstrap";
import "@github/auto-complete-element";
import Blacklight from "blacklight-frontend";
import "controllers/application";
import "geoblacklight";
import "controllers";

import BlacklightRangeLimit from "blacklight-range-limit";
BlacklightRangeLimit.init({onLoadHandler: Blacklight.onLoad });
