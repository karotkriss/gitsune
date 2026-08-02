import React from 'react';
import { injectStyle } from '../core/injectStyle.js';

injectStyle('gs-skeleton', `@keyframes gs-skeleton-shimmer{0%{background-position:200% 0}100%{background-position:-200% 0}}
.gs-skeleton{background:linear-gradient(90deg,var(--gs-skeleton-bg) 25%,var(--gs-skeleton-shimmer) 45%,var(--gs-skeleton-bg) 65%);background-size:200% 100%;animation:gs-skeleton-shimmer 1.8s ease-in-out infinite}`);

/** Pajamas Skeleton loader: shimmering placeholder bars while content loads. */
export function Skeleton({ width = '100%', height = 12, radius = 'var(--gl-border-radius-md)', lines = 1, gap = 8, style }) {
  const bar = (w, k) => <span key={k} className="gs-skeleton" style={{ display: 'block', width: w, height, borderRadius: radius }}></span>;
  if (lines === 1) return bar(width, 0);
  return <span style={{ display: 'flex', flexDirection: 'column', gap, ...style }}>{Array.from({ length: lines }, (_, i) => bar(i === lines - 1 ? '60%' : width, i))}</span>;
}
