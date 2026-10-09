# Fork Customizations

Technical notes for changes carried only by this fork (not present upstream).
Keep this file fork-only so it never conflicts when syncing from `upstream`.
The high-level list of fork changes lives in the README "Fork Notes" section;
this file records the non-obvious rationale behind them.

## Tuitui sidebar icon flicker fix

**Where:** `src-tauri/src/inject/custom.js` (guarded to
`https://im.live.360.cn:8282/fed/web-module`).

**Symptom:** In the packaged `tuitui` app on macOS (WKWebView), the left
navigation icons flickered whenever the page repainted — while typing in an
input or scrolling the content list.

**Root cause:** Tuitui recolors its left-nav icons with a
`filter: drop-shadow(30px 0)` + `transform: translate(-30px)` trick (draw a
solid-color silhouette offset into an `overflow:hidden` box, push the original
image out). WKWebView re-rasterizes that filter on every page repaint, so any
repaint elsewhere on the page made the icons flash.

**Fix:** Add `contain: layout style paint` to `.panel-frame-head .main-menu-box`
(the icon container, which already clips its overflow). This scopes paint
invalidation so a repaint in the content pane no longer re-rasterizes the
sidebar icons. The site's own icon styling is left untouched, so the icons keep
their original appearance.

**Why `contain` and not `translateZ(0)` (regression guard):** The first
attempt promoted the sidebar to its own GPU layer with `transform:
translateZ(0)`. That fixed the flicker but forced the whole page into
accelerated compositing, which is a known WKWebView state where the native
blink caret in an _empty_ input stops animating — the caret only reappeared
once the field had content. `contain` isolates paint **without** creating a
compositing layer, so it fixes the flicker while leaving the caret blink alone.

Do not "simplify" this back to `translateZ(0)` / `will-change: transform` /
`isolation` on the sidebar: any of those can re-trigger the empty-input caret
regression. If the flicker ever returns and `contain` proves insufficient,
prefer isolating the scroll/content container's paint over promoting the
sidebar to a GPU layer.

**Also avoid:** neutralizing the icons' own `filter`/`transform` (e.g.
`filter: none !important`). That stops the flicker too, but it breaks tuitui's
offset-recolor trick and leaves the icons clipped/mispositioned.

## Other fork patches worth noting on upstream sync

These touch files upstream changes frequently; expect the occasional conflict
and re-apply the fork intent rather than overwriting upstream wholesale.

- **`src-tauri/src/inject/event.js`** — a `target="_blank"` link that also has a
  `download` attribute is opened in the system browser instead of being
  rewritten into in-app navigation or a Pake-managed download. Tuitui uses this
  pattern to delegate downloads to the user's browser. Covered by
  `tests/unit/event-link-guard.test.js`.

## Dropped fork patches

- **`src-tauri/capabilities/default.json` remote allowlist** — the fork used to
  widen `remote.urls` to `https://*.*`, `https://*.*:*`, `http://*.*`, and
  `http://*.*:*` so packaged apps could load HTTP sites and explicit-port URLs.
  Upstream now keeps the packaged capability local-only and grants IPC to the
  exact configured entry origin (scheme, host, and port) through
  `PakeConfig::remote_capability`, which already covers
  `https://im.live.360.cn:8282`. Do not re-add the wildcards: they would grant
  native IPC to every remote origin and fail upstream's
  `remote_ipc_requires_the_configured_scheme_host_and_port` test.
