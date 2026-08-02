import React from 'react';
import { Badge } from '../../components/display/Badge.jsx';
import { Label } from '../../components/display/Label.jsx';
import { Avatar } from '../../components/display/Avatar.jsx';
import { Card } from '../../components/containers/Card.jsx';
import { Tabs } from '../../components/containers/Tabs.jsx';
import { Button } from '../../components/actions/Button.jsx';
import { Icon } from '../../components/core/Icon.jsx';
import { CiIcon } from '../../components/core/CiIcon.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { NavHeader } from './PhoneShell.jsx';
import { DiffList } from './DiffView.jsx';
import { mr } from './data.js';

const BranchChip = ({ children }) => <span style={{ font: '12px/16px var(--gs-font-mono)', background: 'var(--gs-token-bg)', borderRadius: 4, padding: '2px 6px', maxWidth: 150, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', display: 'inline-block', verticalAlign: 'bottom' }}>{children}</span>;

/** Surface 4 — MR view: state badge, branch chips, approvals, pipelines, and the orange merge box. */
export function MergeRequest({ nav, params }) {
  const [tab, setTab] = React.useState((params && params.tab) || 'overview');
  const [approved, setApproved] = React.useState(false);
  const approvals = mr.approvedBy.length + (approved ? 1 : 0);
  const ready = approvals >= mr.approvalsRequired;
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <NavHeader title={`${mr.project} · ${mr.ref}`} mono onBack={nav.pop} right={<button onClick={() => nav.toast('Actions are not part of this mock')} aria-label="More" style={{ all: 'unset', cursor: 'pointer', color: 'var(--gs-action-color)', padding: 6 }}><Icon name="ellipsis_h" size={18} /></button>} />
      <div style={{ padding: '4px 16px 12px' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
          <Badge variant="success" icon="merge-request-open">Open</Badge>
          <span style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)' }}>{mr.author} · {mr.time}</span>
        </div>
        <h2 style={{ fontSize: 'var(--gl-font-size-600)', marginBottom: 8 }}>{mr.title}</h2>
        <div style={{ fontSize: 13, color: 'var(--gl-text-color-subtle)', marginBottom: 8 }}><BranchChip>{mr.source}</BranchChip> <Icon name="long-arrow" size={14} style={{ display: 'inline-block', verticalAlign: '-2px' }} /> <BranchChip>{mr.target}</BranchChip></div>
        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
          {mr.labels.map(l => <Label key={l.name} name={l.name} color={l.color} />)}
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, fontSize: 12, color: 'var(--gl-text-color-subtle)' }}><Icon name="milestone" size={12} />{mr.milestone}</span>
        </div>
      </div>
      <Tabs tabs={[{ id: 'overview', label: 'Overview' }, { id: 'changes', label: 'Changes', count: mr.filesChanged }, { id: 'pipelines', label: 'Pipelines' }]} active={tab} onChange={setTab} />
      <div style={{ flex: 1, overflowY: 'auto', background: 'var(--gs-surface-subtle)' }}>
        {tab === 'overview' ? (
          <div style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
            <Card>
              <ListRow leading={<CiIcon status="running" size={20} />} title={<span>Pipeline <span style={{ fontFamily: 'var(--gs-font-mono)' }}>#88123</span> running</span>} subtitle="Merge blocked until the pipeline passes" trailing={null} divider />
              <ListRow leading={<Icon name="approval" size={20} color={ready ? 'var(--gl-status-success-color)' : 'var(--gl-icon-color-subtle)'} />} title={`Approvals · ${approvals} of ${mr.approvalsRequired}`} subtitle={approved ? 'Priya, you' : 'Priya'} trailing={<span style={{ display: 'flex' }}>{mr.approvers.map(a => <Avatar key={a} name={a} size={24} style={{ marginLeft: -6, boxShadow: '0 0 0 2px var(--gs-surface-card)' }} />)}</span>} divider />
              <ListRow leading={<Icon name="comments" size={20} color="var(--gl-status-warning-color)" />} title={`${mr.unresolved} unresolved threads`} subtitle="Resolve all threads before merging" trailing={null} />
            </Card>
            <Card padded>
              <div style={{ display: 'flex', gap: 8 }}>
                <Button variant="confirm" block disabled={!ready} style={{ borderRadius: '4px 0 0 4px' }}>Merge</Button>
                <Button variant="confirm" iconOnly icon="chevron-down" label="Merge options" style={{ marginLeft: -8, borderRadius: '0 4px 4px 0', boxShadow: 'inset 1px 0 0 rgba(255,255,255,.3)' }} />
              </div>
              <div style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)', marginTop: 8, textAlign: 'center' }}>{ready ? 'All requirements met' : 'Blocked: pipeline running · approvals incomplete · unresolved threads'}</div>
              {!approved ? <Button icon="approval" block style={{ marginTop: 10 }} onClick={() => { setApproved(true); nav.toast('Merge request approved'); }}>Approve</Button> : null}
            </Card>
            <Card>
              <ListRow leading={<Icon name="commit" size={18} />} title={`${mr.commits} commits`} meta="" divider onPress={() => nav.toast('Commit list is not part of this mock')} />
              <ListRow leading={<Icon name="doc-changes" size={18} />} title={`${mr.filesChanged} files changed`} onPress={() => setTab('changes')} />
            </Card>
          </div>
        ) : tab === 'changes' ? <DiffList nav={nav} /> : (
          <div style={{ padding: 16 }}>
            <Card>
              {mr.pipelines.map((p, i) => (
                <ListRow key={p.id} leading={<CiIcon status={p.status} size={20} />} title={<span><span style={{ fontFamily: 'var(--gs-font-mono)' }}>{p.id}</span> · {p.status}</span>} subtitle={p.note} meta={p.time} divider={i < mr.pipelines.length - 1}
                  trailing={p.status === 'failed' ? <Button size="sm" icon="retry" onClick={() => nav.toast('Pipeline retried')}>Retry</Button> : p.status === 'running' ? <Button size="sm" variant="ghost" icon="cancel" label="Cancel" iconOnly onClick={() => nav.toast('Pipeline canceled')} /> : null} />
              ))}
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}
