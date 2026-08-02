import React from 'react';
import { Icon } from '../../components/core/Icon.jsx';
import { Avatar } from '../../components/display/Avatar.jsx';
import { ListRow } from '../../components/navigation/ListRow.jsx';
import { NavHeader } from './PhoneShell.jsx';
import { fileTree, libTree, dartFile } from './data.js';

const C = { k: 'var(--gs-code-keyword)', s: 'var(--gs-code-string)', c: 'var(--gs-code-comment)', f: 'var(--gs-code-function)', n: 'var(--gs-code-number)', t: 'var(--gl-text-color-heading)', p: 'var(--gl-text-color-default)' };
const BranchChip = ({ children }) => <span style={{ font: '12px/16px var(--gs-font-mono)', background: 'var(--gs-token-bg)', borderRadius: 4, padding: '2px 6px', display: 'inline-flex', alignItems: 'center', gap: 4 }}><Icon name="branch" size={12} />{children}</span>;

/** Surface 5 — code browser: drill-down list with file-type icons, then GitLab Mono file view. */
export function CodeBrowser({ nav }) {
  const [path, setPath] = React.useState([]); // [] → root, ['lib'] → lib/, ['lib','main.dart'] → file
  const inFile = path.length === 2;
  const tree = path.length === 0 ? fileTree : libTree;
  const [wrap, setWrap] = React.useState(false);
  return (
    <div style={{ flex: 1, minHeight: 0, display: 'flex', flexDirection: 'column' }}>
      <NavHeader mono title={inFile ? dartFile.path : path.length ? `gitsune/app/${path[0]}` : 'gitsune / app'} onBack={() => path.length ? setPath(path.slice(0, -1)) : nav.pop()}
        right={inFile ? <button onClick={() => setWrap(!wrap)} aria-label="Toggle wrap" style={{ all: 'unset', cursor: 'pointer', padding: 6, color: wrap ? 'var(--gs-action-color)' : 'var(--gl-icon-color-subtle)' }}><Icon name="list-indent" size={18} /></button> : null} />
      {!inFile ? (
        <div style={{ flex: 1, overflowY: 'auto' }}>
          {path.length === 0 ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '4px 16px 14px' }}>
              <Avatar name="gitsune app" entity="project" size={40} />
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 600, color: 'var(--gl-text-color-heading)', fontFamily: 'var(--gs-font-mono)', fontSize: 14 }}>gitsune / app</div>
                <div style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)', marginTop: 2 }}>Flutter client for GitLab · 214 stars</div>
              </div>
              <BranchChip>main</BranchChip>
            </div>
          ) : null}
          {tree.map((f, i) => (
            <ListRow key={f.name} divider={i < tree.length - 1}
              leading={f.type === 'folder' ? <Icon name="folder-o" size={18} color="var(--gl-status-info-color)" /> : <Icon name={f.icon} file size={18} />}
              title={<span style={{ fontFamily: 'var(--gs-font-mono)', fontSize: 13 }}>{f.name}{f.type === 'folder' ? '/' : ''}</span>}
              onPress={() => f.type === 'folder' ? (path.length === 0 && f.name === 'lib' ? setPath(['lib']) : nav.toast('Only lib/ is populated in this mock')) : (f.name.endsWith('.dart') ? setPath(['lib', f.name]) : nav.toast('Only main.dart is populated in this mock'))} />
          ))}
        </div>
      ) : (
        <div style={{ flex: 1, overflow: 'auto', background: 'var(--gs-code-bg)' }}>
          <table style={{ borderCollapse: 'collapse', width: '100%' }}><tbody>
            {dartFile.lines.map((line, i) => (
              <tr key={i}>
                <td style={{ font: '11px/20px var(--gs-font-mono)', color: 'var(--gl-text-color-disabled)', textAlign: 'right', padding: '0 10px', width: 28, userSelect: 'none', verticalAlign: 'top' }}>{i + 1}</td>
                <td style={{ font: '12px/20px var(--gs-font-mono)', whiteSpace: wrap ? 'pre-wrap' : 'pre', paddingRight: 16 }}>{line.map(([cls, text], j) => <span key={j} style={{ color: C[cls] }}>{text}</span>)}</td>
              </tr>
            ))}
          </tbody></table>
          <div style={{ padding: '10px 16px 16px', fontSize: 12, color: 'var(--gl-text-color-subtle)', display: 'flex', gap: 14 }}>
            <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}><Icon name="history" size={14} />History</span>
            <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}><Icon name="doc-versions" size={14} />Blame</span>
            <span style={{ display: 'inline-flex', gap: 4, alignItems: 'center' }}><Icon name="external-link" size={14} />View on web</span>
          </div>
        </div>
      )}
    </div>
  );
}
