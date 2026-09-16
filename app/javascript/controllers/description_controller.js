import { Controller } from "@hotwired/stimulus"

// Shows or hides one search result's description, driven by the toggledescriptions
// controller. Expanding and collapsing a visible description is GeoBlacklight's job,
// not ours: it truncates the description inside this element and adds its own read
// more button next to it.
export default class extends Controller {
  show() {
    this.element.hidden = false;
  }

  hide() {
    this.element.hidden = true;
  }
}
