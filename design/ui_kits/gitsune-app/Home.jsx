import React from 'react';
import { Card } from '../../components/containers/Card.jsx';
import { Tile } from '../../components/navigation/Tile.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { Avatar } from '../../components/display/Avatar.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { CiIcon } from '../../components/core/CiIcon.jsx';
import { LargeTitle } from './PhoneShell.jsx';
import { myWork, favorites, user } from './data.js';

const Section = ({ children, action }) => <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '20px 4px 8px' }}><h2 style={{ fontSize: 'var(--gl-font-size-500)' }}>{children}</h2>{action}</div>;

/** Surface 2 — Home: My Work tiles, Favorites, Recent (GitHub Mobile shape, GitLab nouns). */
export function Home({ nav }) {
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <LargeTitle title="Home" right={
        <button onClick={() => nav.openSwitcher()} aria-label="Switch account" style={{ all: 'unset', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6 }}>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, font: '11px/1 var(--gs-font-mono)', color: 'var(--gl-text-color-subtle)', background: 'var(--gs-glass-bg)', backdropFilter: 'var(--gs-glass-blur)', WebkitBackdropFilter: 'var(--gs-glass-blur)', boxShadow: '0 0 0 1px var(--gs-glass-border)', borderRadius: 9999, padding: '5px 9px' }}>{user.host}</span>
          <Avatar name={user.name} size={32} />
        </button>} />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 96px', background: 'var(--gs-surface-subtle)' }}>
        <Section action={<button onClick={() => nav.toast('Reordering is not part of this mock')} aria-label="Edit My Work" style={{ all: 'unset', cursor: 'pointer', color: 'var(--gl-icon-color-subtle)', padding: 6 }}><Icon name="ellipsis_h" size={16} /></button>}>My Work</Section>
        <Card>
          {myWork.map((t, i) => <Tile key={t.id} hue={t.hue} icon={t.icon} label={t.label} count={t.count} divider={i < myWork.length - 1} onPress={() => nav.openWork(t.id)} />)}
        </Card>
        <Section>Favorites</Section>
        <Card>
          {favorites.map((f, i) => <ListRow key={f.name} leading={<Avatar name={f.name} entity="project" size={28} />} title={<span style={{ fontFamily: 'var(--gs-font-mono)', fontSize: 13 }}>{f.name}</span>} subtitle={f.desc} meta={<span style={{ display: 'inline-flex', alignItems: 'center', gap: 3 }}><Icon name="star-o" size={12} />{f.stars}</span>} divider={i < favorites.length - 1} onPress={() => nav.push('code')} />)}
        </Card>
        <Section>Recent</Section>
        <Card>
          <ListRow leading={<CiIcon status="running" size={20} />} title="Pipeline #88123 running" subtitle="gitsune/app · feat/instance-switcher" meta="2h" divider onPress={() => nav.push('mr', { tab: 'pipelines' })} />
          <ListRow leading={<Icon name="merge-request" size={20} color="var(--gl-status-success-color)" />} title="Add instance switcher sheet" subtitle="gitsune/app !142" meta="13h" onPress={() => nav.push('mr')} />
        </Card>
      </div>
    </div>
  );
}
