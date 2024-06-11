// Borrowed from:
// https://github.com/sul-dlss/sul-embed/blob/main/app/javascript/src/modules/m3_viewer.js
const setupViewer = function () {
  const target = document.getElementById("mirador");
  if (target) {
    Mirador.viewer({
      id: "mirador",
      selectedTheme: "sul",
      themes: {
        sul: {
          palette: {
            type: "light",
            primary: {
              main: "#8c1515",
            },
            secondary: {
              main: "#8c1515",
            },
            shades: {
              dark: "#2e2d29",
              main: "#ffffff",
              light: "#f4f4f4",
            },
            notification: {
              main: "#e98300",
            },
          },
        },
      },
      windows: [
        {
          id: "main",
          loadedManifest: target.dataset.manifestUrl,
        },
      ],
      window: {
        allowClose: false,
        allowFullscreen: true,
        allowMaximize: false,
        authNewWindowCenter: "screen",
        hideWindowTitle: true,
        sidebarPanel: "attribution",
        views: [
          { key: "single", behaviors: [null, "individuals"] },
          { key: "book", behaviors: [null, "paged"] },
          { key: "scroll", behaviors: ["continuous"] },
          { key: "gallery" },
        ],
      },
      workspace: {
        showZoomControls: true,
        type: "single",
      },
      workspaceControlPanel: {
        enabled: false,
      },
    });
  }
};

// Load the viewer on page load and Turbolinks page change
document.addEventListener("DOMContentLoaded", setupViewer);
document.addEventListener("turbolinks:load", setupViewer);
