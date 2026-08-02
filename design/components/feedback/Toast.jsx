import React from 'react';

/** Pajamas Toast: transient confirmation, often with an Undo action after a destructive swipe. */
export function Toast({ children, action, onAction, style }) {
  return (
    <div role="status" style={{ display: 'flex', alignItems: 'center', gap: 16, background: 'var(--gs-toast-bg)', backdropFilter: 'var(--gs-glass-blur)', WebkitBackdropFilter: 'var(--gs-glass-blur)', color: 'var(--gs-toast-text)', borderRadius: 'var(--gl-border-radius-full)', padding: '12px 20px', boxShadow: 'inset 0 1px 0 rgba(255,255,255,.12), 0 8px 24px rgba(5,5,6,.35)', font: 'var(--gs-text-body)', ...style }}>
      <span style={{ flex: 1 }}>{children}</span>
      {action ? <button onClick={onAction} style={{ all: 'unset', cursor: 'pointer', color: 'var(--gs-toast-action)', fontWeight: 'var(--gl-font-weight-bold)', padding: '4px 0' }}>{action}</button> : null}
    </div>
  );
}
