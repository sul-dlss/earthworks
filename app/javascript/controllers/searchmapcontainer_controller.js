import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    toggleMap() {
        this.element.classList.toggle("d-none");
    }
}