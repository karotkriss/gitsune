# Icon

Renders a glyph from GitLab's own SVG icon set (the only sanctioned glyph source); use for every icon in the product.

```jsx
<Icon name="merge-request" size={20} />
<Icon name="todo-done" color="var(--gl-status-success-color)" label="Done" />
<Icon name="javascript" file size={16} />
```

Icons inherit `currentColor`. UI set is drawn on a 16px grid with 1.5px strokes; render at 20–24px inside 44pt touch targets. `file` switches to the file-type set (code browser rows). Available names live in `iconPaths.js` (`ICONS`, `STATUS_ICONS`, `FILE_ICONS`).
