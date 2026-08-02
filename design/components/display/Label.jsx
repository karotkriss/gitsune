import React from 'react';

const lum = hex => { const h = hex.replace('#', ''); const f = h.length === 3 ? h.split('').map(c => c + c).join('') : h; const [r, g, b] = [0, 2, 4].map(i => parseInt(f.slice(i, i + 2), 16) / 255); return 0.2126 * r + 0.7152 * g + 0.0722 * b; };

/** GitLab Label pill. Scoped labels (name contains "::") render as the signature two-tone pill. */
export function Label({ name, color = '#428fdc', onRemove, style }) {
  const light = lum(color) > 0.55;
  const fg = light ? 'var(--gl-color-neutral-950)' : '#fff';
  const scoped = name.includes('::');
  const base = { display: 'inline-flex', alignItems: 'center', borderRadius: 'var(--gl-border-radius-full)', font: 'var(--gs-text-caption)', fontWeight: 'var(--gl-font-weight-normal)', lineHeight: '16px', whiteSpace: 'nowrap', ...style };
  if (!scoped) return <span style={{ ...base, background: color, color: fg, padding: '2px 8px' }}>{name}{onRemove ? <Rm fg={fg} onRemove={onRemove} /> : null}</span>;
  const [scope, value] = name.split('::');
  return (
    <span style={{ ...base, boxShadow: `inset 0 0 0 2px ${color}`, background: 'var(--gs-surface-card)' }}>
      <span style={{ background: color, color: fg, padding: '2px 6px 2px 8px', borderRadius: '9999px 0 0 9999px' }}>{scope}</span>
      <span style={{ color: 'var(--gl-text-color-default)', padding: '2px 8px 2px 6px' }}>{value}{onRemove ? <Rm fg="currentColor" onRemove={onRemove} /> : null}</span>
    </span>
  );
}
const Rm = ({ fg, onRemove }) => <button onClick={onRemove} aria-label="Remove label" style={{ all: 'unset', cursor: 'pointer', marginLeft: 4, color: fg, fontSize: 11, lineHeight: 1 }}>×</button>;
