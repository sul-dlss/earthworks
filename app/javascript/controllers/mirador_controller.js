
import { Controller } from "@hotwired/stimulus";
import Mirador from "mirador";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    console.log("connect");
    this.setupViewer();
  }

  setupViewer() {
    const target = this.containerTarget;
    if (target) {
      console.log('Mirador viewer setup for', target);
      // TODO: why is there no Mirador?
      if (Mirador) {
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
    }
  }
}