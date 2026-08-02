// Sample data for the Gitsune UI kit. All copy follows the voice rules: plain, factual, GitLab nouns.
export const user = { name: 'Marin Katsuragi', handle: '@marin', host: 'gitlab.com' };
export const accounts = [
  { name: 'Marin Katsuragi', handle: '@marin', host: 'gitlab.com', active: true },
  { name: 'marin-k', handle: '@marin-k', host: 'git.kitsune.dev', unread: 2 },
];
export const myWork = [
  { id: 'issues', hue: 'issues', icon: 'issues', label: 'Issues', count: 12 },
  { id: 'mrs', hue: 'mrs', icon: 'merge-request', label: 'Merge Requests', count: 4 },
  { id: 'todos', hue: 'todos', icon: 'todo-done', label: 'To-Do List', count: 7 },
  { id: 'pipelines', hue: 'pipelines', icon: 'rocket', label: 'Pipelines', count: 2 },
  { id: 'projects', hue: 'projects', icon: 'project', label: 'Projects', count: 9 },
  { id: 'groups', hue: 'groups', icon: 'group', label: 'Groups', count: 3 },
];
export const favorites = [
  { name: 'gitsune / app', desc: 'Flutter client for GitLab', stars: 214 },
  { name: 'gitsune / website', desc: 'Marketing site and docs', stars: 38 },
];
export const todos = [
  { id: 1, icon: 'merge-request', color: 'var(--gl-status-info-color)', project: 'gitsune/app', ref: '!142', title: 'Add instance switcher sheet', note: 'Ade requested your review', time: '13h', reason: 'Review requested' },
  { id: 2, icon: 'issues', color: 'var(--gl-status-success-color)', project: 'gitsune/app', ref: '#233', title: 'Sign-in: PAT fallback hidden behind wrong affordance', note: 'Priya assigned you', time: '1d', reason: 'Assigned' },
  { id: 3, icon: 'status_failed', color: 'var(--gl-status-danger-color)', project: 'gitsune/app', ref: '#88101', title: 'Pipeline failed on main', note: 'test: widget_test.dart · 2 failed', time: '2d', reason: 'Pipeline failed' },
  { id: 4, icon: 'comment', color: 'var(--gl-status-neutral-color)', project: 'gitsune/website', ref: '#87', title: 'Document self-hosted OAuth registration', note: '@marin can you confirm the redirect URI?', time: '2d', reason: 'Mentioned' },
  { id: 5, icon: 'merge-request', color: 'var(--gl-status-info-color)', project: 'gitsune/app', ref: '!139', title: 'Offline read cache for issues', note: 'Tom approved your merge request', time: '4d', reason: 'Review requested' },
];
export const todoReasons = ['All', 'Assigned', 'Mentioned', 'Review requested', 'Pipeline failed'];
export const mr = {
  ref: '!142', project: 'gitsune / app', title: 'Add instance switcher sheet',
  source: 'feat/instance-switcher', target: 'main',
  author: 'Ade Ogunleye', time: 'updated 2h ago',
  labels: [{ name: 'workflow::in review', color: '#7b58cf' }, { name: 'mobile', color: '#1f75cb' }],
  milestone: 'v1.0', unresolved: 2, approvalsRequired: 2,
  approvers: ['Marin Katsuragi', 'Priya Sharma'], approvedBy: ['Priya Sharma'],
  commits: 6, filesChanged: 4,
  pipelines: [
    { id: '#88123', status: 'running', note: 'build · feat/instance-switcher', time: '2h ago' },
    { id: '#88119', status: 'success', note: 'test · feat/instance-switcher', time: '5h ago' },
    { id: '#88101', status: 'failed', note: 'test · feat/instance-switcher', time: '1d ago' },
  ],
};
export const diffFiles = [
  { path: 'lib/ui/switcher_sheet.dart', icon: 'dart', add: 86, del: 12 },
  { path: 'lib/state/accounts.dart', icon: 'dart', add: 24, del: 3 },
  { path: 'lib/ui/profile_screen.dart', icon: 'dart', add: 9, del: 41 },
  { path: 'test/switcher_sheet_test.dart', icon: 'dart', add: 52, del: 0 },
];
export const hunk = {
  file: 'lib/ui/switcher_sheet.dart', header: '@@ -18,7 +18,15 @@ class SwitcherSheet extends StatelessWidget {',
  lines: [
    { o: 18, n: 18, t: ' ', code: '  Widget build(BuildContext context) {' },
    { o: 19, n: 19, t: ' ', code: '    return DraggableSheet(' },
    { o: 20, n: null, t: '-', code: '      child: AccountList(accounts: accounts),' },
    { o: null, n: 20, t: '+', code: '      child: Column(children: [' },
    { o: null, n: 21, t: '+', code: '        for (final a in accounts)' },
    { o: null, n: 22, t: '+', code: '          AccountRow(' },
    { o: null, n: 23, t: '+', code: '            account: a,' },
    { o: null, n: 24, t: '+', code: '            host: a.host, // always visible' },
    { o: null, n: 25, t: '+', code: '          ),' },
    { o: null, n: 26, t: '+', code: '        AddAccountRow(),' },
    { o: null, n: 27, t: '+', code: '      ]),' },
    { o: 21, n: 28, t: ' ', code: '    );' },
    { o: 22, n: 29, t: ' ', code: '  }' },
  ],
  comment: { author: 'Marin Katsuragi', time: '3h ago', line: 24, text: 'Host on every row — this is the safety feature for multi-instance users. Can we truncate long self-hosted domains with a leading ellipsis instead?' },
};
export const issue = {
  ref: '#233', project: 'gitsune / app', title: 'Sign-in: PAT fallback hidden behind wrong affordance',
  author: 'Priya Sharma', time: '2 days ago',
  labels: [{ name: 'bug', color: '#dd2b0e' }, { name: 'workflow::triage', color: '#7b58cf' }],
  milestone: 'v1.0',
  body: 'The Personal Access Token entry currently sits behind the instance field\u2019s edit icon. Per the auth blueprint it belongs behind a \u201cHaving trouble signing in?\u201d affordance under the primary action.',
  events: [{ icon: 'labels', text: 'Priya added the workflow::triage label', time: '2d' }],
  comments: [
    { author: 'Marin Katsuragi', time: '1d ago', text: 'Agreed. OAuth stays the only visible path on the primary screen; PAT is a fallback, not a peer.' },
    { author: 'Tom Chen', time: '20h ago', text: 'Will pick this up after !142 merges.' },
  ],
};
export const fileTree = [
  { name: 'android', type: 'folder' },
  { name: 'ios', type: 'folder' },
  { name: 'lib', type: 'folder' },
  { name: 'test', type: 'folder' },
  { name: '.gitlab-ci.yml', icon: 'gitlab' },
  { name: 'pubspec.yaml', icon: 'settings' },
  { name: 'README.md', icon: 'markdown' },
];
export const libTree = [
  { name: 'state', type: 'folder' },
  { name: 'ui', type: 'folder' },
  { name: 'api.dart', icon: 'dart' },
  { name: 'main.dart', icon: 'dart' },
];
export const dartFile = {
  path: 'lib/main.dart', branch: 'main',
  lines: [
    [['k', 'import'], ['s', " 'package:flutter/material.dart'"], ['p', ';']],
    [['k', 'import'], ['s', " 'state/accounts.dart'"], ['p', ';']],
    [],
    [['k', 'void'], ['f', ' main'], ['p', '() {']],
    [['p', '  '], ['f', 'runApp'], ['p', '('], ['k', 'const'], ['p', ' GitsuneApp());']],
    [['p', '}']],
    [],
    [['c', '// Instance-URL-first: no project-operated servers, ever.']],
    [['k', 'class'], ['t', ' GitsuneApp'], ['k', ' extends'], ['t', ' StatelessWidget'], ['p', ' {']],
    [['p', '  @'], ['t', 'override']],
    [['t', '  Widget'], ['f', ' build'], ['p', '(BuildContext context) {']],
    [['k', '    return'], ['f', ' MaterialApp'], ['p', '(']],
    [['p', '      title: '], ['s', "'Gitsune'"], ['p', ',']],
    [['p', '      theme: buildTheme(Brightness.light),']],
    [['p', '    );']],
    [['p', '  }']],
    [['p', '}']],
  ],
};
