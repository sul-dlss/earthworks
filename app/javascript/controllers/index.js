// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import {
  CloverViewerController,
  LeafletViewerController,
  OpenlayersViewerController,
  OembedViewerController,
  SearchResultsController,
  DownloadsController,
  ClipboardController,
} from "@geoblacklight/frontend";

// Register GeoBlacklight stimulus controllers
application.register("clover-viewer", CloverViewerController);
application.register("leaflet-viewer", LeafletViewerController);
application.register("oembed-viewer", OembedViewerController);
application.register("openlayers-viewer", OpenlayersViewerController);
application.register("search-results", SearchResultsController);
application.register("downloads", DownloadsController);
application.register("clipboard", ClipboardController);

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load controllers as they appear in the DOM (remember not to preload controllers in import map!)
// import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
// lazyLoadControllersFrom("controllers", application)
