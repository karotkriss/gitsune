import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-listrow', `.gs-listrow{-webkit-tap-highlight-color:transparent}
.gs-listrow[data-press]:active{background:var(--gs-press-overlay)}`);

/** List row: leading glyph/avatar, title + subtitle, right-aligned meta, chevron. The workhorse of every list screen. */
export function ListRow({ leading, title, titleMono = false, subtitle, meta, trailing = 'chevron', onPress, divider = false, style }) {
  const T = onPress ? 'button' : 'div';
  return (
    <T className="gs-listrow" data-press={onPress ? '' : undefined} onClick={onPress}
      style={{ all: 'unset', boxSizing: 'border-box', display: 'flex', alignItems: 'center', gap: 12, width: '100%', minHeight: 'var(--gs-touch-target)', padding: '10px 16px', cursor: onPress ? 'pointer' : undefined, borderBottom: divider ? '1px solid var(--gl-border-color-subtle)' : 'none', font: 'var(--gs-text-body)', ...style }}>
      {leading ? <span style={{ flex: 'none', display: 'flex' }}>{leading}</span> : null}
      <span style={{ flex: 1, minWidth: 0, display: 'flex', flexDirection: 'column', gap: 2 }}>
        <span style={{ color: 'var(--gl-text-color-default)', fontSize: 'var(--gl-font-size-300)', lineHeight: '20px', fontFamily: titleMono ? 'var(--gs-font-mono)' : undefined, overflow: 'hidden', textOverflow: 'ellipsis', display: '-webkit-box', WebkitLineClamp: 2, WebkitBoxOrient: 'vertical' }}>{title}</span>
        {subtitle ? <span style={{ color: 'var(--gl-text-color-subtle)', fontSize: 'var(--gl-font-size-200)', lineHeight: '16px', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{subtitle}</span> : null}
      </span>
      {meta ? <span style={{ flex: 'none', color: 'var(--gl-text-color-subtle)', fontSize: 'var(--gl-font-size-200)', alignSelf: subtitle ? 'flex-start' : 'center', paddingTop: subtitle ? 2 : 0 }}>{meta}</span> : null}
      {trailing === 'chevron' ? <Icon name="chevron-lg-right" size={16} color="var(--gl-color-neutral-300)" /> : trailing}
    </T>
  );
}
