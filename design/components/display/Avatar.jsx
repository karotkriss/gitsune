import React from 'react';

const HUES = ['blue', 'green', 'orange', 'purple', 'red', 'neutral'];
const hash = s => { let h = 0; for (const c of String(s)) h = (h * 31 + c.charCodeAt(0)) | 0; return Math.abs(h); };

/** User/project/group avatar. Users are circles; projects & groups are rounded squares. Falls back to tinted initials. */
export function Avatar({ src, name = '', entity = 'user', size = 32, style }) {
  const circle = entity === 'user';
  const radius = circle ? '50%' : size >= 32 ? 'var(--gl-border-radius-lg)' : 'var(--gl-border-radius-md)';
  const base = { width: size, height: size, borderRadius: radius, flex: 'none', boxShadow: 'inset 0 0 0 1px var(--gl-color-alpha-dark-8)', display: 'block' };
  if (src) return <img src={src} alt={name} style={{ ...base, objectFit: 'cover', ...style }} />;
  const hue = HUES[hash(name) % HUES.length];
  const initials = name.split(/[\s-_]+/).map(w => w[0]).filter(Boolean).slice(0, 2).join('').toUpperCase() || '?';
  return (
    <span role="img" aria-label={name} style={{ ...base, display: 'flex', alignItems: 'center', justifyContent: 'center', background: `var(--gs-avatar-bg-${hue})`, color: `var(--gs-avatar-text-${hue})`, fontWeight: 'var(--gl-font-weight-bold)', fontSize: Math.max(10, Math.round(size * 0.4)), ...style }}>
      {size >= 20 ? initials : initials[0]}
    </span>
  );
}
