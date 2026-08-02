import React from 'react';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-drawer', `@keyframes gs-drawer-up{from{transform:translateY(100%)}to{transform:translateY(0)}}
@keyframes gs-fade{from{opacity:0}to{opacity:1}}`);

/** Pajamas Drawer as a mobile bottom sheet. Fills its nearest positioned ancestor (the phone frame) — wrap standalone use in a relative container. */
export function Drawer({ open, onClose, title, children, style }) {
  if (!open) return null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 40, display: 'flex', flexDirection: 'column', justifyContent: 'flex-end' }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'var(--gs-scrim)', animation: 'gs-fade .2s ease-out' }}></div>
      <div role="dialog" aria-modal="true" aria-label={title} style={{ position: 'relative', background: 'var(--gs-glass-bg-strong)', backdropFilter: 'var(--gs-glass-blur)', WebkitBackdropFilter: 'var(--gs-glass-blur)', borderRadius: '28px 28px 0 0', boxShadow: 'var(--gs-glass-edge)', animation: 'gs-drawer-up .25s cubic-bezier(.2,.7,.3,1)', maxHeight: '85%', display: 'flex', flexDirection: 'column', ...style }}>
        <div style={{ width: 36, height: 4, borderRadius: 2, background: 'var(--gl-border-color-strong)', margin: '8px auto 0', flex: 'none' }}></div>
        {title ? <div style={{ padding: '12px 16px 4px', fontWeight: 'var(--gl-font-weight-bold)', fontSize: 'var(--gl-font-size-400)', color: 'var(--gl-text-color-heading)', textAlign: 'center' }}>{title}</div> : null}
        <div style={{ overflowY: 'auto', padding: '8px 0 24px' }}>{children}</div>
      </div>
    </div>
  );
}
