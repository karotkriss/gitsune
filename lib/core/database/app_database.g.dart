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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCacheEntriesTable localCacheEntries =
      $LocalCacheEntriesTable(this);
  late final $CurrentUserProfilesTable currentUserProfiles =
      $CurrentUserProfilesTable(this);
  late final $PaginationCursorsTable paginationCursors =
      $PaginationCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCacheEntries,
    currentUserProfiles,
    paginationCursors,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCacheEntriesTableTableManager get localCacheEntries =>
      $$LocalCacheEntriesTableTableManager(_db, _db.localCacheEntries);
  $$CurrentUserProfilesTableTableManager get currentUserProfiles =>
      $$CurrentUserProfilesTableTableManager(_db, _db.currentUserProfiles);
  $$PaginationCursorsTableTableManager get paginationCursors =>
      $$PaginationCursorsTableTableManager(_db, _db.paginationCursors);
}
