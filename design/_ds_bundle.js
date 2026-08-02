/* @ds-bundle: {"format":4,"namespace":"GitsuneDesignSystem_6e1df4","components":[{"name":"Button","sourcePath":"components/actions/Button.jsx"},{"name":"Card","sourcePath":"components/containers/Card.jsx"},{"name":"Tabs","sourcePath":"components/containers/Tabs.jsx"},{"name":"CiIcon","sourcePath":"components/core/CiIcon.jsx"},{"name":"Icon","sourcePath":"components/core/Icon.jsx"},{"name":"ICONS","sourcePath":"components/core/iconPaths.js"},{"name":"STATUS_ICONS","sourcePath":"components/core/iconPaths.js"},{"name":"FILE_ICONS","sourcePath":"components/core/iconPaths.js"},{"name":"ALL","sourcePath":"components/core/iconPaths.js"},{"name":"Avatar","sourcePath":"components/display/Avatar.jsx"},{"name":"Badge","sourcePath":"components/display/Badge.jsx"},{"name":"Label","sourcePath":"components/display/Label.jsx"},{"name":"Skeleton","sourcePath":"components/display/Skeleton.jsx"},{"name":"Token","sourcePath":"components/display/Token.jsx"},{"name":"Alert","sourcePath":"components/feedback/Alert.jsx"},{"name":"Toast","sourcePath":"components/feedback/Toast.jsx"},{"name":"ListRow","sourcePath":"components/navigation/ListRow.jsx"},{"name":"TabBar","sourcePath":"components/navigation/TabBar.jsx"},{"name":"Tile","sourcePath":"components/navigation/Tile.jsx"},{"name":"Drawer","sourcePath":"components/overlays/Drawer.jsx"},{"name":"Modal","sourcePath":"components/overlays/Modal.jsx"},{"name":"CodeBrowser","sourcePath":"ui_kits/gitsune-app/CodeBrowser.jsx"},{"name":"DiffList","sourcePath":"ui_kits/gitsune-app/DiffView.jsx"},{"name":"Explore","sourcePath":"ui_kits/gitsune-app/Explore.jsx"},{"name":"GitsuneApp","sourcePath":"ui_kits/gitsune-app/GitsuneApp.jsx"},{"name":"Home","sourcePath":"ui_kits/gitsune-app/Home.jsx"},{"name":"IssueView","sourcePath":"ui_kits/gitsune-app/IssueView.jsx"},{"name":"MergeRequest","sourcePath":"ui_kits/gitsune-app/MergeRequest.jsx"},{"name":"PhoneShell","sourcePath":"ui_kits/gitsune-app/PhoneShell.jsx"},{"name":"NavHeader","sourcePath":"ui_kits/gitsune-app/PhoneShell.jsx"},{"name":"LargeTitle","sourcePath":"ui_kits/gitsune-app/PhoneShell.jsx"},{"name":"Profile","sourcePath":"ui_kits/gitsune-app/Profile.jsx"},{"name":"SignIn","sourcePath":"ui_kits/gitsune-app/SignIn.jsx"},{"name":"TodoInbox","sourcePath":"ui_kits/gitsune-app/TodoInbox.jsx"}],"sourceHashes":{"components/actions/Button.jsx":"24617685e444","components/containers/Card.jsx":"452b069816ae","components/containers/Tabs.jsx":"f9c2de5d5c8c","components/core/CiIcon.jsx":"96eceaa4a3ad","components/core/Icon.jsx":"4311f5eb9f54","components/core/iconPaths.js":"37933014d3b3","components/core/injectStyle.js":"99309f545d71","components/display/Avatar.jsx":"3ea8159bab07","components/display/Badge.jsx":"dba70b1b78e9","components/display/Label.jsx":"403c348fe94a","components/display/Skeleton.jsx":"05ecc9d3345e","components/display/Token.jsx":"237b188401fb","components/feedback/Alert.jsx":"a9c2181184ec","components/feedback/Toast.jsx":"92791c78e90b","components/navigation/ListRow.jsx":"b7643891ba0f","components/navigation/TabBar.jsx":"4b6452e69136","components/navigation/Tile.jsx":"cd9f4bc5ee93","components/overlays/Drawer.jsx":"3c7c817c9258","components/overlays/Modal.jsx":"368b65bfd670","ui_kits/gitsune-app/CodeBrowser.jsx":"b8be0c36a755","ui_kits/gitsune-app/DiffView.jsx":"492d26dca8c4","ui_kits/gitsune-app/Explore.jsx":"4a3a5918ac28","ui_kits/gitsune-app/GitsuneApp.jsx":"eed0170d0320","ui_kits/gitsune-app/Home.jsx":"f7208707efb6","ui_kits/gitsune-app/IssueView.jsx":"8bb0f8876949","ui_kits/gitsune-app/MergeRequest.jsx":"ae7dfcd40ab5","ui_kits/gitsune-app/PhoneShell.jsx":"48f2e86774ed","ui_kits/gitsune-app/Profile.jsx":"80c8a0f0772a","ui_kits/gitsune-app/SignIn.jsx":"8ede6f984212","ui_kits/gitsune-app/TodoInbox.jsx":"02e5308655d7","ui_kits/gitsune-app/data.js":"a6333b8e2ff3"},"inlinedExternals":[],"unexposedExports":[{"name":"accounts","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"dartFile","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"diffFiles","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"favorites","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"fileTree","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"hunk","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"injectStyle","sourcePath":"components/core/injectStyle.js"},{"name":"issue","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"libTree","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"mr","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"myWork","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"todoReasons","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"todos","sourcePath":"ui_kits/gitsune-app/data.js"},{"name":"user","sourcePath":"ui_kits/gitsune-app/data.js"}]} */

(() => {

const __ds_ns = (window.GitsuneDesignSystem_6e1df4 = window.GitsuneDesignSystem_6e1df4 || {});

const __ds_scope = {};

(__ds_ns.__errors = __ds_ns.__errors || []);

// components/containers/Card.jsx
try { (() => {
/** Pajamas Card: bordered container grouping related content. */
function Card({
  children,
  padded = false,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--gs-surface-card)',
      border: '1px solid var(--gl-border-color-subtle)',
      borderRadius: 'var(--gl-card-border-radius)',
      boxShadow: '0 1px 2px var(--gl-color-alpha-dark-2)',
      overflow: 'hidden',
      padding: padded ? 16 : 0,
      ...style
    }
  }, children);
}
Object.assign(__ds_scope, { Card });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/containers/Card.jsx", error: String((e && e.message) || e) }); }

// components/core/iconPaths.js
try { (() => {
// GitLab SVG glyphs extracted verbatim from @gitlab/svgs 3.163.0 (dist/icons.svg, dist/file_icons/file_icons.svg).
// Do not hand-edit; regenerate from assets/icons/*.svg.
const ICONS = {
  "approval": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 6.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM7 5a2.99 2.99 0 0 1-.87 2.113A3.997 3.997 0 0 1 8 10.5V12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-1.5c0-1.427.747-2.679 1.87-3.387A3 3 0 1 1 7 5zm-5.5 5.5a2.5 2.5 0 0 1 5 0V12a.5.5 0 0 1-.5.5H2a.5.5 0 0 1-.5-.5v-1.5zm14.28-5.22a.75.75 0 0 0-1.06-1.06L12 6.94l-1.22-1.22a.75.75 0 1 0-1.06 1.06l1.75 1.75a.75.75 0 0 0 1.06 0l3.25-3.25z\"></path>"
  },
  "arrow-left": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.841 5.28a.75.75 0 0 0-1.06-1.06L1.53 7.47 1 8l.53.53 3.25 3.25a.75.75 0 0 0 1.061-1.06l-1.97-1.97H14.25a.75.75 0 0 0 0-1.5H3.871l1.97-1.97z\"></path>"
  },
  "arrow-right": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.159 10.72a.75.75 0 1 0 1.06 1.06l3.25-3.25L15 8l-.53-.53-3.25-3.25a.75.75 0 0 0-1.061 1.06l1.97 1.97H1.75a.75.75 0 1 0 0 1.5h10.379l-1.97 1.97z\"></path>"
  },
  "arrow-up": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.72 5.841a.75.75 0 1 0 1.06-1.06L8.53 1.53 8 1l-.53.53-3.25 3.25a.75.75 0 0 0 1.06 1.061l1.97-1.97V14.25a.75.75 0 0 0 1.5 0V3.871l1.97 1.97z\"></path>"
  },
  "arrow-down": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.72 10.159a.75.75 0 1 1 1.06 1.06l-3.25 3.25L8 15l-.53-.53-3.25-3.25a.75.75 0 0 1 1.06-1.061l1.97 1.97V1.75a.75.75 0 1 1 1.5 0v10.379l1.97-1.97z\"></path>"
  },
  "at": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.774 1.747a6.5 6.5 0 1 0 1.142 12.062.75.75 0 0 1 .673 1.34A8 8 0 1 1 16 8v1.25a2.75 2.75 0 0 1-5.072 1.475A4 4 0 1 1 12 8v1.25a1.25 1.25 0 0 0 2.5 0V8a6.5 6.5 0 0 0-4.726-6.253zM10.5 8a2.5 2.5 0 1 0-5 0 2.5 2.5 0 0 0 5 0z\"></path>"
  },
  "bold": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 2a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h5.5a3.5 3.5 0 0 0 1.852-6.47A3.5 3.5 0 0 0 8.5 2H4zm4.5 5a1.5 1.5 0 1 0 0-3H5v3h3.5zM5 9v3h4.5a1.5 1.5 0 0 0 0-3H5z\"></path>"
  },
  "branch": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.5 4.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm2.5-1a2.501 2.501 0 0 1-1.872 2.42A3.502 3.502 0 0 1 8.75 8.5h-1.5a2 2 0 0 0-1.965 1.626 2.501 2.501 0 1 1-1.535-.011v-4.23a2.501 2.501 0 1 1 1.5 0v1.742a3.484 3.484 0 0 1 2-.627h1.5a2 2 0 0 0 1.823-1.177A2.5 2.5 0 1 1 14 3.5zm-8.5 9a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm0-9a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "calendar": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.75 1a.75.75 0 0 1 .75.75V3h5V1.75a.75.75 0 0 1 1.5 0V3h2a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h2V1.75A.75.75 0 0 1 4.75 1zM2.5 4.5V6h11V4.5h-11zm0 9v-6h11v6h-11zM11 11a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "cancel": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.035 13.096a6.5 6.5 0 0 1-9.131-9.131l9.131 9.131zm1.061-1.06L3.965 2.903a6.5 6.5 0 0 1 9.131 9.131zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0z\"></path>"
  },
  "check": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.78 4.62a.75.75 0 0 1 0 1.06l-6.097 6.097a.75.75 0 0 1-1.069-.009L3.211 9.284a.75.75 0 1 1 1.078-1.043l1.873 1.936L11.72 4.62a.75.75 0 0 1 1.06 0z\"></path>"
  },
  "check-circle": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-4.22-1.72a.75.75 0 0 0-1.06-1.06L6.75 9.19 5.53 7.97a.75.75 0 0 0-1.06 1.06l1.75 1.75a.75.75 0 0 0 1.06 0l4.5-4.5z\"></path>"
  },
  "check-circle-filled": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm3.78-9.72a.75.75 0 0 0-1.06-1.06L6.75 9.19 5.53 7.97a.75.75 0 0 0-1.06 1.06l1.75 1.75a.75.75 0 0 0 1.06 0l4.5-4.5z\"></path>"
  },
  "check-sm": {
    v: "0 0 12 12",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.78 2.62a.75.75 0 0 1 0 1.06L4.683 9.777a.75.75 0 0 1-1.069-.009L1.211 7.284a.75.75 0 0 1 1.078-1.043l1.873 1.936L9.72 2.62a.75.75 0 0 1 1.06 0z\"></path>"
  },
  "chevron-down": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.22 6.22a.75.75 0 0 1 1.06 0L8 8.94l2.72-2.72a.75.75 0 1 1 1.06 1.06l-3.25 3.25a.75.75 0 0 1-1.06 0L4.22 7.28a.75.75 0 0 1 0-1.06z\"></path>"
  },
  "chevron-left": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.78 4.22a.75.75 0 0 1 0 1.06L7.06 8l2.72 2.72a.75.75 0 1 1-1.06 1.06L5.47 8.53a.75.75 0 0 1 0-1.06l3.25-3.25a.75.75 0 0 1 1.06 0z\"></path>"
  },
  "chevron-lg-down": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.22 5.22a.75.75 0 0 0 0 1.06l5.252 5.252a.75.75 0 0 0 1.06 0l5.252-5.252a.75.75 0 1 0-1.06-1.06L8.001 9.94 3.28 5.22a.75.75 0 0 0-1.06 0z\"></path>"
  },
  "chevron-lg-left": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.78 2.22a.75.75 0 0 0-1.06 0L4.468 7.472a.75.75 0 0 0 0 1.06l5.252 5.252a.75.75 0 1 0 1.06-1.06L6.06 8.001l4.72-4.721a.75.75 0 0 0 0-1.06z\"></path>"
  },
  "chevron-lg-right": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.22 2.22a.75.75 0 0 1 1.06 0l5.252 5.252a.75.75 0 0 1 0 1.06L6.28 13.784a.75.75 0 1 1-1.06-1.06l4.72-4.723L5.22 3.28a.75.75 0 0 1 0-1.06z\"></path>"
  },
  "chevron-lg-up": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.22 10.78a.75.75 0 0 1 0-1.06l5.252-5.252a.75.75 0 0 1 1.06 0l5.252 5.252a.75.75 0 1 1-1.06 1.06L8.001 6.06 3.28 10.78a.75.75 0 0 1-1.06 0z\"></path>"
  },
  "chevron-right": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.22 4.22a.75.75 0 0 0 0 1.06L8.94 8l-2.72 2.72a.75.75 0 1 0 1.06 1.06l3.25-3.25a.75.75 0 0 0 0-1.06L7.28 4.22a.75.75 0 0 0-1.06 0z\"></path>"
  },
  "chevron-up": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.22 9.78a.75.75 0 0 0 1.06 0L8 7.06l2.72 2.72a.75.75 0 1 0 1.06-1.06L8.53 5.47a.75.75 0 0 0-1.06 0L4.22 8.72a.75.75 0 0 0 0 1.06z\"></path>"
  },
  "clear": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zM4.22 4.22a.75.75 0 0 1 1.06 0L8 6.94l2.72-2.72a.75.75 0 1 1 1.06 1.06L9.06 8l2.72 2.72a.75.75 0 1 1-1.06 1.06L8 9.06l-2.72 2.72a.75.75 0 0 1-1.06-1.06L6.94 8 4.22 5.28a.75.75 0 0 1 0-1.06z\"></path>"
  },
  "clock": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM8.75 3.75a.75.75 0 0 0-1.5 0v4.56l.22.22 2.254 2.254a.75.75 0 1 0 1.06-1.06L8.75 7.689V3.75z\"></path>"
  },
  "close": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.28 3.22a.75.75 0 0 0-1.06 1.06L6.94 8l-3.72 3.72a.75.75 0 1 0 1.06 1.06L8 9.06l3.72 3.72a.75.75 0 1 0 1.06-1.06L9.06 8l3.72-3.72a.75.75 0 0 0-1.06-1.06L8 6.94 4.28 3.22z\"></path>"
  },
  "close-sm": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.72 4.22a.75.75 0 1 1 1.06 1.06L9.06 8l2.72 2.72a.75.75 0 0 1-1.06 1.06L8 9.06l-2.72 2.72a.75.75 0 0 1-1.06-1.06L6.94 8 4.22 5.28a.75.75 0 1 1 1.06-1.06L8 6.94l2.72-2.72z\"></path>"
  },
  "code": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.424 2.023a.75.75 0 0 1 .556.904L7.48 13.42a.75.75 0 0 1-1.46-.348L8.52 2.58a.75.75 0 0 1 .904-.556zM11.16 4.22a.75.75 0 0 1 1.06 0l3.25 3.25L16 8l-.53.53-3.25 3.25a.75.75 0 1 1-1.06-1.06L13.88 8l-2.72-2.72a.75.75 0 0 1 0-1.06zM4.84 5.28a.75.75 0 1 0-1.06-1.06L.53 7.47 0 8l.53.53 3.25 3.25a.75.75 0 0 0 1.06-1.06L2.12 8l2.72-2.72z\"></path>"
  },
  "comment": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M0 4a3 3 0 0 1 3-3h10a3 3 0 0 1 3 3v6a3 3 0 0 1-3 3H4.063L1.28 15.78A.75.75 0 0 1 0 15.25V4zm3-1.5A1.5 1.5 0 0 0 1.5 4v9.44l1.723-1.72.22-.22H13a1.5 1.5 0 0 0 1.5-1.5V4A1.5 1.5 0 0 0 13 2.5H3z\"></path>"
  },
  "comment-dots": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 1a3 3 0 0 0-3 3v11.25a.75.75 0 0 0 1.28.53L4.063 13H13a3 3 0 0 0 3-3V4a3 3 0 0 0-3-3H3zM1.5 4A1.5 1.5 0 0 1 3 2.5h10A1.5 1.5 0 0 1 14.5 4v6a1.5 1.5 0 0 1-1.5 1.5H3.443l-.22.22L1.5 13.44V4zM11 8a1 1 0 1 0 0-2 1 1 0 0 0 0 2zM9 7a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM5 8a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "comments": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2 0a2 2 0 0 0-2 2v10.06l1.28-1.28 1.53-1.53H4V11a2 2 0 0 0 2 2h7l1.5 1.5L16 16V6a2 2 0 0 0-2-2h-2V2a2 2 0 0 0-2-2H2zm8.5 4V2a.5.5 0 0 0-.5-.5H2a.5.5 0 0 0-.5.5v6.44l.47-.47.22-.22H4V6a2 2 0 0 1 2-2h4.5zm3.56 7.94l.44.439V6a.5.5 0 0 0-.5-.5H6a.5.5 0 0 0-.5.5v5a.5.5 0 0 0 .5.5h7.621l.44.44z\"></path>"
  },
  "commit": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 10.5a2.5 2.5 0 1 0 0-5 2.5 2.5 0 0 0 0 5zM8 12c1.953 0 3.579-1.4 3.93-3.25h3.32a.75.75 0 0 0 0-1.5h-3.32a4.001 4.001 0 0 0-7.86 0H.75a.75.75 0 0 0 0 1.5h3.32A4.001 4.001 0 0 0 8 12z\"></path>"
  },
  "compass": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM7.186 5.605L12 4l-1.605 4.814a2.5 2.5 0 0 1-1.58 1.581L4 12l1.605-4.814a2.5 2.5 0 0 1 1.58-1.581zM9 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "copy-to-clipboard": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 9.5H2.5v-7h7V4H11V2a1 1 0 0 0-1-1H2a1 1 0 0 0-1 1v8a1 1 0 0 0 1 1h2V9.5zm9.5 4h-7v-7h7v7zM5 6a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H6a1 1 0 0 1-1-1V6z\"></path>"
  },
  "dash": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2 8a.75.75 0 0 1 .75-.75h10.5a.75.75 0 0 1 0 1.5H2.75A.75.75 0 0 1 2 8z\"></path>"
  },
  "doc-changes": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3.5 13.5v-12H8v2.75C8 5.216 8.784 6 9.75 6h3.375a.76.76 0 0 0 .063-.003A.75.75 0 0 0 14 5.25v-.774a1 1 0 0 0-.282-.695L10.363.305A1 1 0 0 0 9.643 0H3a1 1 0 0 0-1 1v13a1 1 0 0 0 1 1h4.25a.75.75 0 0 0 0-1.5H3.5zm8.828-9L9.5 1.57v2.68c0 .138.112.25.25.25h2.578zM10 15.25a.75.75 0 0 1 .75-.75h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1-.75-.75zm3-2a.75.75 0 0 1-.75-.75V11h-1.5a.75.75 0 0 1 0-1.5h1.5V8a.75.75 0 0 1 1.5 0v1.5h1.5a.75.75 0 0 1 0 1.5h-1.5v1.5a.75.75 0 0 1-.75.75z\"></path>"
  },
  "doc-code": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.5 14.5V6H9.75A1.75 1.75 0 0 1 8 4.25V1.5H3.5v13h9zm-.121-10L9.5 1.621V4.25c0 .138.112.25.25.25h2.629zM2 1a1 1 0 0 1 1-1h6.586a1 1 0 0 1 .707.293l3.414 3.414a1 1 0 0 1 .293.707V15a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V1zm5.75 10.5a.75.75 0 0 0 0 1.5h2.5a.75.75 0 0 0 0-1.5h-2.5zM6.28 6.22a.75.75 0 0 0-1.06 1.06L6.44 8.5 5.22 9.72a.75.75 0 1 0 1.06 1.06l1.75-1.75.53-.53-.53-.53-1.75-1.75z\"></path>"
  },
  "doc-text": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.5 6v8.5h-9v-13H8v2.75C8 5.216 8.784 6 9.75 6h2.75zm-.121-1.5L9.5 1.621V4.25c0 .138.112.25.25.25h2.629zM2 1a1 1 0 0 1 1-1h6.586a1 1 0 0 1 .707.293l3.414 3.414a1 1 0 0 1 .293.707V15a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V1zm3.75 7a.75.75 0 0 0 0 1.5h4.5a.75.75 0 0 0 0-1.5h-4.5zM5 11.25a.75.75 0 0 1 .75-.75h2.5a.75.75 0 0 1 0 1.5h-2.5a.75.75 0 0 1-.75-.75z\"></path>"
  },
  "doc-versions": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 7v5.5h-7v-9H11V6a1 1 0 0 0 1 1h2.5zm-2-3.379L14.379 5.5H12.5V3.621zM7 2a1 1 0 0 0-1 1H4a1 1 0 0 0-1 1H1a1 1 0 0 0-1 1v6a1 1 0 0 0 1 1h2a1 1 0 0 0 1 1h2a1 1 0 0 0 1 1h8a1 1 0 0 0 1-1V5.414a1 1 0 0 0-.293-.707l-2.414-2.414A1 1 0 0 0 12.586 2H7zm-1 9.5v-7H4.5v7H6zm-3-1v-5H1.5v5H3z\"></path>"
  },
  "document": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.5 6v8.5h-9v-13H8v2.75C8 5.216 8.784 6 9.75 6h2.75zm-.121-1.5L9.5 1.621V4.25c0 .138.112.25.25.25h2.629zM2 1a1 1 0 0 1 1-1h6.586a1 1 0 0 1 .707.293l3.414 3.414a1 1 0 0 1 .293.707V15a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V1z\"></path>"
  },
  "download": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.78 7.159a.75.75 0 0 0-1.06 0l-1.97 1.97V1.75a.75.75 0 0 0-1.5 0v7.379l-1.97-1.97a.75.75 0 0 0-1.06 1.06l3.25 3.25L8 12l.53-.53 3.25-3.25a.75.75 0 0 0 0-1.061zM2.5 9.75a.75.75 0 0 0-1.5 0V13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V9.75a.75.75 0 0 0-1.5 0V13a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V9.75z\"></path>"
  },
  "earth": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 14.5c.23 0 .843-.226 1.487-1.514.306-.612.563-1.37.742-2.236H5.771c.179.866.436 1.624.742 2.236C7.157 14.274 7.77 14.5 8 14.5zM5.554 9.25a14.444 14.444 0 0 1 0-2.5h4.892a14.452 14.452 0 0 1 0 2.5H5.554zm6.203 1.5c-.224 1.224-.593 2.308-1.066 3.168a6.525 6.525 0 0 0 3.2-3.168h-2.134zm2.623-1.5h-2.43a16.019 16.019 0 0 0 0-2.5h2.429a6.533 6.533 0 0 1 0 2.5zm-10.331 0H1.62a6.533 6.533 0 0 1 0-2.5h2.43a15.994 15.994 0 0 0 0 2.5zm-1.94 1.5h2.134c.224 1.224.593 2.308 1.066 3.168a6.525 6.525 0 0 1-3.2-3.168zm3.662-5.5h4.458c-.179-.866-.436-1.624-.742-2.236C8.843 1.726 8.23 1.5 8 1.5c-.23 0-.843.226-1.487 1.514-.306.612-.563 1.37-.742 2.236zm5.986 0h2.134a6.526 6.526 0 0 0-3.2-3.168c.473.86.842 1.944 1.066 3.168zM5.31 2.082c-.473.86-.842 1.944-1.066 3.168H2.109a6.525 6.525 0 0 1 3.2-3.168zM8 0a8 8 0 1 1 0 16A8 8 0 0 1 8 0z\"></path>"
  },
  "ellipsis_h": {
    v: "0 0 16 16",
    c: "<path d=\"M4 8a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm6 0a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm4 2a2 2 0 1 0 0-4 2 2 0 0 0 0 4z\"></path>"
  },
  "ellipsis_v": {
    v: "0 0 16 16",
    c: "<path d=\"M8 12a2 2 0 1 1 0 4 2 2 0 0 1 0-4zm0-6a2 2 0 1 1 0 4 2 2 0 0 1 0-4zm2-4a2 2 0 1 0-4 0 2 2 0 0 0 4 0z\"></path>"
  },
  "epic": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M1.5 8.5l2.5-6h8l2.5 6h-13zM0 8.569v2.181c0 .966.784 1.75 1.75 1.75H2v.75c0 .966.784 1.75 1.75 1.75h8.5a.75.75 0 0 0 0-1.5h-8.5a.25.25 0 0 1-.25-.25v-.75h10.25a.75.75 0 0 0 0-1.5h-12a.25.25 0 0 1-.25-.25V10h13a1.5 1.5 0 0 0 1.385-2.077l-2.629-6.308A1 1 0 0 0 12.333 1H3.667a1 1 0 0 0-.923.615L.115 7.923A1.498 1.498 0 0 0 0 8.569z\"></path>"
  },
  "error": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 14.5a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13zM8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zm1-5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-.25-6.25a.75.75 0 0 0-1.5 0v3.5a.75.75 0 0 0 1.5 0v-3.5z\"></path>"
  },
  "external-link": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.75 1a.75.75 0 0 0 0 1.5h1.69L8.22 6.72a.75.75 0 0 0 1.06 1.06l4.22-4.22v1.69a.75.75 0 0 0 1.5 0V1h-4.25zM2.5 4v9a.5.5 0 0 0 .5.5h9a.5.5 0 0 0 .5-.5V8.75a.75.75 0 0 1 1.5 0V13a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h4.25a.75.75 0 0 1 0 1.5H3a.5.5 0 0 0-.5.5z\"></path>"
  },
  "eye": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M0 8s3-6 8-6 8 6 8 6-3 6-8 6-8-6-8-6zm1.81.13A13.593 13.593 0 0 1 1.73 8l.082-.13c.326-.51.806-1.187 1.42-1.856C4.494 4.635 6.12 3.5 8 3.5c1.878 0 3.506 1.135 4.77 2.514A13.705 13.705 0 0 1 14.27 8a14.021 14.021 0 0 1-1.502 1.986C11.506 11.365 9.88 12.5 8 12.5c-1.878 0-3.506-1.135-4.77-2.514A13.703 13.703 0 0 1 1.81 8.13zM11 8a3 3 0 1 1-2.117-2.868 1.5 1.5 0 1 0 1.985 1.985A3 3 0 0 1 11 8z\"></path>"
  },
  "eye-slash": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.776 2.284a.75.75 0 0 0-1.06-1.06l-1.953 1.953C10.707 2.499 9.44 2 8 2 5.506 2 3.533 3.49 2.24 4.86A14.615 14.615 0 0 0 .226 7.576a5.39 5.39 0 0 0-.028.052l-.008.014-.003.005v.002L.85 8l-.663-.35L.002 8l.185.35L.85 8l-.663.35v.002l.002.002.004.007.012.023c.01.02.026.047.046.082a14.417 14.417 0 0 0 .82 1.262c.47.647 1.13 1.447 1.96 2.18L1.22 13.72a.75.75 0 1 0 1.06 1.06L14.776 2.284zm-10.681 8.56l1.32-1.32a3 3 0 0 1 4.109-4.109l1.148-1.147C9.864 3.8 8.969 3.5 8 3.5c-1.88 0-3.483 1.134-4.67 2.39A13.114 13.114 0 0 0 1.716 8c.13.213.32.508.567.846a11.98 11.98 0 0 0 1.811 1.998zm9.42-5.166a.75.75 0 0 1 1.053.122c.447.564.901 1.2 1.245 1.85l.185.35-.185.35L15.15 8l.663.351-.001.002-.003.005-.008.014a9.81 9.81 0 0 1-.53.865 14.62 14.62 0 0 1-1.51 1.903C12.467 12.51 10.494 14 8 14a6.939 6.939 0 0 1-1.021-.08l-.02-.002-.006-.001h-.002l.12-.741-.12.74a.75.75 0 0 1 .239-1.48h.002l.011.001a6.024 6.024 0 0 0 .235.03c.158.017.362.033.562.033 1.88 0 3.483-1.134 4.67-2.39a13.11 13.11 0 0 0 1.616-2.115 12.33 12.33 0 0 0-.893-1.263.75.75 0 0 1 .121-1.054z\"></path>"
  },
  "file-addition": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 3.5h8a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-.5.5H4a.5.5 0 0 1-.5-.5V4a.5.5 0 0 1 .5-.5zM2 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4zm6 7a.75.75 0 0 1-.75-.75v-1.5h-1.5a.75.75 0 0 1 0-1.5h1.5v-1.5a.75.75 0 0 1 1.5 0v1.5h1.5a.75.75 0 0 1 0 1.5h-1.5v1.5A.75.75 0 0 1 8 11z\"></path>"
  },
  "file-deletion": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 3.5h8a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-.5.5H4a.5.5 0 0 1-.5-.5V4a.5.5 0 0 1 .5-.5zM2 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4zm3.75 3.25a.75.75 0 0 0 0 1.5h4.5a.75.75 0 0 0 0-1.5h-4.5z\"></path>"
  },
  "file-modified": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 3.5h8a.5.5 0 0 1 .5.5v8a.5.5 0 0 1-.5.5H4a.5.5 0 0 1-.5-.5V4a.5.5 0 0 1 .5-.5zM2 4a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v8a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V4zm6 6a2 2 0 1 0 0-4 2 2 0 0 0 0 4z\"></path>"
  },
  "file-tree": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.5 1.75a.75.75 0 0 0-1.5 0v8.5a3 3 0 0 0 3 3h3V14a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-3a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v.75H4a1.5 1.5 0 0 1-1.5-1.5V6.849c.441.255.954.401 1.5.401h3V8a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1V5a1 1 0 0 0-1-1H8a1 1 0 0 0-1 1v.75H4a1.5 1.5 0 0 1-1.5-1.5v-2.5zm11 11.75h-5v-2h5v2zm-5-6v-2h5v2h-5z\"></path>"
  },
  "filter": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8.5 8.379l.44-.44 4.56-4.56V2.5h-11v.879l4.56 4.56.44.44v4l1-1v-3zM10 12l-2.5 2.5L6 16V9L1.293 4.293A1 1 0 0 1 1 3.586V2a1 1 0 0 1 1-1h12a1 1 0 0 1 1 1v1.586a1 1 0 0 1-.293.707L10 9v3z\"></path>"
  },
  "folder-o": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M1.5 4V2.5h4.697l1 1.5H1.5zM0 4V2a1 1 0 0 1 1-1h5.465a1 1 0 0 1 .832.445l1.667 2.5.034.055H15a1 1 0 0 1 1 1v8a1 1 0 0 1-1 1H1a1 1 0 0 1-1-1V4zm1.5 1.5v7h13v-7h-13z\"></path>"
  },
  "fork": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.5 3.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-.25 2.386a2.501 2.501 0 1 0-1.5 0v.364a2.5 2.5 0 0 0 2.5 2.5 1 1 0 0 1 1 1v.364a2.501 2.501 0 1 0 1.5 0V9.75a1 1 0 0 1 1-1 2.5 2.5 0 0 0 2.5-2.5v-.364a2.501 2.501 0 1 0-1.5 0v.364a1 1 0 0 1-1 1c-.681 0-1.3.273-1.75.715a2.492 2.492 0 0 0-1.75-.715 1 1 0 0 1-1-1v-.364zM11.5 4.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm-3.5 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "git-merge": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.34 1.22a.75.75 0 0 0-1.06 0L7.53 2.97 7 3.5l.53.53 1.75 1.75a.75.75 0 1 0 1.06-1.06l-.47-.47h.63c.69 0 1.25.56 1.25 1.25v4.614a2.501 2.501 0 1 0 1.5 0V5.5a2.75 2.75 0 0 0-2.75-2.75h-.63l.47-.47a.75.75 0 0 0 0-1.06zM13.5 12.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-9 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm1.5 0a2.5 2.5 0 1 1-3.25-2.386V5.886a2.501 2.501 0 1 1 1.5 0v4.228A2.501 2.501 0 0 1 6 12.5zm-1.5-9a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "group": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6 4a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm1.5 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0zm4 5.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm0 1.5a3 3 0 1 0 0-6 3 3 0 0 0 0 6zm-7 2.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm0 1.5a3 3 0 1 0 0-6 3 3 0 0 0 0 6z\"></path>"
  },
  "history": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.806.665A8 8 0 1 1 .612 11.07a.75.75 0 1 1 1.385-.575A6.5 6.5 0 1 0 2.523 4.5H4.25a.75.75 0 0 1 0 1.5H0V1.75a.75.75 0 0 1 1.5 0v1.586A8 8 0 0 1 4.806.666zM8 3a.75.75 0 0 1 .75.75v3.94l2.034 2.034a.75.75 0 1 1-1.06 1.06L7.47 8.53l-.22-.22V3.75A.75.75 0 0 1 8 3z\"></path>"
  },
  "home": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8.38 1.353L8 1.131l-.38.222-7.25 4.25a.75.75 0 0 0 .76 1.294l.87-.51V14h12V6.387l.87.51a.75.75 0 1 0 .76-1.294l-7.25-4.25zm4.12 4.154L8 2.87 3.5 5.507V12.5H6V8h4v4.5h2.5V5.507zM8.5 9.5v3h-1v-3h1z\"></path>"
  },
  "hourglass": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.75 0a.75.75 0 0 0 0 1.5H3v.593c0 1.26.5 2.468 1.391 3.359L6.94 8l-2.548 2.548A4.75 4.75 0 0 0 3 13.907v.593h-.25a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5H13v-.593c0-1.26-.5-2.468-1.391-3.359L9.06 8l2.548-2.548A4.75 4.75 0 0 0 13 2.093V1.5h.25a.75.75 0 0 0 0-1.5H2.75zm8.75 1.5h-7v.593c0 .69.219 1.356.618 1.907h5.764a3.25 3.25 0 0 0 .618-1.907V1.5zM8 6.94L6.56 5.5h2.88L8 6.94zm3.5 7.56v-.593a3.25 3.25 0 0 0-.952-2.298L8 9.06l-2.548 2.548a3.25 3.25 0 0 0-.952 2.298v.593h7z\"></path>"
  },
  "information-o": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-9.75 2.5a.75.75 0 0 0 0 1.5h3.5a.75.75 0 0 0 0-1.5h-1V7H7a.75.75 0 0 0 0 1.5h.25v2h-1zM8 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "issue-close": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM3.75 7.25a.75.75 0 0 0 0 1.5h8.5a.75.75 0 0 0 0-1.5h-8.5z\"></path>"
  },
  "issue-open-m": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 14.5a6.5 6.5 0 1 0 0-13 6.5 6.5 0 0 0 0 13zM8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16z\"></path>"
  },
  "issue-type-issue": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 2.5h6a.5.5 0 0 1 .5.5v10a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V3a.5.5 0 0 1 .5-.5zM1 3a2 2 0 0 1 2-2h6a2 2 0 0 1 1.97 1.658l2.913 1.516a1.75 1.75 0 0 1 .744 2.36l-3.878 7.45a.753.753 0 0 1-.098.145c-.36.526-.965.871-1.651.871H3a2 2 0 0 1-2-2V3zm10 7.254l2.297-4.413a.25.25 0 0 0-.106-.337L11 4.364v5.89z\"></path>"
  },
  "issues": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 2.5h6a.5.5 0 0 1 .5.5v10a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V3a.5.5 0 0 1 .5-.5zM1 3a2 2 0 0 1 2-2h6a2 2 0 0 1 1.97 1.658l2.913 1.516a1.75 1.75 0 0 1 .744 2.36l-3.878 7.45a.753.753 0 0 1-.098.145c-.36.526-.965.871-1.651.871H3a2 2 0 0 1-2-2V3zm10 7.254l2.297-4.413a.25.25 0 0 0-.106-.337L11 4.364v5.89z\"></path>"
  },
  "italic": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.5 2a.75.75 0 0 0 0 1.5h1.93l-2.412 9H4A.75.75 0 0 0 4 14h5.5a.75.75 0 0 0 0-1.5H7.57l2.412-9H12A.75.75 0 0 0 12 2H6.5z\"></path>"
  },
  "key": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.358 8.763l.675-.674-.325-.897A3.5 3.5 0 1 1 10 9.5H7.5v1H6.379l-.44.44-1 1-.439.439V13.5h-2v-.879l3.858-3.858zM6 15v-2l1-1h2v-1h1a5 5 0 1 0-4.703-3.297L1 12v3h5zm5-9a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "label": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.664 1a1.75 1.75 0 0 0-1.237.512L1.514 8.419a1.75 1.75 0 0 0-.001 2.475L5.1 14.48a1.75 1.75 0 0 0 2.474 0l6.914-6.906A1.75 1.75 0 0 0 15 6.335V1H9.664zm-.177 1.573a.25.25 0 0 1 .177-.073H13.5v3.835a.25.25 0 0 1-.073.177L6.513 13.42a.25.25 0 0 1-.353 0L2.574 9.833a.25.25 0 0 1 0-.353l6.913-6.907zM11 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "labels": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.427.512A1.75 1.75 0 0 1 7.664 0H13v3h3v5.335c0 .465-.185.91-.513 1.239L9.573 15.48a1.75 1.75 0 0 1-2.473 0l-2.293-2.293-1.293-1.293-3-3a1.75 1.75 0 0 1 0-2.475L6.428.512zM11.5 1.5V3h-.836a1.75 1.75 0 0 0-1.237.512L3.514 9.419c-.06.06-.115.123-.165.19L1.574 7.833a.25.25 0 0 1 0-.353l5.913-5.907a.25.25 0 0 1 .177-.073H11.5zM5.866 12.126l-1.292-1.293a.25.25 0 0 1 0-.353l5.913-5.907a.25.25 0 0 1 .177-.073H14.5v3.835a.25.25 0 0 1-.073.177L8.513 14.42a.25.25 0 0 1-.353 0l-2.294-2.293zM12 8a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "link": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.929 3.132a2.078 2.078 0 1 1 2.94 2.94l-.65.648a.75.75 0 0 0 1.061 1.06l.649-.648a3.579 3.579 0 0 0-5.06-5.06L6.218 4.72a3.578 3.578 0 0 0 0 5.06.75.75 0 0 0 1.061-1.06 2.078 2.078 0 0 1 0-2.94L9.93 3.132zm-.15 3.086a.75.75 0 0 0-1.057 1.064c.816.81.818 2.13.004 2.942l-2.654 2.647a2.08 2.08 0 0 1-2.94-2.944l.647-.647a.75.75 0 0 0-1.06-1.06l-.648.647a3.58 3.58 0 0 0 5.06 5.066l2.654-2.647a3.575 3.575 0 0 0-.007-5.068z\"></path>"
  },
  "list-bulleted": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" d=\"M2 4.75a1 1 0 1 0 0-2 1 1 0 0 0 0 2zM5.75 3a.75.75 0 0 0 0 1.5h8.5a.75.75 0 0 0 0-1.5h-8.5zm0 4.25a.75.75 0 0 0 0 1.5h8.5a.75.75 0 0 0 0-1.5h-8.5zm-.75 5a.75.75 0 0 1 .75-.75h8.5a.75.75 0 0 1 0 1.5h-8.5a.75.75 0 0 1-.75-.75zM3 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-1 5.25a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\" clip-rule=\"evenodd\"></path>"
  },
  "list-indent": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4.75 3a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5H4.75zm2 4.25a.75.75 0 0 0 0 1.5h8.5a.75.75 0 0 0 0-1.5h-8.5zM.22 5.72a.75.75 0 0 1 1.06 0l1.75 1.75.53.53-.53.53-1.75 1.75A.75.75 0 1 1 .22 9.22L1.44 8 .22 6.78a.75.75 0 0 1 0-1.06zm4.53 5.78a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5H4.75z\"></path>"
  },
  "lock": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 5a4 4 0 1 1 8 0v1h1a1 1 0 0 1 1 1v7a1 1 0 0 1-1 1H3a1 1 0 0 1-1-1V7a1 1 0 0 1 1-1h1V5zm6.5 0v1h-5V5a2.5 2.5 0 0 1 5 0zm-7 2.5v6h9v-6h-9zM9 12V9H7v3h2z\"></path>"
  },
  "log": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3.5 2.5v11h9v-11h-9zM3 1a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V2a1 1 0 0 0-1-1H3zm5 10a.75.75 0 0 1 .75-.75h1.75a.75.75 0 0 1 0 1.5H8.75A.75.75 0 0 1 8 11zm-2 1a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm2-4a.75.75 0 0 1 .75-.75h1.75a.75.75 0 0 1 0 1.5H8.75A.75.75 0 0 1 8 8zM6 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm2-4a.75.75 0 0 1 .75-.75h1.75a.75.75 0 0 1 0 1.5H8.75A.75.75 0 0 1 8 5zM6 6a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "long-arrow": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.159 10.72a.75.75 0 1 0 1.06 1.06l3.25-3.25L15 8l-.53-.53-3.25-3.25a.75.75 0 0 0-1.061 1.06l1.97 1.97H1.75a.75.75 0 1 0 0 1.5h10.379l-1.97 1.97z\"></path>"
  },
  "markdown-mark": {
    v: "0 0 16 16",
    c: "<path d=\"M2.308 5.308v5.23h1.538v-3l1.539 1.924 1.538-1.924v3h1.539v-5.23H6.923L5.385 7.23 3.846 5.308H2.308zM9.615 8l2.308 2.539L14.231 8h-1.539V5.308h-1.538V8H9.615z\"></path><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M1.154 3C.517 3 0 3.517 0 4.154v7.538c0 .637.517 1.154 1.154 1.154h13.692c.637 0 1.154-.517 1.154-1.154V4.154C16 3.517 15.483 3 14.846 3H1.154zM.769 4.154c0-.213.172-.385.385-.385h13.692c.213 0 .385.172.385.385v7.538a.385.385 0 0 1-.385.385H1.154a.385.385 0 0 1-.385-.385V4.154z\"></path>"
  },
  "media": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M13 2.5H3a.5.5 0 0 0-.5.5v10a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5V3a.5.5 0 0 0-.5-.5zM3 1a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V3a2 2 0 0 0-2-2H3zm9 9.857L9.5 8l-2.476 2.83L5.5 9 4 10.8V12h8v-1.143zM6.5 8a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z\"></path>"
  },
  "merge": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.5 3.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-.044 2.31a2.5 2.5 0 1 0-1.706.076v4.228a2.501 2.501 0 1 0 1.5 0V8.373a5.735 5.735 0 0 0 3.86 1.864 2.501 2.501 0 1 0 .01-1.504 4.254 4.254 0 0 1-3.664-2.922zM11.5 10.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm-6 2a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "merge-request": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.34 1.22a.75.75 0 0 0-1.06 0L7.53 2.97 7 3.5l.53.53 1.75 1.75a.75.75 0 1 0 1.06-1.06l-.47-.47h.63c.69 0 1.25.56 1.25 1.25v4.614a2.501 2.501 0 1 0 1.5 0V5.5a2.75 2.75 0 0 0-2.75-2.75h-.63l.47-.47a.75.75 0 0 0 0-1.06zM13.5 12.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-9 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm1.5 0a2.5 2.5 0 1 1-3.25-2.386V5.886a2.501 2.501 0 1 1 1.5 0v4.228A2.501 2.501 0 0 1 6 12.5zm-1.5-9a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "merge-request-close-m": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.28 4.22a.75.75 0 0 0-1.06 1.06L6.94 8l-2.72 2.72a.75.75 0 1 0 1.06 1.06L8 9.06l2.72 2.72a.75.75 0 1 0 1.06-1.06L9.06 8l2.72-2.72a.75.75 0 0 0-1.06-1.06L8 6.94 5.28 4.22z\"></path>"
  },
  "merge-request-open": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.34 1.22a.75.75 0 0 0-1.06 0L7.53 2.97 7 3.5l.53.53 1.75 1.75a.75.75 0 1 0 1.06-1.06l-.47-.47h.63c.69 0 1.25.56 1.25 1.25v4.614a2.501 2.501 0 1 0 1.5 0V5.5a2.75 2.75 0 0 0-2.75-2.75h-.63l.47-.47a.75.75 0 0 0 0-1.06zM13.5 12.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-9 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm1.5 0a2.5 2.5 0 1 1-3.25-2.386V5.886a2.501 2.501 0 1 1 1.5 0v4.228A2.501 2.501 0 0 1 6 12.5zm-1.5-9a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "milestone": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" d=\"M8.354 2.664a.5.5 0 0 0-.708 0L2.664 7.646a.5.5 0 0 0 0 .708l4.982 4.982a.5.5 0 0 0 .708 0l4.982-4.982a.5.5 0 0 0 0-.708L8.354 2.664zm-1.768-1.06a2 2 0 0 1 2.828 0l4.982 4.982a2 2 0 0 1 0 2.828l-4.982 4.982a2 2 0 0 1-2.828 0L1.604 9.414a2 2 0 0 1 0-2.828l4.982-4.982z\" clip-rule=\"evenodd\"></path>"
  },
  "mobile": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5 1.5h6a.5.5 0 0 1 .5.5v12a.5.5 0 0 1-.5.5H5a.5.5 0 0 1-.5-.5V2a.5.5 0 0 1 .5-.5zM3 2a2 2 0 0 1 2-2h6a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V2zm5 11a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "notifications": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 1a1 1 0 0 0-1 1v.1A5.002 5.002 0 0 0 3 7v4l-1.205 1.328c-.583.643-.127 1.672.74 1.672h3.733a2 2 0 0 0 3.464 0h3.733c.867 0 1.323-1.03.74-1.672L13 11V7a5.002 5.002 0 0 0-4-4.9V2a1 1 0 0 0-1-1zM4.5 11.58l-.39.428-.446.492h8.672l-.447-.492-.389-.429V7a3.5 3.5 0 1 0-7 0v4.58z\"></path>"
  },
  "notifications-off": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 1a1 1 0 0 0-1 1v.1A5.002 5.002 0 0 0 3 7v4.94l-1.78 1.78a.75.75 0 1 0 1.06 1.06L14.776 2.284a.75.75 0 0 0-1.06-1.06l-2.211 2.21A4.991 4.991 0 0 0 9 2.1V2a1 1 0 0 0-1-1zm0 2.5c.95 0 1.813.379 2.444.995L4.5 10.439V7A3.5 3.5 0 0 1 8 3.5zm5 4.25a.75.75 0 0 0-1.5 0v3.817l.194.214.65.719H6.75a.75.75 0 0 0-.728.932l.011.043A2.02 2.02 0 0 0 7.993 15c.737 0 1.389-.4 1.738-1h3.74c.868 0 1.324-1.028.742-1.671L13 10.989V7.75z\"></path>"
  },
  "paper-airplane": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.968 1.966a.75.75 0 0 0-.934-.934l-12.5 3.75a.75.75 0 0 0-.18 1.355L5.952 8.99l-1.731 1.73a.75.75 0 1 0 1.06 1.061l1.731-1.73 2.852 4.595a.75.75 0 0 0 1.355-.18l3.75-12.5zM8.101 8.96l2.159 3.48 2.417-8.056L8.1 8.96zm3.515-5.637L3.56 5.74 7.04 7.9l4.576-4.577z\"></path>"
  },
  "paperclip": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.414 3.05L4.085 8.38a3 3 0 0 0 4.243 4.242l2.403-2.403a.75.75 0 1 1 1.06 1.06l-2.403 2.404a4.5 4.5 0 0 1-6.364-6.364l5.33-5.33a3.25 3.25 0 0 1 4.596 4.597l-5.33 5.329a2 2 0 0 1-2.828-2.828l5.33-5.33a.75.75 0 0 1 1.06 1.061l-5.33 5.33a.5.5 0 1 0 .708.706l5.33-5.329A1.75 1.75 0 0 0 9.413 3.05z\"></path>"
  },
  "passkey": {
    v: "0 0 16 16",
    c: "<path d=\"M6.385 8.158c1.784 0 3.23-1.379 3.23-3.08C9.615 3.379 8.17 2 6.385 2S3.154 3.379 3.154 5.079c0 1.7 1.446 3.079 3.23 3.079zm8.615 0a2.31 2.31 0 0 0-.346-1.22 2.46 2.46 0 0 0-.949-.883 2.612 2.612 0 0 0-2.557.068c-.38.23-.69.551-.896.933a2.3 2.3 0 0 0 .153 2.433c.251.356.599.64 1.005.824v3.66L12.487 15l1.795-1.71-1.077-1.027 1.077-1.026-.89-.849c.473-.174.88-.48 1.166-.878A2.32 2.32 0 0 0 15 8.158zm-2.513 0a.75.75 0 0 1-.516-.196.684.684 0 0 1-.216-.488.658.658 0 0 1 .216-.489.722.722 0 0 1 .516-.195.736.736 0 0 1 .499.205.665.665 0 0 1 0 .958.736.736 0 0 1-.499.205zM9.213 9.54a4.489 4.489 0 0 0-1.751-.356H5.308a4.418 4.418 0 0 0-3.046 1.203A4.01 4.01 0 0 0 1 13.289v1.369h9.333v-3.77a3.564 3.564 0 0 1-1.12-1.348z\"></path>"
  },
  "pencil": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.5 13.5v-1.879l7.28-7.28 1.88 1.879-7.28 7.28H2.5zm10.22-8.341l.805-.805a.5.5 0 0 0 0-.708l-1.171-1.171a.5.5 0 0 0-.708 0l-.805.805 1.879 1.88zM1 13.5V11l9.586-9.586a2 2 0 0 1 2.828 0l1.172 1.172a2 2 0 0 1 0 2.828L5 15H1v-1.5z\"></path>"
  },
  "pencil-square": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.287.303a1 1 0 1 1 1.415 1.414l-.707.708L13.58 1.01l.707-.707zm0 2.829l-6.873 6.873H6V8.59l6.873-6.874 1.415 1.415zM3 13.5a.5.5 0 0 1-.5-.5V3a.5.5 0 0 1 .5-.5h6.25a.75.75 0 0 0 0-1.5H3a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V6.75a.75.75 0 0 0-1.5 0V13a.5.5 0 0 1-.5.5H3z\"></path>"
  },
  "play": {
    v: "0 0 16 16",
    c: "<path d=\"M11.629 7.306a.835.835 0 0 1 0 1.388l-6.401 4.177C4.695 13.218 4 12.825 4 12.176V3.824c0-.649.695-1.042 1.228-.695l6.4 4.177z\"></path>"
  },
  "plus": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8.75 2.75a.75.75 0 0 0-1.5 0v4.5h-4.5a.75.75 0 0 0 0 1.5h4.5v4.5a.75.75 0 0 0 1.5 0v-4.5h4.5a.75.75 0 0 0 0-1.5h-4.5v-4.5z\"></path>"
  },
  "profile": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8 14.5a6.47 6.47 0 0 0 3.25-.87V11.5A2.25 2.25 0 0 0 9 9.25H7a2.25 2.25 0 0 0-2.25 2.25v2.13A6.47 6.47 0 0 0 8 14.5zm4.75-3v.937a6.5 6.5 0 1 0-9.5 0V11.5a3.752 3.752 0 0 1 2.486-3.532 3 3 0 1 1 4.528 0A3.752 3.752 0 0 1 12.75 11.5zM8 16A8 8 0 1 0 8 0a8 8 0 0 0 0 16zM9.5 6a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0z\"></path>"
  },
  "project": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.5 14.5l-6-2.5V4l6-2.5v13zm-6.885-1.244A1 1 0 0 1 2 12.333V3.667a1 1 0 0 1 .615-.923L8.923.115A1.5 1.5 0 0 1 11 1.5V2h1.25c.966 0 1.75.783 1.75 1.75v8.5A1.75 1.75 0 0 1 12.25 14H11v.5a1.5 1.5 0 0 1-2.077 1.385l-6.308-2.629zM11 12.5h1.25a.25.25 0 0 0 .25-.25v-8.5a.25.25 0 0 0-.25-.25H11v9z\"></path>"
  },
  "question-o": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM4.927 4.99c-.285.429-.427.853-.427 1.27 0 .203.09.392.27.566.18.174.4.26.661.26.443 0 .744-.248.903-.746.168-.475.373-.835.616-1.08.243-.244.62-.366 1.134-.366.439 0 .797.12 1.075.363.277.242.416.54.416.892a.97.97 0 0 1-.136.502 1.91 1.91 0 0 1-.336.419 14.35 14.35 0 0 1-.648.558c-.34.282-.611.525-.812.73-.2.205-.362.443-.483.713-.322 1.245 1.35 1.345 1.736.456.047-.086.118-.18.213-.284.096-.103.223-.223.382-.36a41.14 41.14 0 0 0 1.194-1.034c.221-.204.412-.448.573-.73a1.95 1.95 0 0 0 .242-.984c0-.475-.141-.915-.424-1.32-.282-.406-.682-.726-1.2-.962-.518-.235-1.115-.353-1.792-.353-.728 0-1.365.14-1.911.423-.546.282-.961.637-1.246 1.066zm2.14 7.08a1 1 0 1 0 2 0 1 1 0 0 0-2 0z\"></path>"
  },
  "quote": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M1.5 3.75a.75.75 0 0 0-1.5 0v8.5a.75.75 0 0 0 1.5 0v-8.5zM4.75 3a.75.75 0 0 0 0 1.5h7.5a.75.75 0 0 0 0-1.5h-7.5zm0 4.25a.75.75 0 0 0 0 1.5h10.5a.75.75 0 0 0 0-1.5H4.75zm-.75 5a.75.75 0 0 1 .75-.75h6.5a.75.75 0 0 1 0 1.5h-6.5a.75.75 0 0 1-.75-.75z\"></path>"
  },
  "remove": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5.75 3V1.5h4.5V3h-4.5zm-1.5 0V1a1 1 0 0 1 1-1h5.5a1 1 0 0 1 1 1v2h2.5a.75.75 0 0 1 0 1.5h-.365l-.743 9.653A2 2 0 0 1 11.148 16H4.852a2 2 0 0 1-1.994-1.847L2.115 4.5H1.75a.75.75 0 0 1 0-1.5h2.5zm-.63 1.5h8.76l-.734 9.538a.5.5 0 0 1-.498.462H4.852a.5.5 0 0 1-.498-.462L3.62 4.5z\"></path>"
  },
  "retry": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M7.32.029a8 8 0 0 1 7.18 3.307V1.75a.75.75 0 0 1 1.5 0V6h-4.25a.75.75 0 0 1 0-1.5h1.727A6.5 6.5 0 0 0 1.694 6.424.75.75 0 1 1 .239 6.06 8 8 0 0 1 7.319.03zm-3.4 14.852A8 8 0 0 0 15.76 9.94a.75.75 0 0 0-1.455-.364A6.5 6.5 0 0 1 2.523 11.5H4.25a.75.75 0 0 0 0-1.5H0v4.25a.75.75 0 0 0 1.5 0v-1.586a8 8 0 0 0 2.42 2.217z\"></path>"
  },
  "review-list": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9 2.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm1.45-.5a2.5 2.5 0 0 0-4.9 0H3a1 1 0 0 0-1 1v12a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V3a1 1 0 0 0-1-1h-2.55zM8 5H5.5V3.5h-2v11h9v-11h-2V5H8zM5 7.75A.75.75 0 0 1 5.75 7h4.5a.75.75 0 0 1 0 1.5h-4.5A.75.75 0 0 1 5 7.75zm.75 1.75a.75.75 0 0 0 0 1.5h4.5a.75.75 0 0 0 0-1.5h-4.5z\"></path>"
  },
  "rocket": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M16 .776l.027-.803-.803.027-1.309.046A10.75 10.75 0 0 0 5.753 4.25H3.667A2.75 2.75 0 0 0 .962 6.504l-.8 4.36L0 11.75h2.69l1.56 1.56V16l.885-.162 4.36-.8a2.75 2.75 0 0 0 2.255-2.705v-2.086a10.75 10.75 0 0 0 4.204-8.162L16 .775zM9.348 9.988l-4.2 2.1-1.235-1.236 2.1-4.2a9.25 9.25 0 0 1 7.954-5.107l.506-.018-.018.506a9.25 9.25 0 0 1-5.107 7.955zM5.75 14.2v-.736l4.268-2.135.232-.116v1.12a1.25 1.25 0 0 1-1.025 1.23L5.75 14.2zm-3.214-3.95l2.135-4.268.115-.232h-1.12a1.25 1.25 0 0 0-1.229 1.025L1.8 10.25h.736zM10.5 6a.5.5 0 1 1-1 0 .5.5 0 0 1 1 0zM12 6a2 2 0 1 1-4 0 2 2 0 0 1 4 0z\"></path>"
  },
  "rocket-launch": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M15.808 0a9.999 9.999 0 0 0-7.142 3H6.75A2.75 2.75 0 0 0 4 5.75V8h2l2 2v2h2.25A2.75 2.75 0 0 0 13 9.25V7.334a9.998 9.998 0 0 0 3-7.142V0h-.192zM6.44 6.5a9.964 9.964 0 0 1 1.015-2H6.75c-.69 0-1.25.56-1.25 1.25v.75h.94zm3.06 4v-.94a9.966 9.966 0 0 0 2-1.015v.705c0 .69-.56 1.25-1.25 1.25H9.5zm4.88-8.88a8.502 8.502 0 0 0-6.71 5.928l.782.783a8.502 8.502 0 0 0 5.928-6.71zm-11.6 8.66a.75.75 0 1 0-1.06-1.06l-1.5 1.5a.75.75 0 1 0 1.06 1.06l1.5-1.5zm3 1a.75.75 0 1 0-1.06-1.06l-4.5 4.5a.75.75 0 1 0 1.06 1.06l4.5-4.5zm1 1.94a.75.75 0 0 1 0 1.06l-1.5 1.5a.75.75 0 0 1-1.06-1.06l1.5-1.5a.75.75 0 0 1 1.06 0z\"></path>"
  },
  "search": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.5 7a4.5 4.5 0 1 1-9 0 4.5 4.5 0 0 1 9 0zm-.82 4.74a6 6 0 1 1 1.06-1.06l3.04 3.04a.75.75 0 1 1-1.06 1.06l-3.04-3.04z\"></path>"
  },
  "settings": {
    v: "0 0 16 16",
    c: "<path d=\"M6.43 1.168l-.74-.123.74.123zm-.156.939l.74.123-.74-.123zm-.173.2l.237.711-.237-.711zM4.02 3.509l-.498-.56.498.56zm-.26.05l.263-.702-.263.702zm-.893-.334l.263-.703-.263.703zm-.608.218l-.65-.375.65.375zM1.183 5.307l-.65-.375.65.375zm.115.636l.477-.579-.477.58zm.736.606l-.477.579.477-.58zm.086.25l.735.149-.735-.15zm0 2.403l.735-.15-.735.15zm-.086.25l.476.578-.476-.579zm-.736.605l-.476-.58.476.58zm-.115.636l-.65.375.65-.375zm1.077 1.864l.65-.375-.65.375zm.608.218l.263.703-.263-.703zm.893-.334l-.263-.703.263.703zm.26.05l-.498.56.498-.56zm2.08 1.202l.237-.711-.237.711zm.173.2l.74-.123-.74.123zm.156.94l.74-.124-.74.123zm3.14 0l-.74-.124.74.123zm.156-.94l.74.123-.74-.123zm.173-.2l.238.712-.238-.712zm2.08-1.202l-.497-.561.497.56zm.26-.05l.263-.703-.263.703zm.893.334l-.263.703.263-.703zm.609-.218l-.65-.375.65.375zm1.076-1.864l.65.375-.65-.375zm-.115-.636l-.477.579.477-.58zm-.736-.606l-.476.58.476-.58zm-.086-.25l.735.15-.735-.15zm0-2.403l.735-.15-.735.15zm.086-.25l-.476-.578.476.579zm.736-.605l-.477-.579.477.58zm.115-.636l.65-.375-.65.375zM13.74 3.443l-.65.375.65-.375zm-.609-.218l-.263-.703.263.703zm-.893.334l-.263-.702.263.702zm-.26-.05l-.497.561.497-.56zM9.9 2.307l-.237.711.237-.711zm-.173-.2l.74-.123-.74.123zm-.156-.94l-.74.124.74-.123zM6.924 1.5h2.152V0H6.924v1.5zm.246-.209a.25.25 0 0 1-.246.209V0A1.25 1.25 0 0 0 5.69 1.044l1.48.247zm-.156.94l.156-.94-1.48-.246-.156.939 1.48.246zm-.676.787c.343-.114.613-.41.676-.788l-1.48-.246a.494.494 0 0 1 .33-.389l.474 1.423zM4.518 4.07a5.244 5.244 0 0 1 1.82-1.052l-.474-1.423a6.744 6.744 0 0 0-2.34 1.353l.994 1.122zm-1.02.192c.36.134.75.048 1.02-.192l-.995-1.122a.494.494 0 0 1 .501-.091l-.526 1.405zm-.893-.335l.893.335.526-1.405-.893-.335-.526 1.405zm.304-.11a.25.25 0 0 1-.304.11l.526-1.405a1.25 1.25 0 0 0-1.521.546l1.3.75zM1.833 5.683l1.076-1.864-1.299-.75L.534 4.932l1.299.75zm-.058-.318a.25.25 0 0 1 .058.318l-1.3-.75a1.25 1.25 0 0 0 .289 1.59l.953-1.158zm.735.606l-.735-.606-.953 1.158.735.606.953-1.158zm.345.978a1.006 1.006 0 0 0-.345-.978l-.953 1.158a.494.494 0 0 1-.172-.48l1.47.3zM2.75 8c0-.361.036-.713.105-1.052l-1.47-.3c-.088.438-.135.89-.135 1.352h1.5zm.105 1.052A5.277 5.277 0 0 1 2.75 8h-1.5c0 .462.047.914.135 1.351l1.47-.299zm-.345.978c.296-.243.417-.624.345-.978l-1.47.3a.494.494 0 0 1 .172-.48l.953 1.158zm-.735.606l.735-.606-.953-1.158-.735.606.953 1.158zm.058-.318a.25.25 0 0 1-.058.318L.822 9.478a1.25 1.25 0 0 0-.288 1.59l1.299-.75zm1.076 1.864l-1.076-1.864-1.3.75 1.077 1.864 1.3-.75zm-.304-.109a.25.25 0 0 1 .304.11l-1.299.75c.306.528.949.76 1.521.545l-.526-1.405zm.893-.335l-.893.335.526 1.405.893-.335-.526-1.405zm1.02.192a1.006 1.006 0 0 0-1.02-.191l.526 1.404a.494.494 0 0 1-.5-.091l.994-1.122zm1.82 1.052a5.243 5.243 0 0 1-1.82-1.052l-.995 1.122a6.745 6.745 0 0 0 2.34 1.353l.475-1.423zm.676.788a1.006 1.006 0 0 0-.676-.788l-.474 1.423a.494.494 0 0 1-.33-.388l1.48-.247zm.156.939l-.156-.94-1.48.248.157.939 1.48-.247zm-.246-.209a.25.25 0 0 1 .246.209l-1.48.247A1.25 1.25 0 0 0 6.925 16v-1.5zm2.152 0H6.924V16h2.152v-1.5zm-.246.209a.25.25 0 0 1 .246-.209V16a1.25 1.25 0 0 0 1.233-1.044l-1.48-.247zm.156-.94l-.156.94 1.48.247.156-.94-1.48-.246zm.676-.787c-.343.114-.613.41-.676.788l1.48.246a.494.494 0 0 1-.33.389l-.474-1.423zm1.82-1.052a5.244 5.244 0 0 1-1.82 1.052l.474 1.423a6.745 6.745 0 0 0 2.34-1.353l-.994-1.122zm1.02-.191a1.006 1.006 0 0 0-1.02.19l.995 1.123a.494.494 0 0 1-.501.091l.526-1.405zm.893.334l-.893-.335-.526 1.405.893.335.526-1.405zm-.304.11a.25.25 0 0 1 .304-.11l-.526 1.405a1.25 1.25 0 0 0 1.521-.546l-1.299-.75zm1.076-1.865l-1.076 1.864 1.299.75 1.076-1.864-1.299-.75zm.058.318a.25.25 0 0 1-.058-.318l1.3.75a1.25 1.25 0 0 0-.289-1.59l-.953 1.158zm-.735-.606l.735.606.953-1.158-.735-.606-.953 1.158zm-.345-.978c-.072.354.049.735.345.978l.953-1.158c.15.123.206.311.172.48l-1.47-.3zM13.25 8c0 .361-.036.713-.105 1.052l1.47.3c.088-.438.135-.89.135-1.352h-1.5zm-.105-1.052c.069.339.105.69.105 1.052h1.5c0-.462-.046-.914-.135-1.351l-1.47.299zm.345-.978a1.007 1.007 0 0 0-.345.978l1.47-.3a.494.494 0 0 1-.172.48L13.49 5.97zm.735-.606l-.735.606.953 1.158.735-.606-.953-1.158zm-.058.318a.25.25 0 0 1 .058-.318l.953 1.158a1.25 1.25 0 0 0 .288-1.59l-1.299.75zm-1.076-1.864l1.076 1.864 1.3-.75-1.077-1.864-1.299.75zm.304.109a.25.25 0 0 1-.304-.11l1.299-.75a1.25 1.25 0 0 0-1.521-.545l.526 1.405zm-.893.334l.893-.334-.526-1.405-.893.335.526 1.404zm-1.02-.19c.27.24.66.325 1.02.19l-.526-1.404a.494.494 0 0 1 .5.091l-.994 1.122zm-1.82-1.053a5.244 5.244 0 0 1 1.82 1.052l.995-1.122a6.744 6.744 0 0 0-2.34-1.353l-.475 1.423zm-.676-.788c.063.379.333.674.676.788l.474-1.423a.494.494 0 0 1 .33.389l-1.48.246zm-.156-.939l.156.94 1.48-.247-.157-.94-1.48.247zm.246.209a.25.25 0 0 1-.246-.209l1.48-.246A1.25 1.25 0 0 0 9.075 0v1.5zM10.25 8A2.25 2.25 0 0 1 8 10.25v1.5A3.75 3.75 0 0 0 11.75 8h-1.5zM8 5.75A2.25 2.25 0 0 1 10.25 8h1.5A3.75 3.75 0 0 0 8 4.25v1.5zM5.75 8A2.25 2.25 0 0 1 8 5.75v-1.5A3.75 3.75 0 0 0 4.25 8h1.5zM8 10.25A2.25 2.25 0 0 1 5.75 8h-1.5A3.75 3.75 0 0 0 8 11.75v-1.5z\"></path>"
  },
  "share": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M12.5 4.5a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm0 1.5a2.5 2.5 0 1 0-2.469-2.104L5.298 6.263a2.5 2.5 0 1 0 0 3.475l4.733 2.366a2.5 2.5 0 1 0 .671-1.341L5.97 8.396a2.519 2.519 0 0 0 0-.792l4.733-2.367c.455.47 1.092.763 1.798.763zm1 6.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM4.5 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "shield": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M2.5 5.4V3.132l4.75-1.357v11.608l-1.782-1.528A8.5 8.5 0 0 1 2.5 5.401zm6.25 7.982l1.782-1.528A8.5 8.5 0 0 0 13.5 5.401V3.13L8.75 1.774v11.608zM1 2l7-2 7 2v3.4a10 10 0 0 1-3.492 7.593L8 16l-3.508-3.007A10 10 0 0 1 1 5.401V2z\"></path>"
  },
  "slight-smile": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14.5 8a6.5 6.5 0 1 1-13 0 6.5 6.5 0 0 1 13 0zM16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zM6 8a1 1 0 1 0 0-2 1 1 0 0 0 0 2zm5-1a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-4.37 4.384a2.749 2.749 0 0 0 3.751-1.009.75.75 0 0 0-1.299-.75 1.25 1.25 0 0 1-2.163.003.75.75 0 0 0-1.297.753c.242.417.59.763 1.007 1.003z\"></path>"
  },
  "snippet": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3.625.1A.75.75 0 0 1 4.65.375L8 6.177 11.35.375a.75.75 0 1 1 1.3.75L8.864 7.677l1.97 3.412A2.503 2.503 0 0 1 14 13.5a2.5 2.5 0 1 1-4.425-1.595L7.999 9.176l-.26.45a.75.75 0 0 1-1.298-.751l.692-1.199L3.35 1.125A.75.75 0 0 1 3.625.1zM5.5 13.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm1.5 0a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zm5.5 0a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "sort-highest": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 14l.53-.53 2.25-2.25a.75.75 0 0 0-1.06-1.061l-.97.97v-8.38a.75.75 0 1 0-1.5 0v8.38l-.97-.97a.75.75 0 0 0-1.06 1.06l2.25 2.25L3 14zM8.75 2a.75.75 0 0 0 0 1.5h6.5a.75.75 0 0 0 0-1.5h-6.5zm0 3.25a.75.75 0 0 0 0 1.5h4.5a.75.75 0 0 0 0-1.5h-4.5zm-.75 4a.75.75 0 0 1 .75-.75h1.5a.75.75 0 0 1 0 1.5h-1.5A.75.75 0 0 1 8 9.25z\"></path>"
  },
  "sort-lowest": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 2l.53.53 2.25 2.25a.75.75 0 0 1-1.06 1.061l-.97-.97v8.38a.75.75 0 0 1-1.5 0V4.87l-.97.97A.75.75 0 0 1 .22 4.78l2.25-2.25L3 2zm5 4.75c0 .414.336.75.75.75h1.5a.75.75 0 0 0 0-1.5h-1.5a.75.75 0 0 0-.75.75zm.75 4a.75.75 0 0 1 0-1.5h4.5a.75.75 0 0 1 0 1.5h-4.5zm0 3.25a.75.75 0 0 1 0-1.5h6.5a.75.75 0 0 1 0 1.5h-6.5z\"></path>"
  },
  "star": {
    v: "0 0 16 16",
    c: "<path d=\"M7.454 1.694a.591.591 0 0 1 1.092 0l1.585 3.81a.25.25 0 0 0 .21.154l4.114.33a.591.591 0 0 1 .338 1.038L11.658 9.71a.25.25 0 0 0-.08.247l.957 4.015a.591.591 0 0 1-.883.641l-3.522-2.15a.25.25 0 0 0-.26 0l-3.522 2.15a.591.591 0 0 1-.883-.641l.957-4.015a.25.25 0 0 0-.08-.247L1.207 7.026a.591.591 0 0 1 .338-1.038l4.113-.33a.25.25 0 0 0 .211-.153l1.585-3.81z\"></path>"
  },
  "star-o": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M7.189 2.332l-.001.003-1.319 3.17a.25.25 0 0 1-.21.153l-3.423.274h-.003l-.095.008-.593.048a.591.591 0 0 0-.338 1.038l.452.387.073.062.002.002 2.608 2.234a.25.25 0 0 1 .08.247l-.796 3.34-.001.003-.022.093-.138.579a.591.591 0 0 0 .883.641l.507-.31.082-.05.003-.001 2.93-1.79a.25.25 0 0 1 .26 0l2.93 1.79.003.002.082.05.507.31a.591.591 0 0 0 .883-.642l-.138-.579-.022-.093v-.003l-.797-3.34a.25.25 0 0 1 .08-.247l2.608-2.234.002-.002.073-.062.452-.387a.591.591 0 0 0-.338-1.038l-.593-.048-.095-.008h-.003l-3.422-.274a.25.25 0 0 1-.211-.153l-1.319-3.17-.001-.003-.037-.089-.228-.549a.591.591 0 0 0-1.092 0l-.228.55-.037.088zM8 4.288L7.254 6.08a1.75 1.75 0 0 1-1.476 1.072l-1.935.155L5.317 8.57a1.75 1.75 0 0 1 .564 1.736l-.45 1.888 1.657-1.012a1.75 1.75 0 0 1 1.824 0l1.657 1.012-.45-1.889a1.75 1.75 0 0 1 .564-1.735l1.474-1.263-1.935-.155A1.75 1.75 0 0 1 8.746 6.08L8 4.288z\"></path>"
  },
  "subgroup": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6 4a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm1.5 0a3 3 0 1 1-6 0 3 3 0 0 1 6 0zm7 4a3 3 0 1 1-6 0 3 3 0 0 1 6 0zm-10 5.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zm0 1.5a3 3 0 1 0 0-6 3 3 0 0 0 0 6z\"></path>"
  },
  "tag": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.172 5.5a.5.5 0 0 1 .353.146l1.06-1.06-1.06 1.06L13.88 8l-2.354 2.354a.5.5 0 0 1-.353.146H2a.5.5 0 0 1-.5-.5V6a.5.5 0 0 1 .5-.5h9.172zm3.767 1.44l-2.353-2.354A2 2 0 0 0 11.172 4H2a2 2 0 0 0-2 2v4a2 2 0 0 0 2 2h9.172a2 2 0 0 0 1.414-.586l2.353-2.353L16 8l-1.06-1.06zm-8.189.31a.75.75 0 0 0 0 1.5h3.5a.75.75 0 0 0 0-1.5h-3.5z\"></path>"
  },
  "terminal": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M14 3.5H2a.5.5 0 0 0-.5.5v8a.5.5 0 0 0 .5.5h12a.5.5 0 0 0 .5-.5V4a.5.5 0 0 0-.5-.5zM2 2a2 2 0 0 0-2 2v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H2zm5 8.25a.75.75 0 0 1 .75-.75h4.5a.75.75 0 0 1 0 1.5h-4.5a.75.75 0 0 1-.75-.75zM4.28 5.22a.75.75 0 0 0-1.06 1.06L4.94 8 3.22 9.72a.75.75 0 1 0 1.06 1.06l2.25-2.25.53-.53-.53-.53-2.25-2.25z\"></path>"
  },
  "thumb-up": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.72 2.598l-.27.902L10 5h3.989a2 2 0 0 1 1.932 2.517l-1.19 4.448a4 4 0 0 1-4.88 2.835L3 13H0V5h3L7.39.61c1.47-1.47 3.928-.002 3.33 1.988zM3 6.5H1.5v5H3v-5zm7.232 6.85L4.5 11.843V5.621L8.451 1.67a.466.466 0 0 1 .296-.155.533.533 0 0 1 .314.08c.11.065.183.154.22.238.03.07.051.173.003.334l-.72 2.402-.58 1.931h6.005a.5.5 0 0 1 .483.63l-1.19 4.447a2.5 2.5 0 0 1-3.05 1.773z\"></path>"
  },
  "thumb-down": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.72 13.402l-.27-.902L10 11h3.989a2 2 0 0 0 1.932-2.517l-1.19-4.448A4 4 0 0 0 9.852 1.2L3 3H0v8h3l4.39 4.39c1.47 1.47 3.928.002 3.33-1.988zM3 9.5H1.5v-5H3v5zm7.232-6.85L4.5 4.157v6.222l3.951 3.951c.12.119.22.149.296.155a.533.533 0 0 0 .314-.08.533.533 0 0 0 .22-.238.466.466 0 0 0 .003-.334l-.72-2.402-.58-1.931h6.005a.5.5 0 0 0 .483-.63l-1.19-4.447a2.5 2.5 0 0 0-3.05-1.772z\"></path>"
  },
  "todo-add": {
    v: "0 0 16 16",
    c: "<path d=\"M6.25 1a.75.75 0 0 1 0 1.5H3a.5.5 0 0 0-.5.5v10a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5V9.75a.75.75 0 0 1 1.5 0V13a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h3.25zM12 0a.75.75 0 0 1 .75.75v2.5h2.5a.75.75 0 0 1 0 1.5h-2.5v2.5a.75.75 0 0 1-1.5 0v-2.5h-2.5a.75.75 0 0 1 0-1.5h2.5V.75A.75.75 0 0 1 12 0z\"></path>"
  },
  "todo-done": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M3 13.5a.5.5 0 0 1-.5-.5V3a.5.5 0 0 1 .5-.5h9.25a.75.75 0 0 0 0-1.5H3a2 2 0 0 0-2 2v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V9.75a.75.75 0 0 0-1.5 0V13a.5.5 0 0 1-.5.5H3zm12.78-8.82a.75.75 0 0 0-1.06-1.06L9.162 9.177 7.289 7.241a.75.75 0 1 0-1.078 1.043l2.403 2.484a.75.75 0 0 0 1.07.01L15.78 4.68z\"></path>"
  },
  "token": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M5 4.5h6a3.5 3.5 0 1 1 0 7H5a3.5 3.5 0 1 1 0-7zM0 8a5 5 0 0 1 5-5h6a5 5 0 0 1 0 10H5a5 5 0 0 1-5-5zm11 1a1 1 0 1 0 0-2 1 1 0 0 0 0 2zM9 8a1 1 0 1 1-2 0 1 1 0 0 1 2 0zM5 9a1 1 0 1 0 0-2 1 1 0 0 0 0 2z\"></path>"
  },
  "unapproval": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M4 6.5a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM7 5a2.99 2.99 0 0 1-.87 2.113A3.997 3.997 0 0 1 8 10.5V12a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2v-1.5c0-1.427.747-2.679 1.87-3.387A3 3 0 1 1 7 5zm-5.5 5.5a2.5 2.5 0 0 1 5 0V12a.5.5 0 0 1-.5.5H2a.5.5 0 0 1-.5-.5v-1.5zm9.72-6.28a.75.75 0 0 1 1.06 0l1.22 1.22 1.22-1.22a.75.75 0 1 1 1.06 1.06L14.56 6.5l1.22 1.22a.75.75 0 0 1-1.06 1.06L13.5 7.56l-1.22 1.22a.75.75 0 1 1-1.06-1.06l1.22-1.22-1.22-1.22a.75.75 0 0 1 0-1.06z\"></path>"
  },
  "user": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M10.5 5a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0zm.514 2.63a4 4 0 1 0-6.028 0A4.002 4.002 0 0 0 2 11.5V13a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-1.5a4.002 4.002 0 0 0-2.986-3.87zM8 9H6a2.5 2.5 0 0 0-2.5 2.5V13a.5.5 0 0 0 .5.5h8a.5.5 0 0 0 .5-.5v-1.5A2.5 2.5 0 0 0 10 9H8z\"></path>"
  },
  "users": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.5 4a1.5 1.5 0 1 1-3 0 1.5 1.5 0 0 1 3 0zm.63 2.113a3 3 0 1 0-4.259 0A3.997 3.997 0 0 0 1 9.5V13a2 2 0 0 0 2 2h4c.597 0 1.134-.262 1.5-.677.366.415.903.677 1.5.677h3a2 2 0 0 0 2-2v-2c0-1.218-.622-2.29-1.565-2.917a2.5 2.5 0 1 0-3.87 0c-.241.16-.462.35-.656.564a4.005 4.005 0 0 0-1.78-2.534zM5 7a2.5 2.5 0 0 0-2.5 2.5V13a.5.5 0 0 0 .5.5h4a.5.5 0 0 0 .5-.5V9.5A2.5 2.5 0 0 0 5 7zm7.5-.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-1 2.5a2 2 0 0 0-2 2v2a.5.5 0 0 0 .5.5h3a.5.5 0 0 0 .5-.5v-2a2 2 0 0 0-2-2z\"></path>"
  },
  "warning": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M8.429 2.746a.5.5 0 0 0-.858 0L1.58 12.743a.5.5 0 0 0 .429.757h11.984a.5.5 0 0 0 .43-.757L8.428 2.746zm-2.144-.77C7.06.68 8.939.68 9.715 1.975l5.993 9.996c.799 1.333-.161 3.028-1.716 3.028H2.008C.453 15-.507 13.305.292 11.972l5.993-9.997zM9 11.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0zm-.25-5.75a.75.75 0 0 0-1.5 0v3a.75.75 0 0 0 1.5 0v-3z\"></path>"
  },
  "warning-solid": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6.285 1.975C7.06.68 8.939.68 9.715 1.975l5.993 9.997c.799 1.333-.161 3.028-1.716 3.028H2.008C.453 15-.507 13.305.292 11.972l5.993-9.997zM8 5a.75.75 0 0 1 .75.75v3a.75.75 0 0 1-1.5 0v-3A.75.75 0 0 1 8 5zm1 6.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0z\"></path>"
  },
  "weight": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M9.25 3.75a1.25 1.25 0 1 1-2.5 0 1.25 1.25 0 0 1 2.5 0zM10.45 5a2.75 2.75 0 1 0-4.9 0H3.82a1 1 0 0 0-.98.804l-1.6 8A1 1 0 0 0 2.22 15h11.56a1 1 0 0 0 .98-1.196l-1.6-8A1 1 0 0 0 12.18 5h-1.73zM8 6.5H4.23l-1.4 7h10.34l-1.4-7H8z\"></path>"
  },
  "work": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M6 1a1.75 1.75 0 0 0-1.75 1.75V4H3a2 2 0 0 0-2 2v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-1.25V2.75A1.75 1.75 0 0 0 10 1H6zm4.25 3V2.75A.25.25 0 0 0 10 2.5H6a.25.25 0 0 0-.25.25V4h4.5zM3 5.5h10a.5.5 0 0 1 .5.5v1h-11V6a.5.5 0 0 1 .5-.5zm-.5 3V13a.5.5 0 0 0 .5.5h10a.5.5 0 0 0 .5-.5V8.5H9V10H7V8.5H2.5z\"></path>"
  },
  "leave": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.16 4.28a.75.75 0 1 1 1.06-1.06l3.25 3.25L16 7l-.53.53-3.25 3.25a.75.75 0 0 1-1.06-1.06l1.97-1.97H3.25a1.75 1.75 0 1 0 0 3.5h2a.75.75 0 0 1 0 1.5h-2a3.25 3.25 0 0 1 0-6.5h9.88l-1.97-1.97z\"></path>"
  },
  "import": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.78 7.159a.75.75 0 0 0-1.06 0l-1.97 1.97V1.75a.75.75 0 0 0-1.5 0v7.379l-1.97-1.97a.75.75 0 0 0-1.06 1.06l3.25 3.25L8 12l.53-.53 3.25-3.25a.75.75 0 0 0 0-1.061zM2.5 9.75a.75.75 0 1 0-1.5 0V13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V9.75a.75.75 0 0 0-1.5 0V13a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V9.75z\"></path>"
  },
  "export": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M11.78 5.841a.75.75 0 0 1-1.06 0l-1.97-1.97v7.379a.75.75 0 0 1-1.5 0V3.871l-1.97 1.97a.75.75 0 0 1-1.06-1.06l3.25-3.25L8 1l.53.53 3.25 3.25a.75.75 0 0 1 0 1.061zM2.5 9.75a.75.75 0 0 0-1.5 0V13a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V9.75a.75.75 0 0 0-1.5 0V13a.5.5 0 0 1-.5.5H3a.5.5 0 0 1-.5-.5V9.75z\"></path>"
  },
  "power": {
    v: "0 0 16 16",
    c: "<path fill-rule=\"evenodd\" clip-rule=\"evenodd\" d=\"M7.25 7.25a.75.75 0 0 0 1.5 0V.75a.75.75 0 0 0-1.5 0v6.5zm4.04 5.157A5.5 5.5 0 1 1 5 3.39a.75.75 0 1 0-.818-1.257 7 7 0 1 0 7.635 0A.75.75 0 0 0 11 3.39a5.5 5.5 0 0 1 .291 9.017z\"></path>"
  }
};
const STATUS_ICONS = {
  "status_success": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M6.278 7.697L5.045 6.464a.296.296 0 0 0-.42-.002l-.613.614a.298.298 0 0 0 .002.42l1.91 1.909a.5.5 0 0 0 .703.005l.265-.265L9.997 6.04a.291.291 0 0 0-.009-.408l-.614-.614a.29.29 0 0 0-.408-.009L6.278 7.697z\"></path>"
  },
  "status_success_solid": {
    v: "0 0 14 14",
    c: "<path d=\"M0 7a7 7 0 1 1 14 0A7 7 0 0 1 0 7zm6.278.697L5.045 6.464a.296.296 0 0 0-.42-.002l-.613.614a.298.298 0 0 0 .002.42l1.91 1.909a.5.5 0 0 0 .703.005l.265-.265L9.997 6.04a.291.291 0 0 0-.009-.408l-.614-.614a.29.29 0 0 0-.408-.009L6.278 7.697z\" fill-rule=\"evenodd\"></path>"
  },
  "status_failed": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M7 5.969L5.599 4.568a.29.29 0 0 0-.413.004l-.614.614a.294.294 0 0 0-.004.413L5.968 7l-1.4 1.401a.29.29 0 0 0 .004.413l.614.614c.113.114.3.117.413.004L7 8.032l1.401 1.4a.29.29 0 0 0 .413-.004l.614-.614a.294.294 0 0 0 .004-.413L8.032 7l1.4-1.401a.29.29 0 0 0-.004-.413l-.614-.614a.294.294 0 0 0-.413-.004L7 5.968z\"></path>"
  },
  "status_running": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M7 3c2.2 0 4 1.8 4 4s-1.8 4-4 4c-1.3 0-2.5-.7-3.3-1.7L7 7V3\"></path>"
  },
  "status_pending": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M4.7 5.3c0-.2.1-.3.3-.3h.9c.2 0 .3.1.3.3v3.4c0 .2-.1.3-.3.3H5c-.2 0-.3-.1-.3-.3V5.3m3 0c0-.2.1-.3.3-.3h.9c.2 0 .3.1.3.3v3.4c0 .2-.1.3-.3.3H8c-.2 0-.3-.1-.3-.3V5.3\"></path>"
  },
  "status_created": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><circle cx=\"7\" cy=\"7\" r=\"3.25\"></circle>"
  },
  "status_canceled": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M5.2 3.8l4.9 4.9c.2.2.2.5 0 .7l-.7.7c-.2.2-.5.2-.7 0L3.8 5.2c-.2-.2-.2-.5 0-.7l.7-.7c.2-.2.5-.2.7 0\"></path>"
  },
  "status_skipped": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M6.415 7.04L4.579 5.203a.295.295 0 0 1 .004-.416l.349-.349a.29.29 0 0 1 .416-.004l2.214 2.214a.289.289 0 0 1 .019.021l.132.133c.11.11.108.291 0 .398L5.341 9.573a.282.282 0 0 1-.398 0l-.331-.331a.285.285 0 0 1 0-.399L6.415 7.04zm2.54 0L7.119 5.203a.295.295 0 0 1 .004-.416l.349-.349a.29.29 0 0 1 .416-.004l2.214 2.214a.289.289 0 0 1 .019.021l.132.133c.11.11.108.291 0 .398L7.881 9.573a.282.282 0 0 1-.398 0l-.331-.331a.285.285 0 0 1 0-.399L8.955 7.04z\"></path>"
  },
  "status_manual": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M10.5 7.63V6.37l-.787-.13c-.044-.175-.132-.349-.263-.61l.481-.652-.918-.913-.657.478a2.346 2.346 0 0 0-.612-.26L7.656 3.5H6.388l-.132.783c-.219.043-.394.13-.612.26l-.657-.478-.918.913.437.652c-.131.218-.175.392-.262.61l-.744.086v1.261l.787.13c.044.218.132.392.263.61l-.438.651.92.913.655-.434c.175.086.394.173.613.26l.131.783h1.313l.131-.783c.219-.043.394-.13.613-.26l.656.478.918-.913-.48-.652c.13-.218.218-.435.262-.61l.656-.13zM7 8.283a1.285 1.285 0 0 1-1.313-1.305c0-.739.57-1.304 1.313-1.304.744 0 1.313.565 1.313 1.304 0 .74-.57 1.305-1.313 1.305z\"></path>"
  },
  "status_scheduled": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M6.995 10.64a3.645 3.645 0 1 1 0-7.29 3.645 3.645 0 0 1 0 7.29zm0-1.042a2.603 2.603 0 1 0 0-5.206 2.603 2.603 0 0 0 0 5.206z\"></path><path d=\"M7.033 4.92h-.065a.488.488 0 0 0-.488.488v1.627c0 .27.218.488.488.488h.065c.27 0 .488-.218.488-.488V5.408a.488.488 0 0 0-.488-.488z\"></path><path d=\"M8.075 6.48H6.968a.488.488 0 0 0-.488.488v.065c0 .27.218.488.488.488h1.107c.27 0 .488-.218.488-.488v-.065a.488.488 0 0 0-.488-.488z\"></path>"
  },
  "status_warning": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M6 3.5c0-.3.2-.5.5-.5h1c.3 0 .5.2.5.5v4c0 .3-.2.5-.5.5h-1c-.3 0-.5-.2-.5-.5v-4m0 6c0-.3.2-.5.5-.5h1c.3 0 .5.2.5.5v1c0 .3-.2.5-.5.5h-1c-.3 0-.5-.2-.5-.5v-1\"></path>"
  },
  "status_preparing": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><circle cx=\"7\" cy=\"7\" r=\"1\"></circle><circle cx=\"10\" cy=\"7\" r=\"1\"></circle><circle cx=\"4\" cy=\"7\" r=\"1\"></circle>"
  },
  "status_notfound": {
    v: "0 0 14 14",
    c: "<path d=\"M7 0a7 7 0 1 1 0 14A7 7 0 0 1 7 0zm0 1a6 6 0 1 0 0 12A6 6 0 0 0 7 1z\"></path><path d=\"M8.16 7.184c.519-.37.904-.857 1.07-1.477.384-1.427-.619-2.897-2.246-2.897-.732 0-1.327.26-1.766.692a2.163 2.163 0 0 0-.509.743.75.75 0 0 0 1.4.54.78.78 0 0 1 .16-.213c.168-.165.39-.262.715-.262.597 0 .936.496.798 1.007-.067.249-.235.462-.492.644-.231.165-.47.264-.601.3a.75.75 0 0 0-.556.724v1.421a.75.75 0 0 0 1.5 0v-.909a3.74 3.74 0 0 0 .526-.313z\"></path><circle cx=\"6.889\" cy=\"10.634\" r=\"1\"></circle>"
  }
};
const FILE_ICONS = {
  "javascript": {
    v: "0 0 24 24",
    c: "<path d=\"M3 3h18v18H3V3m4.73 15.04c.4.85 1.19 1.55 2.54 1.55 1.5 0 2.53-.8 2.53-2.55v-5.78h-1.7V17c0 .86-.35 1.08-.9 1.08-.58 0-.82-.4-1.09-.87l-1.38.83m5.98-.18c.5.98 1.51 1.73 3.09 1.73 1.6 0 2.8-.83 2.8-2.36 0-1.41-.81-2.04-2.25-2.66l-.42-.18c-.73-.31-1.04-.52-1.04-1.02 0-.41.31-.73.81-.73.48 0 .8.21 1.09.73l1.31-.87c-.55-.96-1.33-1.33-2.4-1.33-1.51 0-2.48.96-2.48 2.23 0 1.38.81 2.03 2.03 2.55l.42.18c.78.34 1.24.55 1.24 1.13 0 .48-.45.83-1.15.83-.83 0-1.31-.43-1.67-1.03l-1.38.8z\" fill=\"#ffca28\"></path>"
  },
  "typescript": {
    v: "0 0 500 500",
    c: "<path d=\"M46 46v408h408V46H46zm310.02 198.17v.006c3.912.012 8.359.213 11.703.576 13.619 1.473 24.225 7.349 33.248 18.416 4.493 5.513 6.03 7.925 5.703 8.957-.211.666-3.294 2.874-13.096 9.38-9.629 6.393-12.73 8.308-13.45 8.308-.731 0-2.253-1.566-4.446-4.573-4.225-5.789-8.538-8.431-15.205-9.312-7.17-.95-13.602 1.31-16.752 5.888-2.693 3.912-3.1 10.206-.96 14.78 2.48 5.297 6.968 8.226 24.167 15.767 19.836 8.698 29.888 14.651 37.209 22.04 7.884 7.956 11.878 17.142 13.105 30.136.599 6.334-.133 13.84-1.945 19.943-4.445 14.961-16.44 25.916-34.02 31.072-4.86 1.425-9.382 2.276-13.855 2.604-6.829.503-16.603.226-22.486-.63-14.884-2.169-31.686-10.83-40.064-20.65-4.113-4.821-9.364-12.755-9.364-14.15 0-.674.334-1.057 1.656-1.897 3.922-2.492 26.394-15.338 26.83-15.338.264 0 1.438 1.383 2.608 3.074 2.651 3.828 9.17 10.407 12.484 12.602 2.707 1.793 6.169 3.232 10.279 4.271 2.354.587 3.6.692 8.736.692 5.248-.002 6.324-.09 8.672-.721 6.21-1.671 11.057-5.13 13.111-9.354.9-1.825.918-2.053.918-6.48v-4.59l-1.104-2.19c-2.673-5.306-8.433-8.947-26.645-16.835-8.365-3.624-18.61-8.733-22.61-11.275-9.129-5.801-15.456-12.433-19.608-20.551-4.13-8.073-4.745-11.078-4.755-23.217-.01-9.503-.026-9.386 1.941-15.451 1.785-5.504 5.439-11.652 9.473-15.94 8.05-8.557 19.813-14.057 32.406-15.151 1.61-.153 3.768-.212 6.115-.205zm-108.36 1.877h.004c24.253.012 38.156.096 38.379.236.42.26.473 2.371.473 15.842v15.541l-24.201.088-24.201.088v68.713c0 37.793-.077 68.938-.182 69.213-.171.463-2.033.498-17.78.498h-17.587l-.182-.71c-.117-.39-.203-31.537-.205-69.214l-.006-68.504-24.2-.086-24.202-.088v-15.357c0-12.18.084-15.442.409-15.766.333-.343 12.684-.431 65.902-.484 10.26-.01 19.495-.015 27.58-.01z\" fill=\"#0288d1\"></path>"
  },
  "dart": {
    v: "0 0 24 24",
    c: "<path d=\"M12.618 1.566a.978.978 0 0 0-.682.281l-.01.007-6.388 3.692 6.372 6.372v.004l7.658 7.659 1.46-2.63-5.264-12.64-2.457-2.457a.972.972 0 0 0-.69-.288z\" fill=\"#66C3FA\"></path><path d=\"M5.553 5.531l-3.69 6.383-.007.01a.967.967 0 0 0 .006 1.371l3.058 3.061 11.963 4.706 2.705-1.502-.073-.073-.019.002-7.5-7.512h-.009L5.553 5.53z\" fill=\"#215896\"></path><path d=\"M5.537 5.534l6.518 6.525h.01l7.501 7.51 2.856-.544.004-8.449-3.015-2.955c-.66-.647-1.675-1.064-2.695-1.202l.002-.032-11.18-.852z\" fill=\"#235997\"></path><path d=\"M5.545 5.542l6.522 6.522v.009l7.506 7.506-.546 2.855h-8.449l-2.954-3.017c-.647-.66-1.063-1.676-1.2-2.696l-.033.003-.846-11.182z\" fill=\"#58B6F0\"></path>"
  },
  "json": {
    v: "0 0 24 24",
    c: "<path d=\"M5.759 3.975h1.783V5.76H5.759v4.458A1.783 1.783 0 0 1 3.975 12a1.783 1.783 0 0 1 1.784 1.783v4.459h1.783v1.783H5.759c-.954-.24-1.784-.803-1.784-1.783v-3.567a1.783 1.783 0 0 0-1.783-1.783H1.3v-1.783h.892a1.783 1.783 0 0 0 1.783-1.784V5.76A1.783 1.783 0 0 1 5.76 3.975m12.483 0a1.783 1.783 0 0 1 1.783 1.784v3.566a1.783 1.783 0 0 0 1.783 1.784h.892v1.783h-.892a1.783 1.783 0 0 0-1.783 1.783v3.567a1.783 1.783 0 0 1-1.783 1.783h-1.784v-1.783h1.784v-4.459A1.783 1.783 0 0 1 20.025 12a1.783 1.783 0 0 1-1.783-1.783V5.759h-1.784V3.975h1.784M12 14.675a.892.892 0 0 1 .892.892.892.892 0 0 1-.892.892.892.892 0 0 1-.891-.892.892.892 0 0 1 .891-.892m-3.566 0a.892.892 0 0 1 .891.892.892.892 0 0 1-.891.892.892.892 0 0 1-.892-.892.892.892 0 0 1 .892-.892m7.133 0a.892.892 0 0 1 .891.892.892.892 0 0 1-.891.892.892.892 0 0 1-.892-.892.892.892 0 0 1 .892-.892z\" fill=\"#fbc02d\"></path>"
  },
  "markdown": {
    v: "0 0 24 24",
    c: "<path d=\"M2.25 15.75v-8h2l3 3 3-3h2v8h-2v-5.17l-3 3-3-3v5.17h-2m14-8h3v4h2.5l-4 4.5-4-4.5h2.5z\" fill=\"#42a5f5\"></path>"
  },
  "css": {
    v: "0 0 24 24",
    c: "<path d=\"M5 3l-.65 3.34h13.59L17.5 8.5H3.92l-.66 3.33h13.59l-.76 3.81-5.48 1.81-4.75-1.81.33-1.64H2.85l-.79 4 7.85 3 9.05-3 1.2-6.03.24-1.21L21.94 3H5z\" fill=\"#42a5f5\"></path>"
  },
  "html": {
    v: "0 0 24 24",
    c: "<path d=\"M12 17.56l4.07-1.13.55-6.1H9.38L9.2 8.3h7.6l.2-1.99H7l.56 6.01h6.89l-.23 2.58-2.22.6-2.22-.6-.14-1.66h-2l.29 3.19L12 17.56M4.07 3h15.86L18.5 19.2 12 21l-6.5-1.8L4.07 3z\" fill=\"#e44d26\"></path>"
  },
  "docker": {
    v: "0 0 24 24",
    c: "<path d=\"M22.593 10.11c-.065-.043-.605-.464-1.77-.464-.303 0-.606.032-.908.086-.227-1.512-1.49-2.278-1.544-2.31l-.313-.184-.195.291a3.57 3.57 0 0 0-.55 1.285c-.216.864-.087 1.685.356 2.387-.53.302-1.393.378-1.577.378H1.87a.675.675 0 0 0-.67.68c0 1.242.195 2.483.627 3.65.486 1.285 1.22 2.235 2.16 2.818 1.058.648 2.797 1.015 4.773 1.015.853 0 1.738-.075 2.613-.237a10.655 10.655 0 0 0 3.445-1.253 8.962 8.962 0 0 0 2.343-1.933c1.134-1.263 1.803-2.7 2.29-3.941h.204c1.231 0 1.998-.497 2.42-.918.28-.26.485-.572.636-.94l.087-.259-.205-.15M3.199 11.178h1.9a.178.178 0 0 0 .173-.173V9.3a.178.178 0 0 0-.173-.173H3.2a.17.17 0 0 0-.173.173v1.706c.01.098.075.173.173.173m2.624 0h1.9a.178.178 0 0 0 .173-.173V9.3a.178.178 0 0 0-.173-.173h-1.9a.17.17 0 0 0-.173.173v1.706c.01.098.075.173.173.173m2.667 0h1.89c.108 0 .183-.075.183-.173V9.3a.174.174 0 0 0-.183-.173H8.49c-.087 0-.162.076-.162.173v1.706c0 .098.065.173.162.173m2.635 0h1.91a.169.169 0 0 0 .163-.173V9.3c0-.086-.065-.173-.162-.173h-1.911c-.087 0-.162.076-.162.173v1.706c0 .098.075.173.162.173M5.823 8.76h1.9c.087 0 .173-.097.173-.194V6.87a.17.17 0 0 0-.173-.172h-1.9c-.098 0-.173.064-.173.172v1.696c.01.097.075.194.173.194m2.667 0h1.89c.108 0 .183-.097.183-.194V6.87c0-.097-.065-.172-.183-.172H8.49c-.087 0-.162.064-.162.172v1.696c0 .097.065.194.162.194m2.635 0h1.91c.087 0 .163-.097.163-.194V6.87a.168.168 0 0 0-.162-.172h-1.911c-.087 0-.162.064-.162.172v1.696c0 .097.075.194.162.194m0-2.462h1.91a.169.169 0 0 0 .163-.173V4.441c0-.108-.076-.184-.162-.184h-1.911c-.087 0-.162.065-.162.184v1.684c0 .087.075.173.162.173m2.656 4.881h1.9a.17.17 0 0 0 .173-.173V9.3a.178.178 0 0 0-.172-.173H13.78c-.086 0-.162.076-.162.173v1.706c0 .097.076.173.162.173\" fill=\"#0087c9\"></path>"
  },
  "gitlab": {
    v: "0 0 25 24",
    c: "<path d=\"M24.507 9.5l-.034-.09L21.082.562a.896.896 0 0 0-1.694.091l-2.29 7.01H7.825L5.535.653a.898.898 0 0 0-1.694-.09L.451 9.411.416 9.5a6.297 6.297 0 0 0 2.09 7.278l.012.01.03.022 5.16 3.867 2.56 1.935 1.554 1.176a1.051 1.051 0 0 0 1.268 0l1.555-1.176 2.56-1.935 5.197-3.89.014-.01A6.297 6.297 0 0 0 24.507 9.5z\" fill=\"#E24329\"></path><path d=\"M24.507 9.5l-.034-.09a11.44 11.44 0 0 0-4.56 2.051l-7.447 5.632 4.742 3.584 5.197-3.89.014-.01A6.297 6.297 0 0 0 24.507 9.5z\" fill=\"#FC6D26\"></path><path d=\"M7.707 20.677l2.56 1.935 1.555 1.176a1.051 1.051 0 0 0 1.268 0l1.555-1.176 2.56-1.935-4.743-3.584-4.755 3.584z\" fill=\"#FCA326\"></path><path d=\"M5.01 11.461a11.43 11.43 0 0 0-4.56-2.05L.416 9.5a6.297 6.297 0 0 0 2.09 7.278l.012.01.03.022 5.16 3.867 4.745-3.584-7.444-5.632z\" fill=\"#FC6D26\"></path>"
  },
  "image": {
    v: "0 0 24 24",
    c: "<path d=\"M12.976 9.072h5.368l-5.368-5.367v5.367M6.144 2.241h7.808l5.856 5.855v11.711a1.952 1.952 0 0 1-1.952 1.952H6.145a1.951 1.951 0 0 1-1.952-1.952V4.192c0-1.083.868-1.951 1.952-1.951m0 17.567h11.71V12l-3.903 3.904L12 13.952l-5.856 5.856M8.096 9.073a1.952 1.952 0 0 0-1.952 1.952 1.952 1.952 0 0 0 1.952 1.951 1.952 1.952 0 0 0 1.952-1.951 1.952 1.952 0 0 0-1.952-1.952z\" fill=\"#26a69a\"></path>"
  },
  "python": {
    v: "0 0 24 24",
    c: "<path d=\"M9.86 2A2.86 2.86 0 0 0 7 4.86v1.68h4.29c.39 0 .71.57.71.96H4.86A2.86 2.86 0 0 0 2 10.36v3.781a2.86 2.86 0 0 0 2.86 2.86h1.18v-2.68a2.85 2.85 0 0 1 2.85-2.86h5.25c1.58 0 2.86-1.271 2.86-2.851V4.86A2.86 2.86 0 0 0 14.14 2zm-.72 1.61c.4 0 .72.12.72.71s-.32.891-.72.891c-.39 0-.71-.3-.71-.89s.32-.711.71-.711z\" fill=\"#3c78aa\"></path><path d=\"M17.959 7v2.68a2.85 2.85 0 0 1-2.85 2.859H9.86A2.85 2.85 0 0 0 7 15.389v3.75a2.86 2.86 0 0 0 2.86 2.86h4.28A2.86 2.86 0 0 0 17 19.14v-1.68h-4.291c-.39 0-.709-.57-.709-.96h7.14A2.86 2.86 0 0 0 22 13.64V9.86A2.86 2.86 0 0 0 19.14 7zM8.32 11.513l-.004.004c.012-.002.025-.001.038-.004zm6.54 7.276c.39 0 .71.3.71.89a.71.71 0 0 1-.71.71c-.4 0-.72-.12-.72-.71s.32-.89.72-.89z\" fill=\"#fdd835\"></path>"
  },
  "ruby": {
    v: "0 0 24 24",
    c: "<path d=\"M18.041 3.177c2.24.382 2.879 1.919 2.843 3.527V6.67l-1.013 13.266-13.132.897h.008c-1.093-.044-3.518-.151-3.634-3.545l1.217-2.222 2.462 5.74 2.097-6.77-.045.009.018-.018 6.85 2.186L13.945 9.3l6.53-.409-5.144-4.212 2.71-1.51v.009M3.113 17.252v.017-.017M6.916 6.874c2.63-2.622 6.033-4.168 7.34-2.844 1.297 1.306-.072 4.523-2.702 7.135-2.666 2.613-6.015 4.248-7.322 2.933-1.306-1.324.036-4.612 2.675-7.224z\" fill=\"#f44336\"></path>"
  },
  "react": {
    v: "0 0 24 24",
    c: "<path d=\"M12 10.11c1.03 0 1.87.84 1.87 1.89 0 1-.84 1.85-1.87 1.85S10.13 13 10.13 12c0-1.05.84-1.89 1.87-1.89M7.37 20c.63.38 2.01-.2 3.6-1.7-.52-.59-1.03-1.23-1.51-1.9a22.7 22.7 0 0 1-2.4-.36c-.51 2.14-.32 3.61.31 3.96m.71-5.74l-.29-.51c-.11.29-.22.58-.29.86.27.06.57.11.88.16l-.3-.51m6.54-.76l.81-1.5-.81-1.5c-.3-.53-.62-1-.91-1.47C13.17 9 12.6 9 12 9s-1.17 0-1.71.03c-.29.47-.61.94-.91 1.47L8.57 12l.81 1.5c.3.53.62 1 .91 1.47.54.03 1.11.03 1.71.03s1.17 0 1.71-.03c.29-.47.61-.94.91-1.47M12 6.78c-.19.22-.39.45-.59.72h1.18c-.2-.27-.4-.5-.59-.72m0 10.44c.19-.22.39-.45.59-.72h-1.18c.2.27.4.5.59.72M16.62 4c-.62-.38-2 .2-3.59 1.7.52.59 1.03 1.23 1.51 1.9.82.08 1.63.2 2.4.36.51-2.14.32-3.61-.32-3.96m-.7 5.74l.29.51c.11-.29.22-.58.29-.86-.27-.06-.57-.11-.88-.16l.3.51m1.45-7.05c1.47.84 1.63 3.05 1.01 5.63 2.54.75 4.37 1.99 4.37 3.68s-1.83 2.93-4.37 3.68c.62 2.58.46 4.79-1.01 5.63-1.46.84-3.45-.12-5.37-1.95-1.92 1.83-3.91 2.79-5.38 1.95-1.46-.84-1.62-3.05-1-5.63-2.54-.75-4.37-1.99-4.37-3.68s1.83-2.93 4.37-3.68c-.62-2.58-.46-4.79 1-5.63 1.47-.84 3.46.12 5.38 1.95 1.92-1.83 3.91-2.79 5.37-1.95M17.08 12c.34.75.64 1.5.89 2.26 2.1-.63 3.28-1.53 3.28-2.26s-1.18-1.63-3.28-2.26c-.25.76-.55 1.51-.89 2.26M6.92 12c-.34-.75-.64-1.5-.89-2.26-2.1.63-3.28 1.53-3.28 2.26s1.18 1.63 3.28 2.26c.25-.76.55-1.51.89-2.26m9 2.26l-.3.51c.31-.05.61-.1.88-.16-.07-.28-.18-.57-.29-.86l-.29.51m-2.89 4.04c1.59 1.5 2.97 2.08 3.59 1.7.64-.35.83-1.82.32-3.96-.77.16-1.58.28-2.4.36-.48.67-.99 1.31-1.51 1.9M8.08 9.74l.3-.51c-.31.05-.61.1-.88.16.07.28.18.57.29.86l.29-.51m2.89-4.04C9.38 4.2 8 3.62 7.37 4c-.63.35-.82 1.82-.31 3.96a22.7 22.7 0 0 1 2.4-.36c.48-.67.99-1.31 1.51-1.9z\" fill=\"#00bcd4\"></path>"
  },
  "vue": {
    v: "0 0 24 24",
    c: "<path d=\"M1.791 3.851L12 21.471 22.209 3.936V3.85H18.24l-6.18 10.616L5.906 3.851z\" fill=\"#41b883\"></path><path d=\"M5.907 3.851l6.152 10.617L18.24 3.851h-3.723L12.084 8.03 9.66 3.85z\" fill=\"#35495e\"></path>"
  },
  "yaml": {
    v: "0 0 24 24",
    c: "<path d=\"M13 9h5.5L13 3.5V9M6 2h8l6 6v12c0 1.1-.9 2-2 2H6c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2m12 16v-2H9v2h9m-4-4v-2H6v2z\" fill=\"#FF5252\"></path>"
  },
  "lock": {
    v: "0 0 24 24",
    c: "<path d=\"M12 17.5a2 2 0 0 0 2-2 2 2 0 0 0-2-2 2 2 0 0 0-2 2 2 2 0 0 0 2 2m6-9a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-10a2 2 0 0 1 2-2h1v-2a5 5 0 0 1 5-5 5 5 0 0 1 5 5v2h1m-6-5a3 3 0 0 0-3 3v2h6v-2a3 3 0 0 0-3-3z\" fill=\"#ffd54f\"></path>"
  },
  "log": {
    v: "0 0 24 24",
    c: "<path d=\"M13.921 16.802H7.198v-1.92h6.723m2.881-1.922H7.198v-1.92h9.604m0-1.922H7.198v-1.92h9.604m1.921-3.842H5.277c-1.066 0-1.92.855-1.92 1.92v13.447a1.92 1.92 0 0 0 1.92 1.92h13.446a1.92 1.92 0 0 0 1.921-1.92V5.277a1.92 1.92 0 0 0-1.92-1.921z\" fill=\"#afb42b\"></path>"
  },
  "font": {
    v: "0 0 24 24",
    c: "<path d=\"M8.98 14.538L12 6.507l3.007 8.031M10.731 3.119L3.753 20.882h2.855l1.42-3.806h7.93l1.434 3.806h2.855L13.269 3.119z\" fill=\"#f44336\"></path>"
  },
  "database": {
    v: "0 0 24 24",
    c: "<path d=\"M12 3C7.58 3 4 4.79 4 7s3.58 4 8 4 8-1.79 8-4-3.58-4-8-4M4 9v3c0 2.21 3.58 4 8 4s8-1.79 8-4V9c0 2.21-3.58 4-8 4s-8-1.79-8-4m0 5v3c0 2.21 3.58 4 8 4s8-1.79 8-4v-3c0 2.21-3.58 4-8 4s-8-1.79-8-4z\" fill=\"#ffca28\"></path>"
  },
  "go": {
    v: "0 0 300 300",
    c: "<g fill=\"#00acc1\"><path class=\"st4\" d=\"M22.734 138.395c-.584 0-.73-.291-.438-.73l3.065-3.94c.292-.438 1.022-.73 1.605-.73h52.105c.583 0 .73.438.437.876l-2.48 3.795c-.293.438-1.022.875-1.46.875zM.695 151.823c-.583 0-.73-.292-.437-.73l3.065-3.94c.291-.438 1.021-.73 1.605-.73h66.553c.584 0 .876.438.73.875l-1.168 3.503c-.146.584-.73.876-1.313.876zm35.32 13.427c-.583 0-.73-.438-.438-.875l2.044-3.65c.292-.437.876-.875 1.46-.875h29.19c.583 0 .875.438.875 1.022l-.292 3.503c0 .583-.584 1.021-1.022 1.021zM187.511 135.768c-9.194 2.336-15.47 4.087-24.52 6.422-2.188.584-2.334.73-4.232-1.46-2.189-2.48-3.794-4.086-6.86-5.545-9.194-4.525-18.097-3.211-26.416 2.189-9.925 6.422-15.033 15.908-14.887 27.73.146 11.676 8.173 21.309 19.703 22.914 9.925 1.314 18.244-2.189 24.812-9.632 1.313-1.606 2.48-3.357 3.94-5.4h-28.168c-3.065 0-3.795-1.898-2.773-4.379 1.897-4.524 5.4-12.114 7.443-15.908.438-.876 1.46-2.336 3.649-2.336h53.126c-.292 3.941-.292 7.882-.876 11.822-1.605 10.509-5.546 20.141-11.968 28.607-10.508 13.865-24.227 22.476-41.596 24.811-14.303 1.897-27.584-.876-39.26-9.633-10.8-8.173-16.93-18.973-18.536-32.4-1.897-15.91 2.773-30.212 12.406-42.764 10.362-13.573 24.082-22.184 40.866-25.25 13.72-2.48 26.855-.875 38.677 7.152 7.735 5.109 13.281 12.114 16.93 20.58.876 1.313.292 2.043-1.46 2.48z\"></path><path class=\"st4\" d=\"M235.82 216.479c-13.28-.292-25.394-4.087-35.61-12.844-8.612-7.443-14.012-16.93-15.764-28.168-2.627-16.493 1.898-31.088 11.822-44.077 10.655-14.011 23.498-21.309 40.866-24.374 14.887-2.627 28.899-1.167 41.596 7.444 11.53 7.881 18.682 18.535 20.58 32.547 2.48 19.703-3.212 35.757-16.785 49.477-9.633 9.778-21.455 15.908-35.028 18.681-3.94.73-7.881.876-11.676 1.314zm34.737-58.964c-.146-1.897-.146-3.357-.438-4.816-2.627-14.45-15.908-22.623-29.774-19.412-13.573 3.065-22.33 11.676-25.54 25.396-2.628 11.384 2.918 22.914 13.426 27.584 8.028 3.503 16.055 3.065 23.79-.876 11.53-5.984 17.806-15.324 18.536-27.876z\"></path></g>"
  },
  "rust": {
    v: "0 0 144 144",
    c: "<path d=\"M68.252 26.207a3.561 3.561 0 0 1 7.123 0 3.561 3.561 0 0 1-7.123 0M25.766 58.452a3.561 3.561 0 0 1 7.123 0 3.561 3.561 0 0 1-7.123 0m84.97.166a3.561 3.561 0 0 1 7.123 0 3.561 3.561 0 0 1-7.123 0m-74.661 4.88a3.252 3.252 0 0 0 1.651-4.29l-1.58-3.574h6.214v28.01H29.823a43.847 43.847 0 0 1-1.42-16.738zm25.994.688V55.93h14.798c.764 0 5.397.883 5.397 4.347 0 2.877-3.553 3.908-6.475 3.908zm-20.203 44.452a3.561 3.561 0 0 1 7.123 0 3.561 3.561 0 0 1-7.123 0m52.769.166a3.561 3.561 0 0 1 7.123 0 3.561 3.561 0 0 1-7.123 0m1.101-8.076a3.246 3.246 0 0 0-3.856 2.498l-1.787 8.342a43.847 43.847 0 0 1-36.566-.175l-1.787-8.342a3.246 3.246 0 0 0-3.854-2.497l-7.365 1.581a43.847 43.847 0 0 1-3.808-4.488h35.834c.406 0 .676-.074.676-.443V84.528c0-.369-.27-.442-.676-.442h-10.48v-8.035h11.335c1.035 0 5.532.296 6.97 6.045.45 1.768 1.44 7.519 2.116 9.36.674 2.065 3.417 6.19 6.34 6.19h18.501a43.847 43.847 0 0 1-4.06 4.7zm19.898-33.468a43.847 43.847 0 0 1 .093 7.612h-4.499c-.45 0-.631.296-.631.737v2.066c0 4.863-2.742 5.92-5.145 6.19-2.288.258-4.825-.958-5.138-2.358-1.35-7.593-3.6-9.214-7.152-12.016 4.409-2.8 8.996-6.93 8.996-12.457 0-5.97-4.092-9.729-6.881-11.572-3.914-2.58-8.246-3.096-9.415-3.096H39.336A43.847 43.847 0 0 1 63.867 28.52l5.484 5.753a3.243 3.243 0 0 0 4.59.105l6.137-5.869a43.847 43.847 0 0 1 30.017 21.38l-4.201 9.487a3.256 3.256 0 0 0 1.652 4.29zm10.477.154l-.143-1.467 4.327-4.036c.88-.82.55-2.472-.574-2.891l-5.532-2.068-.433-1.428 3.45-4.792c.704-.974.058-2.53-1.127-2.724l-5.833-.949-.7-1.31 2.45-5.38c.502-1.095-.43-2.496-1.636-2.45l-5.92.206-.935-1.135 1.36-5.766c.275-1.17-.913-2.36-2.084-2.085l-5.765 1.359-1.136-.935.207-5.92c.046-1.198-1.357-2.135-2.45-1.637l-5.379 2.452-1.31-.703-.95-5.833c-.193-1.183-1.75-1.83-2.723-1.128l-4.796 3.45-1.425-.432-2.068-5.532c-.42-1.127-2.072-1.452-2.89-.576l-4.036 4.33-1.467-.143-3.117-5.036c-.63-1.02-2.318-1.02-2.946 0l-3.117 5.036-1.467.143-4.037-4.33c-.819-.876-2.47-.551-2.89.576l-2.069 5.532-1.426.432-4.795-3.45c-.974-.703-2.53-.055-2.723 1.128l-.951 5.833-1.31.703-5.379-2.452c-1.093-.5-2.496.439-2.45 1.637l.206 5.92-1.136.935-5.765-1.36c-1.171-.272-2.36.915-2.086 2.086l1.358 5.766-.933 1.135-5.92-.206c-1.193-.035-2.134 1.355-1.637 2.45l2.453 5.38-.703 1.31-5.832.949c-1.185.192-1.827 1.75-1.128 2.724l3.45 4.792-.433 1.428-5.532 2.068c-1.123.42-1.452 2.07-.574 2.891l4.328 4.036-.143 1.467-5.035 3.116c-1.02.63-1.02 2.318 0 2.946l5.035 3.117.143 1.467-4.328 4.037c-.878.818-.549 2.468.574 2.89l5.532 2.068.433 1.428-3.45 4.793c-.701.976-.056 2.532 1.129 2.723l5.831.948.703 1.312-2.453 5.378c-.5 1.093.444 2.5 1.638 2.451l5.917-.207.935 1.136-1.358 5.768c-.275 1.168.915 2.355 2.086 2.08l5.765-1.357 1.137.932-.207 5.921c-.046 1.199 1.357 2.136 2.45 1.636l5.379-2.45 1.31.702.95 5.83c.193 1.187 1.75 1.829 2.725 1.13l4.792-3.453 1.427.435 2.069 5.53c.42 1.123 2.072 1.454 2.89.574l4.037-4.328 1.467.146 3.117 5.035c.628 1.016 2.316 1.018 2.946 0l3.117-5.035 1.467-.146 4.036 4.328c.818.88 2.47.549 2.89-.574l2.068-5.53 1.428-.435 4.793 3.453c.974.699 2.53.055 2.722-1.13l.952-5.83 1.31-.703 5.378 2.451c1.093.5 2.493-.435 2.45-1.636l-.206-5.92 1.135-.933 5.765 1.357c1.171.275 2.36-.912 2.085-2.08l-1.358-5.768.932-1.136 5.92.207c1.194.048 2.138-1.358 1.636-2.451l-2.45-5.378.7-1.312 5.833-.948c1.187-.19 1.831-1.747 1.127-2.723l-3.45-4.793.433-1.428 5.532-2.068c1.125-.422 1.454-2.072.574-2.89l-4.327-4.037.143-1.467 5.035-3.117c1.02-.628 1.021-2.315.001-2.946z\" fill=\"#ff7043\"></path>"
  },
  "swift": {
    v: "0 0 24 24",
    c: "<path d=\"M17.087 19.721c-2.36 1.36-5.59 1.5-8.86.1a13.807 13.807 0 0 1-6.23-5.32c.67.55 1.46 1 2.3 1.4 3.37 1.57 6.73 1.46 9.1 0-3.37-2.59-6.24-5.96-8.37-8.71-.45-.45-.78-1.01-1.12-1.51 8.28 6.05 7.92 7.59 2.41-1.01 4.89 4.94 9.43 7.74 9.43 7.74.16.09.25.16.36.22.1-.25.19-.51.26-.78.79-2.85-.11-6.12-2.08-8.81 4.55 2.75 7.25 7.91 6.12 12.24-.03.11-.06.22-.05.39 2.24 2.83 1.64 5.78 1.35 5.22-1.21-2.39-3.48-1.65-4.62-1.17z\" fill=\"#fe5e2f\"></path>"
  },
  "kotlin": {
    v: "0 0 48 48",
    c: "<path d=\"M48 48H0V0h48L23.505 23.648 48 48z\" fill=\"url(#dtpaint0_radial_4080_74)\"></path><defs><radialGradient id=\"dtpaint0_radial_4080_74\" cx=\"0\" cy=\"0\" r=\"1\" gradientUnits=\"userSpaceOnUse\" gradientTransform=\"matrix(-48 0 0 -48 48 0)\"><stop stop-color=\"#E44857\"></stop><stop offset=\".504\" stop-color=\"#C711E1\"></stop><stop offset=\"1\" stop-color=\"#7F52FF\"></stop></radialGradient></defs>"
  },
  "java": {
    v: "0 0 24 24",
    c: "<path d=\"M2 21h18v-2H2M20 8h-2V5h2m0-2H4v10a4 4 0 0 0 4 4h6a4 4 0 0 0 4-4v-3h2a2 2 0 0 0 2-2V5a2 2 0 0 0-2-2z\" fill=\"#f44336\"></path>"
  },
  "folder-git": {
    v: "0 0 24 24",
    c: "<path d=\"M10 4H4c-1.11 0-2 .89-2 2v12c0 1.097.903 2 2 2h16c1.097 0 2-.903 2-2V8a2 2 0 0 0-2-2h-8l-2-2z\" fill-rule=\"nonzero\" fill=\"#ff7043\"></path><path d=\"M10.43 14.14l4.044-4.051 1.183 1.19a1.387 1.387 0 0 0 .65 1.56v3.877c-.42.238-.7.693-.7 1.21 0 .768.633 1.4 1.4 1.4s1.4-.632 1.4-1.4c0-.517-.28-.972-.7-1.21v-3.401l1.449 1.462c-.05.105-.05.224-.05.35 0 .768.633 1.4 1.4 1.4s1.4-.632 1.4-1.4-.632-1.4-1.4-1.4c-.126 0-.245 0-.35.05l-1.798-1.799a1.386 1.386 0 0 0-.805-1.637c-.3-.112-.616-.14-.896-.063l-1.19-1.183.554-.546a1.381 1.381 0 0 1 1.973 0l5.591 5.592a1.381 1.381 0 0 1 0 1.973l-5.591 5.591a1.381 1.381 0 0 1-1.973 0l-5.592-5.591a1.381 1.381 0 0 1 0-1.973z\" fill-rule=\"nonzero\" fill=\"#ffccbc\"></path>"
  },
  "console": {
    v: "0 0 24 24",
    c: "<path d=\"M20 19V7H4v12h16m0-16a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h16m-7 14v-2h5v2h-5m-3.42-4L5.57 9H8.4l3.3 3.3c.39.39.39 1.03 0 1.42L8.42 17H5.59z\" fill=\"#ff7043\"></path>"
  },
  "git": {
    v: "0 0 24 24",
    c: "<path d=\"M2.6 10.59L8.38 4.8l1.69 1.7c-.24.85.15 1.78.93 2.23v5.54c-.6.34-1 .99-1 1.73a2 2 0 0 0 2 2 2 2 0 0 0 2-2c0-.74-.4-1.39-1-1.73V9.41l2.07 2.09c-.07.15-.07.32-.07.5a2 2 0 0 0 2 2 2 2 0 0 0 2-2 2 2 0 0 0-2-2c-.18 0-.35 0-.5.07L13.93 7.5a1.98 1.98 0 0 0-1.15-2.34c-.43-.16-.88-.2-1.28-.09L9.8 3.38l.79-.78c.78-.79 2.04-.79 2.82 0l7.99 7.99c.79.78.79 2.04 0 2.82l-7.99 7.99c-.78.79-2.04.79-2.82 0L2.6 13.41c-.79-.78-.79-2.04 0-2.82z\" fill=\"#e64a19\"></path>"
  },
  "settings": {
    v: "0 0 24 24",
    c: "<path d=\"M12.002 15.5a3.5 3.5 0 0 1-3.5-3.5 3.5 3.5 0 0 1 3.5-3.5 3.5 3.5 0 0 1 3.5 3.5 3.5 3.5 0 0 1-3.5 3.5m7.43-2.53c.04-.32.07-.64.07-.97s-.03-.66-.07-1l2.11-1.63c.19-.15.24-.42.12-.64l-2-3.46c-.12-.22-.39-.31-.61-.22l-2.49 1c-.52-.39-1.06-.73-1.69-.98l-.37-2.65a.506.506 0 0 0-.5-.42h-4c-.25 0-.46.18-.5.42l-.37 2.65c-.63.25-1.17.59-1.69.98l-2.49-1c-.22-.09-.49 0-.61.22l-2 3.46c-.13.22-.07.49.12.64L4.572 11c-.04.34-.07.67-.07 1s.03.65.07.97l-2.11 1.66c-.19.15-.25.42-.12.64l2 3.46c.12.22.39.3.61.22l2.49-1.01c.52.4 1.06.74 1.69.99l.37 2.65c.04.24.25.42.5.42h4c.25 0 .46-.18.5-.42l.37-2.65c.63-.26 1.17-.59 1.69-.99l2.49 1.01c.22.08.49 0 .61-.22l2-3.46c.12-.22.07-.49-.12-.64z\" fill=\"#42a5f5\"></path>"
  }
};
const ALL = {
  ...ICONS,
  ...STATUS_ICONS
};
Object.assign(__ds_scope, { ICONS, STATUS_ICONS, FILE_ICONS, ALL });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/iconPaths.js", error: String((e && e.message) || e) }); }

// components/core/Icon.jsx
try { (() => {
/** Renders a GitLab SVG glyph (vendored verbatim from @gitlab/svgs). Inherits currentColor. */
function Icon({
  name,
  size = 16,
  file = false,
  color,
  label,
  style,
  className
}) {
  const def = (file ? __ds_scope.FILE_ICONS : __ds_scope.ALL)[name];
  if (!def) return /*#__PURE__*/React.createElement("span", {
    style: {
      width: size,
      height: size,
      display: 'inline-block'
    },
    "data-missing-icon": name
  });
  return /*#__PURE__*/React.createElement("svg", {
    viewBox: def.v,
    width: size,
    height: size,
    fill: "currentColor",
    role: label ? 'img' : 'presentation',
    "aria-label": label,
    "aria-hidden": label ? undefined : true,
    focusable: "false",
    className: className,
    style: {
      display: 'block',
      flex: 'none',
      color,
      ...style
    },
    dangerouslySetInnerHTML: {
      __html: def.c
    }
  });
}
Object.assign(__ds_scope, { Icon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/Icon.jsx", error: String((e && e.message) || e) }); }

// components/core/CiIcon.jsx
try { (() => {
const MAP = {
  success: ['status_success', 'var(--gl-status-success-color)'],
  failed: ['status_failed', 'var(--gl-status-danger-color)'],
  running: ['status_running', 'var(--gl-status-info-color)'],
  pending: ['status_pending', 'var(--gl-status-warning-color)'],
  warning: ['status_warning', 'var(--gl-status-warning-color)'],
  canceled: ['status_canceled', 'var(--gl-status-neutral-color)'],
  skipped: ['status_skipped', 'var(--gl-status-neutral-color)'],
  manual: ['status_manual', 'var(--gl-status-neutral-color)'],
  created: ['status_created', 'var(--gl-status-neutral-color)'],
  scheduled: ['status_scheduled', 'var(--gl-status-neutral-color)']
};

/** GitLab's circular pipeline-status icon. Status→color mapping is fixed product-wide. */
function CiIcon({
  status = 'success',
  size = 16,
  style
}) {
  const [icon, color] = MAP[status] || MAP.success;
  return /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size,
    color: color,
    label: `Pipeline: ${status}`,
    style: style
  });
}
CiIcon.statuses = Object.keys(MAP);
Object.assign(__ds_scope, { CiIcon });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/CiIcon.jsx", error: String((e && e.message) || e) }); }

// components/core/injectStyle.js
try { (() => {
function injectStyle(id, css) {
  if (typeof document === 'undefined' || document.getElementById(id)) return;
  const s = document.createElement('style');
  s.id = id;
  s.textContent = css;
  document.head.appendChild(s);
}
Object.assign(__ds_scope, { injectStyle });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/core/injectStyle.js", error: String((e && e.message) || e) }); }

// components/actions/Button.jsx
try { (() => {
__ds_scope.injectStyle('gs-button', `@keyframes gs-spin{to{transform:rotate(360deg)}}
.gs-btn{display:inline-flex;align-items:center;justify-content:center;gap:6px;border:1px solid transparent;border-radius:var(--gs-radius-control,10px);font-family:var(--gs-font-ui);font-weight:var(--gl-font-weight-bold);cursor:pointer;white-space:nowrap;transition:background-color .1s ease-out,border-color .1s ease-out;-webkit-tap-highlight-color:transparent}
.gs-btn:focus-visible{outline:none;box-shadow:var(--gs-focus-ring)}
.gs-btn[disabled]{cursor:not-allowed;opacity:.5}
.gs-btn-confirm{background:var(--gs-action-color);color:var(--gs-action-text-on)}
.gs-btn-confirm:not([disabled]):hover{background:var(--gs-action-color-hover)}
.gs-btn-confirm:not([disabled]):active{background:var(--gs-action-color-active)}
.gs-btn-default{background:var(--gs-surface-card);color:var(--gl-text-color-default);border-color:var(--gl-border-color-strong)}
.gs-btn-default:not([disabled]):hover{background:var(--gl-background-color-strong)}
.gs-btn-default:not([disabled]):active{background:var(--gl-border-color-default)}
.gs-btn-danger{background:var(--gl-color-red-500);color:#fff}
.gs-btn-danger:not([disabled]):hover{background:var(--gl-color-red-600)}
.gs-btn-danger:not([disabled]):active{background:var(--gl-color-red-700)}
.gs-btn-ghost{background:transparent;color:var(--gl-text-color-default)}
.gs-btn-ghost:not([disabled]):hover{background:var(--gs-press-overlay)}
.gs-btn-ghost:not([disabled]):active{background:var(--gs-press-overlay-strong)}`);
const SIZES = {
  sm: [32, '0 12px', 'var(--gl-font-size-200)'],
  md: [44, '0 16px', 'var(--gl-font-size-300)'],
  lg: [50, '0 20px', 'var(--gl-font-size-400)']
};

/** Pajamas Button. Confirm is brand orange — the interactive color; green is reserved for achieved success states. */
function Button({
  variant = 'default',
  size = 'md',
  icon,
  iconOnly = false,
  loading = false,
  block = false,
  disabled,
  children,
  onClick,
  label,
  style
}) {
  const [h, pad, fs] = SIZES[size] || SIZES.md;
  return /*#__PURE__*/React.createElement("button", {
    className: `gs-btn gs-btn-${variant}`,
    disabled: disabled || loading,
    onClick: onClick,
    "aria-label": iconOnly ? label || String(children) : label,
    style: {
      height: h,
      padding: iconOnly ? 0 : pad,
      width: iconOnly ? h : block ? '100%' : undefined,
      fontSize: fs,
      ...style
    }
  }, loading ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "spinner",
    size: 16,
    style: {
      animation: 'gs-spin 1s linear infinite'
    }
  }) : icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: size === 'sm' ? 14 : 16
  }) : null, iconOnly ? null : children);
}
Object.assign(__ds_scope, { Button });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/actions/Button.jsx", error: String((e && e.message) || e) }); }

// components/containers/Tabs.jsx
try { (() => {
__ds_scope.injectStyle('gs-tabs', `.gs-tab{all:unset;box-sizing:border-box;cursor:pointer;padding:12px 4px 10px;font-family:var(--gs-font-ui);font-size:var(--gl-font-size-300);color:var(--gl-text-color-subtle);border-bottom:2px solid transparent;display:inline-flex;align-items:center;gap:6px;-webkit-tap-highlight-color:transparent}
.gs-tab:hover{color:var(--gl-text-color-default)}
.gs-tab[aria-selected="true"]{color:var(--gl-text-color-heading);font-weight:var(--gl-font-weight-bold);border-bottom-color:var(--gs-action-color)}
.gs-tab:focus-visible{box-shadow:var(--gs-focus-ring);border-radius:4px}`);

/** Pajamas Tabs: underline tabs for in-screen sections (Overview / Changes / Pipelines). */
function Tabs({
  tabs,
  active,
  onChange,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "tablist",
    style: {
      display: 'flex',
      gap: 20,
      borderBottom: '1px solid var(--gl-border-color-default)',
      padding: '0 16px',
      overflowX: 'auto',
      ...style
    }
  }, tabs.map(t => /*#__PURE__*/React.createElement("button", {
    key: t.id,
    role: "tab",
    "aria-selected": active === t.id,
    className: "gs-tab",
    onClick: () => onChange && onChange(t.id)
  }, t.label, t.count != null ? /*#__PURE__*/React.createElement("span", {
    style: {
      background: 'var(--gl-background-color-strong)',
      borderRadius: 'var(--gl-border-radius-full)',
      padding: '0 7px',
      fontSize: 'var(--gl-font-size-100)',
      lineHeight: '16px',
      fontWeight: 400,
      color: 'var(--gl-text-color-subtle)'
    }
  }, t.count) : null)));
}
Object.assign(__ds_scope, { Tabs });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/containers/Tabs.jsx", error: String((e && e.message) || e) }); }

// components/display/Avatar.jsx
try { (() => {
const HUES = ['blue', 'green', 'orange', 'purple', 'red', 'neutral'];
const hash = s => {
  let h = 0;
  for (const c of String(s)) h = h * 31 + c.charCodeAt(0) | 0;
  return Math.abs(h);
};

/** User/project/group avatar. Users are circles; projects & groups are rounded squares. Falls back to tinted initials. */
function Avatar({
  src,
  name = '',
  entity = 'user',
  size = 32,
  style
}) {
  const circle = entity === 'user';
  const radius = circle ? '50%' : size >= 32 ? 'var(--gl-border-radius-lg)' : 'var(--gl-border-radius-md)';
  const base = {
    width: size,
    height: size,
    borderRadius: radius,
    flex: 'none',
    boxShadow: 'inset 0 0 0 1px var(--gl-color-alpha-dark-8)',
    display: 'block'
  };
  if (src) return /*#__PURE__*/React.createElement("img", {
    src: src,
    alt: name,
    style: {
      ...base,
      objectFit: 'cover',
      ...style
    }
  });
  const hue = HUES[hash(name) % HUES.length];
  const initials = name.split(/[\s-_]+/).map(w => w[0]).filter(Boolean).slice(0, 2).join('').toUpperCase() || '?';
  return /*#__PURE__*/React.createElement("span", {
    role: "img",
    "aria-label": name,
    style: {
      ...base,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: `var(--gs-avatar-bg-${hue})`,
      color: `var(--gs-avatar-text-${hue})`,
      fontWeight: 'var(--gl-font-weight-bold)',
      fontSize: Math.max(10, Math.round(size * 0.4)),
      ...style
    }
  }, size >= 20 ? initials : initials[0]);
}
Object.assign(__ds_scope, { Avatar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/display/Avatar.jsx", error: String((e && e.message) || e) }); }

// components/display/Badge.jsx
try { (() => {
const V = {
  neutral: ['var(--gl-background-color-strong)', 'var(--gl-text-color-default)'],
  info: ['var(--gl-feedback-info-background-color)', 'var(--gl-feedback-info-text-color)'],
  success: ['var(--gl-feedback-success-background-color)', 'var(--gl-feedback-success-text-color)'],
  warning: ['var(--gl-feedback-warning-background-color)', 'var(--gl-feedback-warning-text-color)'],
  danger: ['var(--gl-feedback-danger-background-color)', 'var(--gl-feedback-danger-text-color)']
};

/** Pajamas Badge: muted colored pill for states and counts ("Open", "Merged", "3 failed"). */
function Badge({
  variant = 'neutral',
  icon,
  children,
  style
}) {
  const [bg, color] = V[variant] || V.neutral;
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      background: bg,
      color,
      borderRadius: 'var(--gl-border-radius-full)',
      padding: '2px 8px',
      font: 'var(--gs-text-caption)',
      fontWeight: 'var(--gl-font-weight-bold)',
      whiteSpace: 'nowrap',
      ...style
    }
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 12
  }) : null, children);
}
Object.assign(__ds_scope, { Badge });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/display/Badge.jsx", error: String((e && e.message) || e) }); }

// components/display/Label.jsx
try { (() => {
const lum = hex => {
  const h = hex.replace('#', '');
  const f = h.length === 3 ? h.split('').map(c => c + c).join('') : h;
  const [r, g, b] = [0, 2, 4].map(i => parseInt(f.slice(i, i + 2), 16) / 255);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
};

/** GitLab Label pill. Scoped labels (name contains "::") render as the signature two-tone pill. */
function Label({
  name,
  color = '#428fdc',
  onRemove,
  style
}) {
  const light = lum(color) > 0.55;
  const fg = light ? 'var(--gl-color-neutral-950)' : '#fff';
  const scoped = name.includes('::');
  const base = {
    display: 'inline-flex',
    alignItems: 'center',
    borderRadius: 'var(--gl-border-radius-full)',
    font: 'var(--gs-text-caption)',
    fontWeight: 'var(--gl-font-weight-normal)',
    lineHeight: '16px',
    whiteSpace: 'nowrap',
    ...style
  };
  if (!scoped) return /*#__PURE__*/React.createElement("span", {
    style: {
      ...base,
      background: color,
      color: fg,
      padding: '2px 8px'
    }
  }, name, onRemove ? /*#__PURE__*/React.createElement(Rm, {
    fg: fg,
    onRemove: onRemove
  }) : null);
  const [scope, value] = name.split('::');
  return /*#__PURE__*/React.createElement("span", {
    style: {
      ...base,
      boxShadow: `inset 0 0 0 2px ${color}`,
      background: 'var(--gs-surface-card)'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      background: color,
      color: fg,
      padding: '2px 6px 2px 8px',
      borderRadius: '9999px 0 0 9999px'
    }
  }, scope), /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--gl-text-color-default)',
      padding: '2px 8px 2px 6px'
    }
  }, value, onRemove ? /*#__PURE__*/React.createElement(Rm, {
    fg: "currentColor",
    onRemove: onRemove
  }) : null));
}
const Rm = ({
  fg,
  onRemove
}) => /*#__PURE__*/React.createElement("button", {
  onClick: onRemove,
  "aria-label": "Remove label",
  style: {
    all: 'unset',
    cursor: 'pointer',
    marginLeft: 4,
    color: fg,
    fontSize: 11,
    lineHeight: 1
  }
}, "\xD7");
Object.assign(__ds_scope, { Label });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/display/Label.jsx", error: String((e && e.message) || e) }); }

// components/display/Skeleton.jsx
try { (() => {
__ds_scope.injectStyle('gs-skeleton', `@keyframes gs-skeleton-shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}
.gs-skeleton{background:linear-gradient(90deg,var(--gs-skeleton-bg) 25%,var(--gs-skeleton-shimmer) 45%,var(--gs-skeleton-bg) 65%);background-size:200% 100%;animation:gs-skeleton-shimmer 1.8s ease-in-out infinite}`);

/** Pajamas Skeleton loader: shimmering placeholder bars while content loads. */
function Skeleton({
  width = '100%',
  height = 12,
  radius = 'var(--gl-border-radius-md)',
  lines = 1,
  gap = 8,
  style
}) {
  const bar = (w, k) => /*#__PURE__*/React.createElement("span", {
    key: k,
    className: "gs-skeleton",
    style: {
      display: 'block',
      width: w,
      height,
      borderRadius: radius
    }
  });
  if (lines === 1) return bar(width, 0);
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap,
      ...style
    }
  }, Array.from({
    length: lines
  }, (_, i) => bar(i === lines - 1 ? '60%' : width, i)));
}
Object.assign(__ds_scope, { Skeleton });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/display/Skeleton.jsx", error: String((e && e.message) || e) }); }

// components/display/Token.jsx
try { (() => {
/** Pajamas Token: a removable filter chip (never call it a "chip" in UI copy). */
function Token({
  children,
  icon,
  onRemove,
  style
}) {
  return /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      background: 'var(--gs-token-bg)',
      color: 'var(--gl-text-color-default)',
      borderRadius: 'var(--gl-border-radius-md)',
      padding: '2px 4px 2px 8px',
      font: 'var(--gs-text-caption)',
      lineHeight: '16px',
      ...style
    }
  }, icon ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 12
  }) : null, children, onRemove ? /*#__PURE__*/React.createElement("button", {
    onClick: onRemove,
    "aria-label": "Remove",
    style: {
      all: 'unset',
      cursor: 'pointer',
      display: 'flex',
      padding: 2,
      borderRadius: 2
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "close-sm",
    size: 12
  })) : /*#__PURE__*/React.createElement("span", {
    style: {
      width: 4
    }
  }));
}
Object.assign(__ds_scope, { Token });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/display/Token.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Alert.jsx
try { (() => {
const V = {
  info: ['information-o', 'var(--gl-feedback-info-background-color)', 'var(--gl-status-info-color)'],
  success: ['check-circle', 'var(--gl-feedback-success-background-color)', 'var(--gl-status-success-color)'],
  warning: ['warning', 'var(--gl-feedback-warning-background-color)', 'var(--gl-status-warning-color)'],
  danger: ['error', 'var(--gl-feedback-danger-background-color)', 'var(--gl-status-danger-color)']
};

/** Pajamas Alert: inline feedback banner. Plain, factual copy — "Pipeline failed", no exclamation marks. */
function Alert({
  variant = 'info',
  title,
  children,
  onDismiss,
  style
}) {
  const [icon, bg, iconColor] = V[variant] || V.info;
  return /*#__PURE__*/React.createElement("div", {
    role: "alert",
    style: {
      display: 'flex',
      gap: 12,
      padding: '12px 16px',
      background: bg,
      borderRadius: 'var(--gl-border-radius-lg)',
      ...style
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: icon,
    size: 16,
    color: iconColor,
    style: {
      marginTop: 2
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minWidth: 0
    }
  }, title ? /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 'var(--gl-font-weight-bold)',
      color: 'var(--gl-text-color-heading)',
      marginBottom: children ? 4 : 0
    }
  }, title) : null, children ? /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--gl-text-color-default)'
    }
  }, children) : null), onDismiss ? /*#__PURE__*/React.createElement("button", {
    onClick: onDismiss,
    "aria-label": "Dismiss",
    style: {
      all: 'unset',
      cursor: 'pointer',
      display: 'flex',
      padding: 4,
      margin: -4,
      color: 'var(--gl-icon-color-subtle)',
      height: 'fit-content'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "close",
    size: 16
  })) : null);
}
Object.assign(__ds_scope, { Alert });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Alert.jsx", error: String((e && e.message) || e) }); }

// components/feedback/Toast.jsx
try { (() => {
/** Pajamas Toast: transient confirmation, often with an Undo action after a destructive swipe. */
function Toast({
  children,
  action,
  onAction,
  style
}) {
  return /*#__PURE__*/React.createElement("div", {
    role: "status",
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 16,
      background: 'var(--gs-toast-bg)',
      backdropFilter: 'var(--gs-glass-blur)',
      WebkitBackdropFilter: 'var(--gs-glass-blur)',
      color: 'var(--gs-toast-text)',
      borderRadius: 'var(--gl-border-radius-full)',
      padding: '12px 20px',
      boxShadow: 'inset 0 1px 0 rgba(255,255,255,.12), 0 8px 24px rgba(5,5,6,.35)',
      font: 'var(--gs-text-body)',
      ...style
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1
    }
  }, children), action ? /*#__PURE__*/React.createElement("button", {
    onClick: onAction,
    style: {
      all: 'unset',
      cursor: 'pointer',
      color: 'var(--gs-toast-action)',
      fontWeight: 'var(--gl-font-weight-bold)',
      padding: '4px 0'
    }
  }, action) : null);
}
Object.assign(__ds_scope, { Toast });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/feedback/Toast.jsx", error: String((e && e.message) || e) }); }

// components/navigation/ListRow.jsx
try { (() => {
__ds_scope.injectStyle('gs-listrow', `.gs-listrow{-webkit-tap-highlight-color:transparent}
.gs-listrow[data-press]:active{background:var(--gs-press-overlay)}`);

/** List row: leading glyph/avatar, title + subtitle, right-aligned meta, chevron. The workhorse of every list screen. */
function ListRow({
  leading,
  title,
  titleMono = false,
  subtitle,
  meta,
  trailing = 'chevron',
  onPress,
  divider = false,
  style
}) {
  const T = onPress ? 'button' : 'div';
  return /*#__PURE__*/React.createElement(T, {
    className: "gs-listrow",
    "data-press": onPress ? '' : undefined,
    onClick: onPress,
    style: {
      all: 'unset',
      boxSizing: 'border-box',
      display: 'flex',
      alignItems: 'center',
      gap: 12,
      width: '100%',
      minHeight: 'var(--gs-touch-target)',
      padding: '10px 16px',
      cursor: onPress ? 'pointer' : undefined,
      borderBottom: divider ? '1px solid var(--gl-border-color-subtle)' : 'none',
      font: 'var(--gs-text-body)',
      ...style
    }
  }, leading ? /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 'none',
      display: 'flex'
    }
  }, leading) : null, /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      minWidth: 0,
      display: 'flex',
      flexDirection: 'column',
      gap: 2
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--gl-text-color-default)',
      fontSize: 'var(--gl-font-size-300)',
      lineHeight: '20px',
      fontFamily: titleMono ? 'var(--gs-font-mono)' : undefined,
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      display: '-webkit-box',
      WebkitLineClamp: 2,
      WebkitBoxOrient: 'vertical'
    }
  }, title), subtitle ? /*#__PURE__*/React.createElement("span", {
    style: {
      color: 'var(--gl-text-color-subtle)',
      fontSize: 'var(--gl-font-size-200)',
      lineHeight: '16px',
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, subtitle) : null), meta ? /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 'none',
      color: 'var(--gl-text-color-subtle)',
      fontSize: 'var(--gl-font-size-200)',
      alignSelf: subtitle ? 'flex-start' : 'center',
      paddingTop: subtitle ? 2 : 0
    }
  }, meta) : null, trailing === 'chevron' ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-lg-right",
    size: 16,
    color: "var(--gl-color-neutral-300)"
  }) : trailing);
}
Object.assign(__ds_scope, { ListRow });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/ListRow.jsx", error: String((e && e.message) || e) }); }

// components/navigation/TabBar.jsx
try { (() => {
__ds_scope.injectStyle('gs-tabbar', `.gs-tabbar-item{all:unset;box-sizing:border-box;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;border-radius:9999px;cursor:pointer;color:var(--gl-text-color-subtle);-webkit-tap-highlight-color:transparent;transition:background-color .15s ease-out,color .15s ease-out}
.gs-tabbar-item[aria-current="true"]{color:var(--gl-text-color-heading);background:var(--gs-glass-active)}
.gs-tabbar-item:active{opacity:.75}`);

/** Liquid-glass capsule tab bar: floats over the scrolling content (blur samples it); active item sits in a lighter glass pill. */
function TabBar({
  items,
  active,
  onChange,
  floating = true,
  style
}) {
  return /*#__PURE__*/React.createElement("nav", {
    style: {
      position: floating ? 'absolute' : 'relative',
      left: floating ? 12 : undefined,
      right: floating ? 12 : undefined,
      bottom: floating ? 10 : undefined,
      zIndex: 30,
      display: 'flex',
      gap: 4,
      height: 'var(--gs-tabbar-height)',
      padding: 6,
      borderRadius: 'var(--gl-border-radius-full)',
      background: 'var(--gs-glass-bg)',
      backdropFilter: 'var(--gs-glass-blur)',
      WebkitBackdropFilter: 'var(--gs-glass-blur)',
      boxShadow: 'var(--gs-glass-edge)',
      ...style
    }
  }, items.map(it => /*#__PURE__*/React.createElement("button", {
    key: it.id,
    className: "gs-tabbar-item",
    "aria-current": active === it.id,
    onClick: () => onChange && onChange(it.id)
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: it.icon,
    size: 24
  }), it.badge ? /*#__PURE__*/React.createElement("span", {
    style: {
      position: 'absolute',
      top: -4,
      right: -10,
      background: 'var(--gs-action-color)',
      color: '#fff',
      borderRadius: 'var(--gl-border-radius-full)',
      fontSize: 10,
      fontWeight: 600,
      lineHeight: '14px',
      minWidth: 14,
      padding: '0 3px',
      textAlign: 'center'
    }
  }, it.badge) : null), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 'var(--gl-font-size-xs)',
      fontWeight: 'var(--gl-font-weight-semibold)'
    }
  }, it.label))));
}
Object.assign(__ds_scope, { TabBar });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/TabBar.jsx", error: String((e && e.message) || e) }); }

// components/navigation/Tile.jsx
try { (() => {
const HUES = {
  issues: 'var(--gs-tile-issues)',
  mrs: 'var(--gs-tile-mrs)',
  todos: 'var(--gs-tile-todos)',
  pipelines: 'var(--gs-tile-pipelines)',
  projects: 'var(--gs-tile-projects)',
  groups: 'var(--gs-tile-groups)'
};

/** Home shortcut tile: colored container + GitLab glyph, in a row. Container colors come from the ramps; glyphs stay GitLab SVGs. */
function Tile({
  hue = 'issues',
  color,
  icon,
  label,
  count,
  onPress,
  divider = false
}) {
  return /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    divider: divider,
    onPress: onPress,
    meta: count != null ? String(count) : undefined,
    leading: /*#__PURE__*/React.createElement("span", {
      style: {
        width: 32,
        height: 32,
        borderRadius: 'var(--gl-border-radius-lg)',
        background: color || HUES[hue] || HUES.issues,
        color: '#fff',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: icon,
      size: 20
    })),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        fontWeight: 'var(--gl-font-weight-semibold)'
      }
    }, label)
  });
}
Tile.hues = Object.keys(HUES);
Object.assign(__ds_scope, { Tile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/navigation/Tile.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Drawer.jsx
try { (() => {
__ds_scope.injectStyle('gs-drawer', `@keyframes gs-drawer-up{from{transform:translateY(100%)}to{transform:translateY(0)}}
@keyframes gs-fade{from{opacity:0}to{opacity:1}}`);

/** Pajamas Drawer as a mobile bottom sheet. Fills its nearest positioned ancestor (the phone frame) — wrap standalone use in a relative container. */
function Drawer({
  open,
  onClose,
  title,
  children,
  style
}) {
  if (!open) return null;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 40,
      display: 'flex',
      flexDirection: 'column',
      justifyContent: 'flex-end'
    }
  }, /*#__PURE__*/React.createElement("div", {
    onClick: onClose,
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--gs-scrim)',
      animation: 'gs-fade .2s ease-out'
    }
  }), /*#__PURE__*/React.createElement("div", {
    role: "dialog",
    "aria-modal": "true",
    "aria-label": title,
    style: {
      position: 'relative',
      background: 'var(--gs-glass-bg-strong)',
      backdropFilter: 'var(--gs-glass-blur)',
      WebkitBackdropFilter: 'var(--gs-glass-blur)',
      borderRadius: '28px 28px 0 0',
      boxShadow: 'var(--gs-glass-edge)',
      animation: 'gs-drawer-up .25s cubic-bezier(.2,.7,.3,1)',
      maxHeight: '85%',
      display: 'flex',
      flexDirection: 'column',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      width: 36,
      height: 4,
      borderRadius: 2,
      background: 'var(--gl-border-color-strong)',
      margin: '8px auto 0',
      flex: 'none'
    }
  }), title ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '12px 16px 4px',
      fontWeight: 'var(--gl-font-weight-bold)',
      fontSize: 'var(--gl-font-size-400)',
      color: 'var(--gl-text-color-heading)',
      textAlign: 'center'
    }
  }, title) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      overflowY: 'auto',
      padding: '8px 0 24px'
    }
  }, children)));
}
Object.assign(__ds_scope, { Drawer });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Drawer.jsx", error: String((e && e.message) || e) }); }

// components/overlays/Modal.jsx
try { (() => {
__ds_scope.injectStyle('gs-modal', `@keyframes gs-modal-in{from{opacity:0;transform:scale(.96)}to{opacity:1;transform:scale(1)}}
@keyframes gs-fade{from{opacity:0}to{opacity:1}}`);

/** Pajamas Modal: focused confirmation dialog. Reserve for blocking decisions; prefer Drawer for pickers. */
function Modal({
  open,
  onClose,
  title,
  children,
  actions,
  style
}) {
  if (!open) return null;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      inset: 0,
      zIndex: 50,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: 24
    }
  }, /*#__PURE__*/React.createElement("div", {
    onClick: onClose,
    style: {
      position: 'absolute',
      inset: 0,
      background: 'var(--gs-scrim)',
      animation: 'gs-fade .2s ease-out'
    }
  }), /*#__PURE__*/React.createElement("div", {
    role: "dialog",
    "aria-modal": "true",
    "aria-label": title,
    style: {
      position: 'relative',
      background: 'var(--gs-glass-bg-strong)',
      backdropFilter: 'var(--gs-glass-blur)',
      WebkitBackdropFilter: 'var(--gs-glass-blur)',
      borderRadius: 24,
      boxShadow: 'var(--gs-glass-edge)',
      width: '100%',
      maxWidth: 340,
      animation: 'gs-modal-in .18s ease-out',
      ...style
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '20px 20px 8px',
      fontWeight: 'var(--gl-font-weight-bold)',
      fontSize: 'var(--gl-font-size-400)',
      color: 'var(--gl-text-color-heading)'
    }
  }, title), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 20px 16px',
      color: 'var(--gl-text-color-default)'
    }
  }, children), actions ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8,
      justifyContent: 'flex-end',
      padding: '0 16px 16px'
    }
  }, actions) : null));
}
Modal.Button = __ds_scope.Button;
Object.assign(__ds_scope, { Modal });
})(); } catch (e) { __ds_ns.__errors.push({ path: "components/overlays/Modal.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/PhoneShell.jsx
try { (() => {
__ds_scope.injectStyle('gs-shell', `.gs-shell *{box-sizing:border-box}.gs-shell button{-webkit-tap-highlight-color:transparent}
.gs-back:active{opacity:.6}`);

/** 390×844 phone viewport with iOS-style status bar and home indicator. Dark liquid glass is the default theme. */
function PhoneShell({
  children,
  theme = 'dark',
  tabbar
}) {
  return /*#__PURE__*/React.createElement("div", {
    className: "gs-shell",
    "data-theme": theme === 'dark' ? 'dark' : undefined,
    style: {
      width: 390,
      height: 844,
      background: 'var(--gs-surface-app)',
      display: 'flex',
      flexDirection: 'column',
      overflow: 'hidden',
      position: 'relative',
      fontFamily: 'var(--gs-font-ui)',
      color: 'var(--gl-text-color-default)'
    }
  }, /*#__PURE__*/React.createElement(StatusBar, null), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column',
      position: 'relative',
      overflow: 'hidden'
    }
  }, children, tabbar), /*#__PURE__*/React.createElement("div", {
    style: {
      height: 24,
      flex: 'none',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      background: 'inherit'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: 134,
      height: 5,
      borderRadius: 3,
      background: 'var(--gl-text-color-heading)',
      opacity: .9
    }
  })));
}
function StatusBar() {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      height: 48,
      flex: 'none',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '0 24px 0 32px',
      fontSize: 15,
      fontWeight: 600,
      color: 'var(--gl-text-color-heading)'
    }
  }, /*#__PURE__*/React.createElement("span", null, "9:41"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 6
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      gap: 1.5
    }
  }, [4, 6, 8, 10].map((h, i) => /*#__PURE__*/React.createElement("span", {
    key: i,
    style: {
      width: 3,
      height: h,
      borderRadius: 1,
      background: 'currentColor',
      opacity: i < 3 ? 1 : .35
    }
  }))), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 24,
      height: 12,
      border: '1px solid currentColor',
      borderRadius: 3.5,
      padding: 1.5,
      display: 'flex'
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      width: '72%',
      borderRadius: 1.5,
      background: 'currentColor'
    }
  }))));
}

/** Push-screen header: back chevron, centered title, optional right action. */
function NavHeader({
  title,
  onBack,
  right,
  mono = false
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      height: 48,
      flex: 'none',
      padding: '0 8px',
      gap: 4
    }
  }, /*#__PURE__*/React.createElement("button", {
    className: "gs-back",
    onClick: onBack,
    "aria-label": "Back",
    style: {
      all: 'unset',
      cursor: 'pointer',
      display: 'flex',
      alignItems: 'center',
      gap: 2,
      color: 'var(--gs-action-color)',
      padding: '8px 4px',
      fontSize: 15
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-lg-left",
    size: 20
  }), "Back"), /*#__PURE__*/React.createElement("span", {
    style: {
      flex: 1,
      textAlign: 'center',
      fontWeight: 600,
      fontSize: 15,
      color: 'var(--gl-text-color-heading)',
      fontFamily: mono ? 'var(--gs-font-mono)' : undefined,
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap'
    }
  }, title), /*#__PURE__*/React.createElement("span", {
    style: {
      width: 64,
      display: 'flex',
      justifyContent: 'flex-end'
    }
  }, right));
}

/** Large-title screen header (GitHub Mobile shape) with optional right-side accessory. */
function LargeTitle({
  title,
  right
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'flex-end',
      justifyContent: 'space-between',
      padding: '4px 16px 10px',
      flex: 'none'
    }
  }, /*#__PURE__*/React.createElement("h1", {
    style: {
      fontSize: 'var(--gs-screen-title-size)',
      letterSpacing: 'var(--gl-letter-spacing-heading-reduced)'
    }
  }, title), right);
}
Object.assign(__ds_scope, { PhoneShell, NavHeader, LargeTitle });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/PhoneShell.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/Explore.jsx
try { (() => {
/** Explore/Search — scoped search with filter tokens and a designed empty state. */
function Explore({
  nav
}) {
  const [q, setQ] = React.useState('');
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.LargeTitle, {
    title: "Explore"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '0 16px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      background: 'var(--gs-surface-inset)',
      border: '1px solid var(--gl-border-color-default)',
      borderRadius: 10,
      padding: '0 12px',
      height: 44
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "search",
    size: 16,
    color: "var(--gl-icon-color-subtle)"
  }), /*#__PURE__*/React.createElement("input", {
    value: q,
    onChange: e => setQ(e.target.value),
    placeholder: "Search projects, issues, merge requests",
    style: {
      all: 'unset',
      flex: 1,
      fontSize: 15,
      color: 'var(--gl-text-color-default)'
    },
    "aria-label": "Search"
  }), q ? /*#__PURE__*/React.createElement("button", {
    onClick: () => setQ(''),
    "aria-label": "Clear",
    style: {
      all: 'unset',
      cursor: 'pointer',
      display: 'flex',
      color: 'var(--gl-icon-color-subtle)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "clear",
    size: 16
  })) : null), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      marginTop: 10,
      flexWrap: 'wrap'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Token, {
    icon: "project"
  }, "in: gitsune/app"), /*#__PURE__*/React.createElement(__ds_scope.Token, {
    icon: "merge-request",
    onRemove: () => {}
  }, "type = merge request"))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      textAlign: 'center',
      padding: '48px 40px 120px'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/illustrations/search-sm.svg",
    alt: "",
    style: {
      width: 120
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 600,
      fontSize: 16,
      color: 'var(--gl-text-color-heading)',
      marginTop: 16
    }
  }, q ? `No results for “${q}”` : 'Search this instance'), /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--gl-text-color-subtle)',
      fontSize: 13,
      marginTop: 4
    }
  }, q ? 'Cross-project code search depends on this instance\u2019s tier — falling back to web search when unavailable.' : 'Results stay scoped to gitlab.com until you switch accounts.')));
}
Object.assign(__ds_scope, { Explore });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/Explore.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/SignIn.jsx
try { (() => {
/** Surface 1 — instance-URL-first sign-in (Bluesky shape, GitLab language). */
function SignIn({
  nav
}) {
  const [url, setUrl] = React.useState('gitlab.com');
  const [error, setError] = React.useState(false);
  const [pat, setPat] = React.useState(false);
  const go = () => {
    if (!/gitlab|kitsune/.test(url)) {
      setError(true);
      return;
    }
    setError(false);
    nav.signIn();
  };
  const field = {
    display: 'flex',
    alignItems: 'center',
    gap: 10,
    background: 'var(--gs-surface-inset)',
    border: '1px solid var(--gl-border-color-default)',
    borderRadius: 'var(--gs-radius-control,10px)',
    padding: '0 14px',
    height: 50
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 20px',
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '48px 0 40px',
      textAlign: 'center'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      font: '600 40px/1 var(--gs-font-ui)',
      letterSpacing: '-0.01em',
      color: 'var(--gs-color-brand-500)'
    }
  }, "Gitsune"), /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 8,
      color: 'var(--gl-text-color-subtle)',
      fontSize: 14
    }
  }, "GitLab in your pocket")), /*#__PURE__*/React.createElement("label", {
    style: {
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--gl-text-color-heading)',
      marginBottom: 6
    }
  }, "GitLab instance"), /*#__PURE__*/React.createElement("div", {
    style: field
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "earth",
    size: 18,
    color: "var(--gl-icon-color-subtle)"
  }), /*#__PURE__*/React.createElement("input", {
    value: url,
    onChange: e => {
      setUrl(e.target.value);
      setError(false);
    },
    spellCheck: "false",
    autoCapitalize: "none",
    style: {
      all: 'unset',
      flex: 1,
      font: '400 15px var(--gs-font-mono)',
      color: 'var(--gl-text-color-default)'
    },
    "aria-label": "GitLab instance URL"
  }), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "pencil",
    size: 16,
    color: "var(--gl-icon-color-subtle)"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      margin: '8px 2px 20px'
    }
  }, "gitlab.com or any self-hosted instance. Sign-in opens in your browser."), error ? /*#__PURE__*/React.createElement(__ds_scope.Alert, {
    variant: "danger",
    title: "Unable to reach this instance",
    style: {
      marginBottom: 16
    }
  }, url || 'This URL', " does not answer as a GitLab instance. Check the address and try again.") : null, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "confirm",
    size: "lg",
    block: true,
    onClick: go
  }, "Continue"), /*#__PURE__*/React.createElement("button", {
    onClick: () => setPat(!pat),
    style: {
      all: 'unset',
      cursor: 'pointer',
      textAlign: 'center',
      padding: 14,
      color: 'var(--gs-link-color)',
      fontSize: 14
    }
  }, "Having trouble signing in?"), pat ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      flexDirection: 'column',
      gap: 10
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: field
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "token",
    size: 18,
    color: "var(--gl-icon-color-subtle)"
  }), /*#__PURE__*/React.createElement("input", {
    placeholder: "Personal Access Token",
    style: {
      all: 'unset',
      flex: 1,
      font: '400 15px var(--gs-font-mono)',
      color: 'var(--gl-text-color-default)'
    },
    "aria-label": "Personal Access Token"
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      padding: '0 2px'
    }
  }, "For instances where OAuth app registration is unavailable. Needs the ", /*#__PURE__*/React.createElement("span", {
    style: {
      fontFamily: 'var(--gs-font-mono)'
    }
  }, "api"), " scope.")) : null, /*#__PURE__*/React.createElement("div", {
    style: {
      marginTop: 'auto',
      padding: '24px 0 16px',
      textAlign: 'center',
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)'
    }
  }, "Open source \xB7 No project-operated servers, ever"));
}
Object.assign(__ds_scope, { SignIn });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/SignIn.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/data.js
try { (() => {
// Sample data for the Gitsune UI kit. All copy follows the voice rules: plain, factual, GitLab nouns.
const user = {
  name: 'Marin Katsuragi',
  handle: '@marin',
  host: 'gitlab.com'
};
const accounts = [{
  name: 'Marin Katsuragi',
  handle: '@marin',
  host: 'gitlab.com',
  active: true
}, {
  name: 'marin-k',
  handle: '@marin-k',
  host: 'git.kitsune.dev',
  unread: 2
}];
const myWork = [{
  id: 'issues',
  hue: 'issues',
  icon: 'issues',
  label: 'Issues',
  count: 12
}, {
  id: 'mrs',
  hue: 'mrs',
  icon: 'merge-request',
  label: 'Merge Requests',
  count: 4
}, {
  id: 'todos',
  hue: 'todos',
  icon: 'todo-done',
  label: 'To-Do List',
  count: 7
}, {
  id: 'pipelines',
  hue: 'pipelines',
  icon: 'rocket',
  label: 'Pipelines',
  count: 2
}, {
  id: 'projects',
  hue: 'projects',
  icon: 'project',
  label: 'Projects',
  count: 9
}, {
  id: 'groups',
  hue: 'groups',
  icon: 'group',
  label: 'Groups',
  count: 3
}];
const favorites = [{
  name: 'gitsune / app',
  desc: 'Flutter client for GitLab',
  stars: 214
}, {
  name: 'gitsune / website',
  desc: 'Marketing site and docs',
  stars: 38
}];
const todos = [{
  id: 1,
  icon: 'merge-request',
  color: 'var(--gl-status-info-color)',
  project: 'gitsune/app',
  ref: '!142',
  title: 'Add instance switcher sheet',
  note: 'Ade requested your review',
  time: '13h',
  reason: 'Review requested'
}, {
  id: 2,
  icon: 'issues',
  color: 'var(--gl-status-success-color)',
  project: 'gitsune/app',
  ref: '#233',
  title: 'Sign-in: PAT fallback hidden behind wrong affordance',
  note: 'Priya assigned you',
  time: '1d',
  reason: 'Assigned'
}, {
  id: 3,
  icon: 'status_failed',
  color: 'var(--gl-status-danger-color)',
  project: 'gitsune/app',
  ref: '#88101',
  title: 'Pipeline failed on main',
  note: 'test: widget_test.dart · 2 failed',
  time: '2d',
  reason: 'Pipeline failed'
}, {
  id: 4,
  icon: 'comment',
  color: 'var(--gl-status-neutral-color)',
  project: 'gitsune/website',
  ref: '#87',
  title: 'Document self-hosted OAuth registration',
  note: '@marin can you confirm the redirect URI?',
  time: '2d',
  reason: 'Mentioned'
}, {
  id: 5,
  icon: 'merge-request',
  color: 'var(--gl-status-info-color)',
  project: 'gitsune/app',
  ref: '!139',
  title: 'Offline read cache for issues',
  note: 'Tom approved your merge request',
  time: '4d',
  reason: 'Review requested'
}];
const todoReasons = ['All', 'Assigned', 'Mentioned', 'Review requested', 'Pipeline failed'];
const mr = {
  ref: '!142',
  project: 'gitsune / app',
  title: 'Add instance switcher sheet',
  source: 'feat/instance-switcher',
  target: 'main',
  author: 'Ade Ogunleye',
  time: 'updated 2h ago',
  labels: [{
    name: 'workflow::in review',
    color: '#7b58cf'
  }, {
    name: 'mobile',
    color: '#1f75cb'
  }],
  milestone: 'v1.0',
  unresolved: 2,
  approvalsRequired: 2,
  approvers: ['Marin Katsuragi', 'Priya Sharma'],
  approvedBy: ['Priya Sharma'],
  commits: 6,
  filesChanged: 4,
  pipelines: [{
    id: '#88123',
    status: 'running',
    note: 'build · feat/instance-switcher',
    time: '2h ago'
  }, {
    id: '#88119',
    status: 'success',
    note: 'test · feat/instance-switcher',
    time: '5h ago'
  }, {
    id: '#88101',
    status: 'failed',
    note: 'test · feat/instance-switcher',
    time: '1d ago'
  }]
};
const diffFiles = [{
  path: 'lib/ui/switcher_sheet.dart',
  icon: 'dart',
  add: 86,
  del: 12
}, {
  path: 'lib/state/accounts.dart',
  icon: 'dart',
  add: 24,
  del: 3
}, {
  path: 'lib/ui/profile_screen.dart',
  icon: 'dart',
  add: 9,
  del: 41
}, {
  path: 'test/switcher_sheet_test.dart',
  icon: 'dart',
  add: 52,
  del: 0
}];
const hunk = {
  file: 'lib/ui/switcher_sheet.dart',
  header: '@@ -18,7 +18,15 @@ class SwitcherSheet extends StatelessWidget {',
  lines: [{
    o: 18,
    n: 18,
    t: ' ',
    code: '  Widget build(BuildContext context) {'
  }, {
    o: 19,
    n: 19,
    t: ' ',
    code: '    return DraggableSheet('
  }, {
    o: 20,
    n: null,
    t: '-',
    code: '      child: AccountList(accounts: accounts),'
  }, {
    o: null,
    n: 20,
    t: '+',
    code: '      child: Column(children: ['
  }, {
    o: null,
    n: 21,
    t: '+',
    code: '        for (final a in accounts)'
  }, {
    o: null,
    n: 22,
    t: '+',
    code: '          AccountRow('
  }, {
    o: null,
    n: 23,
    t: '+',
    code: '            account: a,'
  }, {
    o: null,
    n: 24,
    t: '+',
    code: '            host: a.host, // always visible'
  }, {
    o: null,
    n: 25,
    t: '+',
    code: '          ),'
  }, {
    o: null,
    n: 26,
    t: '+',
    code: '        AddAccountRow(),'
  }, {
    o: null,
    n: 27,
    t: '+',
    code: '      ]),'
  }, {
    o: 21,
    n: 28,
    t: ' ',
    code: '    );'
  }, {
    o: 22,
    n: 29,
    t: ' ',
    code: '  }'
  }],
  comment: {
    author: 'Marin Katsuragi',
    time: '3h ago',
    line: 24,
    text: 'Host on every row — this is the safety feature for multi-instance users. Can we truncate long self-hosted domains with a leading ellipsis instead?'
  }
};
const issue = {
  ref: '#233',
  project: 'gitsune / app',
  title: 'Sign-in: PAT fallback hidden behind wrong affordance',
  author: 'Priya Sharma',
  time: '2 days ago',
  labels: [{
    name: 'bug',
    color: '#dd2b0e'
  }, {
    name: 'workflow::triage',
    color: '#7b58cf'
  }],
  milestone: 'v1.0',
  body: 'The Personal Access Token entry currently sits behind the instance field\u2019s edit icon. Per the auth blueprint it belongs behind a \u201cHaving trouble signing in?\u201d affordance under the primary action.',
  events: [{
    icon: 'labels',
    text: 'Priya added the workflow::triage label',
    time: '2d'
  }],
  comments: [{
    author: 'Marin Katsuragi',
    time: '1d ago',
    text: 'Agreed. OAuth stays the only visible path on the primary screen; PAT is a fallback, not a peer.'
  }, {
    author: 'Tom Chen',
    time: '20h ago',
    text: 'Will pick this up after !142 merges.'
  }]
};
const fileTree = [{
  name: 'android',
  type: 'folder'
}, {
  name: 'ios',
  type: 'folder'
}, {
  name: 'lib',
  type: 'folder'
}, {
  name: 'test',
  type: 'folder'
}, {
  name: '.gitlab-ci.yml',
  icon: 'gitlab'
}, {
  name: 'pubspec.yaml',
  icon: 'settings'
}, {
  name: 'README.md',
  icon: 'markdown'
}];
const libTree = [{
  name: 'state',
  type: 'folder'
}, {
  name: 'ui',
  type: 'folder'
}, {
  name: 'api.dart',
  icon: 'dart'
}, {
  name: 'main.dart',
  icon: 'dart'
}];
const dartFile = {
  path: 'lib/main.dart',
  branch: 'main',
  lines: [[['k', 'import'], ['s', " 'package:flutter/material.dart'"], ['p', ';']], [['k', 'import'], ['s', " 'state/accounts.dart'"], ['p', ';']], [], [['k', 'void'], ['f', ' main'], ['p', '() {']], [['p', '  '], ['f', 'runApp'], ['p', '('], ['k', 'const'], ['p', ' GitsuneApp());']], [['p', '}']], [], [['c', '// Instance-URL-first: no project-operated servers, ever.']], [['k', 'class'], ['t', ' GitsuneApp'], ['k', ' extends'], ['t', ' StatelessWidget'], ['p', ' {']], [['p', '  @'], ['t', 'override']], [['t', '  Widget'], ['f', ' build'], ['p', '(BuildContext context) {']], [['k', '    return'], ['f', ' MaterialApp'], ['p', '(']], [['p', '      title: '], ['s', "'Gitsune'"], ['p', ',']], [['p', '      theme: buildTheme(Brightness.light),']], [['p', '    );']], [['p', '  }']], [['p', '}']]]
};
Object.assign(__ds_scope, { user, accounts, myWork, favorites, todos, todoReasons, mr, diffFiles, hunk, issue, fileTree, libTree, dartFile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/data.js", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/CodeBrowser.jsx
try { (() => {
const C = {
  k: 'var(--gs-code-keyword)',
  s: 'var(--gs-code-string)',
  c: 'var(--gs-code-comment)',
  f: 'var(--gs-code-function)',
  n: 'var(--gs-code-number)',
  t: 'var(--gl-text-color-heading)',
  p: 'var(--gl-text-color-default)'
};
const BranchChip = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    font: '12px/16px var(--gs-font-mono)',
    background: 'var(--gs-token-bg)',
    borderRadius: 4,
    padding: '2px 6px',
    display: 'inline-flex',
    alignItems: 'center',
    gap: 4
  }
}, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
  name: "branch",
  size: 12
}), children);

/** Surface 5 — code browser: drill-down list with file-type icons, then GitLab Mono file view. */
function CodeBrowser({
  nav
}) {
  const [path, setPath] = React.useState([]); // [] → root, ['lib'] → lib/, ['lib','main.dart'] → file
  const inFile = path.length === 2;
  const tree = path.length === 0 ? __ds_scope.fileTree : __ds_scope.libTree;
  const [wrap, setWrap] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.NavHeader, {
    mono: true,
    title: inFile ? __ds_scope.dartFile.path : path.length ? `gitsune/app/${path[0]}` : 'gitsune / app',
    onBack: () => path.length ? setPath(path.slice(0, -1)) : nav.pop(),
    right: inFile ? /*#__PURE__*/React.createElement("button", {
      onClick: () => setWrap(!wrap),
      "aria-label": "Toggle wrap",
      style: {
        all: 'unset',
        cursor: 'pointer',
        padding: 6,
        color: wrap ? 'var(--gs-action-color)' : 'var(--gl-icon-color-subtle)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "list-indent",
      size: 18
    })) : null
  }), !inFile ? /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto'
    }
  }, path.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 10,
      padding: '4px 16px 14px'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
    name: "gitsune app",
    entity: "project",
    size: 40
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 600,
      color: 'var(--gl-text-color-heading)',
      fontFamily: 'var(--gs-font-mono)',
      fontSize: 14
    }
  }, "gitsune / app"), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      marginTop: 2
    }
  }, "Flutter client for GitLab \xB7 214 stars")), /*#__PURE__*/React.createElement(BranchChip, null, "main")) : null, tree.map((f, i) => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: f.name,
    divider: i < tree.length - 1,
    leading: f.type === 'folder' ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "folder-o",
      size: 18,
      color: "var(--gl-status-info-color)"
    }) : /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: f.icon,
      file: true,
      size: 18
    }),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)',
        fontSize: 13
      }
    }, f.name, f.type === 'folder' ? '/' : ''),
    onPress: () => f.type === 'folder' ? path.length === 0 && f.name === 'lib' ? setPath(['lib']) : nav.toast('Only lib/ is populated in this mock') : f.name.endsWith('.dart') ? setPath(['lib', f.name]) : nav.toast('Only main.dart is populated in this mock')
  }))) : /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflow: 'auto',
      background: 'var(--gs-code-bg)'
    }
  }, /*#__PURE__*/React.createElement("table", {
    style: {
      borderCollapse: 'collapse',
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement("tbody", null, __ds_scope.dartFile.lines.map((line, i) => /*#__PURE__*/React.createElement("tr", {
    key: i
  }, /*#__PURE__*/React.createElement("td", {
    style: {
      font: '11px/20px var(--gs-font-mono)',
      color: 'var(--gl-text-color-disabled)',
      textAlign: 'right',
      padding: '0 10px',
      width: 28,
      userSelect: 'none',
      verticalAlign: 'top'
    }
  }, i + 1), /*#__PURE__*/React.createElement("td", {
    style: {
      font: '12px/20px var(--gs-font-mono)',
      whiteSpace: wrap ? 'pre-wrap' : 'pre',
      paddingRight: 16
    }
  }, line.map(([cls, text], j) => /*#__PURE__*/React.createElement("span", {
    key: j,
    style: {
      color: C[cls]
    }
  }, text))))))), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '10px 16px 16px',
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      display: 'flex',
      gap: 14
    }
  }, /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 4,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "history",
    size: 14
  }), "History"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 4,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "doc-versions",
    size: 14
  }), "Blame"), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      gap: 4,
      alignItems: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "external-link",
    size: 14
  }), "View on web"))));
}
Object.assign(__ds_scope, { CodeBrowser });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/CodeBrowser.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/DiffView.jsx
try { (() => {
const mono = {
  fontFamily: 'var(--gs-font-mono)',
  fontSize: 12,
  lineHeight: '20px'
};

/** Surface 4b — diff review: hunk-per-file, green/red line backgrounds, line-level comments. */
function DiffList({
  nav
}) {
  const [open, setOpen] = React.useState(__ds_scope.diffFiles[0].path);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      paddingBottom: 60,
      position: 'relative'
    }
  }, __ds_scope.diffFiles.map(f => /*#__PURE__*/React.createElement("div", {
    key: f.path
  }, /*#__PURE__*/React.createElement("button", {
    onClick: () => setOpen(open === f.path ? null : f.path),
    style: {
      all: 'unset',
      boxSizing: 'border-box',
      cursor: 'pointer',
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      width: '100%',
      padding: '10px 16px',
      background: 'var(--gs-surface-card)',
      borderBottom: '1px solid var(--gl-border-color-subtle)',
      borderTop: '1px solid var(--gl-border-color-subtle)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "chevron-down",
    size: 14,
    style: {
      transform: open === f.path ? 'none' : 'rotate(-90deg)'
    },
    color: "var(--gl-icon-color-subtle)"
  }), /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: f.icon,
    file: true,
    size: 16
  }), /*#__PURE__*/React.createElement("span", {
    style: {
      ...mono,
      flex: 1,
      minWidth: 0,
      overflow: 'hidden',
      textOverflow: 'ellipsis',
      whiteSpace: 'nowrap',
      direction: 'rtl',
      textAlign: 'left'
    }
  }, f.path), /*#__PURE__*/React.createElement("span", {
    style: {
      ...mono,
      color: 'var(--gl-status-success-color)'
    }
  }, "+", f.add), /*#__PURE__*/React.createElement("span", {
    style: {
      ...mono,
      color: 'var(--gl-status-danger-color)'
    }
  }, "\u2212", f.del)), open === f.path ? /*#__PURE__*/React.createElement(Hunk, {
    nav: nav
  }) : null)), /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'sticky',
      bottom: 12,
      display: 'flex',
      justifyContent: 'center',
      pointerEvents: 'none'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    size: "sm",
    icon: "file-tree",
    style: {
      pointerEvents: 'auto',
      boxShadow: 'var(--gl-shadow-md)',
      borderRadius: 9999
    },
    onClick: () => nav.toast('Jump to file is not part of this mock')
  }, "Jump to file")));
}
function Hunk({
  nav
}) {
  const [reply, setReply] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      background: 'var(--gs-surface-card)',
      overflowX: 'auto'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      ...mono,
      padding: '6px 12px',
      color: 'var(--gl-text-color-subtle)',
      background: 'var(--gs-surface-inset)'
    }
  }, __ds_scope.hunk.header), /*#__PURE__*/React.createElement("table", {
    style: {
      borderCollapse: 'collapse',
      width: '100%'
    }
  }, /*#__PURE__*/React.createElement("tbody", null, __ds_scope.hunk.lines.map((l, i) => {
    const bg = l.t === '+' ? 'var(--gs-diff-add-bg)' : l.t === '-' ? 'var(--gs-diff-del-bg)' : 'transparent';
    const numBg = l.t === '+' ? 'var(--gs-diff-add-strong)' : l.t === '-' ? 'var(--gs-diff-del-strong)' : 'var(--gs-surface-inset)';
    return /*#__PURE__*/React.createElement(React.Fragment, {
      key: i
    }, /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("td", {
      style: {
        ...mono,
        background: numBg,
        color: 'var(--gl-text-color-subtle)',
        textAlign: 'right',
        padding: '0 6px',
        width: 30,
        userSelect: 'none'
      }
    }, l.o || ''), /*#__PURE__*/React.createElement("td", {
      style: {
        ...mono,
        background: numBg,
        color: 'var(--gl-text-color-subtle)',
        textAlign: 'right',
        padding: '0 6px',
        width: 30,
        userSelect: 'none'
      }
    }, l.n || ''), /*#__PURE__*/React.createElement("td", {
      style: {
        ...mono,
        background: bg,
        whiteSpace: 'pre',
        padding: '0 10px 0 4px'
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        color: l.t === '+' ? 'var(--gl-status-success-color)' : l.t === '-' ? 'var(--gl-status-danger-color)' : 'var(--gl-text-color-subtle)',
        userSelect: 'none'
      }
    }, l.t), " ", l.code)), __ds_scope.hunk.comment && l.n === __ds_scope.hunk.comment.line ? /*#__PURE__*/React.createElement("tr", null, /*#__PURE__*/React.createElement("td", {
      colSpan: 3,
      style: {
        padding: '8px 12px',
        borderTop: '1px solid var(--gl-border-color-subtle)',
        borderBottom: '1px solid var(--gl-border-color-subtle)'
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: 10
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      name: __ds_scope.hunk.comment.author,
      size: 28
    }), /*#__PURE__*/React.createElement("div", {
      style: {
        flex: 1
      }
    }, /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 13
      }
    }, /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--gl-text-color-heading)'
      }
    }, __ds_scope.hunk.comment.author), " ", /*#__PURE__*/React.createElement("span", {
      style: {
        color: 'var(--gl-text-color-subtle)',
        fontSize: 12
      }
    }, "\xB7 ", __ds_scope.hunk.comment.time)), /*#__PURE__*/React.createElement("div", {
      style: {
        fontSize: 13,
        marginTop: 2
      }
    }, __ds_scope.hunk.comment.text), /*#__PURE__*/React.createElement("div", {
      style: {
        display: 'flex',
        gap: 12,
        marginTop: 8
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      variant: "ghost",
      icon: "comment",
      onClick: () => setReply(true)
    }, reply ? 'Replying…' : 'Reply'), /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      variant: "ghost",
      icon: "check-circle",
      onClick: () => nav.toast('Thread resolved')
    }, "Resolve thread")))))) : null);
  }))));
}
Object.assign(__ds_scope, { DiffList });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/DiffView.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/Home.jsx
try { (() => {
const Section = ({
  children,
  action
}) => /*#__PURE__*/React.createElement("div", {
  style: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '20px 4px 8px'
  }
}, /*#__PURE__*/React.createElement("h2", {
  style: {
    fontSize: 'var(--gl-font-size-500)'
  }
}, children), action);

/** Surface 2 — Home: My Work tiles, Favorites, Recent (GitHub Mobile shape, GitLab nouns). */
function Home({
  nav
}) {
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.LargeTitle, {
    title: "Home",
    right: /*#__PURE__*/React.createElement("button", {
      onClick: () => nav.openSwitcher(),
      "aria-label": "Switch account",
      style: {
        all: 'unset',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: 6
      }
    }, /*#__PURE__*/React.createElement("span", {
      style: {
        display: 'inline-flex',
        alignItems: 'center',
        gap: 4,
        font: '11px/1 var(--gs-font-mono)',
        color: 'var(--gl-text-color-subtle)',
        background: 'var(--gs-glass-bg)',
        backdropFilter: 'var(--gs-glass-blur)',
        WebkitBackdropFilter: 'var(--gs-glass-blur)',
        boxShadow: '0 0 0 1px var(--gs-glass-border)',
        borderRadius: 9999,
        padding: '5px 9px'
      }
    }, __ds_scope.user.host), /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      name: __ds_scope.user.name,
      size: 32
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 16px 96px',
      background: 'var(--gs-surface-subtle)'
    }
  }, /*#__PURE__*/React.createElement(Section, {
    action: /*#__PURE__*/React.createElement("button", {
      onClick: () => nav.toast('Reordering is not part of this mock'),
      "aria-label": "Edit My Work",
      style: {
        all: 'unset',
        cursor: 'pointer',
        color: 'var(--gl-icon-color-subtle)',
        padding: 6
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "ellipsis_h",
      size: 16
    }))
  }, "My Work"), /*#__PURE__*/React.createElement(__ds_scope.Card, null, __ds_scope.myWork.map((t, i) => /*#__PURE__*/React.createElement(__ds_scope.Tile, {
    key: t.id,
    hue: t.hue,
    icon: t.icon,
    label: t.label,
    count: t.count,
    divider: i < __ds_scope.myWork.length - 1,
    onPress: () => nav.openWork(t.id)
  }))), /*#__PURE__*/React.createElement(Section, null, "Favorites"), /*#__PURE__*/React.createElement(__ds_scope.Card, null, __ds_scope.favorites.map((f, i) => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: f.name,
    leading: /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      name: f.name,
      entity: "project",
      size: 28
    }),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)',
        fontSize: 13
      }
    }, f.name),
    subtitle: f.desc,
    meta: /*#__PURE__*/React.createElement("span", {
      style: {
        display: 'inline-flex',
        alignItems: 'center',
        gap: 3
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "star-o",
      size: 12
    }), f.stars),
    divider: i < __ds_scope.favorites.length - 1,
    onPress: () => nav.push('code')
  }))), /*#__PURE__*/React.createElement(Section, null, "Recent"), /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.CiIcon, {
      status: "running",
      size: 20
    }),
    title: "Pipeline #88123 running",
    subtitle: "gitsune/app \xB7 feat/instance-switcher",
    meta: "2h",
    divider: true,
    onPress: () => nav.push('mr', {
      tab: 'pipelines'
    })
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "merge-request",
      size: 20,
      color: "var(--gl-status-success-color)"
    }),
    title: "Add instance switcher sheet",
    subtitle: "gitsune/app !142",
    meta: "13h",
    onPress: () => nav.push('mr')
  }))));
}
Object.assign(__ds_scope, { Home });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/Home.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/IssueView.jsx
try { (() => {
const Comment = ({
  author,
  time,
  children
}) => /*#__PURE__*/React.createElement("div", {
  style: {
    display: 'flex',
    gap: 10,
    padding: '12px 16px',
    borderBottom: '1px solid var(--gl-border-color-subtle)',
    background: 'var(--gs-surface-card)'
  }
}, /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
  name: author,
  size: 32
}), /*#__PURE__*/React.createElement("div", {
  style: {
    flex: 1,
    minWidth: 0
  }
}, /*#__PURE__*/React.createElement("div", {
  style: {
    fontSize: 13
  }
}, /*#__PURE__*/React.createElement("b", {
  style: {
    color: 'var(--gl-text-color-heading)'
  }
}, author), " ", /*#__PURE__*/React.createElement("span", {
  style: {
    color: 'var(--gl-text-color-subtle)',
    fontSize: 12
  }
}, "\xB7 ", time)), /*#__PURE__*/React.createElement("div", {
  style: {
    fontSize: 14,
    marginTop: 4,
    lineHeight: '20px'
  }
}, children)));

/** Surface 3 — issue thread: state badge, metadata pill row, inline events, pinned composer, actions sheet. */
function IssueView({
  nav
}) {
  const [sheet, setSheet] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column',
      position: 'relative'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.NavHeader, {
    title: `${__ds_scope.issue.project} · ${__ds_scope.issue.ref}`,
    mono: true,
    onBack: nav.pop,
    right: /*#__PURE__*/React.createElement("button", {
      onClick: () => setSheet(true),
      "aria-label": "Issue actions",
      style: {
        all: 'unset',
        cursor: 'pointer',
        color: 'var(--gs-action-color)',
        padding: 6
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "ellipsis_h",
      size: 18
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      background: 'var(--gs-surface-subtle)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 16px 12px',
      background: 'var(--gs-surface-app)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Badge, {
    variant: "success",
    icon: "issue-open-m"
  }, "Open"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)'
    }
  }, __ds_scope.issue.author, " opened ", __ds_scope.issue.time)), /*#__PURE__*/React.createElement("h2", {
    style: {
      fontSize: 'var(--gl-font-size-600)',
      marginBottom: 10
    }
  }, __ds_scope.issue.title), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      flexWrap: 'nowrap',
      overflowX: 'auto',
      paddingBottom: 2
    }
  }, __ds_scope.issue.labels.map(l => /*#__PURE__*/React.createElement(__ds_scope.Label, {
    key: l.name,
    name: l.name,
    color: l.color
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      background: 'var(--gs-token-bg)',
      borderRadius: 9999,
      padding: '2px 8px',
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "milestone",
    size: 12
  }), __ds_scope.issue.milestone), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      background: 'var(--gs-token-bg)',
      borderRadius: 9999,
      padding: '2px 8px',
      whiteSpace: 'nowrap'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "assignee",
    size: 12
  }), "Marin"))), /*#__PURE__*/React.createElement(Comment, {
    author: __ds_scope.issue.author,
    time: __ds_scope.issue.time
  }, __ds_scope.issue.body), __ds_scope.issue.events.map((e, i) => /*#__PURE__*/React.createElement("div", {
    key: i,
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '8px 16px 8px 24px',
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: e.icon,
    size: 14
  }), e.text, " \xB7 ", e.time)), __ds_scope.issue.comments.map((c, i) => /*#__PURE__*/React.createElement(Comment, {
    key: i,
    author: c.author,
    time: c.time
  }, c.text))), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 'none',
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      padding: '8px 16px',
      borderTop: '1px solid var(--gl-border-color-default)',
      background: 'var(--gs-surface-app)'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      background: 'var(--gs-surface-inset)',
      border: '1px solid var(--gl-border-color-default)',
      borderRadius: 9999,
      padding: '10px 14px',
      fontSize: 14,
      color: 'var(--gl-text-color-disabled)'
    }
  }, "Add a comment\u2026"), /*#__PURE__*/React.createElement("button", {
    "aria-label": "Send",
    onClick: () => nav.toast('Commenting is not part of this mock'),
    style: {
      all: 'unset',
      cursor: 'pointer',
      width: 40,
      height: 40,
      borderRadius: '50%',
      background: 'var(--gs-action-color)',
      color: '#fff',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "paper-airplane",
    size: 18
  }))), /*#__PURE__*/React.createElement(__ds_scope.Drawer, {
    open: sheet,
    onClose: () => setSheet(false),
    title: "Issue actions"
  }, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "assignee",
      size: 20
    }),
    title: "Assignees",
    meta: "Marin",
    divider: true,
    onPress: () => setSheet(false)
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "labels",
      size: 20
    }),
    title: "Labels",
    meta: "2",
    divider: true,
    onPress: () => setSheet(false)
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "milestone",
      size: 20
    }),
    title: "Milestone",
    meta: "v1.0",
    divider: true,
    onPress: () => setSheet(false)
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "issue-close",
      size: 20,
      color: "var(--gl-status-danger-color)"
    }),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        color: 'var(--gl-text-color-danger)'
      }
    }, "Close issue"),
    trailing: null,
    onPress: () => {
      setSheet(false);
      nav.toast('Issue closed', {
        action: 'Undo'
      });
    }
  })));
}
Object.assign(__ds_scope, { IssueView });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/IssueView.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/MergeRequest.jsx
try { (() => {
const BranchChip = ({
  children
}) => /*#__PURE__*/React.createElement("span", {
  style: {
    font: '12px/16px var(--gs-font-mono)',
    background: 'var(--gs-token-bg)',
    borderRadius: 4,
    padding: '2px 6px',
    maxWidth: 150,
    overflow: 'hidden',
    textOverflow: 'ellipsis',
    whiteSpace: 'nowrap',
    display: 'inline-block',
    verticalAlign: 'bottom'
  }
}, children);

/** Surface 4 — MR view: state badge, branch chips, approvals, pipelines, and the blue merge box. */
function MergeRequest({
  nav,
  params
}) {
  const [tab, setTab] = React.useState(params && params.tab || 'overview');
  const [approved, setApproved] = React.useState(false);
  const approvals = __ds_scope.mr.approvedBy.length + (approved ? 1 : 0);
  const ready = approvals >= __ds_scope.mr.approvalsRequired;
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.NavHeader, {
    title: `${__ds_scope.mr.project} · ${__ds_scope.mr.ref}`,
    mono: true,
    onBack: nav.pop,
    right: /*#__PURE__*/React.createElement("button", {
      onClick: () => nav.toast('Actions are not part of this mock'),
      "aria-label": "More",
      style: {
        all: 'unset',
        cursor: 'pointer',
        color: 'var(--gs-action-color)',
        padding: 6
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "ellipsis_h",
      size: 18
    }))
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '4px 16px 12px'
    }
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      alignItems: 'center',
      gap: 8,
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Badge, {
    variant: "success",
    icon: "merge-request-open"
  }, "Open"), /*#__PURE__*/React.createElement("span", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)'
    }
  }, __ds_scope.mr.author, " \xB7 ", __ds_scope.mr.time)), /*#__PURE__*/React.createElement("h2", {
    style: {
      fontSize: 'var(--gl-font-size-600)',
      marginBottom: 8
    }
  }, __ds_scope.mr.title), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      color: 'var(--gl-text-color-subtle)',
      marginBottom: 8
    }
  }, /*#__PURE__*/React.createElement(BranchChip, null, __ds_scope.mr.source), " ", /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "long-arrow",
    size: 14,
    style: {
      display: 'inline-block',
      verticalAlign: '-2px'
    }
  }), " ", /*#__PURE__*/React.createElement(BranchChip, null, __ds_scope.mr.target)), /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 6,
      flexWrap: 'wrap'
    }
  }, __ds_scope.mr.labels.map(l => /*#__PURE__*/React.createElement(__ds_scope.Label, {
    key: l.name,
    name: l.name,
    color: l.color
  })), /*#__PURE__*/React.createElement("span", {
    style: {
      display: 'inline-flex',
      alignItems: 'center',
      gap: 4,
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
    name: "milestone",
    size: 12
  }), __ds_scope.mr.milestone))), /*#__PURE__*/React.createElement(__ds_scope.Tabs, {
    tabs: [{
      id: 'overview',
      label: 'Overview'
    }, {
      id: 'changes',
      label: 'Changes',
      count: __ds_scope.mr.filesChanged
    }, {
      id: 'pipelines',
      label: 'Pipelines'
    }],
    active: tab,
    onChange: setTab
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      background: 'var(--gs-surface-subtle)'
    }
  }, tab === 'overview' ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 16,
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.CiIcon, {
      status: "running",
      size: 20
    }),
    title: /*#__PURE__*/React.createElement("span", null, "Pipeline ", /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)'
      }
    }, "#88123"), " running"),
    subtitle: "Merge blocked until the pipeline passes",
    trailing: null,
    divider: true
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "approval",
      size: 20,
      color: ready ? 'var(--gl-status-success-color)' : 'var(--gl-icon-color-subtle)'
    }),
    title: `Approvals · ${approvals} of ${__ds_scope.mr.approvalsRequired}`,
    subtitle: approved ? 'Priya, you' : 'Priya',
    trailing: /*#__PURE__*/React.createElement("span", {
      style: {
        display: 'flex'
      }
    }, __ds_scope.mr.approvers.map(a => /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      key: a,
      name: a,
      size: 24,
      style: {
        marginLeft: -6,
        boxShadow: '0 0 0 2px var(--gs-surface-card)'
      }
    }))),
    divider: true
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "comments",
      size: 20,
      color: "var(--gl-status-warning-color)"
    }),
    title: `${__ds_scope.mr.unresolved} unresolved threads`,
    subtitle: "Resolve all threads before merging",
    trailing: null
  })), /*#__PURE__*/React.createElement(__ds_scope.Card, {
    padded: true
  }, /*#__PURE__*/React.createElement("div", {
    style: {
      display: 'flex',
      gap: 8
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "confirm",
    block: true,
    disabled: !ready,
    style: {
      borderRadius: '4px 0 0 4px'
    }
  }, "Merge"), /*#__PURE__*/React.createElement(__ds_scope.Button, {
    variant: "confirm",
    iconOnly: true,
    icon: "chevron-down",
    label: "Merge options",
    style: {
      marginLeft: -8,
      borderRadius: '0 4px 4px 0',
      boxShadow: 'inset 1px 0 0 rgba(255,255,255,.3)'
    }
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      marginTop: 8,
      textAlign: 'center'
    }
  }, ready ? 'All requirements met' : 'Blocked: pipeline running · approvals incomplete · unresolved threads'), !approved ? /*#__PURE__*/React.createElement(__ds_scope.Button, {
    icon: "approval",
    block: true,
    style: {
      marginTop: 10
    },
    onClick: () => {
      setApproved(true);
      nav.toast('Merge request approved');
    }
  }, "Approve") : null), /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "commit",
      size: 18
    }),
    title: `${__ds_scope.mr.commits} commits`,
    meta: "",
    divider: true,
    onPress: () => nav.toast('Commit list is not part of this mock')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "doc-changes",
      size: 18
    }),
    title: `${__ds_scope.mr.filesChanged} files changed`,
    onPress: () => setTab('changes')
  }))) : tab === 'changes' ? /*#__PURE__*/React.createElement(__ds_scope.DiffList, {
    nav: nav
  }) : /*#__PURE__*/React.createElement("div", {
    style: {
      padding: 16
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Card, null, __ds_scope.mr.pipelines.map((p, i) => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: p.id,
    leading: /*#__PURE__*/React.createElement(__ds_scope.CiIcon, {
      status: p.status,
      size: 20
    }),
    title: /*#__PURE__*/React.createElement("span", null, /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)'
      }
    }, p.id), " \xB7 ", p.status),
    subtitle: p.note,
    meta: p.time,
    divider: i < __ds_scope.mr.pipelines.length - 1,
    trailing: p.status === 'failed' ? /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      icon: "retry",
      onClick: () => nav.toast('Pipeline retried')
    }, "Retry") : p.status === 'running' ? /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      variant: "ghost",
      icon: "cancel",
      label: "Cancel",
      iconOnly: true,
      onClick: () => nav.toast('Pipeline canceled')
    }) : null
  }))))));
}
Object.assign(__ds_scope, { MergeRequest });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/MergeRequest.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/Profile.jsx
try { (() => {
const themeLabel = {
  light: 'Light',
  dark: 'Dark',
  auto: 'Auto'
};

/** Surface 7 — Profile, settings, and the account/instance switcher (host always visible). */
function Profile({
  nav,
  switcherOpen
}) {
  const [signout, setSignout] = React.useState(false);
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.LargeTitle, {
    title: "Profile"
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      padding: '0 16px 96px',
      background: 'var(--gs-surface-subtle)',
      display: 'flex',
      flexDirection: 'column',
      gap: 12
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      name: __ds_scope.user.name,
      size: 48
    }),
    title: /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--gl-text-color-heading)',
        fontSize: 16
      }
    }, __ds_scope.user.name),
    subtitle: /*#__PURE__*/React.createElement("span", null, __ds_scope.user.handle, " \xB7 ", /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)'
      }
    }, __ds_scope.user.host)),
    onPress: () => nav.openSwitcher(),
    trailing: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "chevron-lg-down",
      size: 16,
      color: "var(--gl-icon-color-subtle)"
    })
  })), /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "pencil-square",
      size: 20
    }),
    title: "Set status",
    divider: true,
    onPress: () => nav.toast('Status is not part of this mock')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "star-o",
      size: 20
    }),
    title: "Favorites",
    divider: true,
    onPress: () => nav.toast('Favorites live on Home')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "snippet",
      size: 20
    }),
    title: "Snippets",
    onPress: () => nav.toast('Snippets are out of v1 scope')
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      fontSize: 13,
      fontWeight: 600,
      color: 'var(--gl-text-color-subtle)',
      padding: '8px 4px 0'
    }
  }, "Settings"), /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "eye",
      size: 20
    }),
    title: "Appearance",
    meta: themeLabel[nav.theme],
    divider: true,
    onPress: nav.cycleTheme
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "code",
      size: 20
    }),
    title: "Code options",
    subtitle: "Wrap lines \xB7 syntax theme",
    divider: true,
    onPress: () => nav.toast('Code options are not part of this mock')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "shield",
      size: 20
    }),
    title: "Biometric app lock",
    meta: "On",
    divider: true,
    onPress: () => nav.toast('Biometric lock is device-managed')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "notifications",
      size: 20
    }),
    title: "Notifications",
    subtitle: "Polling \xB7 near-real-time",
    divider: true,
    onPress: () => nav.toast('Notification channels are not part of this mock')
  }), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "external-link",
      size: 20
    }),
    title: "External links",
    meta: "In-app",
    onPress: () => nav.toast('Link handling is not part of this mock')
  })), /*#__PURE__*/React.createElement(__ds_scope.Card, null, /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "leave",
      size: 20,
      color: "var(--gl-status-danger-color)"
    }),
    title: /*#__PURE__*/React.createElement("span", {
      style: {
        color: 'var(--gl-text-color-danger)'
      }
    }, "Sign out of gitlab.com"),
    trailing: null,
    onPress: () => setSignout(true)
  })), /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      padding: 8
    }
  }, "Gitsune 1.0.0 \xB7 open source")), /*#__PURE__*/React.createElement(__ds_scope.Drawer, {
    open: switcherOpen,
    onClose: nav.closeSwitcher,
    title: "Accounts"
  }, __ds_scope.accounts.map((a, i) => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: a.handle,
    divider: true,
    leading: /*#__PURE__*/React.createElement(__ds_scope.Avatar, {
      name: a.name,
      size: 36
    }),
    title: /*#__PURE__*/React.createElement("b", {
      style: {
        color: 'var(--gl-text-color-heading)'
      }
    }, a.name),
    subtitle: /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)'
      }
    }, a.handle, " \xB7 ", a.host),
    meta: a.unread ? /*#__PURE__*/React.createElement("span", {
      style: {
        background: 'var(--gs-action-color)',
        color: '#fff',
        borderRadius: 9999,
        fontSize: 11,
        fontWeight: 600,
        padding: '1px 7px'
      }
    }, a.unread) : null,
    trailing: a.active ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "check",
      size: 18,
      color: "var(--gs-action-color)"
    }) : null,
    onPress: () => {
      nav.closeSwitcher();
      if (!a.active) nav.toast(`Switched to ${a.host}`);
    }
  })), /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    leading: /*#__PURE__*/React.createElement("span", {
      style: {
        width: 36,
        height: 36,
        borderRadius: '50%',
        border: '1.5px dashed var(--gl-border-color-strong)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'var(--gl-icon-color-subtle)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "plus",
      size: 18
    })),
    title: "Add account",
    subtitle: "Any GitLab instance",
    trailing: null,
    onPress: () => {
      nav.closeSwitcher();
      nav.signOut();
    }
  })), /*#__PURE__*/React.createElement(__ds_scope.Modal, {
    open: signout,
    onClose: () => setSignout(false),
    title: "Sign out?",
    actions: /*#__PURE__*/React.createElement(React.Fragment, null, /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      onClick: () => setSignout(false)
    }, "Cancel"), /*#__PURE__*/React.createElement(__ds_scope.Button, {
      size: "sm",
      variant: "danger",
      onClick: () => {
        setSignout(false);
        nav.signOut();
      }
    }, "Sign out"))
  }, __ds_scope.user.host, " will be removed from this device. Your offline cache is cleared."));
}
Object.assign(__ds_scope, { Profile });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/Profile.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/TodoInbox.jsx
try { (() => {
/** Surface 6 — To-Do inbox: entity glyph rows, quick Done with undo Toast, filter sheet, purple empty state. */
function TodoInbox({
  nav
}) {
  const [done, setDone] = React.useState([]);
  const [filter, setFilter] = React.useState('All');
  const [sheet, setSheet] = React.useState(false);
  const items = __ds_scope.todos.filter(t => !done.includes(t.id) && (filter === 'All' || t.reason === filter));
  const markDone = id => {
    setDone(d => [...d, id]);
    nav.toast('To-do marked as done', {
      action: 'Undo',
      onAction: () => setDone(d => d.filter(x => x !== id))
    });
  };
  return /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      minHeight: 0,
      display: 'flex',
      flexDirection: 'column'
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.LargeTitle, {
    title: "To-Do List",
    right: /*#__PURE__*/React.createElement("button", {
      onClick: () => setSheet(true),
      style: {
        all: 'unset',
        cursor: 'pointer',
        display: 'flex',
        alignItems: 'center',
        gap: 4,
        color: 'var(--gs-action-color)',
        fontSize: 15,
        padding: 6
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "filter",
      size: 16
    }), filter === 'All' ? 'Filter' : filter)
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      flex: 1,
      overflowY: 'auto',
      paddingBottom: 88
    }
  }, items.length === 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      textAlign: 'center',
      padding: '64px 40px'
    }
  }, /*#__PURE__*/React.createElement("img", {
    src: "../../assets/illustrations/empty-todos-all-done-md.svg",
    alt: "",
    style: {
      width: 160
    }
  }), /*#__PURE__*/React.createElement("div", {
    style: {
      fontWeight: 600,
      fontSize: 16,
      color: 'var(--gl-text-color-heading)',
      marginTop: 16
    }
  }, "All done"), /*#__PURE__*/React.createElement("div", {
    style: {
      color: 'var(--gl-text-color-subtle)',
      fontSize: 13,
      marginTop: 4
    }
  }, "New to-dos land here in near real time \u2014 honestly not instant.")) : items.map(t => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: t.id,
    divider: true,
    onPress: () => nav.push(t.icon === 'issues' ? 'issue' : 'mr'),
    leading: /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: t.icon,
      size: 20,
      color: t.color
    }),
    title: t.title,
    subtitle: /*#__PURE__*/React.createElement("span", null, /*#__PURE__*/React.createElement("span", {
      style: {
        fontFamily: 'var(--gs-font-mono)'
      }
    }, t.project, " ", t.ref), " \xB7 ", t.note),
    meta: t.time,
    trailing: /*#__PURE__*/React.createElement("button", {
      onClick: e => {
        e.stopPropagation();
        markDone(t.id);
      },
      "aria-label": "Mark as done",
      style: {
        all: 'unset',
        cursor: 'pointer',
        width: 36,
        height: 36,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: 8,
        color: 'var(--gl-status-success-color)'
      }
    }, /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "check-circle",
      size: 20
    }))
  })), items.length > 0 ? /*#__PURE__*/React.createElement("div", {
    style: {
      padding: '14px 16px',
      fontSize: 12,
      color: 'var(--gl-text-color-subtle)',
      textAlign: 'center'
    }
  }, "Swipe right to mark done \xB7 swipe left to snooze") : null), /*#__PURE__*/React.createElement(__ds_scope.Drawer, {
    open: sheet,
    onClose: () => setSheet(false),
    title: "Filter by reason"
  }, __ds_scope.todoReasons.map(r => /*#__PURE__*/React.createElement(__ds_scope.ListRow, {
    key: r,
    divider: r !== 'Pipeline failed',
    onPress: () => {
      setFilter(r);
      setSheet(false);
    },
    title: r,
    trailing: filter === r ? /*#__PURE__*/React.createElement(__ds_scope.Icon, {
      name: "check",
      size: 16,
      color: "var(--gs-action-color)"
    }) : null
  }))));
}
Object.assign(__ds_scope, { TodoInbox });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/TodoInbox.jsx", error: String((e && e.message) || e) }); }

// ui_kits/gitsune-app/GitsuneApp.jsx
try { (() => {
const TABS = ['home', 'todos', 'explore', 'profile'];
const PUSHED = {
  mr: __ds_scope.MergeRequest,
  issue: __ds_scope.IssueView,
  code: __ds_scope.CodeBrowser
};

/** The whole Gitsune app as one interactive component. screen: home|todos|explore|profile|signin|mr|issue|code. */
function GitsuneApp({
  screen = 'home',
  theme: themeProp = 'dark'
}) {
  const [signedIn, setSignedIn] = React.useState(screen !== 'signin');
  const [tab, setTab] = React.useState(TABS.includes(screen) ? screen : 'home');
  const [stack, setStack] = React.useState(PUSHED[screen] ? [{
    screen
  }] : []);
  const [theme, setTheme] = React.useState(themeProp);
  const [toast, setToast] = React.useState(null);
  const [switcher, setSwitcher] = React.useState(false);
  React.useEffect(() => {
    setTheme(themeProp);
  }, [themeProp]);
  React.useEffect(() => {
    setSignedIn(screen !== 'signin');
    setTab(TABS.includes(screen) ? screen : 'home');
    setStack(PUSHED[screen] ? [{
      screen
    }] : []);
  }, [screen]);
  React.useEffect(() => {
    if (!toast) return;
    const t = setTimeout(() => setToast(null), 3500);
    return () => clearTimeout(t);
  }, [toast]);
  const nav = {
    theme,
    cycleTheme: () => setTheme(t => t === 'light' ? 'dark' : t === 'dark' ? 'auto' : 'light'),
    push: (s, params) => setStack(st => [...st, {
      screen: s,
      params
    }]),
    pop: () => setStack(st => st.slice(0, -1)),
    toast: (msg, opts) => setToast({
      msg,
      ...(opts || {})
    }),
    openSwitcher: () => {
      setTab('profile');
      setStack([]);
      setSwitcher(true);
    },
    closeSwitcher: () => setSwitcher(false),
    signIn: () => {
      setSignedIn(true);
      setTab('home');
      setStack([]);
    },
    signOut: () => {
      setSignedIn(false);
      setStack([]);
      setSwitcher(false);
    },
    openWork: id => {
      if (id === 'todos') setTab('todos');else if (id === 'mrs') nav.push('mr');else if (id === 'issues') nav.push('issue');else if (id === 'pipelines') nav.push('mr', {
        tab: 'pipelines'
      });else if (id === 'projects') nav.push('code');else nav.toast('Groups are not part of this mock');
    }
  };
  const effTheme = theme === 'auto' ? typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light' : theme;
  const top = stack[stack.length - 1];
  let el;
  if (!signedIn) el = /*#__PURE__*/React.createElement(__ds_scope.SignIn, {
    nav: nav
  });else if (top) {
    const S = PUSHED[top.screen] || __ds_scope.MergeRequest;
    el = /*#__PURE__*/React.createElement(S, {
      key: stack.length,
      nav: nav,
      params: top.params
    });
  } else el = tab === 'home' ? /*#__PURE__*/React.createElement(__ds_scope.Home, {
    nav: nav
  }) : tab === 'todos' ? /*#__PURE__*/React.createElement(__ds_scope.TodoInbox, {
    nav: nav
  }) : tab === 'explore' ? /*#__PURE__*/React.createElement(__ds_scope.Explore, {
    nav: nav
  }) : /*#__PURE__*/React.createElement(__ds_scope.Profile, {
    nav: nav,
    switcherOpen: switcher
  });
  return /*#__PURE__*/React.createElement(__ds_scope.PhoneShell, {
    theme: effTheme,
    tabbar: signedIn && !top ? /*#__PURE__*/React.createElement(__ds_scope.TabBar, {
      active: tab,
      onChange: setTab,
      items: [{
        id: 'home',
        icon: 'home',
        label: 'Home'
      }, {
        id: 'todos',
        icon: 'todo-done',
        label: 'To-Dos',
        badge: 5
      }, {
        id: 'explore',
        icon: 'compass',
        label: 'Explore'
      }, {
        id: 'profile',
        icon: 'user',
        label: 'Profile'
      }]
    }) : null
  }, el, toast ? /*#__PURE__*/React.createElement("div", {
    style: {
      position: 'absolute',
      left: 16,
      right: 16,
      bottom: signedIn && !top ? 88 : 12,
      zIndex: 60
    }
  }, /*#__PURE__*/React.createElement(__ds_scope.Toast, {
    action: toast.action,
    onAction: () => {
      toast.onAction && toast.onAction();
      setToast(null);
    }
  }, toast.msg)) : null);
}
Object.assign(__ds_scope, { GitsuneApp });
})(); } catch (e) { __ds_ns.__errors.push({ path: "ui_kits/gitsune-app/GitsuneApp.jsx", error: String((e && e.message) || e) }); }

__ds_ns.Button = __ds_scope.Button;

__ds_ns.Card = __ds_scope.Card;

__ds_ns.Tabs = __ds_scope.Tabs;

__ds_ns.CiIcon = __ds_scope.CiIcon;

__ds_ns.Icon = __ds_scope.Icon;

__ds_ns.ICONS = __ds_scope.ICONS;

__ds_ns.STATUS_ICONS = __ds_scope.STATUS_ICONS;

__ds_ns.FILE_ICONS = __ds_scope.FILE_ICONS;

__ds_ns.ALL = __ds_scope.ALL;

__ds_ns.Avatar = __ds_scope.Avatar;

__ds_ns.Badge = __ds_scope.Badge;

__ds_ns.Label = __ds_scope.Label;

__ds_ns.Skeleton = __ds_scope.Skeleton;

__ds_ns.Token = __ds_scope.Token;

__ds_ns.Alert = __ds_scope.Alert;

__ds_ns.Toast = __ds_scope.Toast;

__ds_ns.ListRow = __ds_scope.ListRow;

__ds_ns.TabBar = __ds_scope.TabBar;

__ds_ns.Tile = __ds_scope.Tile;

__ds_ns.Drawer = __ds_scope.Drawer;

__ds_ns.Modal = __ds_scope.Modal;

__ds_ns.CodeBrowser = __ds_scope.CodeBrowser;

__ds_ns.DiffList = __ds_scope.DiffList;

__ds_ns.Explore = __ds_scope.Explore;

__ds_ns.GitsuneApp = __ds_scope.GitsuneApp;

__ds_ns.Home = __ds_scope.Home;

__ds_ns.IssueView = __ds_scope.IssueView;

__ds_ns.MergeRequest = __ds_scope.MergeRequest;

__ds_ns.PhoneShell = __ds_scope.PhoneShell;

__ds_ns.NavHeader = __ds_scope.NavHeader;

__ds_ns.LargeTitle = __ds_scope.LargeTitle;

__ds_ns.Profile = __ds_scope.Profile;

__ds_ns.SignIn = __ds_scope.SignIn;

__ds_ns.TodoInbox = __ds_scope.TodoInbox;

})();
