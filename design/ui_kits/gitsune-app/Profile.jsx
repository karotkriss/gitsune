import React from 'react';
import { Avatar } from '../../components/display/Avatar.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Card } from '../../components/containers/Card.jsx';
import { Drawer } from '../../components/overlays/Drawer.jsx';
import { Modal } from '../../components/overlays/Modal.jsx';
import { Button } from '../../components/actions/Button.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { LargeTitle } from './PhoneShell.jsx';
import { accounts, user } from './data.js';

const themeLabel = { light: 'Light', dark: 'Dark', auto: 'Auto' };

/** Surface 7 — Profile, settings, and the account/instance switcher (host always visible). */
export function Profile({ nav, switcherOpen }) {
  const [signout, setSignout] = React.useState(false);
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <LargeTitle title="Profile" />
      <div style={{ flex: 1, overflowY: 'auto', padding: '0 16px 96px', background: 'var(--gs-surface-subtle)', display: 'flex', flexDirection: 'column', gap: 12 }}>
        <Card>
          <ListRow leading={<Avatar name={user.name} size={48} />} title={<b style={{ color: 'var(--gl-text-color-heading)', fontSize: 16 }}>{user.name}</b>} subtitle={<span>{user.handle} · <span style={{ fontFamily: 'var(--gs-font-mono)' }}>{user.host}</span></span>} onPress={() => nav.openSwitcher()} trailing={<Icon name="chevron-lg-down" size={16} color="var(--gl-icon-color-subtle)" />} />
        </Card>
        <Card>
          <ListRow leading={<Icon name="pencil-square" size={20} />} title="Set status" divider onPress={() => nav.toast('Status is not part of this mock')} />
          <ListRow leading={<Icon name="star-o" size={20} />} title="Favorites" divider onPress={() => nav.toast('Favorites live on Home')} />
          <ListRow leading={<Icon name="snippet" size={20} />} title="Snippets" onPress={() => nav.toast('Snippets are out of v1 scope')} />
        </Card>
        <div style={{ fontSize: 13, fontWeight: 600, color: 'var(--gl-text-color-subtle)', padding: '8px 4px 0' }}>Settings</div>
        <Card>
          <ListRow leading={<Icon name="eye" size={20} />} title="Appearance" meta={themeLabel[nav.theme]} divider onPress={nav.cycleTheme} />
          <ListRow leading={<Icon name="code" size={20} />} title="Code options" subtitle="Wrap lines · syntax theme" divider onPress={() => nav.toast('Code options are not part of this mock')} />
          <ListRow leading={<Icon name="shield" size={20} />} title="Biometric app lock" meta="On" divider onPress={() => nav.toast('Biometric lock is device-managed')} />
          <ListRow leading={<Icon name="notifications" size={20} />} title="Notifications" subtitle="Polling · near-real-time" divider onPress={() => nav.toast('Notification channels are not part of this mock')} />
          <ListRow leading={<Icon name="external-link" size={20} />} title="External links" meta="In-app" onPress={() => nav.toast('Link handling is not part of this mock')} />
        </Card>
        <Card>
          <ListRow leading={<Icon name="leave" size={20} color="var(--gl-status-danger-color)" />} title={<span style={{ color: 'var(--gl-text-color-danger)' }}>Sign out of gitlab.com</span>} trailing={null} onPress={() => setSignout(true)} />
        </Card>
        <div style={{ textAlign: 'center', fontSize: 12, color: 'var(--gl-text-color-subtle)', padding: 8 }}>Gitsune 1.0.0 · open source</div>
      </div>
      <Drawer open={switcherOpen} onClose={nav.closeSwitcher} title="Accounts">
        {accounts.map((a, i) => (
          <ListRow key={a.handle} divider leading={<Avatar name={a.name} size={36} />} title={<b style={{ color: 'var(--gl-text-color-heading)' }}>{a.name}</b>}
            subtitle={<span style={{ fontFamily: 'var(--gs-font-mono)' }}>{a.handle} · {a.host}</span>}
            meta={a.unread ? <span style={{ background: 'var(--gs-action-color)', color: '#fff', borderRadius: 9999, fontSize: 11, fontWeight: 600, padding: '1px 7px' }}>{a.unread}</span> : null}
            trailing={a.active ? <Icon name="check" size={18} color="var(--gs-action-color)" /> : null}
            onPress={() => { nav.closeSwitcher(); if (!a.active) nav.toast(`Switched to ${a.host}`); }} />
        ))}
        <ListRow leading={<span style={{ width: 36, height: 36, borderRadius: '50%', border: '1.5px dashed var(--gl-border-color-strong)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--gl-icon-color-subtle)' }}><Icon name="plus" size={18} /></span>} title="Add account" subtitle="Any GitLab instance" trailing={null} onPress={() => { nav.closeSwitcher(); nav.signOut(); }} />
      </Drawer>
      <Modal open={signout} onClose={() => setSignout(false)} title="Sign out?" actions={<><Button size="sm" onClick={() => setSignout(false)}>Cancel</Button><Button size="sm" variant="danger" onClick={() => { setSignout(false); nav.signOut(); }}>Sign out</Button></>}>
        {user.host} will be removed from this device. Your offline cache is cleared.
      </Modal>
    </div>
  );
}
