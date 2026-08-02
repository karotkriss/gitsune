import React from 'react';
import { Icon } from '../core/Icon.jsx';

/** Pajamas Token: a removable filter chip (never call it a "chip" in UI copy). */
export function Token({ children, icon, onRemove, style }) {
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, background: 'var(--gs-token-bg)', color: 'var(--gl-text-color-default)', borderRadius: 'var(--gl-border-radius-md)', padding: '2px 4px 2px 8px', font: 'var(--gs-text-caption)', lineHeight: '16px', ...style }}>
      {icon ? <Icon name={icon} size={12} /> : null}{children}
      {onRemove ? <button onClick={onRemove} aria-label="Remove" style={{ all: 'unset', cursor: 'pointer', display: 'flex', padding: 2, borderRadius: 2 }}><Icon name="close-sm" size={12} /></button> : <span style={{ width: 4 }}></span>}
    </span>
  );
}
