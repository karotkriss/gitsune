import React from 'react';

/** Pajamas Card: bordered container grouping related content. */
export function Card({ children, padded = false, style }) {
  return (
    <div style={{ background: 'var(--gs-surface-card)', border: '1px solid var(--gl-border-color-subtle)', borderRadius: 'var(--gl-card-border-radius)', boxShadow: '0 1px 2px var(--gl-color-alpha-dark-2)', overflow: 'hidden', padding: padded ? 16 : 0, ...style }}>
      {children}
    </div>
  );
}
