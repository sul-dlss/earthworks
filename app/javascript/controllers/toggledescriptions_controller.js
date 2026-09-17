import { Controller } from "@hotwired/stimulus"
import initializeTruncation from "geoblacklight/initializers/truncation"

// Shows or hides the descriptions of every search result at once. The control is a
// Bootstrap radio button group, which takes its pressed state from the checked radio,
// so there is no button state for us to keep track of here.
//
// GeoBlacklight truncates each description behind its own read more button, but it can
// only measure a description it can see, so truncation has to be (re)initialized once
// the descriptions are visible. It skips descriptions it has already truncated, so
// showing them repeatedly is safe.
export default class extends Controller {
  static outlets = ["description"]

  showDescriptions() {
    this.descriptionOutlets.forEach(description => {
      description.show();
    });

    initializeTruncation();
  }

  hideDescriptions() {
    this.descriptionOutlets.forEach(description => {
      description.hide();
    });
  }
}
