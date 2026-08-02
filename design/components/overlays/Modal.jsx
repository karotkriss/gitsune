import React from 'react';
import { Button } from '../actions/Button.jsx';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-modal', `@keyframes gs-modal-in{from{opacity:0;transform:scale(.96)}to{opacity:1;transform:scale(1)}}
@keyframes gs-fade{from{opacity:0}to{opacity:1}}`);

/** Pajamas Modal: focused confirmation dialog. Reserve for blocking decisions; prefer Drawer for pickers. */
export function Modal({ open, onClose, title, children, actions, style }) {
  if (!open) return null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 50, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 24 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'var(--gs-scrim)', animation: 'gs-fade .2s ease-out' }}></div>
      <div role="dialog" aria-modal="true" aria-label={title} style={{ position: 'relative', background: 'var(--gs-glass-bg-strong)', backdropFilter: 'var(--gs-glass-blur)', WebkitBackdropFilter: 'var(--gs-glass-blur)', borderRadius: 24, boxShadow: 'var(--gs-glass-edge)', width: '100%', maxWidth: 340, animation: 'gs-modal-in .18s ease-out', ...style }}>
        <div style={{ padding: '20px 20px 8px', fontWeight: 'var(--gl-font-weight-bold)', fontSize: 'var(--gl-font-size-400)', color: 'var(--gl-text-color-heading)' }}>{title}</div>
        <div style={{ padding: '0 20px 16px', color: 'var(--gl-text-color-default)' }}>{children}</div>
        {actions ? <div style={{ display: 'flex', gap: 8, justifyContent: 'flex-end', padding: '0 16px 16px' }}>{actions}</div> : null}
      </div>
    </div>
  );
}
Modal.Button = Button;
