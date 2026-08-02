import React from 'react';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-tabs', `.gs-tab{all:unset;box-sizing:border-box;cursor:pointer;padding:12px 4px 10px;font-family:var(--gs-font-ui);font-size:var(--gl-font-size-300);color:var(--gl-text-color-subtle);border-bottom:2px solid transparent;display:inline-flex;align-items:center;gap:6px;-webkit-tap-highlight-color:transparent}
.gs-tab:hover{color:var(--gl-text-color-default)}
.gs-tab[aria-selected="true"]{color:var(--gl-text-color-heading);font-weight:var(--gl-font-weight-bold);border-bottom-color:var(--gs-action-color)}
.gs-tab:focus-visible{box-shadow:var(--gs-focus-ring);border-radius:4px}`);

/** Pajamas Tabs: underline tabs for in-screen sections (Overview / Changes / Pipelines). */
export function Tabs({ tabs, active, onChange, style }) {
  return (
    <div role="tablist" style={{ display: 'flex', gap: 20, borderBottom: '1px solid var(--gl-border-color-default)', padding: '0 16px', overflowX: 'auto', ...style }}>
      {tabs.map(t => (
        <button key={t.id} role="tab" aria-selected={active === t.id} className="gs-tab" onClick={() => onChange && onChange(t.id)}>
          {t.label}
          {t.count != null ? <span style={{ background: 'var(--gl-background-color-strong)', borderRadius: 'var(--gl-border-radius-full)', padding: '0 7px', fontSize: 'var(--gl-font-size-100)', lineHeight: '16px', fontWeight: 400, color: 'var(--gl-text-color-subtle)' }}>{t.count}</span> : null}
        </button>
      ))}
    </div>
  );
}
