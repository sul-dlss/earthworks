import { Controller } from "@hotwired/stimulus";

// More fully-featured version of GeoBlacklight's clipboard controller
// We have to register it under a different name in order to use it in the same app
// TODO: move these changes up to GeoBlacklight?
export default class extends Controller {
  static targets = ["copyButtonText", "copyButtonIcon", "copyContent"];

  // Copy text to clipboard and update copy button
  async copy(event) {
    let text = null;
  
    // If the event included a 'target' param, use the text content of that element
    if (event.params.target) {
      const target = this.element.querySelector(event.params.target);
      if (!target)
        console.warn("Copy target element not found", event.params.target);
      else text = target.textContent;
    }

    // Otherwise if a target element was explicitly designated, use its text content
    else if (this.hasCopyContentTarget) text = this.copyContentTarget.textContent;

    // If no text was found, log a warning and return
    if (!text) {
      console.warn("No text to copy");
      return;
    }

    // Copy the text to the clipboard; trim whitespace
    await navigator.clipboard.writeText(text.trim());

    // Update the copy button
    this.copyButtonTextTarget.innerHTML = "Copied";
    this.copyButtonIconTarget.classList.remove("d-none");
  }

  // Reset to the original state of the copy button
  reset() {
    this.copyButtonTextTarget.innerHTML = "Copy";
    this.copyButtonIconTarget.classList.add("d-none");
  }
}
