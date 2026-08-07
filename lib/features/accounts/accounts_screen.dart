import 'package:flutter/material.dart';

import '../../core/auth/account_sessions.dart';
import '../../core/auth/active_account.dart';
import '../../core/auth/token_store.dart';
import '../../core/database/app_database.dart';
import '../../core/glass/glass_overlays.dart';
import '../../core/icons/gs_icons.dart';
import '../../core/network/account_key.dart';
import '../../core/theme/app_theme.dart';

/// The E13.2 account management surface over the E2.6 session registry:
/// every registered session is one row showing avatar, username, and - on
/// every row, since the same username can exist on many instances - its
/// host. Tapping a row switches to it (one [ActiveAccountStore.setActive]
/// call), the grip handle drags rows into a new switcher order, the trash
/// button removes after confirmation, and "Add account" opens the existing
/// E2.7 sign-in flow.
class AccountsScreen extends StatefulWidget {
  const AccountsScreen({
    super.key,
    required this.sessions,
    required this.activeAccount,
    this.tokenStore,
    this.onAddAccount,
  });

  final AccountSessions sessions;
  final ActiveAccountStore activeAccount;

  /// Clears a removed account's persisted tokens; null skips that step.
  final TokenStore? tokenStore;

  /// Opens the sign-in flow (E2.7); adding an account is signing in.
  final VoidCallback? onAddAccount;

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late final Stream<List<AccountWithProfile>> _accounts = widget.sessions
      .watchAllWithProfiles();

  Future<void> _reorder(
    List<AccountWithProfile> rows,
    int oldIndex,
    int newIndex,
  ) {
    final keys = [for (final row in rows) accountKeyOf(row.account)];
    keys.insert(newIndex, keys.removeAt(oldIndex));
    return widget.sessions.reorder(keys);
  }

  Future<void> _remove(
    List<AccountWithProfile> rows,
    AccountWithProfile row,
  ) async {
    final key = accountKeyOf(row.account);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _RemoveAccountDialog(title: accountTitle(row)),
    );
    if (confirmed != true) return;
    await widget.sessions.remove(key);
    await widget.tokenStore?.clear(key);
    if (widget.activeAccount.value == key) {
      final remaining = [
        for (final other in rows)
          if (accountKeyOf(other.account) != key) accountKeyOf(other.account),
      ];
      await widget.activeAccount.setActive(
        remaining.isEmpty ? null : remaining.first,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: gs.surfaceApp,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                tooltip: 'Back',
                onPressed: Navigator.of(context).pop,
                icon: GsIcon(
                  GsIconGlyph.chevronLeft,
                  size: 20,
                  color: gs.accent,
                ),
              )
            : null,
        title: Text(
          'Accounts',
          style: theme.textTheme.titleMedium?.copyWith(color: gs.textHeading),
        ),
      ),
      body: StreamBuilder<List<AccountWithProfile>>(
        stream: _accounts,
        builder: (context, snapshot) {
          final rows = snapshot.data;
          if (rows == null) return const SizedBox.shrink();
          return ListenableBuilder(
            listenable: widget.activeAccount,
            builder: (context, _) => ReorderableListView(
              buildDefaultDragHandles: false,
              onReorderItem: (oldIndex, newIndex) =>
                  _reorder(rows, oldIndex, newIndex),
              footer: Column(
                children: [
                  if (rows.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'No accounts yet. Add one to get started.',
                        style: gs.caption.copyWith(color: gs.textSubtle),
                      ),
                    ),
                  ListTile(
                    leading: GsIcon(GsIconGlyph.plus, size: 20, color: gs.link),
                    title: Text(
                      'Add account',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: gs.link,
                      ),
                    ),
                    onTap: widget.onAddAccount,
                  ),
                ],
              ),
              children: [
                for (final (index, row) in rows.indexed)
                  _accountRow(context, rows, row, index),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _accountRow(
    BuildContext context,
    List<AccountWithProfile> rows,
    AccountWithProfile row,
    int index,
  ) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final key = accountKeyOf(row.account);
    final active = widget.activeAccount.value == key;
    return ListTile(
      key: ValueKey('account-${key.instanceHost}-${key.accountId}'),
      leading: AccountAvatar(
        label: row.profile?.username ?? key.accountId,
        avatarUrl: row.profile?.avatarUrl,
      ),
      title: Text(accountTitle(row), overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key.instanceHost,
            overflow: TextOverflow.ellipsis,
            style: gs.mono.copyWith(fontSize: 12, color: gs.textSubtle),
          ),
          if (row.account.needsReauth)
            Text(
              'Sign-in required',
              style: gs.caption.copyWith(color: gs.feedbackWarningText),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (active) GsIcon(GsIconGlyph.check, size: 16, color: gs.accent),
          IconButton(
            tooltip: 'Remove account',
            onPressed: () => _remove(rows, row),
            icon: GsIcon(GsIconGlyph.remove, size: 16, color: gs.textSubtle),
          ),
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              key: ValueKey('drag-${key.instanceHost}-${key.accountId}'),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: GsIcon(GsIconGlyph.grip, size: 16, color: gs.textSubtle),
            ),
          ),
        ],
      ),
      onTap: () => widget.activeAccount.setActive(key),
    );
  }
}

/// The row's display name: the cached username when the current-user
/// repository has one, otherwise the account id the registry knows.
String accountTitle(AccountWithProfile row) => row.profile != null
    ? '@${row.profile!.username}'
    : 'Account ${row.account.accountId}';

AccountKey accountKeyOf(Account account) => AccountKey(
  instanceHost: account.instanceHost,
  accountId: account.accountId,
);

/// Opens the quick-switch sheet; picking an account resolves with one
/// [ActiveAccountStore.setActive] call - a single state change.
Future<void> showAccountSwitchSheet(
  BuildContext context, {
  required AccountSessions sessions,
  required ActiveAccountStore activeAccount,
}) async {
  final selected = await showModalBottomSheet<AccountKey>(
    context: context,
    isScrollControlled: true,
    builder: (context) =>
        AccountSwitchSheet(sessions: sessions, activeAccount: activeAccount),
  );
  if (selected != null) await activeAccount.setActive(selected);
}

/// The quick-switch sheet body: every registered session with avatar,
/// username, and host, the active one checked; tapping pops with that
/// account's key.
class AccountSwitchSheet extends StatefulWidget {
  const AccountSwitchSheet({
    super.key,
    required this.sessions,
    required this.activeAccount,
  });

  final AccountSessions sessions;
  final ActiveAccountStore activeAccount;

  @override
  State<AccountSwitchSheet> createState() => _AccountSwitchSheetState();
}

class _AccountSwitchSheetState extends State<AccountSwitchSheet> {
  late final Stream<List<AccountWithProfile>> _accounts = widget.sessions
      .watchAllWithProfiles();

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    return StreamBuilder<List<AccountWithProfile>>(
      stream: _accounts,
      builder: (context, snapshot) {
        final rows = snapshot.data ?? const <AccountWithProfile>[];
        final availableHeight = MediaQuery.sizeOf(context).height * 0.8;
        final desiredHeight = 88.0 + rows.length * 65;
        final height = desiredHeight < availableHeight
            ? desiredHeight
            : availableHeight;
        return SizedBox(
          height: height,
          child: GlassBottomSheet(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text(
                    'Switch account',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: gs.textHeading),
                  ),
                ),
                Expanded(
                  // ListTile ink must draw on a Material above the glass
                  // surface's own background box.
                  child: Material(
                    type: MaterialType.transparency,
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 12),
                      itemCount: rows.length,
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final key = accountKeyOf(row.account);
                        return ListTile(
                          key: ValueKey(
                            'switch-${key.instanceHost}-${key.accountId}',
                          ),
                          leading: AccountAvatar(
                            label: row.profile?.username ?? key.accountId,
                            avatarUrl: row.profile?.avatarUrl,
                            size: 32,
                          ),
                          title: Text(
                            accountTitle(row),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            key.instanceHost,
                            overflow: TextOverflow.ellipsis,
                            style: gs.mono.copyWith(
                              fontSize: 12,
                              color: gs.textSubtle,
                            ),
                          ),
                          trailing: widget.activeAccount.value == key
                              ? GsIcon(
                                  GsIconGlyph.check,
                                  size: 16,
                                  color: gs.accent,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(key),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A circular account avatar: the network image when a URL is cached, else
/// (or on image failure) the label's initial on an inset surface.
class AccountAvatar extends StatefulWidget {
  const AccountAvatar({
    super.key,
    required this.label,
    this.avatarUrl,
    this.size = 40,
  });

  final String label;
  final String? avatarUrl;
  final double size;

  @override
  State<AccountAvatar> createState() => _AccountAvatarState();
}

class _AccountAvatarState extends State<AccountAvatar> {
  bool _imageFailed = false;

  @override
  Widget build(BuildContext context) {
    final gs = Theme.of(context).extension<GsTheme>()!;
    final url = _imageFailed ? null : widget.avatarUrl;
    final initial = widget.label.isEmpty ? '?' : widget.label[0].toUpperCase();
    return CircleAvatar(
      radius: widget.size / 2,
      backgroundColor: gs.surfaceInset,
      foregroundImage: url == null ? null : NetworkImage(url),
      onForegroundImageError: url == null
          ? null
          : (_, _) => setState(() => _imageFailed = true),
      child: Text(
        initial,
        style: TextStyle(
          fontSize: widget.size * 0.45,
          color: gs.textDefault,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RemoveAccountDialog extends StatelessWidget {
  const _RemoveAccountDialog({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gs = theme.extension<GsTheme>()!;
    return GlassModal(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remove $title?',
              style: theme.textTheme.titleMedium?.copyWith(
                color: gs.textHeading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Signs the account out of this device and deletes its local '
              'data. Nothing changes on the GitLab instance.',
              style: theme.textTheme.bodyMedium?.copyWith(color: gs.textSubtle),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: gs.statusDanger,
                    foregroundColor: gs.onAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
