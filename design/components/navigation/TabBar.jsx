import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-tabbar', `.gs-tabbar-item{all:unset;box-sizing:border-box;flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;border-radius:9999px;cursor:pointer;color:var(--gl-text-color-subtle);-webkit-tap-highlight-color:transparent;transition:background-color .15s ease-out,color .15s ease-out}
.gs-tabbar-item[aria-current="true"]{color:var(--gl-text-color-heading);background:var(--gs-glass-active)}
.gs-tabbar-item:active{opacity:.75}`);

/** Liquid-glass capsule tab bar: floats over the scrolling content (blur samples it); active item sits in a lighter glass pill. */
export function TabBar({ items, active, onChange, floating = true, style }) {
  return (
    <nav style={{ position: floating ? 'absolute' : 'relative', left: floating ? 12 : undefined, right: floating ? 12 : undefined, bottom: floating ? 10 : undefined, zIndex: 30, display: 'flex', gap: 4, height: 'var(--gs-tabbar-height)', padding: 6, borderRadius: 'var(--gl-border-radius-full)', background: 'var(--gs-glass-bg)', backdropFilter: 'var(--gs-glass-blur)', WebkitBackdropFilter: 'var(--gs-glass-blur)', boxShadow: 'var(--gs-glass-edge)', ...style }}>
      {items.map(it => (
        <button key={it.id} className="gs-tabbar-item" aria-current={active === it.id} onClick={() => onChange && onChange(it.id)}>
          <span style={{ position: 'relative' }}>
            <Icon name={it.icon} size={24} />
            {it.badge ? <span style={{ position: 'absolute', top: -4, right: -10, background: 'var(--gs-action-color)', color: '#fff', borderRadius: 'var(--gl-border-radius-full)', fontSize: 10, fontWeight: 600, lineHeight: '14px', minWidth: 14, padding: '0 3px', textAlign: 'center' }}>{it.badge}</span> : null}
          </span>
          <span style={{ fontSize: 'var(--gl-font-size-xs)', fontWeight: 'var(--gl-font-weight-semibold)' }}>{it.label}</span>
        </button>
      ))}
    </nav>
  );
}
