(function () {
  document.addEventListener("DOMContentLoaded", () => {
    if (
      location.origin !== "https://im.live.360.cn:8282" ||
      !location.pathname.startsWith("/fed/web-module")
    ) {
      return;
    }

    // Isolate the left navigation's paint from the rest of the page so that
    // scrolling the content pane or typing does not re-rasterize the sidebar
    // icons (their drop-shadow recolor is the flicker source). `contain` scopes
    // paint invalidation without forcing a GPU compositing layer, so it avoids
    // the WKWebView side effect where a composited ancestor stops the caret from
    // blinking in an empty input. `.main-menu-box` already clips its overflow,
    // so paint containment adds no new clipping (the fold-out handle lives on a
    // sibling and is unaffected).
    const css = `
      .panel-frame-head .main-menu-box {
        contain: layout style paint;
      }
    `;

    const STYLE_ID = "pake-tuitui-sidebar-layer";
    if (typeof window.__PAKE_INJECT_STYLE__ === "function") {
      window.__PAKE_INJECT_STYLE__(css, STYLE_ID);
      return;
    }

    const style = document.createElement("style");
    style.id = STYLE_ID;
    style.textContent = css;
    document.head.appendChild(style);
  });
})();
