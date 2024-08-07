/*
 * This code is used by the copy to clipboard function for the code snippet modal
*/
const setupCopyToClipboardListener = function () {
  const modalElement = document.getElementById("blacklight-modal");
  
  // For a click event on the modal itself, capture that and then check if it is the clipboard copy button
  modalElement.addEventListener("click", function(e){
    const button = e.target.closest(".btn-clipboard");
    if (button) {
      // Copy the text content from the selected pane
      copyActivePaneContent();
      // Change the text of the click button and add a checked icon
      displayCopyClick();
    }
    const tabPane = e.target.closest(".code-snippet-tab");
    if(tabPane) {
      resetCopyClick();
    }
  })
}

// Copy active code panel's code, based on which programming language the user has selected
const resetCopyClick = function() {
  const copyButtonText = document.querySelector("span#copyClipText");
  const copyCheck = document.querySelector("span#copyCheck");
  if(! copyButtonText) {
    console.log("Error finding copy button");
    return;
  }

  // Check if the check mark is visible, toggle on that basis
  if(! copyCheck.classList.contains("d-none")) {
    copyButtonText.innerHTML = "Copy";
    copyCheck.classList.add("d-none");
  }
}

const displayCopyClick = function() {
  const copyButtonText = document.querySelector("span#copyClipText");
  const copyCheck = document.querySelector("span#copyCheck");
  if(! copyButtonText) {
    console.log("Error finding copy button");
    return;
  }

  // If the check mark is not visible, then show the checkmark and change the text
  if(copyCheck.classList.contains("d-none")) {
    copyButtonText.innerHTML = "Copied";
    copyCheck.classList.remove("d-none");
  }
}

//
const copyActivePaneContent = function() {
  const codeText = document.querySelector("div#codeContent div.tab-pane.active pre code");
  if(! codeText) {
    console.log("Error copying content.  Code was not found");
    return;
  }

  try {
    navigator.clipboard.writeText(codeText.textContent)
  } catch (e) {
    console.warn(e);
  }  
}

// Load the viewer on page load and Turbolinks page change
document.addEventListener("DOMContentLoaded", setupCopyToClipboardListener);
document.addEventListener("turbolinks:load", setupCopyToClipboardListener);
