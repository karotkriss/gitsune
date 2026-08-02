import React from 'react';
import { Icon } from '../core/Icon.jsx';
import { ListRow } from './ListRow.jsx';

const HUES = { issues: 'var(--gs-tile-issues)', mrs: 'var(--gs-tile-mrs)', todos: 'var(--gs-tile-todos)', pipelines: 'var(--gs-tile-pipelines)', projects: 'var(--gs-tile-projects)', groups: 'var(--gs-tile-groups)' };

/** Home shortcut tile: colored container + GitLab glyph, in a row. Container colors come from the ramps; glyphs stay GitLab SVGs. */
export function Tile({ hue = 'issues', color, icon, label, count, onPress, divider = false }) {
  return (
    <ListRow divider={divider} onPress={onPress} meta={count != null ? String(count) : undefined}
      leading={<span style={{ width: 32, height: 32, borderRadius: 'var(--gl-border-radius-lg)', background: color || HUES[hue] || HUES.issues, color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name={icon} size={20} /></span>}
      title={<span style={{ fontWeight: 'var(--gl-font-weight-semibold)' }}>{label}</span>} />
  );
}
Tile.hues = Object.keys(HUES);
