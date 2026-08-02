import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { Avatar } from '../../components/display/Avatar.jsx';
import { Button } from '../../components/actions/Button.jsx';
import { hunk, diffFiles } from './data.js';

const mono = { fontFamily: 'var(--gs-font-mono)', fontSize: 12, lineHeight: '20px' };

/** Surface 4b — diff review: hunk-per-file, green/red line backgrounds, line-level comments. */
export function DiffList({ nav }) {
  const [open, setOpen] = React.useState(diffFiles[0].path);
  return (
    <div style={{ paddingBottom: 60, position: 'relative' }}>
      {diffFiles.map(f => (
        <div key={f.path}>
          <button onClick={() => setOpen(open === f.path ? null : f.path)} style={{ all: 'unset', boxSizing: 'border-box', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 8, width: '100%', padding: '10px 16px', background: 'var(--gs-surface-card)', borderBottom: '1px solid var(--gl-border-color-subtle)', borderTop: '1px solid var(--gl-border-color-subtle)' }}>
            <Icon name="chevron-down" size={14} style={{ transform: open === f.path ? 'none' : 'rotate(-90deg)' }} color="var(--gl-icon-color-subtle)" />
            <Icon name={f.icon} file size={16} />
            <span style={{ ...mono, flex: 1, minWidth: 0, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', direction: 'rtl', textAlign: 'left' }}>{f.path}</span>
            <span style={{ ...mono, color: 'var(--gl-status-success-color)' }}>+{f.add}</span>
            <span style={{ ...mono, color: 'var(--gl-status-danger-color)' }}>−{f.del}</span>
          </button>
          {open === f.path ? <Hunk nav={nav} /> : null}
        </div>
      ))}
      <div style={{ position: 'sticky', bottom: 12, display: 'flex', justifyContent: 'center', pointerEvents: 'none' }}>
        <Button size="sm" icon="file-tree" style={{ pointerEvents: 'auto', boxShadow: 'var(--gl-shadow-md)', borderRadius: 9999 }} onClick={() => nav.toast('Jump to file is not part of this mock')}>Jump to file</Button>
      </div>
    </div>
  );
}

function Hunk({ nav }) {
  const [reply, setReply] = React.useState(false);
  return (
    <div style={{ background: 'var(--gs-surface-card)', overflowX: 'auto' }}>
      <div style={{ ...mono, padding: '6px 12px', color: 'var(--gl-text-color-subtle)', background: 'var(--gs-surface-inset)' }}>{hunk.header}</div>
      <table style={{ borderCollapse: 'collapse', width: '100%' }}>
        <tbody>
          {hunk.lines.map((l, i) => {
            const bg = l.t === '+' ? 'var(--gs-diff-add-bg)' : l.t === '-' ? 'var(--gs-diff-del-bg)' : 'transparent';
            const numBg = l.t === '+' ? 'var(--gs-diff-add-strong)' : l.t === '-' ? 'var(--gs-diff-del-strong)' : 'var(--gs-surface-inset)';
            return (
              <React.Fragment key={i}>
                <tr>
                  <td style={{ ...mono, background: numBg, color: 'var(--gl-text-color-subtle)', textAlign: 'right', padding: '0 6px', width: 30, userSelect: 'none' }}>{l.o || ''}</td>
                  <td style={{ ...mono, background: numBg, color: 'var(--gl-text-color-subtle)', textAlign: 'right', padding: '0 6px', width: 30, userSelect: 'none' }}>{l.n || ''}</td>
                  <td style={{ ...mono, background: bg, whiteSpace: 'pre', padding: '0 10px 0 4px' }}><span style={{ color: l.t === '+' ? 'var(--gl-status-success-color)' : l.t === '-' ? 'var(--gl-status-danger-color)' : 'var(--gl-text-color-subtle)', userSelect: 'none' }}>{l.t}</span> {l.code}</td>
                </tr>
                {hunk.comment && l.n === hunk.comment.line ? (
                  <tr><td colSpan={3} style={{ padding: '8px 12px', borderTop: '1px solid var(--gl-border-color-subtle)', borderBottom: '1px solid var(--gl-border-color-subtle)' }}>
                    <div style={{ display: 'flex', gap: 10 }}>
                      <Avatar name={hunk.comment.author} size={28} />
                      <div style={{ flex: 1 }}>
                        <div style={{ fontSize: 13 }}><b style={{ color: 'var(--gl-text-color-heading)' }}>{hunk.comment.author}</b> <span style={{ color: 'var(--gl-text-color-subtle)', fontSize: 12 }}>· {hunk.comment.time}</span></div>
                        <div style={{ fontSize: 13, marginTop: 2 }}>{hunk.comment.text}</div>
                        <div style={{ display: 'flex', gap: 12, marginTop: 8 }}>
                          <Button size="sm" variant="ghost" icon="comment" onClick={() => setReply(true)}>{reply ? 'Replying…' : 'Reply'}</Button>
                          <Button size="sm" variant="ghost" icon="check-circle" onClick={() => nav.toast('Thread resolved')}>Resolve thread</Button>
                        </div>
                      </div>
                    </div>
                  </td></tr>
                ) : null}
              </React.Fragment>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}
