import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { Drawer } from '../../components/overlays/Drawer.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { LargeTitle } from './PhoneShell.jsx';
import { todos as allTodos, todoReasons } from './data.js';

/** Surface 6 — To-Do inbox: entity glyph rows, quick Done with undo Toast, filter sheet, purple empty state. */
export function TodoInbox({ nav }) {
  const [done, setDone] = React.useState([]);
  const [filter, setFilter] = React.useState('All');
  const [sheet, setSheet] = React.useState(false);
  const items = allTodos.filter(t => !done.includes(t.id) && (filter === 'All' || t.reason === filter));
  const markDone = id => { setDone(d => [...d, id]); nav.toast('To-do marked as done', { action: 'Undo', onAction: () => setDone(d => d.filter(x => x !== id)) }); };
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <LargeTitle title="To-Do List" right={
        <button onClick={() => setSheet(true)} style={{ all: 'unset', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4, color: 'var(--gs-action-color)', fontSize: 15, padding: 6 }}><Icon name="filter" size={16} />{filter === 'All' ? 'Filter' : filter}</button>} />
      <div style={{ flex: 1, overflowY: 'auto', paddingBottom: 88 }}>
        {items.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '64px 40px' }}>
            <img src="../../assets/illustrations/empty-todos-all-done-md.svg" alt="" style={{ width: 160 }} />
            <div style={{ fontWeight: 600, fontSize: 16, color: 'var(--gl-text-color-heading)', marginTop: 16 }}>All done</div>
            <div style={{ color: 'var(--gl-text-color-subtle)', fontSize: 13, marginTop: 4 }}>New to-dos land here in near real time — honestly not instant.</div>
          </div>
        ) : items.map(t => (
          <ListRow key={t.id} divider onPress={() => nav.push(t.icon === 'issues' ? 'issue' : 'mr')}
            leading={<Icon name={t.icon} size={20} color={t.color} />}
            title={t.title}
            subtitle={<span><span style={{ fontFamily: 'var(--gs-font-mono)' }}>{t.project} {t.ref}</span> · {t.note}</span>}
            meta={t.time}
            trailing={<button onClick={e => { e.stopPropagation(); markDone(t.id); }} aria-label="Mark as done" style={{ all: 'unset', cursor: 'pointer', width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', borderRadius: 8, color: 'var(--gl-status-success-color)' }}><Icon name="check-circle" size={20} /></button>} />
        ))}
        {items.length > 0 ? <div style={{ padding: '14px 16px', fontSize: 12, color: 'var(--gl-text-color-subtle)', textAlign: 'center' }}>Swipe right to mark done · swipe left to snooze</div> : null}
      </div>
      <Drawer open={sheet} onClose={() => setSheet(false)} title="Filter by reason">
        {todoReasons.map(r => <ListRow key={r} divider={r !== 'Pipeline failed'} onPress={() => { setFilter(r); setSheet(false); }} title={r} trailing={filter === r ? <Icon name="check" size={16} color="var(--gs-action-color)" /> : null} />)}
      </Drawer>
    </div>
  );
}
