// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, color, userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      ),
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final String? userId;
  const LocalCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.userId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      userId: serializer.fromJson<String?>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'userId': serializer.toJson<String?>(userId),
    };
  }

  LocalCategory copyWith({
    String? id,
    String? name,
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    Value<String?> userId = const Value.absent(),
  }) => LocalCategory(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    userId: userId.present ? userId.value : this.userId,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      userId: data.userId.present ? data.userId.value : this.userId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, color, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.userId == this.userId);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<String?> userId;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.userId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<String>? userId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (userId != null) 'user_id': userId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? icon,
    Value<String?>? color,
    Value<String?>? userId,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('userId: $userId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalExpensesTable extends LocalExpenses
    with TableInfo<$LocalExpensesTable, LocalExpense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMeta = const VerificationMeta(
    'transactionDate',
  );
  @override
  late final GeneratedColumn<DateTime> transactionDate =
      GeneratedColumn<DateTime>(
        'transaction_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _screenshotUrlMeta = const VerificationMeta(
    'screenshotUrl',
  );
  @override
  late final GeneratedColumn<String> screenshotUrl = GeneratedColumn<String>(
    'screenshot_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    description,
    amount,
    transactionDate,
    categoryId,
    userId,
    screenshotUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalExpense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_date')) {
      context.handle(
        _transactionDateMeta,
        transactionDate.isAcceptableOrUnknown(
          data['transaction_date']!,
          _transactionDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('screenshot_url')) {
      context.handle(
        _screenshotUrlMeta,
        screenshotUrl.isAcceptableOrUnknown(
          data['screenshot_url']!,
          _screenshotUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalExpense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalExpense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      transactionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}transaction_date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      screenshotUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}screenshot_url'],
      ),
    );
  }

  @override
  $LocalExpensesTable createAlias(String alias) {
    return $LocalExpensesTable(attachedDatabase, alias);
  }
}

class LocalExpense extends DataClass implements Insertable<LocalExpense> {
  final String id;
  final String? description;
  final double amount;
  final DateTime transactionDate;
  final String categoryId;
  final String userId;
  final String? screenshotUrl;
  const LocalExpense({
    required this.id,
    this.description,
    required this.amount,
    required this.transactionDate,
    required this.categoryId,
    required this.userId,
    this.screenshotUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['amount'] = Variable<double>(amount);
    map['transaction_date'] = Variable<DateTime>(transactionDate);
    map['category_id'] = Variable<String>(categoryId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || screenshotUrl != null) {
      map['screenshot_url'] = Variable<String>(screenshotUrl);
    }
    return map;
  }

  LocalExpensesCompanion toCompanion(bool nullToAbsent) {
    return LocalExpensesCompanion(
      id: Value(id),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: Value(amount),
      transactionDate: Value(transactionDate),
      categoryId: Value(categoryId),
      userId: Value(userId),
      screenshotUrl: screenshotUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(screenshotUrl),
    );
  }

  factory LocalExpense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalExpense(
      id: serializer.fromJson<String>(json['id']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<double>(json['amount']),
      transactionDate: serializer.fromJson<DateTime>(json['transactionDate']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      userId: serializer.fromJson<String>(json['userId']),
      screenshotUrl: serializer.fromJson<String?>(json['screenshotUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<double>(amount),
      'transactionDate': serializer.toJson<DateTime>(transactionDate),
      'categoryId': serializer.toJson<String>(categoryId),
      'userId': serializer.toJson<String>(userId),
      'screenshotUrl': serializer.toJson<String?>(screenshotUrl),
    };
  }

  LocalExpense copyWith({
    String? id,
    Value<String?> description = const Value.absent(),
    double? amount,
    DateTime? transactionDate,
    String? categoryId,
    String? userId,
    Value<String?> screenshotUrl = const Value.absent(),
  }) => LocalExpense(
    id: id ?? this.id,
    description: description.present ? description.value : this.description,
    amount: amount ?? this.amount,
    transactionDate: transactionDate ?? this.transactionDate,
    categoryId: categoryId ?? this.categoryId,
    userId: userId ?? this.userId,
    screenshotUrl: screenshotUrl.present
        ? screenshotUrl.value
        : this.screenshotUrl,
  );
  LocalExpense copyWithCompanion(LocalExpensesCompanion data) {
    return LocalExpense(
      id: data.id.present ? data.id.value : this.id,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionDate: data.transactionDate.present
          ? data.transactionDate.value
          : this.transactionDate,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      userId: data.userId.present ? data.userId.value : this.userId,
      screenshotUrl: data.screenshotUrl.present
          ? data.screenshotUrl.value
          : this.screenshotUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpense(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('userId: $userId, ')
          ..write('screenshotUrl: $screenshotUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    description,
    amount,
    transactionDate,
    categoryId,
    userId,
    screenshotUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalExpense &&
          other.id == this.id &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.transactionDate == this.transactionDate &&
          other.categoryId == this.categoryId &&
          other.userId == this.userId &&
          other.screenshotUrl == this.screenshotUrl);
}

class LocalExpensesCompanion extends UpdateCompanion<LocalExpense> {
  final Value<String> id;
  final Value<String?> description;
  final Value<double> amount;
  final Value<DateTime> transactionDate;
  final Value<String> categoryId;
  final Value<String> userId;
  final Value<String?> screenshotUrl;
  final Value<int> rowid;
  const LocalExpensesCompanion({
    this.id = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionDate = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.userId = const Value.absent(),
    this.screenshotUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalExpensesCompanion.insert({
    required String id,
    this.description = const Value.absent(),
    required double amount,
    required DateTime transactionDate,
    required String categoryId,
    required String userId,
    this.screenshotUrl = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       transactionDate = Value(transactionDate),
       categoryId = Value(categoryId),
       userId = Value(userId);
  static Insertable<LocalExpense> custom({
    Expression<String>? id,
    Expression<String>? description,
    Expression<double>? amount,
    Expression<DateTime>? transactionDate,
    Expression<String>? categoryId,
    Expression<String>? userId,
    Expression<String>? screenshotUrl,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (transactionDate != null) 'transaction_date': transactionDate,
      if (categoryId != null) 'category_id': categoryId,
      if (userId != null) 'user_id': userId,
      if (screenshotUrl != null) 'screenshot_url': screenshotUrl,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalExpensesCompanion copyWith({
    Value<String>? id,
    Value<String?>? description,
    Value<double>? amount,
    Value<DateTime>? transactionDate,
    Value<String>? categoryId,
    Value<String>? userId,
    Value<String?>? screenshotUrl,
    Value<int>? rowid,
  }) {
    return LocalExpensesCompanion(
      id: id ?? this.id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      transactionDate: transactionDate ?? this.transactionDate,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      screenshotUrl: screenshotUrl ?? this.screenshotUrl,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (transactionDate.present) {
      map['transaction_date'] = Variable<DateTime>(transactionDate.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (screenshotUrl.present) {
      map['screenshot_url'] = Variable<String>(screenshotUrl.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalExpensesCompanion(')
          ..write('id: $id, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('transactionDate: $transactionDate, ')
          ..write('categoryId: $categoryId, ')
          ..write('userId: $userId, ')
          ..write('screenshotUrl: $screenshotUrl, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalExpensesTable localExpenses = $LocalExpensesTable(this);
  late final CategoryDao categoryDao = CategoryDao(this as AppDatabase);
  late final ExpenseDao expenseDao = ExpenseDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCategories,
    localExpenses,
  ];
}

typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String id,
      required String name,
      Value<String?> icon,
      Value<String?> color,
      Value<String?> userId,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> icon,
      Value<String?> color,
      Value<String?> userId,
      Value<int> rowid,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategory,
            BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
          ),
          LocalCategory,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                color: color,
                userId: userId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<String?> userId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                color: color,
                userId: userId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategory,
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
      ),
      LocalCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalExpensesTableCreateCompanionBuilder =
    LocalExpensesCompanion Function({
      required String id,
      Value<String?> description,
      required double amount,
      required DateTime transactionDate,
      required String categoryId,
      required String userId,
      Value<String?> screenshotUrl,
      Value<int> rowid,
    });
typedef $$LocalExpensesTableUpdateCompanionBuilder =
    LocalExpensesCompanion Function({
      Value<String> id,
      Value<String?> description,
      Value<double> amount,
      Value<DateTime> transactionDate,
      Value<String> categoryId,
      Value<String> userId,
      Value<String?> screenshotUrl,
      Value<int> rowid,
    });

class $$LocalExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get screenshotUrl => $composableBuilder(
    column: $table.screenshotUrl,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get screenshotUrl => $composableBuilder(
    column: $table.screenshotUrl,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalExpensesTable> {
  $$LocalExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get transactionDate => $composableBuilder(
    column: $table.transactionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get screenshotUrl => $composableBuilder(
    column: $table.screenshotUrl,
    builder: (column) => column,
  );
}

class $$LocalExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalExpensesTable,
          LocalExpense,
          $$LocalExpensesTableFilterComposer,
          $$LocalExpensesTableOrderingComposer,
          $$LocalExpensesTableAnnotationComposer,
          $$LocalExpensesTableCreateCompanionBuilder,
          $$LocalExpensesTableUpdateCompanionBuilder,
          (
            LocalExpense,
            BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
          ),
          LocalExpense,
          PrefetchHooks Function()
        > {
  $$LocalExpensesTableTableManager(_$AppDatabase db, $LocalExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> transactionDate = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String?> screenshotUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion(
                id: id,
                description: description,
                amount: amount,
                transactionDate: transactionDate,
                categoryId: categoryId,
                userId: userId,
                screenshotUrl: screenshotUrl,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> description = const Value.absent(),
                required double amount,
                required DateTime transactionDate,
                required String categoryId,
                required String userId,
                Value<String?> screenshotUrl = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalExpensesCompanion.insert(
                id: id,
                description: description,
                amount: amount,
                transactionDate: transactionDate,
                categoryId: categoryId,
                userId: userId,
                screenshotUrl: screenshotUrl,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalExpensesTable,
      LocalExpense,
      $$LocalExpensesTableFilterComposer,
      $$LocalExpensesTableOrderingComposer,
      $$LocalExpensesTableAnnotationComposer,
      $$LocalExpensesTableCreateCompanionBuilder,
      $$LocalExpensesTableUpdateCompanionBuilder,
      (
        LocalExpense,
        BaseReferences<_$AppDatabase, $LocalExpensesTable, LocalExpense>,
      ),
      LocalExpense,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalExpensesTableTableManager get localExpenses =>
      $$LocalExpensesTableTableManager(_db, _db.localExpenses);
}

mixin _$CategoryDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalCategoriesTable get localCategories => attachedDatabase.localCategories;
}
mixin _$ExpenseDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalExpensesTable get localExpenses => attachedDatabase.localExpenses;
}
