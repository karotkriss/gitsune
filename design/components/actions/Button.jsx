import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-button', `@keyframes gs-spin{to{transform:rotate(360deg)}}
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

const SIZES = { sm: [32, '0 12px', 'var(--gl-font-size-200)'], md: [44, '0 16px', 'var(--gl-font-size-300)'], lg: [50, '0 20px', 'var(--gl-font-size-400)'] };

/** Pajamas Button. Confirm is brand orange — the interactive color; green is reserved for achieved success states. */
export function Button({ variant = 'default', size = 'md', icon, iconOnly = false, loading = false, block = false, disabled, children, onClick, label, style }) {
  const [h, pad, fs] = SIZES[size] || SIZES.md;
  return (
    <button className={`gs-btn gs-btn-${variant}`} disabled={disabled || loading} onClick={onClick} aria-label={iconOnly ? (label || String(children)) : label}
      style={{ height: h, padding: iconOnly ? 0 : pad, width: iconOnly ? h : block ? '100%' : undefined, fontSize: fs, ...style }}>
      {loading ? <Icon name="spinner" size={16} style={{ animation: 'gs-spin 1s linear infinite' }} /> : icon ? <Icon name={icon} size={size === 'sm' ? 14 : 16} /> : null}
      {iconOnly ? null : children}
    </button>
  );
}
