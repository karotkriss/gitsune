import React from 'react';
import { PhoneShell } from './PhoneShell.jsx';
import { TabBar } from '../../components/navigation/TabBar.jsx';
import { Toast } from '../../components/feedback/Toast.jsx';
import { SignIn } from './SignIn.jsx';
import { Home } from './Home.jsx';
import { TodoInbox } from './TodoInbox.jsx';
import { MergeRequest } from './MergeRequest.jsx';
import { IssueView } from './IssueView.jsx';
import { Explore } from './Explore.jsx';
import { Profile } from './Profile.jsx';
import { CodeBrowser } from './CodeBrowser.jsx';

const TABS = ['home', 'todos', 'explore', 'profile'];
const PUSHED = { mr: MergeRequest, issue: IssueView, code: CodeBrowser };

/** The whole Gitsune app as one interactive component. screen: home|todos|explore|profile|signin|mr|issue|code. */
export function GitsuneApp({ screen = 'home', theme: themeProp = 'dark' }) {
  const [signedIn, setSignedIn] = React.useState(screen !== 'signin');
  const [tab, setTab] = React.useState(TABS.includes(screen) ? screen : 'home');
  const [stack, setStack] = React.useState(PUSHED[screen] ? [{ screen }] : []);
  const [theme, setTheme] = React.useState(themeProp);
  const [toast, setToast] = React.useState(null);
  const [switcher, setSwitcher] = React.useState(false);
  React.useEffect(() => { setTheme(themeProp); }, [themeProp]);
  React.useEffect(() => {
    setSignedIn(screen !== 'signin');
    setTab(TABS.includes(screen) ? screen : 'home');
    setStack(PUSHED[screen] ? [{ screen }] : []);
  }, [screen]);
  React.useEffect(() => { if (!toast) return; const t = setTimeout(() => setToast(null), 3500); return () => clearTimeout(t); }, [toast]);
  const nav = {
    theme,
    cycleTheme: () => setTheme(t => t === 'light' ? 'dark' : t === 'dark' ? 'auto' : 'light'),
    push: (s, params) => setStack(st => [...st, { screen: s, params }]),
    pop: () => setStack(st => st.slice(0, -1)),
    toast: (msg, opts) => setToast({ msg, ...(opts || {}) }),
    openSwitcher: () => { setTab('profile'); setStack([]); setSwitcher(true); },
    closeSwitcher: () => setSwitcher(false),
    signIn: () => { setSignedIn(true); setTab('home'); setStack([]); },
    signOut: () => { setSignedIn(false); setStack([]); setSwitcher(false); },
    openWork: id => {
      if (id === 'todos') setTab('todos');
      else if (id === 'mrs') nav.push('mr');
      else if (id === 'issues') nav.push('issue');
      else if (id === 'pipelines') nav.push('mr', { tab: 'pipelines' });
      else if (id === 'projects') nav.push('code');
      else nav.toast('Groups are not part of this mock');
    },
  };
  const effTheme = theme === 'auto' ? (typeof window !== 'undefined' && window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light') : theme;
  const top = stack[stack.length - 1];
  let el;
  if (!signedIn) el = <SignIn nav={nav} />;
  else if (top) { const S = PUSHED[top.screen] || MergeRequest; el = <S key={stack.length} nav={nav} params={top.params} />; }
  else el = tab === 'home' ? <Home nav={nav} /> : tab === 'todos' ? <TodoInbox nav={nav} /> : tab === 'explore' ? <Explore nav={nav} /> : <Profile nav={nav} switcherOpen={switcher} />;
  return (
    <PhoneShell theme={effTheme} tabbar={signedIn && !top ? <TabBar active={tab} onChange={setTab} items={[
      { id: 'home', icon: 'home', label: 'Home' },
      { id: 'todos', icon: 'todo-done', label: 'To-Dos', badge: 5 },
      { id: 'explore', icon: 'compass', label: 'Explore' },
      { id: 'profile', icon: 'user', label: 'Profile' }]} /> : null}>
      {el}
      {toast ? <div style={{ position: 'absolute', left: 16, right: 16, bottom: signedIn && !top ? 88 : 12, zIndex: 60 }}><Toast action={toast.action} onAction={() => { toast.onAction && toast.onAction(); setToast(null); }}>{toast.msg}</Toast></div> : null}
    </PhoneShell>
  );
}
