import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { Token } from '../../components/display/Token.jsx';
import { LargeTitle } from './PhoneShell.jsx';

/** Explore/Search — scoped search with filter tokens and a designed empty state. */
export function Explore({ nav }) {
  const [q, setQ] = React.useState('');
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <LargeTitle title="Explore" />
      <div style={{ padding: '0 16px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, background: 'var(--gs-surface-inset)', border: '1px solid var(--gl-border-color-default)', borderRadius: 10, padding: '0 12px', height: 44 }}>
          <Icon name="search" size={16} color="var(--gl-icon-color-subtle)" />
          <input value={q} onChange={e => setQ(e.target.value)} placeholder="Search projects, issues, merge requests" style={{ all: 'unset', flex: 1, fontSize: 15, color: 'var(--gl-text-color-default)' }} aria-label="Search" />
          {q ? <button onClick={() => setQ('')} aria-label="Clear" style={{ all: 'unset', cursor: 'pointer', display: 'flex', color: 'var(--gl-icon-color-subtle)' }}><Icon name="clear" size={16} /></button> : null}
        </div>
        <div style={{ display: 'flex', gap: 6, marginTop: 10, flexWrap: 'wrap' }}>
          <Token icon="project">in: gitsune/app</Token>
          <Token icon="merge-request" onRemove={() => {}}>type = merge request</Token>
        </div>
      </div>
      <div style={{ flex: 1, overflowY: 'auto', textAlign: 'center', padding: '48px 40px 120px' }}>
        <img src="../../assets/illustrations/search-sm.svg" alt="" style={{ width: 120 }} />
        <div style={{ fontWeight: 600, fontSize: 16, color: 'var(--gl-text-color-heading)', marginTop: 16 }}>{q ? `No results for “${q}”` : 'Search this instance'}</div>
        <div style={{ color: 'var(--gl-text-color-subtle)', fontSize: 13, marginTop: 4 }}>{q ? 'Cross-project code search depends on this instance\u2019s tier — falling back to web search when unavailable.' : 'Results stay scoped to gitlab.com until you switch accounts.'}</div>
      </div>
    </div>
  );
}
