// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalCacheEntriesTable extends LocalCacheEntries
    with TableInfo<$LocalCacheEntriesTable, LocalCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cacheKeyMeta = const VerificationMeta(
    'cacheKey',
  );
  @override
  late final GeneratedColumn<String> cacheKey = GeneratedColumn<String>(
    'cache_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    cacheKey,
    value,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('cache_key')) {
      context.handle(
        _cacheKeyMeta,
        cacheKey.isAcceptableOrUnknown(data['cache_key']!, _cacheKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_cacheKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId, cacheKey};
  @override
  LocalCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCacheEntry(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      cacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cache_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocalCacheEntriesTable createAlias(String alias) {
    return $LocalCacheEntriesTable(attachedDatabase, alias);
  }
}

class LocalCacheEntry extends DataClass implements Insertable<LocalCacheEntry> {
  final String instanceHost;
  final String accountId;
  final String cacheKey;
  final String value;
  final DateTime updatedAt;
  const LocalCacheEntry({
    required this.instanceHost,
    required this.accountId,
    required this.cacheKey,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['cache_key'] = Variable<String>(cacheKey);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCacheEntriesCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      cacheKey: Value(cacheKey),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCacheEntry(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      cacheKey: serializer.fromJson<String>(json['cacheKey']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'cacheKey': serializer.toJson<String>(cacheKey),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalCacheEntry copyWith({
    String? instanceHost,
    String? accountId,
    String? cacheKey,
    String? value,
    DateTime? updatedAt,
  }) => LocalCacheEntry(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    cacheKey: cacheKey ?? this.cacheKey,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocalCacheEntry copyWithCompanion(LocalCacheEntriesCompanion data) {
    return LocalCacheEntry(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      cacheKey: data.cacheKey.present ? data.cacheKey.value : this.cacheKey,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCacheEntry(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(instanceHost, accountId, cacheKey, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCacheEntry &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.cacheKey == this.cacheKey &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class LocalCacheEntriesCompanion extends UpdateCompanion<LocalCacheEntry> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String> cacheKey;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalCacheEntriesCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.cacheKey = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCacheEntriesCompanion.insert({
    required String instanceHost,
    required String accountId,
    required String cacheKey,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       cacheKey = Value(cacheKey),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<LocalCacheEntry> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? cacheKey,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (cacheKey != null) 'cache_key': cacheKey,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCacheEntriesCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String>? cacheKey,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocalCacheEntriesCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      cacheKey: cacheKey ?? this.cacheKey,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (cacheKey.present) {
      map['cache_key'] = Variable<String>(cacheKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCacheEntriesCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('cacheKey: $cacheKey, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CurrentUserProfilesTable extends CurrentUserProfiles
    with TableInfo<$CurrentUserProfilesTable, CurrentUserProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrentUserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    username,
    name,
    avatarUrl,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'current_user_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrentUserProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId};
  @override
  CurrentUserProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrentUserProfile(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CurrentUserProfilesTable createAlias(String alias) {
    return $CurrentUserProfilesTable(attachedDatabase, alias);
  }
}

class CurrentUserProfile extends DataClass
    implements Insertable<CurrentUserProfile> {
  final String instanceHost;
  final String accountId;
  final String username;
  final String name;
  final String? avatarUrl;
  final DateTime updatedAt;
  const CurrentUserProfile({
    required this.instanceHost,
    required this.accountId,
    required this.username,
    required this.name,
    this.avatarUrl,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['username'] = Variable<String>(username);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CurrentUserProfilesCompanion toCompanion(bool nullToAbsent) {
    return CurrentUserProfilesCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      username: Value(username),
      name: Value(name),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      updatedAt: Value(updatedAt),
    );
  }

  factory CurrentUserProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrentUserProfile(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      username: serializer.fromJson<String>(json['username']),
      name: serializer.fromJson<String>(json['name']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'username': serializer.toJson<String>(username),
      'name': serializer.toJson<String>(name),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CurrentUserProfile copyWith({
    String? instanceHost,
    String? accountId,
    String? username,
    String? name,
    Value<String?> avatarUrl = const Value.absent(),
    DateTime? updatedAt,
  }) => CurrentUserProfile(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    username: username ?? this.username,
    name: name ?? this.name,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CurrentUserProfile copyWithCompanion(CurrentUserProfilesCompanion data) {
    return CurrentUserProfile(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      username: data.username.present ? data.username.value : this.username,
      name: data.name.present ? data.name.value : this.name,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrentUserProfile(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    username,
    name,
    avatarUrl,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrentUserProfile &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.username == this.username &&
          other.name == this.name &&
          other.avatarUrl == this.avatarUrl &&
          other.updatedAt == this.updatedAt);
}

class CurrentUserProfilesCompanion extends UpdateCompanion<CurrentUserProfile> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String> username;
  final Value<String> name;
  final Value<String?> avatarUrl;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CurrentUserProfilesCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.username = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrentUserProfilesCompanion.insert({
    required String instanceHost,
    required String accountId,
    required String username,
    required String name,
    this.avatarUrl = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       username = Value(username),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<CurrentUserProfile> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? username,
    Expression<String>? name,
    Expression<String>? avatarUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (username != null) 'username': username,
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrentUserProfilesCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String>? username,
    Value<String>? name,
    Value<String?>? avatarUrl,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CurrentUserProfilesCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      username: username ?? this.username,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrentUserProfilesCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('username: $username, ')
          ..write('name: $name, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaginationCursorsTable extends PaginationCursors
    with TableInfo<$PaginationCursorsTable, PaginationCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaginationCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _collectionKeyMeta = const VerificationMeta(
    'collectionKey',
  );
  @override
  late final GeneratedColumn<String> collectionKey = GeneratedColumn<String>(
    'collection_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorUriMeta = const VerificationMeta(
    'cursorUri',
  );
  @override
  late final GeneratedColumn<String> cursorUri = GeneratedColumn<String>(
    'cursor_uri',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    collectionKey,
    cursorUri,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pagination_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaginationCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('collection_key')) {
      context.handle(
        _collectionKeyMeta,
        collectionKey.isAcceptableOrUnknown(
          data['collection_key']!,
          _collectionKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionKeyMeta);
    }
    if (data.containsKey('cursor_uri')) {
      context.handle(
        _cursorUriMeta,
        cursorUri.isAcceptableOrUnknown(data['cursor_uri']!, _cursorUriMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorUriMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    instanceHost,
    accountId,
    collectionKey,
  };
  @override
  PaginationCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaginationCursor(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      collectionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_key'],
      )!,
      cursorUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor_uri'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PaginationCursorsTable createAlias(String alias) {
    return $PaginationCursorsTable(attachedDatabase, alias);
  }
}

class PaginationCursor extends DataClass
    implements Insertable<PaginationCursor> {
  final String instanceHost;
  final String accountId;
  final String collectionKey;
  final String cursorUri;
  final DateTime updatedAt;
  const PaginationCursor({
    required this.instanceHost,
    required this.accountId,
    required this.collectionKey,
    required this.cursorUri,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['collection_key'] = Variable<String>(collectionKey);
    map['cursor_uri'] = Variable<String>(cursorUri);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PaginationCursorsCompanion toCompanion(bool nullToAbsent) {
    return PaginationCursorsCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      collectionKey: Value(collectionKey),
      cursorUri: Value(cursorUri),
      updatedAt: Value(updatedAt),
    );
  }

  factory PaginationCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaginationCursor(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      collectionKey: serializer.fromJson<String>(json['collectionKey']),
      cursorUri: serializer.fromJson<String>(json['cursorUri']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'collectionKey': serializer.toJson<String>(collectionKey),
      'cursorUri': serializer.toJson<String>(cursorUri),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PaginationCursor copyWith({
    String? instanceHost,
    String? accountId,
    String? collectionKey,
    String? cursorUri,
    DateTime? updatedAt,
  }) => PaginationCursor(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    collectionKey: collectionKey ?? this.collectionKey,
    cursorUri: cursorUri ?? this.cursorUri,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PaginationCursor copyWithCompanion(PaginationCursorsCompanion data) {
    return PaginationCursor(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      collectionKey: data.collectionKey.present
          ? data.collectionKey.value
          : this.collectionKey,
      cursorUri: data.cursorUri.present ? data.cursorUri.value : this.cursorUri,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaginationCursor(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('collectionKey: $collectionKey, ')
          ..write('cursorUri: $cursorUri, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(instanceHost, accountId, collectionKey, cursorUri, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaginationCursor &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.collectionKey == this.collectionKey &&
          other.cursorUri == this.cursorUri &&
          other.updatedAt == this.updatedAt);
}

class PaginationCursorsCompanion extends UpdateCompanion<PaginationCursor> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String> collectionKey;
  final Value<String> cursorUri;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PaginationCursorsCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.collectionKey = const Value.absent(),
    this.cursorUri = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaginationCursorsCompanion.insert({
    required String instanceHost,
    required String accountId,
    required String collectionKey,
    required String cursorUri,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       collectionKey = Value(collectionKey),
       cursorUri = Value(cursorUri),
       updatedAt = Value(updatedAt);
  static Insertable<PaginationCursor> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? collectionKey,
    Expression<String>? cursorUri,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (collectionKey != null) 'collection_key': collectionKey,
      if (cursorUri != null) 'cursor_uri': cursorUri,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaginationCursorsCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String>? collectionKey,
    Value<String>? cursorUri,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PaginationCursorsCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      collectionKey: collectionKey ?? this.collectionKey,
      cursorUri: cursorUri ?? this.cursorUri,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (collectionKey.present) {
      map['collection_key'] = Variable<String>(collectionKey.value);
    }
    if (cursorUri.present) {
      map['cursor_uri'] = Variable<String>(cursorUri.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaginationCursorsCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('collectionKey: $collectionKey, ')
          ..write('cursorUri: $cursorUri, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoItemsTable extends TodoItems
    with TableInfo<$TodoItemsTable, TodoItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _todoIdMeta = const VerificationMeta('todoId');
  @override
  late final GeneratedColumn<int> todoId = GeneratedColumn<int>(
    'todo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectPathWithNamespaceMeta =
      const VerificationMeta('projectPathWithNamespace');
  @override
  late final GeneratedColumn<String> projectPathWithNamespace =
      GeneratedColumn<String>(
        'project_path_with_namespace',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorUsernameMeta = const VerificationMeta(
    'authorUsername',
  );
  @override
  late final GeneratedColumn<String> authorUsername = GeneratedColumn<String>(
    'author_username',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorAvatarUrlMeta = const VerificationMeta(
    'authorAvatarUrl',
  );
  @override
  late final GeneratedColumn<String> authorAvatarUrl = GeneratedColumn<String>(
    'author_avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionNameMeta = const VerificationMeta(
    'actionName',
  );
  @override
  late final GeneratedColumn<String> actionName = GeneratedColumn<String>(
    'action_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIidMeta = const VerificationMeta(
    'targetIid',
  );
  @override
  late final GeneratedColumn<int> targetIid = GeneratedColumn<int>(
    'target_iid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetTitleMeta = const VerificationMeta(
    'targetTitle',
  );
  @override
  late final GeneratedColumn<String> targetTitle = GeneratedColumn<String>(
    'target_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetUrlMeta = const VerificationMeta(
    'targetUrl',
  );
  @override
  late final GeneratedColumn<String> targetUrl = GeneratedColumn<String>(
    'target_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    todoId,
    projectPathWithNamespace,
    authorName,
    authorUsername,
    authorAvatarUrl,
    actionName,
    targetType,
    targetIid,
    targetTitle,
    targetUrl,
    body,
    state,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('todo_id')) {
      context.handle(
        _todoIdMeta,
        todoId.isAcceptableOrUnknown(data['todo_id']!, _todoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_todoIdMeta);
    }
    if (data.containsKey('project_path_with_namespace')) {
      context.handle(
        _projectPathWithNamespaceMeta,
        projectPathWithNamespace.isAcceptableOrUnknown(
          data['project_path_with_namespace']!,
          _projectPathWithNamespaceMeta,
        ),
      );
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_authorNameMeta);
    }
    if (data.containsKey('author_username')) {
      context.handle(
        _authorUsernameMeta,
        authorUsername.isAcceptableOrUnknown(
          data['author_username']!,
          _authorUsernameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorUsernameMeta);
    }
    if (data.containsKey('author_avatar_url')) {
      context.handle(
        _authorAvatarUrlMeta,
        authorAvatarUrl.isAcceptableOrUnknown(
          data['author_avatar_url']!,
          _authorAvatarUrlMeta,
        ),
      );
    }
    if (data.containsKey('action_name')) {
      context.handle(
        _actionNameMeta,
        actionName.isAcceptableOrUnknown(data['action_name']!, _actionNameMeta),
      );
    } else if (isInserting) {
      context.missing(_actionNameMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_iid')) {
      context.handle(
        _targetIidMeta,
        targetIid.isAcceptableOrUnknown(data['target_iid']!, _targetIidMeta),
      );
    }
    if (data.containsKey('target_title')) {
      context.handle(
        _targetTitleMeta,
        targetTitle.isAcceptableOrUnknown(
          data['target_title']!,
          _targetTitleMeta,
        ),
      );
    }
    if (data.containsKey('target_url')) {
      context.handle(
        _targetUrlMeta,
        targetUrl.isAcceptableOrUnknown(data['target_url']!, _targetUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_targetUrlMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId, todoId};
  @override
  TodoItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoItem(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      todoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}todo_id'],
      )!,
      projectPathWithNamespace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_path_with_namespace'],
      ),
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      )!,
      authorUsername: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_username'],
      )!,
      authorAvatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_avatar_url'],
      ),
      actionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_name'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetIid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_iid'],
      ),
      targetTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_title'],
      ),
      targetUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_url'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TodoItemsTable createAlias(String alias) {
    return $TodoItemsTable(attachedDatabase, alias);
  }
}

class TodoItem extends DataClass implements Insertable<TodoItem> {
  final String instanceHost;
  final String accountId;
  final int todoId;
  final String? projectPathWithNamespace;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String actionName;
  final String targetType;
  final int? targetIid;
  final String? targetTitle;
  final String targetUrl;
  final String body;
  final String state;
  final DateTime createdAt;
  const TodoItem({
    required this.instanceHost,
    required this.accountId,
    required this.todoId,
    this.projectPathWithNamespace,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.actionName,
    required this.targetType,
    this.targetIid,
    this.targetTitle,
    required this.targetUrl,
    required this.body,
    required this.state,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['todo_id'] = Variable<int>(todoId);
    if (!nullToAbsent || projectPathWithNamespace != null) {
      map['project_path_with_namespace'] = Variable<String>(
        projectPathWithNamespace,
      );
    }
    map['author_name'] = Variable<String>(authorName);
    map['author_username'] = Variable<String>(authorUsername);
    if (!nullToAbsent || authorAvatarUrl != null) {
      map['author_avatar_url'] = Variable<String>(authorAvatarUrl);
    }
    map['action_name'] = Variable<String>(actionName);
    map['target_type'] = Variable<String>(targetType);
    if (!nullToAbsent || targetIid != null) {
      map['target_iid'] = Variable<int>(targetIid);
    }
    if (!nullToAbsent || targetTitle != null) {
      map['target_title'] = Variable<String>(targetTitle);
    }
    map['target_url'] = Variable<String>(targetUrl);
    map['body'] = Variable<String>(body);
    map['state'] = Variable<String>(state);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TodoItemsCompanion toCompanion(bool nullToAbsent) {
    return TodoItemsCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      todoId: Value(todoId),
      projectPathWithNamespace: projectPathWithNamespace == null && nullToAbsent
          ? const Value.absent()
          : Value(projectPathWithNamespace),
      authorName: Value(authorName),
      authorUsername: Value(authorUsername),
      authorAvatarUrl: authorAvatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(authorAvatarUrl),
      actionName: Value(actionName),
      targetType: Value(targetType),
      targetIid: targetIid == null && nullToAbsent
          ? const Value.absent()
          : Value(targetIid),
      targetTitle: targetTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(targetTitle),
      targetUrl: Value(targetUrl),
      body: Value(body),
      state: Value(state),
      createdAt: Value(createdAt),
    );
  }

  factory TodoItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoItem(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      todoId: serializer.fromJson<int>(json['todoId']),
      projectPathWithNamespace: serializer.fromJson<String?>(
        json['projectPathWithNamespace'],
      ),
      authorName: serializer.fromJson<String>(json['authorName']),
      authorUsername: serializer.fromJson<String>(json['authorUsername']),
      authorAvatarUrl: serializer.fromJson<String?>(json['authorAvatarUrl']),
      actionName: serializer.fromJson<String>(json['actionName']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetIid: serializer.fromJson<int?>(json['targetIid']),
      targetTitle: serializer.fromJson<String?>(json['targetTitle']),
      targetUrl: serializer.fromJson<String>(json['targetUrl']),
      body: serializer.fromJson<String>(json['body']),
      state: serializer.fromJson<String>(json['state']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'todoId': serializer.toJson<int>(todoId),
      'projectPathWithNamespace': serializer.toJson<String?>(
        projectPathWithNamespace,
      ),
      'authorName': serializer.toJson<String>(authorName),
      'authorUsername': serializer.toJson<String>(authorUsername),
      'authorAvatarUrl': serializer.toJson<String?>(authorAvatarUrl),
      'actionName': serializer.toJson<String>(actionName),
      'targetType': serializer.toJson<String>(targetType),
      'targetIid': serializer.toJson<int?>(targetIid),
      'targetTitle': serializer.toJson<String?>(targetTitle),
      'targetUrl': serializer.toJson<String>(targetUrl),
      'body': serializer.toJson<String>(body),
      'state': serializer.toJson<String>(state),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TodoItem copyWith({
    String? instanceHost,
    String? accountId,
    int? todoId,
    Value<String?> projectPathWithNamespace = const Value.absent(),
    String? authorName,
    String? authorUsername,
    Value<String?> authorAvatarUrl = const Value.absent(),
    String? actionName,
    String? targetType,
    Value<int?> targetIid = const Value.absent(),
    Value<String?> targetTitle = const Value.absent(),
    String? targetUrl,
    String? body,
    String? state,
    DateTime? createdAt,
  }) => TodoItem(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    todoId: todoId ?? this.todoId,
    projectPathWithNamespace: projectPathWithNamespace.present
        ? projectPathWithNamespace.value
        : this.projectPathWithNamespace,
    authorName: authorName ?? this.authorName,
    authorUsername: authorUsername ?? this.authorUsername,
    authorAvatarUrl: authorAvatarUrl.present
        ? authorAvatarUrl.value
        : this.authorAvatarUrl,
    actionName: actionName ?? this.actionName,
    targetType: targetType ?? this.targetType,
    targetIid: targetIid.present ? targetIid.value : this.targetIid,
    targetTitle: targetTitle.present ? targetTitle.value : this.targetTitle,
    targetUrl: targetUrl ?? this.targetUrl,
    body: body ?? this.body,
    state: state ?? this.state,
    createdAt: createdAt ?? this.createdAt,
  );
  TodoItem copyWithCompanion(TodoItemsCompanion data) {
    return TodoItem(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      todoId: data.todoId.present ? data.todoId.value : this.todoId,
      projectPathWithNamespace: data.projectPathWithNamespace.present
          ? data.projectPathWithNamespace.value
          : this.projectPathWithNamespace,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      authorUsername: data.authorUsername.present
          ? data.authorUsername.value
          : this.authorUsername,
      authorAvatarUrl: data.authorAvatarUrl.present
          ? data.authorAvatarUrl.value
          : this.authorAvatarUrl,
      actionName: data.actionName.present
          ? data.actionName.value
          : this.actionName,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetIid: data.targetIid.present ? data.targetIid.value : this.targetIid,
      targetTitle: data.targetTitle.present
          ? data.targetTitle.value
          : this.targetTitle,
      targetUrl: data.targetUrl.present ? data.targetUrl.value : this.targetUrl,
      body: data.body.present ? data.body.value : this.body,
      state: data.state.present ? data.state.value : this.state,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoItem(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('todoId: $todoId, ')
          ..write('projectPathWithNamespace: $projectPathWithNamespace, ')
          ..write('authorName: $authorName, ')
          ..write('authorUsername: $authorUsername, ')
          ..write('authorAvatarUrl: $authorAvatarUrl, ')
          ..write('actionName: $actionName, ')
          ..write('targetType: $targetType, ')
          ..write('targetIid: $targetIid, ')
          ..write('targetTitle: $targetTitle, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('body: $body, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    todoId,
    projectPathWithNamespace,
    authorName,
    authorUsername,
    authorAvatarUrl,
    actionName,
    targetType,
    targetIid,
    targetTitle,
    targetUrl,
    body,
    state,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoItem &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.todoId == this.todoId &&
          other.projectPathWithNamespace == this.projectPathWithNamespace &&
          other.authorName == this.authorName &&
          other.authorUsername == this.authorUsername &&
          other.authorAvatarUrl == this.authorAvatarUrl &&
          other.actionName == this.actionName &&
          other.targetType == this.targetType &&
          other.targetIid == this.targetIid &&
          other.targetTitle == this.targetTitle &&
          other.targetUrl == this.targetUrl &&
          other.body == this.body &&
          other.state == this.state &&
          other.createdAt == this.createdAt);
}

class TodoItemsCompanion extends UpdateCompanion<TodoItem> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<int> todoId;
  final Value<String?> projectPathWithNamespace;
  final Value<String> authorName;
  final Value<String> authorUsername;
  final Value<String?> authorAvatarUrl;
  final Value<String> actionName;
  final Value<String> targetType;
  final Value<int?> targetIid;
  final Value<String?> targetTitle;
  final Value<String> targetUrl;
  final Value<String> body;
  final Value<String> state;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TodoItemsCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.todoId = const Value.absent(),
    this.projectPathWithNamespace = const Value.absent(),
    this.authorName = const Value.absent(),
    this.authorUsername = const Value.absent(),
    this.authorAvatarUrl = const Value.absent(),
    this.actionName = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetIid = const Value.absent(),
    this.targetTitle = const Value.absent(),
    this.targetUrl = const Value.absent(),
    this.body = const Value.absent(),
    this.state = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoItemsCompanion.insert({
    required String instanceHost,
    required String accountId,
    required int todoId,
    this.projectPathWithNamespace = const Value.absent(),
    required String authorName,
    required String authorUsername,
    this.authorAvatarUrl = const Value.absent(),
    required String actionName,
    required String targetType,
    this.targetIid = const Value.absent(),
    this.targetTitle = const Value.absent(),
    required String targetUrl,
    required String body,
    required String state,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       todoId = Value(todoId),
       authorName = Value(authorName),
       authorUsername = Value(authorUsername),
       actionName = Value(actionName),
       targetType = Value(targetType),
       targetUrl = Value(targetUrl),
       body = Value(body),
       state = Value(state),
       createdAt = Value(createdAt);
  static Insertable<TodoItem> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<int>? todoId,
    Expression<String>? projectPathWithNamespace,
    Expression<String>? authorName,
    Expression<String>? authorUsername,
    Expression<String>? authorAvatarUrl,
    Expression<String>? actionName,
    Expression<String>? targetType,
    Expression<int>? targetIid,
    Expression<String>? targetTitle,
    Expression<String>? targetUrl,
    Expression<String>? body,
    Expression<String>? state,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (todoId != null) 'todo_id': todoId,
      if (projectPathWithNamespace != null)
        'project_path_with_namespace': projectPathWithNamespace,
      if (authorName != null) 'author_name': authorName,
      if (authorUsername != null) 'author_username': authorUsername,
      if (authorAvatarUrl != null) 'author_avatar_url': authorAvatarUrl,
      if (actionName != null) 'action_name': actionName,
      if (targetType != null) 'target_type': targetType,
      if (targetIid != null) 'target_iid': targetIid,
      if (targetTitle != null) 'target_title': targetTitle,
      if (targetUrl != null) 'target_url': targetUrl,
      if (body != null) 'body': body,
      if (state != null) 'state': state,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoItemsCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<int>? todoId,
    Value<String?>? projectPathWithNamespace,
    Value<String>? authorName,
    Value<String>? authorUsername,
    Value<String?>? authorAvatarUrl,
    Value<String>? actionName,
    Value<String>? targetType,
    Value<int?>? targetIid,
    Value<String?>? targetTitle,
    Value<String>? targetUrl,
    Value<String>? body,
    Value<String>? state,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TodoItemsCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      todoId: todoId ?? this.todoId,
      projectPathWithNamespace:
          projectPathWithNamespace ?? this.projectPathWithNamespace,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      actionName: actionName ?? this.actionName,
      targetType: targetType ?? this.targetType,
      targetIid: targetIid ?? this.targetIid,
      targetTitle: targetTitle ?? this.targetTitle,
      targetUrl: targetUrl ?? this.targetUrl,
      body: body ?? this.body,
      state: state ?? this.state,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (todoId.present) {
      map['todo_id'] = Variable<int>(todoId.value);
    }
    if (projectPathWithNamespace.present) {
      map['project_path_with_namespace'] = Variable<String>(
        projectPathWithNamespace.value,
      );
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (authorUsername.present) {
      map['author_username'] = Variable<String>(authorUsername.value);
    }
    if (authorAvatarUrl.present) {
      map['author_avatar_url'] = Variable<String>(authorAvatarUrl.value);
    }
    if (actionName.present) {
      map['action_name'] = Variable<String>(actionName.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetIid.present) {
      map['target_iid'] = Variable<int>(targetIid.value);
    }
    if (targetTitle.present) {
      map['target_title'] = Variable<String>(targetTitle.value);
    }
    if (targetUrl.present) {
      map['target_url'] = Variable<String>(targetUrl.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoItemsCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('todoId: $todoId, ')
          ..write('projectPathWithNamespace: $projectPathWithNamespace, ')
          ..write('authorName: $authorName, ')
          ..write('authorUsername: $authorUsername, ')
          ..write('authorAvatarUrl: $authorAvatarUrl, ')
          ..write('actionName: $actionName, ')
          ..write('targetType: $targetType, ')
          ..write('targetIid: $targetIid, ')
          ..write('targetTitle: $targetTitle, ')
          ..write('targetUrl: $targetUrl, ')
          ..write('body: $body, ')
          ..write('state: $state, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RepositoryTreeEntriesTable extends RepositoryTreeEntries
    with TableInfo<$RepositoryTreeEntriesTable, RepositoryTreeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepositoryTreeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentPathMeta = const VerificationMeta(
    'parentPath',
  );
  @override
  late final GeneratedColumn<String> parentPath = GeneratedColumn<String>(
    'parent_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entryTypeMeta = const VerificationMeta(
    'entryType',
  );
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
    'entry_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    projectId,
    ref,
    parentPath,
    name,
    path,
    entryType,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repository_tree_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepositoryTreeEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    } else if (isInserting) {
      context.missing(_refMeta);
    }
    if (data.containsKey('parent_path')) {
      context.handle(
        _parentPathMeta,
        parentPath.isAcceptableOrUnknown(data['parent_path']!, _parentPathMeta),
      );
    } else if (isInserting) {
      context.missing(_parentPathMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('entry_type')) {
      context.handle(
        _entryTypeMeta,
        entryType.isAcceptableOrUnknown(data['entry_type']!, _entryTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    instanceHost,
    accountId,
    projectId,
    ref,
    parentPath,
    name,
  };
  @override
  RepositoryTreeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepositoryTreeEntry(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      )!,
      parentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_path'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      entryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_type'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $RepositoryTreeEntriesTable createAlias(String alias) {
    return $RepositoryTreeEntriesTable(attachedDatabase, alias);
  }
}

class RepositoryTreeEntry extends DataClass
    implements Insertable<RepositoryTreeEntry> {
  final String instanceHost;
  final String accountId;
  final int projectId;
  final String ref;
  final String parentPath;
  final String name;
  final String path;
  final String entryType;
  final int position;
  const RepositoryTreeEntry({
    required this.instanceHost,
    required this.accountId,
    required this.projectId,
    required this.ref,
    required this.parentPath,
    required this.name,
    required this.path,
    required this.entryType,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['project_id'] = Variable<int>(projectId);
    map['ref'] = Variable<String>(ref);
    map['parent_path'] = Variable<String>(parentPath);
    map['name'] = Variable<String>(name);
    map['path'] = Variable<String>(path);
    map['entry_type'] = Variable<String>(entryType);
    map['position'] = Variable<int>(position);
    return map;
  }

  RepositoryTreeEntriesCompanion toCompanion(bool nullToAbsent) {
    return RepositoryTreeEntriesCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      projectId: Value(projectId),
      ref: Value(ref),
      parentPath: Value(parentPath),
      name: Value(name),
      path: Value(path),
      entryType: Value(entryType),
      position: Value(position),
    );
  }

  factory RepositoryTreeEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepositoryTreeEntry(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      ref: serializer.fromJson<String>(json['ref']),
      parentPath: serializer.fromJson<String>(json['parentPath']),
      name: serializer.fromJson<String>(json['name']),
      path: serializer.fromJson<String>(json['path']),
      entryType: serializer.fromJson<String>(json['entryType']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'projectId': serializer.toJson<int>(projectId),
      'ref': serializer.toJson<String>(ref),
      'parentPath': serializer.toJson<String>(parentPath),
      'name': serializer.toJson<String>(name),
      'path': serializer.toJson<String>(path),
      'entryType': serializer.toJson<String>(entryType),
      'position': serializer.toJson<int>(position),
    };
  }

  RepositoryTreeEntry copyWith({
    String? instanceHost,
    String? accountId,
    int? projectId,
    String? ref,
    String? parentPath,
    String? name,
    String? path,
    String? entryType,
    int? position,
  }) => RepositoryTreeEntry(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    projectId: projectId ?? this.projectId,
    ref: ref ?? this.ref,
    parentPath: parentPath ?? this.parentPath,
    name: name ?? this.name,
    path: path ?? this.path,
    entryType: entryType ?? this.entryType,
    position: position ?? this.position,
  );
  RepositoryTreeEntry copyWithCompanion(RepositoryTreeEntriesCompanion data) {
    return RepositoryTreeEntry(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      ref: data.ref.present ? data.ref.value : this.ref,
      parentPath: data.parentPath.present
          ? data.parentPath.value
          : this.parentPath,
      name: data.name.present ? data.name.value : this.name,
      path: data.path.present ? data.path.value : this.path,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepositoryTreeEntry(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('projectId: $projectId, ')
          ..write('ref: $ref, ')
          ..write('parentPath: $parentPath, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('entryType: $entryType, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    projectId,
    ref,
    parentPath,
    name,
    path,
    entryType,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepositoryTreeEntry &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.projectId == this.projectId &&
          other.ref == this.ref &&
          other.parentPath == this.parentPath &&
          other.name == this.name &&
          other.path == this.path &&
          other.entryType == this.entryType &&
          other.position == this.position);
}

class RepositoryTreeEntriesCompanion
    extends UpdateCompanion<RepositoryTreeEntry> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<int> projectId;
  final Value<String> ref;
  final Value<String> parentPath;
  final Value<String> name;
  final Value<String> path;
  final Value<String> entryType;
  final Value<int> position;
  final Value<int> rowid;
  const RepositoryTreeEntriesCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.ref = const Value.absent(),
    this.parentPath = const Value.absent(),
    this.name = const Value.absent(),
    this.path = const Value.absent(),
    this.entryType = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RepositoryTreeEntriesCompanion.insert({
    required String instanceHost,
    required String accountId,
    required int projectId,
    required String ref,
    required String parentPath,
    required String name,
    required String path,
    required String entryType,
    required int position,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       projectId = Value(projectId),
       ref = Value(ref),
       parentPath = Value(parentPath),
       name = Value(name),
       path = Value(path),
       entryType = Value(entryType),
       position = Value(position);
  static Insertable<RepositoryTreeEntry> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<int>? projectId,
    Expression<String>? ref,
    Expression<String>? parentPath,
    Expression<String>? name,
    Expression<String>? path,
    Expression<String>? entryType,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (projectId != null) 'project_id': projectId,
      if (ref != null) 'ref': ref,
      if (parentPath != null) 'parent_path': parentPath,
      if (name != null) 'name': name,
      if (path != null) 'path': path,
      if (entryType != null) 'entry_type': entryType,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RepositoryTreeEntriesCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<int>? projectId,
    Value<String>? ref,
    Value<String>? parentPath,
    Value<String>? name,
    Value<String>? path,
    Value<String>? entryType,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return RepositoryTreeEntriesCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      projectId: projectId ?? this.projectId,
      ref: ref ?? this.ref,
      parentPath: parentPath ?? this.parentPath,
      name: name ?? this.name,
      path: path ?? this.path,
      entryType: entryType ?? this.entryType,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (parentPath.present) {
      map['parent_path'] = Variable<String>(parentPath.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (entryType.present) {
      map['entry_type'] = Variable<String>(entryType.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepositoryTreeEntriesCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('projectId: $projectId, ')
          ..write('ref: $ref, ')
          ..write('parentPath: $parentPath, ')
          ..write('name: $name, ')
          ..write('path: $path, ')
          ..write('entryType: $entryType, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentlyViewedItemsTable extends RecentlyViewedItems
    with TableInfo<$RecentlyViewedItemsTable, RecentlyViewedItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentlyViewedItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastViewedAtMeta = const VerificationMeta(
    'lastViewedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastViewedAt = GeneratedColumn<DateTime>(
    'last_viewed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    itemType,
    projectId,
    itemId,
    payload,
    lastViewedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recently_viewed_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentlyViewedItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('last_viewed_at')) {
      context.handle(
        _lastViewedAtMeta,
        lastViewedAt.isAcceptableOrUnknown(
          data['last_viewed_at']!,
          _lastViewedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastViewedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    instanceHost,
    accountId,
    itemType,
    projectId,
    itemId,
  };
  @override
  RecentlyViewedItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentlyViewedItem(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      lastViewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_viewed_at'],
      )!,
    );
  }

  @override
  $RecentlyViewedItemsTable createAlias(String alias) {
    return $RecentlyViewedItemsTable(attachedDatabase, alias);
  }
}

class RecentlyViewedItem extends DataClass
    implements Insertable<RecentlyViewedItem> {
  final String instanceHost;
  final String accountId;
  final String itemType;
  final int projectId;
  final int itemId;
  final String payload;
  final DateTime lastViewedAt;
  const RecentlyViewedItem({
    required this.instanceHost,
    required this.accountId,
    required this.itemType,
    required this.projectId,
    required this.itemId,
    required this.payload,
    required this.lastViewedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['item_type'] = Variable<String>(itemType);
    map['project_id'] = Variable<int>(projectId);
    map['item_id'] = Variable<int>(itemId);
    map['payload'] = Variable<String>(payload);
    map['last_viewed_at'] = Variable<DateTime>(lastViewedAt);
    return map;
  }

  RecentlyViewedItemsCompanion toCompanion(bool nullToAbsent) {
    return RecentlyViewedItemsCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      itemType: Value(itemType),
      projectId: Value(projectId),
      itemId: Value(itemId),
      payload: Value(payload),
      lastViewedAt: Value(lastViewedAt),
    );
  }

  factory RecentlyViewedItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentlyViewedItem(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      projectId: serializer.fromJson<int>(json['projectId']),
      itemId: serializer.fromJson<int>(json['itemId']),
      payload: serializer.fromJson<String>(json['payload']),
      lastViewedAt: serializer.fromJson<DateTime>(json['lastViewedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'itemType': serializer.toJson<String>(itemType),
      'projectId': serializer.toJson<int>(projectId),
      'itemId': serializer.toJson<int>(itemId),
      'payload': serializer.toJson<String>(payload),
      'lastViewedAt': serializer.toJson<DateTime>(lastViewedAt),
    };
  }

  RecentlyViewedItem copyWith({
    String? instanceHost,
    String? accountId,
    String? itemType,
    int? projectId,
    int? itemId,
    String? payload,
    DateTime? lastViewedAt,
  }) => RecentlyViewedItem(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    itemType: itemType ?? this.itemType,
    projectId: projectId ?? this.projectId,
    itemId: itemId ?? this.itemId,
    payload: payload ?? this.payload,
    lastViewedAt: lastViewedAt ?? this.lastViewedAt,
  );
  RecentlyViewedItem copyWithCompanion(RecentlyViewedItemsCompanion data) {
    return RecentlyViewedItem(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      payload: data.payload.present ? data.payload.value : this.payload,
      lastViewedAt: data.lastViewedAt.present
          ? data.lastViewedAt.value
          : this.lastViewedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentlyViewedItem(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('itemType: $itemType, ')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('payload: $payload, ')
          ..write('lastViewedAt: $lastViewedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    itemType,
    projectId,
    itemId,
    payload,
    lastViewedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentlyViewedItem &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.itemType == this.itemType &&
          other.projectId == this.projectId &&
          other.itemId == this.itemId &&
          other.payload == this.payload &&
          other.lastViewedAt == this.lastViewedAt);
}

class RecentlyViewedItemsCompanion extends UpdateCompanion<RecentlyViewedItem> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String> itemType;
  final Value<int> projectId;
  final Value<int> itemId;
  final Value<String> payload;
  final Value<DateTime> lastViewedAt;
  final Value<int> rowid;
  const RecentlyViewedItemsCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.projectId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.payload = const Value.absent(),
    this.lastViewedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentlyViewedItemsCompanion.insert({
    required String instanceHost,
    required String accountId,
    required String itemType,
    required int projectId,
    required int itemId,
    required String payload,
    required DateTime lastViewedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       itemType = Value(itemType),
       projectId = Value(projectId),
       itemId = Value(itemId),
       payload = Value(payload),
       lastViewedAt = Value(lastViewedAt);
  static Insertable<RecentlyViewedItem> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? itemType,
    Expression<int>? projectId,
    Expression<int>? itemId,
    Expression<String>? payload,
    Expression<DateTime>? lastViewedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (itemType != null) 'item_type': itemType,
      if (projectId != null) 'project_id': projectId,
      if (itemId != null) 'item_id': itemId,
      if (payload != null) 'payload': payload,
      if (lastViewedAt != null) 'last_viewed_at': lastViewedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentlyViewedItemsCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String>? itemType,
    Value<int>? projectId,
    Value<int>? itemId,
    Value<String>? payload,
    Value<DateTime>? lastViewedAt,
    Value<int>? rowid,
  }) {
    return RecentlyViewedItemsCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      itemType: itemType ?? this.itemType,
      projectId: projectId ?? this.projectId,
      itemId: itemId ?? this.itemId,
      payload: payload ?? this.payload,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (lastViewedAt.present) {
      map['last_viewed_at'] = Variable<DateTime>(lastViewedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentlyViewedItemsCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('itemType: $itemType, ')
          ..write('projectId: $projectId, ')
          ..write('itemId: $itemId, ')
          ..write('payload: $payload, ')
          ..write('lastViewedAt: $lastViewedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HomeTileOrdersTable extends HomeTileOrders
    with TableInfo<$HomeTileOrdersTable, HomeTileOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HomeTileOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tileOrderMeta = const VerificationMeta(
    'tileOrder',
  );
  @override
  late final GeneratedColumn<String> tileOrder = GeneratedColumn<String>(
    'tile_order',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    tileOrder,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'home_tile_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<HomeTileOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('tile_order')) {
      context.handle(
        _tileOrderMeta,
        tileOrder.isAcceptableOrUnknown(data['tile_order']!, _tileOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_tileOrderMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId};
  @override
  HomeTileOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HomeTileOrder(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      tileOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tile_order'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HomeTileOrdersTable createAlias(String alias) {
    return $HomeTileOrdersTable(attachedDatabase, alias);
  }
}

class HomeTileOrder extends DataClass implements Insertable<HomeTileOrder> {
  final String instanceHost;
  final String accountId;
  final String tileOrder;
  final DateTime updatedAt;
  const HomeTileOrder({
    required this.instanceHost,
    required this.accountId,
    required this.tileOrder,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['tile_order'] = Variable<String>(tileOrder);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HomeTileOrdersCompanion toCompanion(bool nullToAbsent) {
    return HomeTileOrdersCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      tileOrder: Value(tileOrder),
      updatedAt: Value(updatedAt),
    );
  }

  factory HomeTileOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HomeTileOrder(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      tileOrder: serializer.fromJson<String>(json['tileOrder']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'tileOrder': serializer.toJson<String>(tileOrder),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HomeTileOrder copyWith({
    String? instanceHost,
    String? accountId,
    String? tileOrder,
    DateTime? updatedAt,
  }) => HomeTileOrder(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    tileOrder: tileOrder ?? this.tileOrder,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HomeTileOrder copyWithCompanion(HomeTileOrdersCompanion data) {
    return HomeTileOrder(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      tileOrder: data.tileOrder.present ? data.tileOrder.value : this.tileOrder,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HomeTileOrder(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('tileOrder: $tileOrder, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(instanceHost, accountId, tileOrder, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HomeTileOrder &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.tileOrder == this.tileOrder &&
          other.updatedAt == this.updatedAt);
}

class HomeTileOrdersCompanion extends UpdateCompanion<HomeTileOrder> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String> tileOrder;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HomeTileOrdersCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.tileOrder = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HomeTileOrdersCompanion.insert({
    required String instanceHost,
    required String accountId,
    required String tileOrder,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       tileOrder = Value(tileOrder),
       updatedAt = Value(updatedAt);
  static Insertable<HomeTileOrder> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? tileOrder,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (tileOrder != null) 'tile_order': tileOrder,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HomeTileOrdersCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String>? tileOrder,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return HomeTileOrdersCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      tileOrder: tileOrder ?? this.tileOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (tileOrder.present) {
      map['tile_order'] = Variable<String>(tileOrder.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HomeTileOrdersCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('tileOrder: $tileOrder, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReleaseEntriesTable extends ReleaseEntries
    with TableInfo<$ReleaseEntriesTable, ReleaseEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReleaseEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagNameMeta = const VerificationMeta(
    'tagName',
  );
  @override
  late final GeneratedColumn<String> tagName = GeneratedColumn<String>(
    'tag_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releasedAtMeta = const VerificationMeta(
    'releasedAt',
  );
  @override
  late final GeneratedColumn<DateTime> releasedAt = GeneratedColumn<DateTime>(
    'released_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetsJsonMeta = const VerificationMeta(
    'assetsJson',
  );
  @override
  late final GeneratedColumn<String> assetsJson = GeneratedColumn<String>(
    'assets_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    projectId,
    tagName,
    name,
    description,
    releasedAt,
    authorName,
    assetsJson,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'release_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReleaseEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('tag_name')) {
      context.handle(
        _tagNameMeta,
        tagName.isAcceptableOrUnknown(data['tag_name']!, _tagNameMeta),
      );
    } else if (isInserting) {
      context.missing(_tagNameMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('released_at')) {
      context.handle(
        _releasedAtMeta,
        releasedAt.isAcceptableOrUnknown(data['released_at']!, _releasedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_releasedAtMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('assets_json')) {
      context.handle(
        _assetsJsonMeta,
        assetsJson.isAcceptableOrUnknown(data['assets_json']!, _assetsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_assetsJsonMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    instanceHost,
    accountId,
    projectId,
    tagName,
  };
  @override
  ReleaseEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReleaseEntry(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      tagName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_name'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      releasedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}released_at'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      assetsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}assets_json'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $ReleaseEntriesTable createAlias(String alias) {
    return $ReleaseEntriesTable(attachedDatabase, alias);
  }
}

class ReleaseEntry extends DataClass implements Insertable<ReleaseEntry> {
  final String instanceHost;
  final String accountId;
  final int projectId;
  final String tagName;
  final String name;
  final String description;
  final DateTime releasedAt;
  final String? authorName;
  final String assetsJson;
  final int position;
  const ReleaseEntry({
    required this.instanceHost,
    required this.accountId,
    required this.projectId,
    required this.tagName,
    required this.name,
    required this.description,
    required this.releasedAt,
    this.authorName,
    required this.assetsJson,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['project_id'] = Variable<int>(projectId);
    map['tag_name'] = Variable<String>(tagName);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    map['released_at'] = Variable<DateTime>(releasedAt);
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    map['assets_json'] = Variable<String>(assetsJson);
    map['position'] = Variable<int>(position);
    return map;
  }

  ReleaseEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReleaseEntriesCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      projectId: Value(projectId),
      tagName: Value(tagName),
      name: Value(name),
      description: Value(description),
      releasedAt: Value(releasedAt),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      assetsJson: Value(assetsJson),
      position: Value(position),
    );
  }

  factory ReleaseEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReleaseEntry(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      tagName: serializer.fromJson<String>(json['tagName']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      releasedAt: serializer.fromJson<DateTime>(json['releasedAt']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      assetsJson: serializer.fromJson<String>(json['assetsJson']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'projectId': serializer.toJson<int>(projectId),
      'tagName': serializer.toJson<String>(tagName),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'releasedAt': serializer.toJson<DateTime>(releasedAt),
      'authorName': serializer.toJson<String?>(authorName),
      'assetsJson': serializer.toJson<String>(assetsJson),
      'position': serializer.toJson<int>(position),
    };
  }

  ReleaseEntry copyWith({
    String? instanceHost,
    String? accountId,
    int? projectId,
    String? tagName,
    String? name,
    String? description,
    DateTime? releasedAt,
    Value<String?> authorName = const Value.absent(),
    String? assetsJson,
    int? position,
  }) => ReleaseEntry(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    projectId: projectId ?? this.projectId,
    tagName: tagName ?? this.tagName,
    name: name ?? this.name,
    description: description ?? this.description,
    releasedAt: releasedAt ?? this.releasedAt,
    authorName: authorName.present ? authorName.value : this.authorName,
    assetsJson: assetsJson ?? this.assetsJson,
    position: position ?? this.position,
  );
  ReleaseEntry copyWithCompanion(ReleaseEntriesCompanion data) {
    return ReleaseEntry(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      tagName: data.tagName.present ? data.tagName.value : this.tagName,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      releasedAt: data.releasedAt.present
          ? data.releasedAt.value
          : this.releasedAt,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      assetsJson: data.assetsJson.present
          ? data.assetsJson.value
          : this.assetsJson,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseEntry(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('projectId: $projectId, ')
          ..write('tagName: $tagName, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('authorName: $authorName, ')
          ..write('assetsJson: $assetsJson, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    projectId,
    tagName,
    name,
    description,
    releasedAt,
    authorName,
    assetsJson,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReleaseEntry &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.projectId == this.projectId &&
          other.tagName == this.tagName &&
          other.name == this.name &&
          other.description == this.description &&
          other.releasedAt == this.releasedAt &&
          other.authorName == this.authorName &&
          other.assetsJson == this.assetsJson &&
          other.position == this.position);
}

class ReleaseEntriesCompanion extends UpdateCompanion<ReleaseEntry> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<int> projectId;
  final Value<String> tagName;
  final Value<String> name;
  final Value<String> description;
  final Value<DateTime> releasedAt;
  final Value<String?> authorName;
  final Value<String> assetsJson;
  final Value<int> position;
  final Value<int> rowid;
  const ReleaseEntriesCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.tagName = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.releasedAt = const Value.absent(),
    this.authorName = const Value.absent(),
    this.assetsJson = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReleaseEntriesCompanion.insert({
    required String instanceHost,
    required String accountId,
    required int projectId,
    required String tagName,
    required String name,
    required String description,
    required DateTime releasedAt,
    this.authorName = const Value.absent(),
    required String assetsJson,
    required int position,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       projectId = Value(projectId),
       tagName = Value(tagName),
       name = Value(name),
       description = Value(description),
       releasedAt = Value(releasedAt),
       assetsJson = Value(assetsJson),
       position = Value(position);
  static Insertable<ReleaseEntry> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<int>? projectId,
    Expression<String>? tagName,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? releasedAt,
    Expression<String>? authorName,
    Expression<String>? assetsJson,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (projectId != null) 'project_id': projectId,
      if (tagName != null) 'tag_name': tagName,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (releasedAt != null) 'released_at': releasedAt,
      if (authorName != null) 'author_name': authorName,
      if (assetsJson != null) 'assets_json': assetsJson,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReleaseEntriesCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<int>? projectId,
    Value<String>? tagName,
    Value<String>? name,
    Value<String>? description,
    Value<DateTime>? releasedAt,
    Value<String?>? authorName,
    Value<String>? assetsJson,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return ReleaseEntriesCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      projectId: projectId ?? this.projectId,
      tagName: tagName ?? this.tagName,
      name: name ?? this.name,
      description: description ?? this.description,
      releasedAt: releasedAt ?? this.releasedAt,
      authorName: authorName ?? this.authorName,
      assetsJson: assetsJson ?? this.assetsJson,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (tagName.present) {
      map['tag_name'] = Variable<String>(tagName.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (releasedAt.present) {
      map['released_at'] = Variable<DateTime>(releasedAt.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (assetsJson.present) {
      map['assets_json'] = Variable<String>(assetsJson.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReleaseEntriesCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('projectId: $projectId, ')
          ..write('tagName: $tagName, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('releasedAt: $releasedAt, ')
          ..write('authorName: $authorName, ')
          ..write('assetsJson: $assetsJson, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodoPollStatesTable extends TodoPollStates
    with TableInfo<$TodoPollStatesTable, TodoPollState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoPollStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seenTodoIdsMeta = const VerificationMeta(
    'seenTodoIds',
  );
  @override
  late final GeneratedColumn<String> seenTodoIds = GeneratedColumn<String>(
    'seen_todo_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtHighWaterMeta =
      const VerificationMeta('createdAtHighWater');
  @override
  late final GeneratedColumn<String> createdAtHighWater =
      GeneratedColumn<String>(
        'created_at_high_water',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    etag,
    seenTodoIds,
    createdAtHighWater,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo_poll_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<TodoPollState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('seen_todo_ids')) {
      context.handle(
        _seenTodoIdsMeta,
        seenTodoIds.isAcceptableOrUnknown(
          data['seen_todo_ids']!,
          _seenTodoIdsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seenTodoIdsMeta);
    }
    if (data.containsKey('created_at_high_water')) {
      context.handle(
        _createdAtHighWaterMeta,
        createdAtHighWater.isAcceptableOrUnknown(
          data['created_at_high_water']!,
          _createdAtHighWaterMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId};
  @override
  TodoPollState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoPollState(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      seenTodoIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seen_todo_ids'],
      )!,
      createdAtHighWater: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at_high_water'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TodoPollStatesTable createAlias(String alias) {
    return $TodoPollStatesTable(attachedDatabase, alias);
  }
}

class TodoPollState extends DataClass implements Insertable<TodoPollState> {
  final String instanceHost;
  final String accountId;
  final String? etag;
  final String seenTodoIds;
  final String? createdAtHighWater;
  final DateTime updatedAt;
  const TodoPollState({
    required this.instanceHost,
    required this.accountId,
    this.etag,
    required this.seenTodoIds,
    this.createdAtHighWater,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['seen_todo_ids'] = Variable<String>(seenTodoIds);
    if (!nullToAbsent || createdAtHighWater != null) {
      map['created_at_high_water'] = Variable<String>(createdAtHighWater);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TodoPollStatesCompanion toCompanion(bool nullToAbsent) {
    return TodoPollStatesCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      seenTodoIds: Value(seenTodoIds),
      createdAtHighWater: createdAtHighWater == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAtHighWater),
      updatedAt: Value(updatedAt),
    );
  }

  factory TodoPollState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoPollState(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      etag: serializer.fromJson<String?>(json['etag']),
      seenTodoIds: serializer.fromJson<String>(json['seenTodoIds']),
      createdAtHighWater: serializer.fromJson<String?>(
        json['createdAtHighWater'],
      ),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'etag': serializer.toJson<String?>(etag),
      'seenTodoIds': serializer.toJson<String>(seenTodoIds),
      'createdAtHighWater': serializer.toJson<String?>(createdAtHighWater),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TodoPollState copyWith({
    String? instanceHost,
    String? accountId,
    Value<String?> etag = const Value.absent(),
    String? seenTodoIds,
    Value<String?> createdAtHighWater = const Value.absent(),
    DateTime? updatedAt,
  }) => TodoPollState(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    etag: etag.present ? etag.value : this.etag,
    seenTodoIds: seenTodoIds ?? this.seenTodoIds,
    createdAtHighWater: createdAtHighWater.present
        ? createdAtHighWater.value
        : this.createdAtHighWater,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TodoPollState copyWithCompanion(TodoPollStatesCompanion data) {
    return TodoPollState(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      etag: data.etag.present ? data.etag.value : this.etag,
      seenTodoIds: data.seenTodoIds.present
          ? data.seenTodoIds.value
          : this.seenTodoIds,
      createdAtHighWater: data.createdAtHighWater.present
          ? data.createdAtHighWater.value
          : this.createdAtHighWater,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TodoPollState(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('etag: $etag, ')
          ..write('seenTodoIds: $seenTodoIds, ')
          ..write('createdAtHighWater: $createdAtHighWater, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    etag,
    seenTodoIds,
    createdAtHighWater,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoPollState &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.etag == this.etag &&
          other.seenTodoIds == this.seenTodoIds &&
          other.createdAtHighWater == this.createdAtHighWater &&
          other.updatedAt == this.updatedAt);
}

class TodoPollStatesCompanion extends UpdateCompanion<TodoPollState> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<String?> etag;
  final Value<String> seenTodoIds;
  final Value<String?> createdAtHighWater;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TodoPollStatesCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.etag = const Value.absent(),
    this.seenTodoIds = const Value.absent(),
    this.createdAtHighWater = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodoPollStatesCompanion.insert({
    required String instanceHost,
    required String accountId,
    this.etag = const Value.absent(),
    required String seenTodoIds,
    this.createdAtHighWater = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       seenTodoIds = Value(seenTodoIds),
       updatedAt = Value(updatedAt);
  static Insertable<TodoPollState> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<String>? etag,
    Expression<String>? seenTodoIds,
    Expression<String>? createdAtHighWater,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (etag != null) 'etag': etag,
      if (seenTodoIds != null) 'seen_todo_ids': seenTodoIds,
      if (createdAtHighWater != null)
        'created_at_high_water': createdAtHighWater,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodoPollStatesCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<String?>? etag,
    Value<String>? seenTodoIds,
    Value<String?>? createdAtHighWater,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TodoPollStatesCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      etag: etag ?? this.etag,
      seenTodoIds: seenTodoIds ?? this.seenTodoIds,
      createdAtHighWater: createdAtHighWater ?? this.createdAtHighWater,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (seenTodoIds.present) {
      map['seen_todo_ids'] = Variable<String>(seenTodoIds.value);
    }
    if (createdAtHighWater.present) {
      map['created_at_high_water'] = Variable<String>(createdAtHighWater.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoPollStatesCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('etag: $etag, ')
          ..write('seenTodoIds: $seenTodoIds, ')
          ..write('createdAtHighWater: $createdAtHighWater, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CommentDraftsTable extends CommentDrafts
    with TableInfo<$CommentDraftsTable, CommentDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CommentDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _instanceHostMeta = const VerificationMeta(
    'instanceHost',
  );
  @override
  late final GeneratedColumn<String> instanceHost = GeneratedColumn<String>(
    'instance_host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _draftIdMeta = const VerificationMeta(
    'draftId',
  );
  @override
  late final GeneratedColumn<int> draftId = GeneratedColumn<int>(
    'draft_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _issueIidMeta = const VerificationMeta(
    'issueIid',
  );
  @override
  late final GeneratedColumn<int> issueIid = GeneratedColumn<int>(
    'issue_iid',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    instanceHost,
    accountId,
    draftId,
    projectId,
    issueIid,
    body,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comment_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CommentDraft> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('instance_host')) {
      context.handle(
        _instanceHostMeta,
        instanceHost.isAcceptableOrUnknown(
          data['instance_host']!,
          _instanceHostMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instanceHostMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('draft_id')) {
      context.handle(
        _draftIdMeta,
        draftId.isAcceptableOrUnknown(data['draft_id']!, _draftIdMeta),
      );
    } else if (isInserting) {
      context.missing(_draftIdMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('issue_iid')) {
      context.handle(
        _issueIidMeta,
        issueIid.isAcceptableOrUnknown(data['issue_iid']!, _issueIidMeta),
      );
    } else if (isInserting) {
      context.missing(_issueIidMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {instanceHost, accountId, draftId};
  @override
  CommentDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CommentDraft(
      instanceHost: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instance_host'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      draftId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}draft_id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}project_id'],
      )!,
      issueIid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}issue_iid'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $CommentDraftsTable createAlias(String alias) {
    return $CommentDraftsTable(attachedDatabase, alias);
  }
}

class CommentDraft extends DataClass implements Insertable<CommentDraft> {
  final String instanceHost;
  final String accountId;
  final int draftId;
  final int projectId;
  final int issueIid;
  final String body;
  final String? lastError;
  const CommentDraft({
    required this.instanceHost,
    required this.accountId,
    required this.draftId,
    required this.projectId,
    required this.issueIid,
    required this.body,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['instance_host'] = Variable<String>(instanceHost);
    map['account_id'] = Variable<String>(accountId);
    map['draft_id'] = Variable<int>(draftId);
    map['project_id'] = Variable<int>(projectId);
    map['issue_iid'] = Variable<int>(issueIid);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  CommentDraftsCompanion toCompanion(bool nullToAbsent) {
    return CommentDraftsCompanion(
      instanceHost: Value(instanceHost),
      accountId: Value(accountId),
      draftId: Value(draftId),
      projectId: Value(projectId),
      issueIid: Value(issueIid),
      body: Value(body),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory CommentDraft.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CommentDraft(
      instanceHost: serializer.fromJson<String>(json['instanceHost']),
      accountId: serializer.fromJson<String>(json['accountId']),
      draftId: serializer.fromJson<int>(json['draftId']),
      projectId: serializer.fromJson<int>(json['projectId']),
      issueIid: serializer.fromJson<int>(json['issueIid']),
      body: serializer.fromJson<String>(json['body']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'instanceHost': serializer.toJson<String>(instanceHost),
      'accountId': serializer.toJson<String>(accountId),
      'draftId': serializer.toJson<int>(draftId),
      'projectId': serializer.toJson<int>(projectId),
      'issueIid': serializer.toJson<int>(issueIid),
      'body': serializer.toJson<String>(body),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  CommentDraft copyWith({
    String? instanceHost,
    String? accountId,
    int? draftId,
    int? projectId,
    int? issueIid,
    String? body,
    Value<String?> lastError = const Value.absent(),
  }) => CommentDraft(
    instanceHost: instanceHost ?? this.instanceHost,
    accountId: accountId ?? this.accountId,
    draftId: draftId ?? this.draftId,
    projectId: projectId ?? this.projectId,
    issueIid: issueIid ?? this.issueIid,
    body: body ?? this.body,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  CommentDraft copyWithCompanion(CommentDraftsCompanion data) {
    return CommentDraft(
      instanceHost: data.instanceHost.present
          ? data.instanceHost.value
          : this.instanceHost,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      draftId: data.draftId.present ? data.draftId.value : this.draftId,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      issueIid: data.issueIid.present ? data.issueIid.value : this.issueIid,
      body: data.body.present ? data.body.value : this.body,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CommentDraft(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('draftId: $draftId, ')
          ..write('projectId: $projectId, ')
          ..write('issueIid: $issueIid, ')
          ..write('body: $body, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    instanceHost,
    accountId,
    draftId,
    projectId,
    issueIid,
    body,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CommentDraft &&
          other.instanceHost == this.instanceHost &&
          other.accountId == this.accountId &&
          other.draftId == this.draftId &&
          other.projectId == this.projectId &&
          other.issueIid == this.issueIid &&
          other.body == this.body &&
          other.lastError == this.lastError);
}

class CommentDraftsCompanion extends UpdateCompanion<CommentDraft> {
  final Value<String> instanceHost;
  final Value<String> accountId;
  final Value<int> draftId;
  final Value<int> projectId;
  final Value<int> issueIid;
  final Value<String> body;
  final Value<String?> lastError;
  final Value<int> rowid;
  const CommentDraftsCompanion({
    this.instanceHost = const Value.absent(),
    this.accountId = const Value.absent(),
    this.draftId = const Value.absent(),
    this.projectId = const Value.absent(),
    this.issueIid = const Value.absent(),
    this.body = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CommentDraftsCompanion.insert({
    required String instanceHost,
    required String accountId,
    required int draftId,
    required int projectId,
    required int issueIid,
    required String body,
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : instanceHost = Value(instanceHost),
       accountId = Value(accountId),
       draftId = Value(draftId),
       projectId = Value(projectId),
       issueIid = Value(issueIid),
       body = Value(body);
  static Insertable<CommentDraft> custom({
    Expression<String>? instanceHost,
    Expression<String>? accountId,
    Expression<int>? draftId,
    Expression<int>? projectId,
    Expression<int>? issueIid,
    Expression<String>? body,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (instanceHost != null) 'instance_host': instanceHost,
      if (accountId != null) 'account_id': accountId,
      if (draftId != null) 'draft_id': draftId,
      if (projectId != null) 'project_id': projectId,
      if (issueIid != null) 'issue_iid': issueIid,
      if (body != null) 'body': body,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CommentDraftsCompanion copyWith({
    Value<String>? instanceHost,
    Value<String>? accountId,
    Value<int>? draftId,
    Value<int>? projectId,
    Value<int>? issueIid,
    Value<String>? body,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return CommentDraftsCompanion(
      instanceHost: instanceHost ?? this.instanceHost,
      accountId: accountId ?? this.accountId,
      draftId: draftId ?? this.draftId,
      projectId: projectId ?? this.projectId,
      issueIid: issueIid ?? this.issueIid,
      body: body ?? this.body,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (instanceHost.present) {
      map['instance_host'] = Variable<String>(instanceHost.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (draftId.present) {
      map['draft_id'] = Variable<int>(draftId.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (issueIid.present) {
      map['issue_iid'] = Variable<int>(issueIid.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CommentDraftsCompanion(')
          ..write('instanceHost: $instanceHost, ')
          ..write('accountId: $accountId, ')
          ..write('draftId: $draftId, ')
          ..write('projectId: $projectId, ')
          ..write('issueIid: $issueIid, ')
          ..write('body: $body, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCacheEntriesTable localCacheEntries =
      $LocalCacheEntriesTable(this);
  late final $CurrentUserProfilesTable currentUserProfiles =
      $CurrentUserProfilesTable(this);
  late final $PaginationCursorsTable paginationCursors =
      $PaginationCursorsTable(this);
  late final $TodoItemsTable todoItems = $TodoItemsTable(this);
  late final $RepositoryTreeEntriesTable repositoryTreeEntries =
      $RepositoryTreeEntriesTable(this);
  late final $RecentlyViewedItemsTable recentlyViewedItems =
      $RecentlyViewedItemsTable(this);
  late final $HomeTileOrdersTable homeTileOrders = $HomeTileOrdersTable(this);
  late final $ReleaseEntriesTable releaseEntries = $ReleaseEntriesTable(this);
  late final $TodoPollStatesTable todoPollStates = $TodoPollStatesTable(this);
  late final $CommentDraftsTable commentDrafts = $CommentDraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCacheEntries,
    currentUserProfiles,
    paginationCursors,
    todoItems,
    repositoryTreeEntries,
    recentlyViewedItems,
    homeTileOrders,
    releaseEntries,
    todoPollStates,
    commentDrafts,
  ];
}

typedef $$LocalCacheEntriesTableCreateCompanionBuilder =
    LocalCacheEntriesCompanion Function({
      required String instanceHost,
      required String accountId,
      required String cacheKey,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocalCacheEntriesTableUpdateCompanionBuilder =
    LocalCacheEntriesCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String> cacheKey,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocalCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCacheEntriesTable> {
  $$LocalCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCacheEntriesTable> {
  $$LocalCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cacheKey => $composableBuilder(
    column: $table.cacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCacheEntriesTable> {
  $$LocalCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get cacheKey =>
      $composableBuilder(column: $table.cacheKey, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCacheEntriesTable,
          LocalCacheEntry,
          $$LocalCacheEntriesTableFilterComposer,
          $$LocalCacheEntriesTableOrderingComposer,
          $$LocalCacheEntriesTableAnnotationComposer,
          $$LocalCacheEntriesTableCreateCompanionBuilder,
          $$LocalCacheEntriesTableUpdateCompanionBuilder,
          (
            LocalCacheEntry,
            BaseReferences<
              _$AppDatabase,
              $LocalCacheEntriesTable,
              LocalCacheEntry
            >,
          ),
          LocalCacheEntry,
          PrefetchHooks Function()
        > {
  $$LocalCacheEntriesTableTableManager(
    _$AppDatabase db,
    $LocalCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCacheEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> cacheKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCacheEntriesCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                cacheKey: cacheKey,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required String cacheKey,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocalCacheEntriesCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                cacheKey: cacheKey,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCacheEntriesTable,
      LocalCacheEntry,
      $$LocalCacheEntriesTableFilterComposer,
      $$LocalCacheEntriesTableOrderingComposer,
      $$LocalCacheEntriesTableAnnotationComposer,
      $$LocalCacheEntriesTableCreateCompanionBuilder,
      $$LocalCacheEntriesTableUpdateCompanionBuilder,
      (
        LocalCacheEntry,
        BaseReferences<_$AppDatabase, $LocalCacheEntriesTable, LocalCacheEntry>,
      ),
      LocalCacheEntry,
      PrefetchHooks Function()
    >;
typedef $$CurrentUserProfilesTableCreateCompanionBuilder =
    CurrentUserProfilesCompanion Function({
      required String instanceHost,
      required String accountId,
      required String username,
      required String name,
      Value<String?> avatarUrl,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CurrentUserProfilesTableUpdateCompanionBuilder =
    CurrentUserProfilesCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String> username,
      Value<String> name,
      Value<String?> avatarUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CurrentUserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrentUserProfilesTable> {
  $$CurrentUserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CurrentUserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrentUserProfilesTable> {
  $$CurrentUserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrentUserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrentUserProfilesTable> {
  $$CurrentUserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CurrentUserProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrentUserProfilesTable,
          CurrentUserProfile,
          $$CurrentUserProfilesTableFilterComposer,
          $$CurrentUserProfilesTableOrderingComposer,
          $$CurrentUserProfilesTableAnnotationComposer,
          $$CurrentUserProfilesTableCreateCompanionBuilder,
          $$CurrentUserProfilesTableUpdateCompanionBuilder,
          (
            CurrentUserProfile,
            BaseReferences<
              _$AppDatabase,
              $CurrentUserProfilesTable,
              CurrentUserProfile
            >,
          ),
          CurrentUserProfile,
          PrefetchHooks Function()
        > {
  $$CurrentUserProfilesTableTableManager(
    _$AppDatabase db,
    $CurrentUserProfilesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrentUserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrentUserProfilesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CurrentUserProfilesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrentUserProfilesCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                username: username,
                name: name,
                avatarUrl: avatarUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required String username,
                required String name,
                Value<String?> avatarUrl = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CurrentUserProfilesCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                username: username,
                name: name,
                avatarUrl: avatarUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CurrentUserProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrentUserProfilesTable,
      CurrentUserProfile,
      $$CurrentUserProfilesTableFilterComposer,
      $$CurrentUserProfilesTableOrderingComposer,
      $$CurrentUserProfilesTableAnnotationComposer,
      $$CurrentUserProfilesTableCreateCompanionBuilder,
      $$CurrentUserProfilesTableUpdateCompanionBuilder,
      (
        CurrentUserProfile,
        BaseReferences<
          _$AppDatabase,
          $CurrentUserProfilesTable,
          CurrentUserProfile
        >,
      ),
      CurrentUserProfile,
      PrefetchHooks Function()
    >;
typedef $$PaginationCursorsTableCreateCompanionBuilder =
    PaginationCursorsCompanion Function({
      required String instanceHost,
      required String accountId,
      required String collectionKey,
      required String cursorUri,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$PaginationCursorsTableUpdateCompanionBuilder =
    PaginationCursorsCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String> collectionKey,
      Value<String> cursorUri,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$PaginationCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $PaginationCursorsTable> {
  $$PaginationCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cursorUri => $composableBuilder(
    column: $table.cursorUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaginationCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaginationCursorsTable> {
  $$PaginationCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursorUri => $composableBuilder(
    column: $table.cursorUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaginationCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaginationCursorsTable> {
  $$PaginationCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get collectionKey => $composableBuilder(
    column: $table.collectionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cursorUri =>
      $composableBuilder(column: $table.cursorUri, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PaginationCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaginationCursorsTable,
          PaginationCursor,
          $$PaginationCursorsTableFilterComposer,
          $$PaginationCursorsTableOrderingComposer,
          $$PaginationCursorsTableAnnotationComposer,
          $$PaginationCursorsTableCreateCompanionBuilder,
          $$PaginationCursorsTableUpdateCompanionBuilder,
          (
            PaginationCursor,
            BaseReferences<
              _$AppDatabase,
              $PaginationCursorsTable,
              PaginationCursor
            >,
          ),
          PaginationCursor,
          PrefetchHooks Function()
        > {
  $$PaginationCursorsTableTableManager(
    _$AppDatabase db,
    $PaginationCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaginationCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaginationCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaginationCursorsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> collectionKey = const Value.absent(),
                Value<String> cursorUri = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaginationCursorsCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                collectionKey: collectionKey,
                cursorUri: cursorUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required String collectionKey,
                required String cursorUri,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PaginationCursorsCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                collectionKey: collectionKey,
                cursorUri: cursorUri,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaginationCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaginationCursorsTable,
      PaginationCursor,
      $$PaginationCursorsTableFilterComposer,
      $$PaginationCursorsTableOrderingComposer,
      $$PaginationCursorsTableAnnotationComposer,
      $$PaginationCursorsTableCreateCompanionBuilder,
      $$PaginationCursorsTableUpdateCompanionBuilder,
      (
        PaginationCursor,
        BaseReferences<
          _$AppDatabase,
          $PaginationCursorsTable,
          PaginationCursor
        >,
      ),
      PaginationCursor,
      PrefetchHooks Function()
    >;
typedef $$TodoItemsTableCreateCompanionBuilder =
    TodoItemsCompanion Function({
      required String instanceHost,
      required String accountId,
      required int todoId,
      Value<String?> projectPathWithNamespace,
      required String authorName,
      required String authorUsername,
      Value<String?> authorAvatarUrl,
      required String actionName,
      required String targetType,
      Value<int?> targetIid,
      Value<String?> targetTitle,
      required String targetUrl,
      required String body,
      required String state,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TodoItemsTableUpdateCompanionBuilder =
    TodoItemsCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<int> todoId,
      Value<String?> projectPathWithNamespace,
      Value<String> authorName,
      Value<String> authorUsername,
      Value<String?> authorAvatarUrl,
      Value<String> actionName,
      Value<String> targetType,
      Value<int?> targetIid,
      Value<String?> targetTitle,
      Value<String> targetUrl,
      Value<String> body,
      Value<String> state,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TodoItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectPathWithNamespace => $composableBuilder(
    column: $table.projectPathWithNamespace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorUsername => $composableBuilder(
    column: $table.authorUsername,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorAvatarUrl => $composableBuilder(
    column: $table.authorAvatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetIid => $composableBuilder(
    column: $table.targetIid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTitle => $composableBuilder(
    column: $table.targetTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get todoId => $composableBuilder(
    column: $table.todoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectPathWithNamespace => $composableBuilder(
    column: $table.projectPathWithNamespace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorUsername => $composableBuilder(
    column: $table.authorUsername,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorAvatarUrl => $composableBuilder(
    column: $table.authorAvatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetIid => $composableBuilder(
    column: $table.targetIid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTitle => $composableBuilder(
    column: $table.targetTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetUrl => $composableBuilder(
    column: $table.targetUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoItemsTable> {
  $$TodoItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get todoId =>
      $composableBuilder(column: $table.todoId, builder: (column) => column);

  GeneratedColumn<String> get projectPathWithNamespace => $composableBuilder(
    column: $table.projectPathWithNamespace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorUsername => $composableBuilder(
    column: $table.authorUsername,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorAvatarUrl => $composableBuilder(
    column: $table.authorAvatarUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionName => $composableBuilder(
    column: $table.actionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetIid =>
      $composableBuilder(column: $table.targetIid, builder: (column) => column);

  GeneratedColumn<String> get targetTitle => $composableBuilder(
    column: $table.targetTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetUrl =>
      $composableBuilder(column: $table.targetUrl, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TodoItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoItemsTable,
          TodoItem,
          $$TodoItemsTableFilterComposer,
          $$TodoItemsTableOrderingComposer,
          $$TodoItemsTableAnnotationComposer,
          $$TodoItemsTableCreateCompanionBuilder,
          $$TodoItemsTableUpdateCompanionBuilder,
          (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
          TodoItem,
          PrefetchHooks Function()
        > {
  $$TodoItemsTableTableManager(_$AppDatabase db, $TodoItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> todoId = const Value.absent(),
                Value<String?> projectPathWithNamespace = const Value.absent(),
                Value<String> authorName = const Value.absent(),
                Value<String> authorUsername = const Value.absent(),
                Value<String?> authorAvatarUrl = const Value.absent(),
                Value<String> actionName = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<int?> targetIid = const Value.absent(),
                Value<String?> targetTitle = const Value.absent(),
                Value<String> targetUrl = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoItemsCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                todoId: todoId,
                projectPathWithNamespace: projectPathWithNamespace,
                authorName: authorName,
                authorUsername: authorUsername,
                authorAvatarUrl: authorAvatarUrl,
                actionName: actionName,
                targetType: targetType,
                targetIid: targetIid,
                targetTitle: targetTitle,
                targetUrl: targetUrl,
                body: body,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required int todoId,
                Value<String?> projectPathWithNamespace = const Value.absent(),
                required String authorName,
                required String authorUsername,
                Value<String?> authorAvatarUrl = const Value.absent(),
                required String actionName,
                required String targetType,
                Value<int?> targetIid = const Value.absent(),
                Value<String?> targetTitle = const Value.absent(),
                required String targetUrl,
                required String body,
                required String state,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TodoItemsCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                todoId: todoId,
                projectPathWithNamespace: projectPathWithNamespace,
                authorName: authorName,
                authorUsername: authorUsername,
                authorAvatarUrl: authorAvatarUrl,
                actionName: actionName,
                targetType: targetType,
                targetIid: targetIid,
                targetTitle: targetTitle,
                targetUrl: targetUrl,
                body: body,
                state: state,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoItemsTable,
      TodoItem,
      $$TodoItemsTableFilterComposer,
      $$TodoItemsTableOrderingComposer,
      $$TodoItemsTableAnnotationComposer,
      $$TodoItemsTableCreateCompanionBuilder,
      $$TodoItemsTableUpdateCompanionBuilder,
      (TodoItem, BaseReferences<_$AppDatabase, $TodoItemsTable, TodoItem>),
      TodoItem,
      PrefetchHooks Function()
    >;
typedef $$RepositoryTreeEntriesTableCreateCompanionBuilder =
    RepositoryTreeEntriesCompanion Function({
      required String instanceHost,
      required String accountId,
      required int projectId,
      required String ref,
      required String parentPath,
      required String name,
      required String path,
      required String entryType,
      required int position,
      Value<int> rowid,
    });
typedef $$RepositoryTreeEntriesTableUpdateCompanionBuilder =
    RepositoryTreeEntriesCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<int> projectId,
      Value<String> ref,
      Value<String> parentPath,
      Value<String> name,
      Value<String> path,
      Value<String> entryType,
      Value<int> position,
      Value<int> rowid,
    });

class $$RepositoryTreeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $RepositoryTreeEntriesTable> {
  $$RepositoryTreeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentPath => $composableBuilder(
    column: $table.parentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RepositoryTreeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RepositoryTreeEntriesTable> {
  $$RepositoryTreeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentPath => $composableBuilder(
    column: $table.parentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryType => $composableBuilder(
    column: $table.entryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RepositoryTreeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepositoryTreeEntriesTable> {
  $$RepositoryTreeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get parentPath => $composableBuilder(
    column: $table.parentPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$RepositoryTreeEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepositoryTreeEntriesTable,
          RepositoryTreeEntry,
          $$RepositoryTreeEntriesTableFilterComposer,
          $$RepositoryTreeEntriesTableOrderingComposer,
          $$RepositoryTreeEntriesTableAnnotationComposer,
          $$RepositoryTreeEntriesTableCreateCompanionBuilder,
          $$RepositoryTreeEntriesTableUpdateCompanionBuilder,
          (
            RepositoryTreeEntry,
            BaseReferences<
              _$AppDatabase,
              $RepositoryTreeEntriesTable,
              RepositoryTreeEntry
            >,
          ),
          RepositoryTreeEntry,
          PrefetchHooks Function()
        > {
  $$RepositoryTreeEntriesTableTableManager(
    _$AppDatabase db,
    $RepositoryTreeEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepositoryTreeEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RepositoryTreeEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RepositoryTreeEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> ref = const Value.absent(),
                Value<String> parentPath = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> entryType = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RepositoryTreeEntriesCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                projectId: projectId,
                ref: ref,
                parentPath: parentPath,
                name: name,
                path: path,
                entryType: entryType,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required int projectId,
                required String ref,
                required String parentPath,
                required String name,
                required String path,
                required String entryType,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => RepositoryTreeEntriesCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                projectId: projectId,
                ref: ref,
                parentPath: parentPath,
                name: name,
                path: path,
                entryType: entryType,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RepositoryTreeEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepositoryTreeEntriesTable,
      RepositoryTreeEntry,
      $$RepositoryTreeEntriesTableFilterComposer,
      $$RepositoryTreeEntriesTableOrderingComposer,
      $$RepositoryTreeEntriesTableAnnotationComposer,
      $$RepositoryTreeEntriesTableCreateCompanionBuilder,
      $$RepositoryTreeEntriesTableUpdateCompanionBuilder,
      (
        RepositoryTreeEntry,
        BaseReferences<
          _$AppDatabase,
          $RepositoryTreeEntriesTable,
          RepositoryTreeEntry
        >,
      ),
      RepositoryTreeEntry,
      PrefetchHooks Function()
    >;
typedef $$RecentlyViewedItemsTableCreateCompanionBuilder =
    RecentlyViewedItemsCompanion Function({
      required String instanceHost,
      required String accountId,
      required String itemType,
      required int projectId,
      required int itemId,
      required String payload,
      required DateTime lastViewedAt,
      Value<int> rowid,
    });
typedef $$RecentlyViewedItemsTableUpdateCompanionBuilder =
    RecentlyViewedItemsCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String> itemType,
      Value<int> projectId,
      Value<int> itemId,
      Value<String> payload,
      Value<DateTime> lastViewedAt,
      Value<int> rowid,
    });

class $$RecentlyViewedItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RecentlyViewedItemsTable> {
  $$RecentlyViewedItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentlyViewedItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentlyViewedItemsTable> {
  $$RecentlyViewedItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentlyViewedItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentlyViewedItemsTable> {
  $$RecentlyViewedItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get lastViewedAt => $composableBuilder(
    column: $table.lastViewedAt,
    builder: (column) => column,
  );
}

class $$RecentlyViewedItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentlyViewedItemsTable,
          RecentlyViewedItem,
          $$RecentlyViewedItemsTableFilterComposer,
          $$RecentlyViewedItemsTableOrderingComposer,
          $$RecentlyViewedItemsTableAnnotationComposer,
          $$RecentlyViewedItemsTableCreateCompanionBuilder,
          $$RecentlyViewedItemsTableUpdateCompanionBuilder,
          (
            RecentlyViewedItem,
            BaseReferences<
              _$AppDatabase,
              $RecentlyViewedItemsTable,
              RecentlyViewedItem
            >,
          ),
          RecentlyViewedItem,
          PrefetchHooks Function()
        > {
  $$RecentlyViewedItemsTableTableManager(
    _$AppDatabase db,
    $RecentlyViewedItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentlyViewedItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentlyViewedItemsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecentlyViewedItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> lastViewedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentlyViewedItemsCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                itemType: itemType,
                projectId: projectId,
                itemId: itemId,
                payload: payload,
                lastViewedAt: lastViewedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required String itemType,
                required int projectId,
                required int itemId,
                required String payload,
                required DateTime lastViewedAt,
                Value<int> rowid = const Value.absent(),
              }) => RecentlyViewedItemsCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                itemType: itemType,
                projectId: projectId,
                itemId: itemId,
                payload: payload,
                lastViewedAt: lastViewedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentlyViewedItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentlyViewedItemsTable,
      RecentlyViewedItem,
      $$RecentlyViewedItemsTableFilterComposer,
      $$RecentlyViewedItemsTableOrderingComposer,
      $$RecentlyViewedItemsTableAnnotationComposer,
      $$RecentlyViewedItemsTableCreateCompanionBuilder,
      $$RecentlyViewedItemsTableUpdateCompanionBuilder,
      (
        RecentlyViewedItem,
        BaseReferences<
          _$AppDatabase,
          $RecentlyViewedItemsTable,
          RecentlyViewedItem
        >,
      ),
      RecentlyViewedItem,
      PrefetchHooks Function()
    >;
typedef $$HomeTileOrdersTableCreateCompanionBuilder =
    HomeTileOrdersCompanion Function({
      required String instanceHost,
      required String accountId,
      required String tileOrder,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$HomeTileOrdersTableUpdateCompanionBuilder =
    HomeTileOrdersCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String> tileOrder,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$HomeTileOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $HomeTileOrdersTable> {
  $$HomeTileOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tileOrder => $composableBuilder(
    column: $table.tileOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HomeTileOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $HomeTileOrdersTable> {
  $$HomeTileOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tileOrder => $composableBuilder(
    column: $table.tileOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HomeTileOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $HomeTileOrdersTable> {
  $$HomeTileOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get tileOrder =>
      $composableBuilder(column: $table.tileOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HomeTileOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HomeTileOrdersTable,
          HomeTileOrder,
          $$HomeTileOrdersTableFilterComposer,
          $$HomeTileOrdersTableOrderingComposer,
          $$HomeTileOrdersTableAnnotationComposer,
          $$HomeTileOrdersTableCreateCompanionBuilder,
          $$HomeTileOrdersTableUpdateCompanionBuilder,
          (
            HomeTileOrder,
            BaseReferences<_$AppDatabase, $HomeTileOrdersTable, HomeTileOrder>,
          ),
          HomeTileOrder,
          PrefetchHooks Function()
        > {
  $$HomeTileOrdersTableTableManager(
    _$AppDatabase db,
    $HomeTileOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HomeTileOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HomeTileOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HomeTileOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String> tileOrder = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HomeTileOrdersCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                tileOrder: tileOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required String tileOrder,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => HomeTileOrdersCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                tileOrder: tileOrder,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HomeTileOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HomeTileOrdersTable,
      HomeTileOrder,
      $$HomeTileOrdersTableFilterComposer,
      $$HomeTileOrdersTableOrderingComposer,
      $$HomeTileOrdersTableAnnotationComposer,
      $$HomeTileOrdersTableCreateCompanionBuilder,
      $$HomeTileOrdersTableUpdateCompanionBuilder,
      (
        HomeTileOrder,
        BaseReferences<_$AppDatabase, $HomeTileOrdersTable, HomeTileOrder>,
      ),
      HomeTileOrder,
      PrefetchHooks Function()
    >;
typedef $$ReleaseEntriesTableCreateCompanionBuilder =
    ReleaseEntriesCompanion Function({
      required String instanceHost,
      required String accountId,
      required int projectId,
      required String tagName,
      required String name,
      required String description,
      required DateTime releasedAt,
      Value<String?> authorName,
      required String assetsJson,
      required int position,
      Value<int> rowid,
    });
typedef $$ReleaseEntriesTableUpdateCompanionBuilder =
    ReleaseEntriesCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<int> projectId,
      Value<String> tagName,
      Value<String> name,
      Value<String> description,
      Value<DateTime> releasedAt,
      Value<String?> authorName,
      Value<String> assetsJson,
      Value<int> position,
      Value<int> rowid,
    });

class $$ReleaseEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReleaseEntriesTable> {
  $$ReleaseEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReleaseEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReleaseEntriesTable> {
  $$ReleaseEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagName => $composableBuilder(
    column: $table.tagName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReleaseEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReleaseEntriesTable> {
  $$ReleaseEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get tagName =>
      $composableBuilder(column: $table.tagName, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get releasedAt => $composableBuilder(
    column: $table.releasedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get assetsJson => $composableBuilder(
    column: $table.assetsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$ReleaseEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReleaseEntriesTable,
          ReleaseEntry,
          $$ReleaseEntriesTableFilterComposer,
          $$ReleaseEntriesTableOrderingComposer,
          $$ReleaseEntriesTableAnnotationComposer,
          $$ReleaseEntriesTableCreateCompanionBuilder,
          $$ReleaseEntriesTableUpdateCompanionBuilder,
          (
            ReleaseEntry,
            BaseReferences<_$AppDatabase, $ReleaseEntriesTable, ReleaseEntry>,
          ),
          ReleaseEntry,
          PrefetchHooks Function()
        > {
  $$ReleaseEntriesTableTableManager(
    _$AppDatabase db,
    $ReleaseEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReleaseEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReleaseEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReleaseEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> tagName = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> releasedAt = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<String> assetsJson = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReleaseEntriesCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                projectId: projectId,
                tagName: tagName,
                name: name,
                description: description,
                releasedAt: releasedAt,
                authorName: authorName,
                assetsJson: assetsJson,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required int projectId,
                required String tagName,
                required String name,
                required String description,
                required DateTime releasedAt,
                Value<String?> authorName = const Value.absent(),
                required String assetsJson,
                required int position,
                Value<int> rowid = const Value.absent(),
              }) => ReleaseEntriesCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                projectId: projectId,
                tagName: tagName,
                name: name,
                description: description,
                releasedAt: releasedAt,
                authorName: authorName,
                assetsJson: assetsJson,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReleaseEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReleaseEntriesTable,
      ReleaseEntry,
      $$ReleaseEntriesTableFilterComposer,
      $$ReleaseEntriesTableOrderingComposer,
      $$ReleaseEntriesTableAnnotationComposer,
      $$ReleaseEntriesTableCreateCompanionBuilder,
      $$ReleaseEntriesTableUpdateCompanionBuilder,
      (
        ReleaseEntry,
        BaseReferences<_$AppDatabase, $ReleaseEntriesTable, ReleaseEntry>,
      ),
      ReleaseEntry,
      PrefetchHooks Function()
    >;
typedef $$TodoPollStatesTableCreateCompanionBuilder =
    TodoPollStatesCompanion Function({
      required String instanceHost,
      required String accountId,
      Value<String?> etag,
      required String seenTodoIds,
      Value<String?> createdAtHighWater,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TodoPollStatesTableUpdateCompanionBuilder =
    TodoPollStatesCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<String?> etag,
      Value<String> seenTodoIds,
      Value<String?> createdAtHighWater,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TodoPollStatesTableFilterComposer
    extends Composer<_$AppDatabase, $TodoPollStatesTable> {
  $$TodoPollStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seenTodoIds => $composableBuilder(
    column: $table.seenTodoIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAtHighWater => $composableBuilder(
    column: $table.createdAtHighWater,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TodoPollStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TodoPollStatesTable> {
  $$TodoPollStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seenTodoIds => $composableBuilder(
    column: $table.seenTodoIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAtHighWater => $composableBuilder(
    column: $table.createdAtHighWater,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TodoPollStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodoPollStatesTable> {
  $$TodoPollStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get seenTodoIds => $composableBuilder(
    column: $table.seenTodoIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAtHighWater => $composableBuilder(
    column: $table.createdAtHighWater,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TodoPollStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TodoPollStatesTable,
          TodoPollState,
          $$TodoPollStatesTableFilterComposer,
          $$TodoPollStatesTableOrderingComposer,
          $$TodoPollStatesTableAnnotationComposer,
          $$TodoPollStatesTableCreateCompanionBuilder,
          $$TodoPollStatesTableUpdateCompanionBuilder,
          (
            TodoPollState,
            BaseReferences<_$AppDatabase, $TodoPollStatesTable, TodoPollState>,
          ),
          TodoPollState,
          PrefetchHooks Function()
        > {
  $$TodoPollStatesTableTableManager(
    _$AppDatabase db,
    $TodoPollStatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodoPollStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodoPollStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodoPollStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String> seenTodoIds = const Value.absent(),
                Value<String?> createdAtHighWater = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TodoPollStatesCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                etag: etag,
                seenTodoIds: seenTodoIds,
                createdAtHighWater: createdAtHighWater,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                Value<String?> etag = const Value.absent(),
                required String seenTodoIds,
                Value<String?> createdAtHighWater = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TodoPollStatesCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                etag: etag,
                seenTodoIds: seenTodoIds,
                createdAtHighWater: createdAtHighWater,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TodoPollStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TodoPollStatesTable,
      TodoPollState,
      $$TodoPollStatesTableFilterComposer,
      $$TodoPollStatesTableOrderingComposer,
      $$TodoPollStatesTableAnnotationComposer,
      $$TodoPollStatesTableCreateCompanionBuilder,
      $$TodoPollStatesTableUpdateCompanionBuilder,
      (
        TodoPollState,
        BaseReferences<_$AppDatabase, $TodoPollStatesTable, TodoPollState>,
      ),
      TodoPollState,
      PrefetchHooks Function()
    >;
typedef $$CommentDraftsTableCreateCompanionBuilder =
    CommentDraftsCompanion Function({
      required String instanceHost,
      required String accountId,
      required int draftId,
      required int projectId,
      required int issueIid,
      required String body,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$CommentDraftsTableUpdateCompanionBuilder =
    CommentDraftsCompanion Function({
      Value<String> instanceHost,
      Value<String> accountId,
      Value<int> draftId,
      Value<int> projectId,
      Value<int> issueIid,
      Value<String> body,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$CommentDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $CommentDraftsTable> {
  $$CommentDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get draftId => $composableBuilder(
    column: $table.draftId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get issueIid => $composableBuilder(
    column: $table.issueIid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CommentDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $CommentDraftsTable> {
  $$CommentDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get draftId => $composableBuilder(
    column: $table.draftId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get issueIid => $composableBuilder(
    column: $table.issueIid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CommentDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CommentDraftsTable> {
  $$CommentDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get instanceHost => $composableBuilder(
    column: $table.instanceHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get draftId =>
      $composableBuilder(column: $table.draftId, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get issueIid =>
      $composableBuilder(column: $table.issueIid, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$CommentDraftsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CommentDraftsTable,
          CommentDraft,
          $$CommentDraftsTableFilterComposer,
          $$CommentDraftsTableOrderingComposer,
          $$CommentDraftsTableAnnotationComposer,
          $$CommentDraftsTableCreateCompanionBuilder,
          $$CommentDraftsTableUpdateCompanionBuilder,
          (
            CommentDraft,
            BaseReferences<_$AppDatabase, $CommentDraftsTable, CommentDraft>,
          ),
          CommentDraft,
          PrefetchHooks Function()
        > {
  $$CommentDraftsTableTableManager(_$AppDatabase db, $CommentDraftsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CommentDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CommentDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CommentDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> instanceHost = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> draftId = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<int> issueIid = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentDraftsCompanion(
                instanceHost: instanceHost,
                accountId: accountId,
                draftId: draftId,
                projectId: projectId,
                issueIid: issueIid,
                body: body,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String instanceHost,
                required String accountId,
                required int draftId,
                required int projectId,
                required int issueIid,
                required String body,
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CommentDraftsCompanion.insert(
                instanceHost: instanceHost,
                accountId: accountId,
                draftId: draftId,
                projectId: projectId,
                issueIid: issueIid,
                body: body,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CommentDraftsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CommentDraftsTable,
      CommentDraft,
      $$CommentDraftsTableFilterComposer,
      $$CommentDraftsTableOrderingComposer,
      $$CommentDraftsTableAnnotationComposer,
      $$CommentDraftsTableCreateCompanionBuilder,
      $$CommentDraftsTableUpdateCompanionBuilder,
      (
        CommentDraft,
        BaseReferences<_$AppDatabase, $CommentDraftsTable, CommentDraft>,
      ),
      CommentDraft,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCacheEntriesTableTableManager get localCacheEntries =>
      $$LocalCacheEntriesTableTableManager(_db, _db.localCacheEntries);
  $$CurrentUserProfilesTableTableManager get currentUserProfiles =>
      $$CurrentUserProfilesTableTableManager(_db, _db.currentUserProfiles);
  $$PaginationCursorsTableTableManager get paginationCursors =>
      $$PaginationCursorsTableTableManager(_db, _db.paginationCursors);
  $$TodoItemsTableTableManager get todoItems =>
      $$TodoItemsTableTableManager(_db, _db.todoItems);
  $$RepositoryTreeEntriesTableTableManager get repositoryTreeEntries =>
      $$RepositoryTreeEntriesTableTableManager(_db, _db.repositoryTreeEntries);
  $$RecentlyViewedItemsTableTableManager get recentlyViewedItems =>
      $$RecentlyViewedItemsTableTableManager(_db, _db.recentlyViewedItems);
  $$HomeTileOrdersTableTableManager get homeTileOrders =>
      $$HomeTileOrdersTableTableManager(_db, _db.homeTileOrders);
  $$ReleaseEntriesTableTableManager get releaseEntries =>
      $$ReleaseEntriesTableTableManager(_db, _db.releaseEntries);
  $$TodoPollStatesTableTableManager get todoPollStates =>
      $$TodoPollStatesTableTableManager(_db, _db.todoPollStates);
  $$CommentDraftsTableTableManager get commentDrafts =>
      $$CommentDraftsTableTableManager(_db, _db.commentDrafts);
}
