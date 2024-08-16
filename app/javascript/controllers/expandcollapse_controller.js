import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggleDescriptions(evt) {
    const activeClass = 'active'
    const currentActive = this.element.querySelector(`.${activeClass}`)
    currentActive.classList.remove(activeClass)
    currentActive.disabled = false;
    evt.currentTarget.disabled = true;
    evt.currentTarget.classList.add(activeClass)
    const elements = Array.from(document.getElementsByClassName('more-info-area'));
    elements.forEach(function(element) {
      element.children[0].classList.toggle("collapse");
    });
  }
}