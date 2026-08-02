import React from 'react';
import { Badge } from '../../components/display/Badge.jsx';
import { Label } from '../../components/display/Label.jsx';
import { Avatar } from '../../components/display/Avatar.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { Drawer } from '../../components/overlays/Drawer.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { NavHeader } from './PhoneShell.jsx';
import { issue } from './data.js';

const Comment = ({ author, time, children }) => (
  <div style={{ display: 'flex', gap: 10, padding: '12px 16px', borderBottom: '1px solid var(--gl-border-color-subtle)', background: 'var(--gs-surface-card)' }}>
    <Avatar name={author} size={32} />
    <div style={{ flex: 1, minWidth: 0 }}>
      <div style={{ fontSize: 13 }}><b style={{ color: 'var(--gl-text-color-heading)' }}>{author}</b> <span style={{ color: 'var(--gl-text-color-subtle)', fontSize: 12 }}>· {time}</span></div>
      <div style={{ fontSize: 14, marginTop: 4, lineHeight: '20px' }}>{children}</div>
    </div>
  </div>
);

/** Surface 3 — issue thread: state badge, metadata pill row, inline events, pinned composer, actions sheet. */
export function IssueView({ nav }) {
  const [sheet, setSheet] = React.useState(false);
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column', position: 'relative' }}>
      <NavHeader title={`${issue.project} · ${issue.ref}`} mono onBack={nav.pop} right={<button onClick={() => setSheet(true)} aria-label="Issue actions" style={{ all: 'unset', cursor: 'pointer', color: 'var(--gs-action-color)', padding: 6 }}><Icon name="ellipsis_h" size={18} /></button>} />
      <div style={{ flex: 1, overflowY: 'auto', background: 'var(--gs-surface-subtle)' }}>
        <div style={{ padding: '4px 16px 12px', background: 'var(--gs-surface-app)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
            <Badge variant="success" icon="issue-open-m">Open</Badge>
            <span style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)' }}>{issue.author} opened {issue.time}</span>
          </div>
          <h2 style={{ fontSize: 'var(--gl-font-size-600)', marginBottom: 10 }}>{issue.title}</h2>
          <div style={{ display: 'flex', gap: 6, flexWrap: 'nowrap', overflowX: 'auto', paddingBottom: 2 }}>
            {issue.labels.map(l => <Label key={l.name} name={l.name} color={l.color} />)}
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--gl-text-color-subtle)', background: 'var(--gs-token-bg)', borderRadius: 9999, padding: '2px 8px', whiteSpace: 'nowrap' }}><Icon name="milestone" size={12} />{issue.milestone}</span>
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--gl-text-color-subtle)', background: 'var(--gs-token-bg)', borderRadius: 9999, padding: '2px 8px', whiteSpace: 'nowrap' }}><Icon name="assignee" size={12} />Marin</span>
          </div>
        </div>
        <Comment author={issue.author} time={issue.time}>{issue.body}</Comment>
        {issue.events.map((e, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '8px 16px 8px 24px', fontSize: 12, color: 'var(--gl-text-color-subtle)' }}><Icon name={e.icon} size={14} />{e.text} · {e.time}</div>
        ))}
        {issue.comments.map((c, i) => <Comment key={i} author={c.author} time={c.time}>{c.text}</Comment>)}
      </div>
      <div style={{ flex: 'none', display: 'flex', alignItems: 'center', gap: 8, padding: '8px 16px', borderTop: '1px solid var(--gl-border-color-default)', background: 'var(--gs-surface-app)' }}>
        <div style={{ flex: 1, background: 'var(--gs-surface-inset)', border: '1px solid var(--gl-border-color-default)', borderRadius: 9999, padding: '10px 14px', fontSize: 14, color: 'var(--gl-text-color-disabled)' }}>Add a comment…</div>
        <button aria-label="Send" onClick={() => nav.toast('Commenting is not part of this mock')} style={{ all: 'unset', cursor: 'pointer', width: 40, height: 40, borderRadius: '50%', background: 'var(--gs-action-color)', color: '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center' }}><Icon name="paper-airplane" size={18} /></button>
      </div>
      <Drawer open={sheet} onClose={() => setSheet(false)} title="Issue actions">
        <ListRow leading={<Icon name="assignee" size={20} />} title="Assignees" meta="Marin" divider onPress={() => setSheet(false)} />
        <ListRow leading={<Icon name="labels" size={20} />} title="Labels" meta="2" divider onPress={() => setSheet(false)} />
        <ListRow leading={<Icon name="milestone" size={20} />} title="Milestone" meta="v1.0" divider onPress={() => setSheet(false)} />
        <ListRow leading={<Icon name="issue-close" size={20} color="var(--gl-status-danger-color)" />} title={<span style={{ color: 'var(--gl-text-color-danger)' }}>Close issue</span>} trailing={null} onPress={() => { setSheet(false); nav.toast('Issue closed', { action: 'Undo' }); }} />
      </Drawer>
    </div>
  );
}
