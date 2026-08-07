import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/account_key.dart';

/// The switcher state (E13.2): which registered session the app acts as.
///
/// Switching accounts is exactly one [setActive] call - the single state
/// change the account switcher and quick-switch sheet perform - and the
/// choice persists across launches. Value semantics mirror the registry:
/// null means no account is active (fresh install, or the active account was
/// removed and none remain).
class ActiveAccountStore extends ValueNotifier<AccountKey?> {
  ActiveAccountStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(null);

  static const _key = 'gitsune.activeAccount';

  final FlutterSecureStorage _storage;

  /// Loads the persisted choice. An unreadable or corrupt value loads as
  /// null rather than failing startup.
  Future<void> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return;
      final decoded = jsonDecode(raw);
      if (decoded case {
        'instanceHost': final String instanceHost,
        'accountId': final String accountId,
      }) {
        value = AccountKey(instanceHost: instanceHost, accountId: accountId);
      }
    } catch (_) {}
  }

  /// The single state change: updates listeners synchronously, then
  /// persists.
  Future<void> setActive(AccountKey? account) async {
    value = account;
    await _storage.write(
      key: _key,
      value: account == null
          ? null
          : jsonEncode({
              'instanceHost': account.instanceHost,
              'accountId': account.accountId,
            }),
    );
  }
}
