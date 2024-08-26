import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    expand() {
        this.element.classList.remove("collapse");
    }

    collapse() {
        this.element.classList.add("collapse");
    }
}
