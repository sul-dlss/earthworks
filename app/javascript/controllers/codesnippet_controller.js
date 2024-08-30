import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["clipboardText", "clipboardCheck", "codeContent"];

    async copyToClipboard(event) {  
        const text = this.copyActivePaneContent();
        await navigator.clipboard.writeText(text);
        this.displayCopyClick();
    }

    copyActivePaneContent() {
      const codeText = this.codeContentTarget.querySelector("div.tab-pane.active pre code");
      if(! codeText) {
        console.error("Error copying content.  Code was not found");
        return "";
      }

      return codeText.textContent;
    }

    displayCopyClick() {
      if(! this.clipboardTextTarget) {
        console.log("Error finding copy button");
        return;
      }
    
      // Change the copy button text to "copied".
      // Make the copied checkmark visible. 
      this.clipboardTextTarget.innerHTML = "Copied";
      this.clipboardCheckTarget.classList.remove("d-none");
    }

    // When a user clicks on any of the language tabs, the copy button
    // display is reset to the original (i.e. not copied state).
    resetCopyClick() {
      this.clipboardTextTarget.innerHTML = "Copy";
      this.clipboardCheckTarget.classList.add("d-none");
    }
}
