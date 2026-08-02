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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCacheEntriesTable localCacheEntries =
      $LocalCacheEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localCacheEntries];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCacheEntriesTableTableManager get localCacheEntries =>
      $$LocalCacheEntriesTableTableManager(_db, _db.localCacheEntries);
}
