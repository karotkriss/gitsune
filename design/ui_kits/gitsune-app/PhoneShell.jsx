import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { injectStyle } from '../../components/core/injectStyle.js';

injectStyle('gs-shell', `.gs-shell *{box-sizing:border-box}.gs-shell button{-webkit-tap-highlight-color:transparent}
.gs-back:active{opacity:.6}`);

/** 390×844 phone viewport with iOS-style status bar and home indicator. Dark liquid glass is the default theme. */
export function PhoneShell({ children, theme = 'dark', tabbar }) {
  return (
    <div className="gs-shell" data-theme={theme === 'dark' ? 'dark' : undefined} style={{ width: 390, height: 844, background: 'var(--gs-surface-app)', display: 'flex', flexDirection: 'column', overflow: 'hidden', position: 'relative', fontFamily: 'var(--gs-font-ui)', color: 'var(--gl-text-color-default)' }}>
      <StatusBar />
      <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative', overflow: 'hidden' }}>{children}{tabbar}</div>
      <div style={{ height: 24, flex: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'inherit' }}>
        <span style={{ width: 134, height: 5, borderRadius: 3, background: 'var(--gl-text-color-heading)', opacity: .9 }}></span>
      </div>
    </div>
  );
}

function StatusBar() {
  return (
    <div style={{ height: 48, flex: 'none', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 24px 0 32px', fontSize: 15, fontWeight: 600, color: 'var(--gl-text-color-heading)' }}>
      <span>9:41</span>
      <span style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
        <span style={{ display: 'flex', alignItems: 'flex-end', gap: 1.5 }}>{[4, 6, 8, 10].map((h, i) => <span key={i} style={{ width: 3, height: h, borderRadius: 1, background: 'currentColor', opacity: i < 3 ? 1 : .35 }}></span>)}</span>
        <span style={{ width: 24, height: 12, border: '1px solid currentColor', borderRadius: 3.5, padding: 1.5, display: 'flex' }}><span style={{ width: '72%', borderRadius: 1.5, background: 'currentColor' }}></span></span>
      </span>
    </div>
  );
}

/** Push-screen header: back chevron, centered title, optional right action. */
export function NavHeader({ title, onBack, right, mono = false }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', height: 48, flex: 'none', padding: '0 8px', gap: 4 }}>
      <button className="gs-back" onClick={onBack} aria-label="Back" style={{ all: 'unset', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 2, color: 'var(--gs-action-color)', padding: '8px 4px', fontSize: 15 }}>
        <Icon name="chevron-lg-left" size={20} />Back
      </button>
      <span style={{ flex: 1, textAlign: 'center', fontWeight: 600, fontSize: 15, color: 'var(--gl-text-color-heading)', fontFamily: mono ? 'var(--gs-font-mono)' : undefined, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{title}</span>
      <span style={{ width: 64, display: 'flex', justifyContent: 'flex-end' }}>{right}</span>
    </div>
  );
}

/** Large-title screen header (GitHub Mobile shape) with optional right-side accessory. */
export function LargeTitle({ title, right }) {
  return (
    <div style={{ display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', padding: '4px 16px 10px', flex: 'none' }}>
      <h1 style={{ fontSize: 'var(--gs-screen-title-size)', letterSpacing: 'var(--gl-letter-spacing-heading-reduced)' }}>{title}</h1>
      {right}
    </div>
  );
}
