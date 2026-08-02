import React from 'react';
import { Button } from '../../components/actions/Button.jsx';
import { Alert } from '../../components/feedback/Alert.jsx';
import { Icon } from '../../components/core/Icon.jsx';

/** Surface 1 — instance-URL-first sign-in (Bluesky shape, GitLab language). */
export function SignIn({ nav }) {
  const [url, setUrl] = React.useState('gitlab.com');
  const [error, setError] = React.useState(false);
  const [pat, setPat] = React.useState(false);
  const go = () => {
    if (!/gitlab|kitsune/.test(url)) { setError(true); return; }
    setError(false); nav.signIn();
  };
  const field = { display: 'flex', alignItems: 'center', gap: 10, background: 'var(--gs-surface-inset)', border: '1px solid var(--gl-border-color-default)', borderRadius: 'var(--gs-radius-control,10px)', padding: '0 14px', height: 50 };
  return (
    <div style={{ flex: 1, overflowY: 'auto', padding: '0 20px', display: 'flex', flexDirection: 'column' }}>
      <div style={{ padding: '48px 0 40px', textAlign: 'center' }}>
        <div style={{ font: '600 40px/1 var(--gs-font-ui)', letterSpacing: '-0.01em', color: 'var(--gs-color-brand-500)' }}>Gitsune</div>
        <div style={{ marginTop: 8, color: 'var(--gl-text-color-subtle)', fontSize: 14 }}>GitLab in your pocket</div>
      </div>
      <label style={{ fontSize: 13, fontWeight: 600, color: 'var(--gl-text-color-heading)', marginBottom: 6 }}>GitLab instance</label>
      <div style={field}>
        <Icon name="earth" size={18} color="var(--gl-icon-color-subtle)" />
        <input value={url} onChange={e => { setUrl(e.target.value); setError(false); }} spellCheck="false" autoCapitalize="none" style={{ all: 'unset', flex: 1, font: '400 15px var(--gs-font-mono)', color: 'var(--gl-text-color-default)' }} aria-label="GitLab instance URL" />
        <Icon name="pencil" size={16} color="var(--gl-icon-color-subtle)" />
      </div>
      <div style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)', margin: '8px 2px 20px' }}>gitlab.com or any self-hosted instance. Sign-in opens in your browser.</div>
      {error ? <Alert variant="danger" title="Unable to reach this instance" style={{ marginBottom: 16 }}>{url || 'This URL'} does not answer as a GitLab instance. Check the address and try again.</Alert> : null}
      <Button variant="confirm" size="lg" block onClick={go}>Continue</Button>
      <button onClick={() => setPat(!pat)} style={{ all: 'unset', cursor: 'pointer', textAlign: 'center', padding: 14, color: 'var(--gs-link-color)', fontSize: 14 }}>Having trouble signing in?</button>
      {pat ? (
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          <div style={field}>
            <Icon name="token" size={18} color="var(--gl-icon-color-subtle)" />
            <input placeholder="Personal Access Token" style={{ all: 'unset', flex: 1, font: '400 15px var(--gs-font-mono)', color: 'var(--gl-text-color-default)' }} aria-label="Personal Access Token" />
          </div>
          <div style={{ fontSize: 12, color: 'var(--gl-text-color-subtle)', padding: '0 2px' }}>For instances where OAuth app registration is unavailable. Needs the <span style={{ fontFamily: 'var(--gs-font-mono)' }}>api</span> scope.</div>
        </div>
      ) : null}
      <div style={{ marginTop: 'auto', padding: '24px 0 16px', textAlign: 'center', fontSize: 12, color: 'var(--gl-text-color-subtle)' }}>Open source · No project-operated servers, ever</div>
    </div>
  );
}
