import React from 'react';
import { ALL, FILE_ICONS } from './iconPaths.js';

/** Renders a GitLab SVG glyph (vendored verbatim from @gitlab/svgs). Inherits currentColor. */
export function Icon({ name, size = 16, file = false, color, label, style, className }) {
  const def = (file ? FILE_ICONS : ALL)[name];
  if (!def) return <span style={{ width: size, height: size, display: 'inline-block' }} data-missing-icon={name}></span>;
  return <svg viewBox={def.v} width={size} height={size} fill="currentColor" role={label ? 'img' : 'presentation'} aria-label={label} aria-hidden={label ? undefined : true} focusable="false" className={className} style={{ display: 'block', flex: 'none', color, ...style }} dangerouslySetInnerHTML={{ __html: def.c }}></svg>;
}
