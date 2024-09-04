import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = ["searchmapcontainer"]

  toggleMap() {
    this.searchmapcontainerOutlets[0].toggleMap();
  }
}