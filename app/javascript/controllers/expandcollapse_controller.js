import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static outlets = [ "description" ]
  toggleDescriptions(evt) {
    const activeClass = 'active'
    const currentActive = this.element.querySelector(`.${activeClass}`)
    currentActive.classList.remove(activeClass)
    currentActive.disabled = false;
    evt.currentTarget.disabled = true;
    evt.currentTarget.classList.add(activeClass)
    this.descriptionOutletElements.forEach(function(element) {
      element.classList.toggle("collapse");
    });
  }
}