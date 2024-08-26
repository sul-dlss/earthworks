import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["description"]
  static targets = ["expandButton", "collapseButton"]

  expandDescriptions() {
    this.descriptionOutlets.forEach(description => {
      description.expand();
    });

    this.toggleButtonStates();
  }


  collapseDescriptions() {
    this.descriptionOutlets.forEach(description => {
      description.collapse();
    });

    this.toggleButtonStates();
  }

  toggleButtonStates() {
    this.expandButtonTarget.classList.toggle("active");
    this.collapseButtonTarget.classList.toggle("active");
  }

}