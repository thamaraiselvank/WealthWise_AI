// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
    'age',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyIncomeMeta = const VerificationMeta(
    'monthlyIncome',
  );
  @override
  late final GeneratedColumn<double> monthlyIncome = GeneratedColumn<double>(
    'monthly_income',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyExpensesMeta = const VerificationMeta(
    'monthlyExpenses',
  );
  @override
  late final GeneratedColumn<double> monthlyExpenses = GeneratedColumn<double>(
    'monthly_expenses',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthlyEmiMeta = const VerificationMeta(
    'monthlyEmi',
  );
  @override
  late final GeneratedColumn<double> monthlyEmi = GeneratedColumn<double>(
    'monthly_emi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _savingsMeta = const VerificationMeta(
    'savings',
  );
  @override
  late final GeneratedColumn<double> savings = GeneratedColumn<double>(
    'savings',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _investmentsMeta = const VerificationMeta(
    'investments',
  );
  @override
  late final GeneratedColumn<double> investments = GeneratedColumn<double>(
    'investments',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _loanOutstandingMeta = const VerificationMeta(
    'loanOutstanding',
  );
  @override
  late final GeneratedColumn<double> loanOutstanding = GeneratedColumn<double>(
    'loan_outstanding',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dependentsMeta = const VerificationMeta(
    'dependents',
  );
  @override
  late final GeneratedColumn<int> dependents = GeneratedColumn<int>(
    'dependents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hasHealthInsuranceMeta =
      const VerificationMeta('hasHealthInsurance');
  @override
  late final GeneratedColumn<bool> hasHealthInsurance = GeneratedColumn<bool>(
    'has_health_insurance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_health_insurance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _hasTermInsuranceMeta = const VerificationMeta(
    'hasTermInsurance',
  );
  @override
  late final GeneratedColumn<bool> hasTermInsurance = GeneratedColumn<bool>(
    'has_term_insurance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_term_insurance" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _expenseBreakdownMeta = const VerificationMeta(
    'expenseBreakdown',
  );
  @override
  late final GeneratedColumn<String> expenseBreakdown = GeneratedColumn<String>(
    'expense_breakdown',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    age,
    monthlyIncome,
    monthlyExpenses,
    monthlyEmi,
    savings,
    investments,
    loanOutstanding,
    dependents,
    hasHealthInsurance,
    hasTermInsurance,
    expenseBreakdown,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
        _ageMeta,
        age.isAcceptableOrUnknown(data['age']!, _ageMeta),
      );
    } else if (isInserting) {
      context.missing(_ageMeta);
    }
    if (data.containsKey('monthly_income')) {
      context.handle(
        _monthlyIncomeMeta,
        monthlyIncome.isAcceptableOrUnknown(
          data['monthly_income']!,
          _monthlyIncomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyIncomeMeta);
    }
    if (data.containsKey('monthly_expenses')) {
      context.handle(
        _monthlyExpensesMeta,
        monthlyExpenses.isAcceptableOrUnknown(
          data['monthly_expenses']!,
          _monthlyExpensesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_monthlyExpensesMeta);
    }
    if (data.containsKey('monthly_emi')) {
      context.handle(
        _monthlyEmiMeta,
        monthlyEmi.isAcceptableOrUnknown(data['monthly_emi']!, _monthlyEmiMeta),
      );
    }
    if (data.containsKey('savings')) {
      context.handle(
        _savingsMeta,
        savings.isAcceptableOrUnknown(data['savings']!, _savingsMeta),
      );
    }
    if (data.containsKey('investments')) {
      context.handle(
        _investmentsMeta,
        investments.isAcceptableOrUnknown(
          data['investments']!,
          _investmentsMeta,
        ),
      );
    }
    if (data.containsKey('loan_outstanding')) {
      context.handle(
        _loanOutstandingMeta,
        loanOutstanding.isAcceptableOrUnknown(
          data['loan_outstanding']!,
          _loanOutstandingMeta,
        ),
      );
    }
    if (data.containsKey('dependents')) {
      context.handle(
        _dependentsMeta,
        dependents.isAcceptableOrUnknown(data['dependents']!, _dependentsMeta),
      );
    }
    if (data.containsKey('has_health_insurance')) {
      context.handle(
        _hasHealthInsuranceMeta,
        hasHealthInsurance.isAcceptableOrUnknown(
          data['has_health_insurance']!,
          _hasHealthInsuranceMeta,
        ),
      );
    }
    if (data.containsKey('has_term_insurance')) {
      context.handle(
        _hasTermInsuranceMeta,
        hasTermInsurance.isAcceptableOrUnknown(
          data['has_term_insurance']!,
          _hasTermInsuranceMeta,
        ),
      );
    }
    if (data.containsKey('expense_breakdown')) {
      context.handle(
        _expenseBreakdownMeta,
        expenseBreakdown.isAcceptableOrUnknown(
          data['expense_breakdown']!,
          _expenseBreakdownMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      age: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}age'],
      )!,
      monthlyIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_income'],
      )!,
      monthlyExpenses: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_expenses'],
      )!,
      monthlyEmi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monthly_emi'],
      )!,
      savings: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}savings'],
      )!,
      investments: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}investments'],
      )!,
      loanOutstanding: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loan_outstanding'],
      )!,
      dependents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dependents'],
      )!,
      hasHealthInsurance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_health_insurance'],
      )!,
      hasTermInsurance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_term_insurance'],
      )!,
      expenseBreakdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_breakdown'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final int id;
  final int age;
  final double monthlyIncome;
  final double monthlyExpenses;
  final double monthlyEmi;
  final double savings;
  final double investments;
  final double loanOutstanding;
  final int dependents;
  final bool hasHealthInsurance;
  final bool hasTermInsurance;

  /// JSON map of ExpenseCategory name -> monthly amount (added in schema v2).
  final String? expenseBreakdown;
  final DateTime updatedAt;
  const ProfileRow({
    required this.id,
    required this.age,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.monthlyEmi,
    required this.savings,
    required this.investments,
    required this.loanOutstanding,
    required this.dependents,
    required this.hasHealthInsurance,
    required this.hasTermInsurance,
    this.expenseBreakdown,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['age'] = Variable<int>(age);
    map['monthly_income'] = Variable<double>(monthlyIncome);
    map['monthly_expenses'] = Variable<double>(monthlyExpenses);
    map['monthly_emi'] = Variable<double>(monthlyEmi);
    map['savings'] = Variable<double>(savings);
    map['investments'] = Variable<double>(investments);
    map['loan_outstanding'] = Variable<double>(loanOutstanding);
    map['dependents'] = Variable<int>(dependents);
    map['has_health_insurance'] = Variable<bool>(hasHealthInsurance);
    map['has_term_insurance'] = Variable<bool>(hasTermInsurance);
    if (!nullToAbsent || expenseBreakdown != null) {
      map['expense_breakdown'] = Variable<String>(expenseBreakdown);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      age: Value(age),
      monthlyIncome: Value(monthlyIncome),
      monthlyExpenses: Value(monthlyExpenses),
      monthlyEmi: Value(monthlyEmi),
      savings: Value(savings),
      investments: Value(investments),
      loanOutstanding: Value(loanOutstanding),
      dependents: Value(dependents),
      hasHealthInsurance: Value(hasHealthInsurance),
      hasTermInsurance: Value(hasTermInsurance),
      expenseBreakdown: expenseBreakdown == null && nullToAbsent
          ? const Value.absent()
          : Value(expenseBreakdown),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      id: serializer.fromJson<int>(json['id']),
      age: serializer.fromJson<int>(json['age']),
      monthlyIncome: serializer.fromJson<double>(json['monthlyIncome']),
      monthlyExpenses: serializer.fromJson<double>(json['monthlyExpenses']),
      monthlyEmi: serializer.fromJson<double>(json['monthlyEmi']),
      savings: serializer.fromJson<double>(json['savings']),
      investments: serializer.fromJson<double>(json['investments']),
      loanOutstanding: serializer.fromJson<double>(json['loanOutstanding']),
      dependents: serializer.fromJson<int>(json['dependents']),
      hasHealthInsurance: serializer.fromJson<bool>(json['hasHealthInsurance']),
      hasTermInsurance: serializer.fromJson<bool>(json['hasTermInsurance']),
      expenseBreakdown: serializer.fromJson<String?>(json['expenseBreakdown']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'age': serializer.toJson<int>(age),
      'monthlyIncome': serializer.toJson<double>(monthlyIncome),
      'monthlyExpenses': serializer.toJson<double>(monthlyExpenses),
      'monthlyEmi': serializer.toJson<double>(monthlyEmi),
      'savings': serializer.toJson<double>(savings),
      'investments': serializer.toJson<double>(investments),
      'loanOutstanding': serializer.toJson<double>(loanOutstanding),
      'dependents': serializer.toJson<int>(dependents),
      'hasHealthInsurance': serializer.toJson<bool>(hasHealthInsurance),
      'hasTermInsurance': serializer.toJson<bool>(hasTermInsurance),
      'expenseBreakdown': serializer.toJson<String?>(expenseBreakdown),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileRow copyWith({
    int? id,
    int? age,
    double? monthlyIncome,
    double? monthlyExpenses,
    double? monthlyEmi,
    double? savings,
    double? investments,
    double? loanOutstanding,
    int? dependents,
    bool? hasHealthInsurance,
    bool? hasTermInsurance,
    Value<String?> expenseBreakdown = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileRow(
    id: id ?? this.id,
    age: age ?? this.age,
    monthlyIncome: monthlyIncome ?? this.monthlyIncome,
    monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
    monthlyEmi: monthlyEmi ?? this.monthlyEmi,
    savings: savings ?? this.savings,
    investments: investments ?? this.investments,
    loanOutstanding: loanOutstanding ?? this.loanOutstanding,
    dependents: dependents ?? this.dependents,
    hasHealthInsurance: hasHealthInsurance ?? this.hasHealthInsurance,
    hasTermInsurance: hasTermInsurance ?? this.hasTermInsurance,
    expenseBreakdown: expenseBreakdown.present
        ? expenseBreakdown.value
        : this.expenseBreakdown,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      id: data.id.present ? data.id.value : this.id,
      age: data.age.present ? data.age.value : this.age,
      monthlyIncome: data.monthlyIncome.present
          ? data.monthlyIncome.value
          : this.monthlyIncome,
      monthlyExpenses: data.monthlyExpenses.present
          ? data.monthlyExpenses.value
          : this.monthlyExpenses,
      monthlyEmi: data.monthlyEmi.present
          ? data.monthlyEmi.value
          : this.monthlyEmi,
      savings: data.savings.present ? data.savings.value : this.savings,
      investments: data.investments.present
          ? data.investments.value
          : this.investments,
      loanOutstanding: data.loanOutstanding.present
          ? data.loanOutstanding.value
          : this.loanOutstanding,
      dependents: data.dependents.present
          ? data.dependents.value
          : this.dependents,
      hasHealthInsurance: data.hasHealthInsurance.present
          ? data.hasHealthInsurance.value
          : this.hasHealthInsurance,
      hasTermInsurance: data.hasTermInsurance.present
          ? data.hasTermInsurance.value
          : this.hasTermInsurance,
      expenseBreakdown: data.expenseBreakdown.present
          ? data.expenseBreakdown.value
          : this.expenseBreakdown,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('monthlyExpenses: $monthlyExpenses, ')
          ..write('monthlyEmi: $monthlyEmi, ')
          ..write('savings: $savings, ')
          ..write('investments: $investments, ')
          ..write('loanOutstanding: $loanOutstanding, ')
          ..write('dependents: $dependents, ')
          ..write('hasHealthInsurance: $hasHealthInsurance, ')
          ..write('hasTermInsurance: $hasTermInsurance, ')
          ..write('expenseBreakdown: $expenseBreakdown, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    age,
    monthlyIncome,
    monthlyExpenses,
    monthlyEmi,
    savings,
    investments,
    loanOutstanding,
    dependents,
    hasHealthInsurance,
    hasTermInsurance,
    expenseBreakdown,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.id == this.id &&
          other.age == this.age &&
          other.monthlyIncome == this.monthlyIncome &&
          other.monthlyExpenses == this.monthlyExpenses &&
          other.monthlyEmi == this.monthlyEmi &&
          other.savings == this.savings &&
          other.investments == this.investments &&
          other.loanOutstanding == this.loanOutstanding &&
          other.dependents == this.dependents &&
          other.hasHealthInsurance == this.hasHealthInsurance &&
          other.hasTermInsurance == this.hasTermInsurance &&
          other.expenseBreakdown == this.expenseBreakdown &&
          other.updatedAt == this.updatedAt);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<int> id;
  final Value<int> age;
  final Value<double> monthlyIncome;
  final Value<double> monthlyExpenses;
  final Value<double> monthlyEmi;
  final Value<double> savings;
  final Value<double> investments;
  final Value<double> loanOutstanding;
  final Value<int> dependents;
  final Value<bool> hasHealthInsurance;
  final Value<bool> hasTermInsurance;
  final Value<String?> expenseBreakdown;
  final Value<DateTime> updatedAt;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.age = const Value.absent(),
    this.monthlyIncome = const Value.absent(),
    this.monthlyExpenses = const Value.absent(),
    this.monthlyEmi = const Value.absent(),
    this.savings = const Value.absent(),
    this.investments = const Value.absent(),
    this.loanOutstanding = const Value.absent(),
    this.dependents = const Value.absent(),
    this.hasHealthInsurance = const Value.absent(),
    this.hasTermInsurance = const Value.absent(),
    this.expenseBreakdown = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required int age,
    required double monthlyIncome,
    required double monthlyExpenses,
    this.monthlyEmi = const Value.absent(),
    this.savings = const Value.absent(),
    this.investments = const Value.absent(),
    this.loanOutstanding = const Value.absent(),
    this.dependents = const Value.absent(),
    this.hasHealthInsurance = const Value.absent(),
    this.hasTermInsurance = const Value.absent(),
    this.expenseBreakdown = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : age = Value(age),
       monthlyIncome = Value(monthlyIncome),
       monthlyExpenses = Value(monthlyExpenses);
  static Insertable<ProfileRow> custom({
    Expression<int>? id,
    Expression<int>? age,
    Expression<double>? monthlyIncome,
    Expression<double>? monthlyExpenses,
    Expression<double>? monthlyEmi,
    Expression<double>? savings,
    Expression<double>? investments,
    Expression<double>? loanOutstanding,
    Expression<int>? dependents,
    Expression<bool>? hasHealthInsurance,
    Expression<bool>? hasTermInsurance,
    Expression<String>? expenseBreakdown,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (age != null) 'age': age,
      if (monthlyIncome != null) 'monthly_income': monthlyIncome,
      if (monthlyExpenses != null) 'monthly_expenses': monthlyExpenses,
      if (monthlyEmi != null) 'monthly_emi': monthlyEmi,
      if (savings != null) 'savings': savings,
      if (investments != null) 'investments': investments,
      if (loanOutstanding != null) 'loan_outstanding': loanOutstanding,
      if (dependents != null) 'dependents': dependents,
      if (hasHealthInsurance != null)
        'has_health_insurance': hasHealthInsurance,
      if (hasTermInsurance != null) 'has_term_insurance': hasTermInsurance,
      if (expenseBreakdown != null) 'expense_breakdown': expenseBreakdown,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<int>? age,
    Value<double>? monthlyIncome,
    Value<double>? monthlyExpenses,
    Value<double>? monthlyEmi,
    Value<double>? savings,
    Value<double>? investments,
    Value<double>? loanOutstanding,
    Value<int>? dependents,
    Value<bool>? hasHealthInsurance,
    Value<bool>? hasTermInsurance,
    Value<String?>? expenseBreakdown,
    Value<DateTime>? updatedAt,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      age: age ?? this.age,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      monthlyExpenses: monthlyExpenses ?? this.monthlyExpenses,
      monthlyEmi: monthlyEmi ?? this.monthlyEmi,
      savings: savings ?? this.savings,
      investments: investments ?? this.investments,
      loanOutstanding: loanOutstanding ?? this.loanOutstanding,
      dependents: dependents ?? this.dependents,
      hasHealthInsurance: hasHealthInsurance ?? this.hasHealthInsurance,
      hasTermInsurance: hasTermInsurance ?? this.hasTermInsurance,
      expenseBreakdown: expenseBreakdown ?? this.expenseBreakdown,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (monthlyIncome.present) {
      map['monthly_income'] = Variable<double>(monthlyIncome.value);
    }
    if (monthlyExpenses.present) {
      map['monthly_expenses'] = Variable<double>(monthlyExpenses.value);
    }
    if (monthlyEmi.present) {
      map['monthly_emi'] = Variable<double>(monthlyEmi.value);
    }
    if (savings.present) {
      map['savings'] = Variable<double>(savings.value);
    }
    if (investments.present) {
      map['investments'] = Variable<double>(investments.value);
    }
    if (loanOutstanding.present) {
      map['loan_outstanding'] = Variable<double>(loanOutstanding.value);
    }
    if (dependents.present) {
      map['dependents'] = Variable<int>(dependents.value);
    }
    if (hasHealthInsurance.present) {
      map['has_health_insurance'] = Variable<bool>(hasHealthInsurance.value);
    }
    if (hasTermInsurance.present) {
      map['has_term_insurance'] = Variable<bool>(hasTermInsurance.value);
    }
    if (expenseBreakdown.present) {
      map['expense_breakdown'] = Variable<String>(expenseBreakdown.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('age: $age, ')
          ..write('monthlyIncome: $monthlyIncome, ')
          ..write('monthlyExpenses: $monthlyExpenses, ')
          ..write('monthlyEmi: $monthlyEmi, ')
          ..write('savings: $savings, ')
          ..write('investments: $investments, ')
          ..write('loanOutstanding: $loanOutstanding, ')
          ..write('dependents: $dependents, ')
          ..write('hasHealthInsurance: $hasHealthInsurance, ')
          ..write('hasTermInsurance: $hasTermInsurance, ')
          ..write('expenseBreakdown: $expenseBreakdown, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<GoalType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<GoalType>($GoalsTable.$convertertype);
  static const VerificationMeta _todayCostMeta = const VerificationMeta(
    'todayCost',
  );
  @override
  late final GeneratedColumn<double> todayCost = GeneratedColumn<double>(
    'today_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearsMeta = const VerificationMeta('years');
  @override
  late final GeneratedColumn<double> years = GeneratedColumn<double>(
    'years',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _alreadySavedMeta = const VerificationMeta(
    'alreadySaved',
  );
  @override
  late final GeneratedColumn<double> alreadySaved = GeneratedColumn<double>(
    'already_saved',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    todayCost,
    years,
    alreadySaved,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
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
    if (data.containsKey('today_cost')) {
      context.handle(
        _todayCostMeta,
        todayCost.isAcceptableOrUnknown(data['today_cost']!, _todayCostMeta),
      );
    } else if (isInserting) {
      context.missing(_todayCostMeta);
    }
    if (data.containsKey('years')) {
      context.handle(
        _yearsMeta,
        years.isAcceptableOrUnknown(data['years']!, _yearsMeta),
      );
    } else if (isInserting) {
      context.missing(_yearsMeta);
    }
    if (data.containsKey('already_saved')) {
      context.handle(
        _alreadySavedMeta,
        alreadySaved.isAcceptableOrUnknown(
          data['already_saved']!,
          _alreadySavedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $GoalsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      todayCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}today_cost'],
      )!,
      years: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}years'],
      )!,
      alreadySaved: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}already_saved'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<GoalType, String, String> $convertertype =
      const EnumNameConverter<GoalType>(GoalType.values);
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final String name;
  final GoalType type;
  final double todayCost;
  final double years;
  final double alreadySaved;
  final DateTime createdAt;
  const GoalRow({
    required this.id,
    required this.name,
    required this.type,
    required this.todayCost,
    required this.years,
    required this.alreadySaved,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($GoalsTable.$convertertype.toSql(type));
    }
    map['today_cost'] = Variable<double>(todayCost);
    map['years'] = Variable<double>(years);
    map['already_saved'] = Variable<double>(alreadySaved);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      todayCost: Value(todayCost),
      years: Value(years),
      alreadySaved: Value(alreadySaved),
      createdAt: Value(createdAt),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $GoalsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      todayCost: serializer.fromJson<double>(json['todayCost']),
      years: serializer.fromJson<double>(json['years']),
      alreadySaved: serializer.fromJson<double>(json['alreadySaved']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $GoalsTable.$convertertype.toJson(type),
      ),
      'todayCost': serializer.toJson<double>(todayCost),
      'years': serializer.toJson<double>(years),
      'alreadySaved': serializer.toJson<double>(alreadySaved),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GoalRow copyWith({
    String? id,
    String? name,
    GoalType? type,
    double? todayCost,
    double? years,
    double? alreadySaved,
    DateTime? createdAt,
  }) => GoalRow(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    todayCost: todayCost ?? this.todayCost,
    years: years ?? this.years,
    alreadySaved: alreadySaved ?? this.alreadySaved,
    createdAt: createdAt ?? this.createdAt,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      todayCost: data.todayCost.present ? data.todayCost.value : this.todayCost,
      years: data.years.present ? data.years.value : this.years,
      alreadySaved: data.alreadySaved.present
          ? data.alreadySaved.value
          : this.alreadySaved,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('todayCost: $todayCost, ')
          ..write('years: $years, ')
          ..write('alreadySaved: $alreadySaved, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, todayCost, years, alreadySaved, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.todayCost == this.todayCost &&
          other.years == this.years &&
          other.alreadySaved == this.alreadySaved &&
          other.createdAt == this.createdAt);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<GoalType> type;
  final Value<double> todayCost;
  final Value<double> years;
  final Value<double> alreadySaved;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.todayCost = const Value.absent(),
    this.years = const Value.absent(),
    this.alreadySaved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    required GoalType type,
    required double todayCost,
    required double years,
    this.alreadySaved = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       type = Value(type),
       todayCost = Value(todayCost),
       years = Value(years);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? todayCost,
    Expression<double>? years,
    Expression<double>? alreadySaved,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (todayCost != null) 'today_cost': todayCost,
      if (years != null) 'years': years,
      if (alreadySaved != null) 'already_saved': alreadySaved,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<GoalType>? type,
    Value<double>? todayCost,
    Value<double>? years,
    Value<double>? alreadySaved,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      todayCost: todayCost ?? this.todayCost,
      years: years ?? this.years,
      alreadySaved: alreadySaved ?? this.alreadySaved,
      createdAt: createdAt ?? this.createdAt,
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
    if (type.present) {
      map['type'] = Variable<String>(
        $GoalsTable.$convertertype.toSql(type.value),
      );
    }
    if (todayCost.present) {
      map['today_cost'] = Variable<double>(todayCost.value);
    }
    if (years.present) {
      map['years'] = Variable<double>(years.value);
    }
    if (alreadySaved.present) {
      map['already_saved'] = Variable<double>(alreadySaved.value);
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
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('todayCost: $todayCost, ')
          ..write('years: $years, ')
          ..write('alreadySaved: $alreadySaved, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssetType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AssetType>($AssetsTable.$convertertype);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, type, label, value, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $AssetsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AssetType, String, String> $convertertype =
      const EnumNameConverter<AssetType>(AssetType.values);
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  final String id;
  final AssetType type;
  final String label;
  final double value;
  final int position;
  const AssetRow({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>($AssetsTable.$convertertype.toSql(type));
    }
    map['label'] = Variable<String>(label);
    map['value'] = Variable<double>(value);
    map['position'] = Variable<int>(position);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      type: Value(type),
      label: Value(label),
      value: Value(value),
      position: Value(position),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      id: serializer.fromJson<String>(json['id']),
      type: $AssetsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      label: serializer.fromJson<String>(json['label']),
      value: serializer.fromJson<double>(json['value']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $AssetsTable.$convertertype.toJson(type),
      ),
      'label': serializer.toJson<String>(label),
      'value': serializer.toJson<double>(value),
      'position': serializer.toJson<int>(position),
    };
  }

  AssetRow copyWith({
    String? id,
    AssetType? type,
    String? label,
    double? value,
    int? position,
  }) => AssetRow(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label ?? this.label,
    value: value ?? this.value,
    position: position ?? this.position,
  );
  AssetRow copyWithCompanion(AssetsCompanion data) {
    return AssetRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      value: data.value.present ? data.value.value : this.value,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, label, value, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.label == this.label &&
          other.value == this.value &&
          other.position == this.position);
}

class AssetsCompanion extends UpdateCompanion<AssetRow> {
  final Value<String> id;
  final Value<AssetType> type;
  final Value<String> label;
  final Value<double> value;
  final Value<int> position;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.value = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required AssetType type,
    this.label = const Value.absent(),
    required double value,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       value = Value(value);
  static Insertable<AssetRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? label,
    Expression<double>? value,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (value != null) 'value': value,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith({
    Value<String>? id,
    Value<AssetType>? type,
    Value<String>? label,
    Value<double>? value,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      value: value ?? this.value,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AssetsTable.$convertertype.toSql(type.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
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
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('value: $value, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, LoanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LoanType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LoanType>($LoansTable.$convertertype);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _outstandingMeta = const VerificationMeta(
    'outstanding',
  );
  @override
  late final GeneratedColumn<double> outstanding = GeneratedColumn<double>(
    'outstanding',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emiMeta = const VerificationMeta('emi');
  @override
  late final GeneratedColumn<double> emi = GeneratedColumn<double>(
    'emi',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _annualRateMeta = const VerificationMeta(
    'annualRate',
  );
  @override
  late final GeneratedColumn<double> annualRate = GeneratedColumn<double>(
    'annual_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    label,
    outstanding,
    emi,
    annualRate,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('outstanding')) {
      context.handle(
        _outstandingMeta,
        outstanding.isAcceptableOrUnknown(
          data['outstanding']!,
          _outstandingMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outstandingMeta);
    }
    if (data.containsKey('emi')) {
      context.handle(
        _emiMeta,
        emi.isAcceptableOrUnknown(data['emi']!, _emiMeta),
      );
    }
    if (data.containsKey('annual_rate')) {
      context.handle(
        _annualRateMeta,
        annualRate.isAcceptableOrUnknown(data['annual_rate']!, _annualRateMeta),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: $LoansTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      outstanding: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}outstanding'],
      )!,
      emi: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}emi'],
      )!,
      annualRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}annual_rate'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LoanType, String, String> $convertertype =
      const EnumNameConverter<LoanType>(LoanType.values);
}

class LoanRow extends DataClass implements Insertable<LoanRow> {
  final String id;
  final LoanType type;
  final String label;
  final double outstanding;
  final double emi;

  /// Annual rate (0.09 = 9%); null when unknown.
  final double? annualRate;
  final int position;
  const LoanRow({
    required this.id,
    required this.type,
    required this.label,
    required this.outstanding,
    required this.emi,
    this.annualRate,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['type'] = Variable<String>($LoansTable.$convertertype.toSql(type));
    }
    map['label'] = Variable<String>(label);
    map['outstanding'] = Variable<double>(outstanding);
    map['emi'] = Variable<double>(emi);
    if (!nullToAbsent || annualRate != null) {
      map['annual_rate'] = Variable<double>(annualRate);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      type: Value(type),
      label: Value(label),
      outstanding: Value(outstanding),
      emi: Value(emi),
      annualRate: annualRate == null && nullToAbsent
          ? const Value.absent()
          : Value(annualRate),
      position: Value(position),
    );
  }

  factory LoanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanRow(
      id: serializer.fromJson<String>(json['id']),
      type: $LoansTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      label: serializer.fromJson<String>(json['label']),
      outstanding: serializer.fromJson<double>(json['outstanding']),
      emi: serializer.fromJson<double>(json['emi']),
      annualRate: serializer.fromJson<double?>(json['annualRate']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(
        $LoansTable.$convertertype.toJson(type),
      ),
      'label': serializer.toJson<String>(label),
      'outstanding': serializer.toJson<double>(outstanding),
      'emi': serializer.toJson<double>(emi),
      'annualRate': serializer.toJson<double?>(annualRate),
      'position': serializer.toJson<int>(position),
    };
  }

  LoanRow copyWith({
    String? id,
    LoanType? type,
    String? label,
    double? outstanding,
    double? emi,
    Value<double?> annualRate = const Value.absent(),
    int? position,
  }) => LoanRow(
    id: id ?? this.id,
    type: type ?? this.type,
    label: label ?? this.label,
    outstanding: outstanding ?? this.outstanding,
    emi: emi ?? this.emi,
    annualRate: annualRate.present ? annualRate.value : this.annualRate,
    position: position ?? this.position,
  );
  LoanRow copyWithCompanion(LoansCompanion data) {
    return LoanRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      label: data.label.present ? data.label.value : this.label,
      outstanding: data.outstanding.present
          ? data.outstanding.value
          : this.outstanding,
      emi: data.emi.present ? data.emi.value : this.emi,
      annualRate: data.annualRate.present
          ? data.annualRate.value
          : this.annualRate,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('outstanding: $outstanding, ')
          ..write('emi: $emi, ')
          ..write('annualRate: $annualRate, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, label, outstanding, emi, annualRate, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.label == this.label &&
          other.outstanding == this.outstanding &&
          other.emi == this.emi &&
          other.annualRate == this.annualRate &&
          other.position == this.position);
}

class LoansCompanion extends UpdateCompanion<LoanRow> {
  final Value<String> id;
  final Value<LoanType> type;
  final Value<String> label;
  final Value<double> outstanding;
  final Value<double> emi;
  final Value<double?> annualRate;
  final Value<int> position;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.label = const Value.absent(),
    this.outstanding = const Value.absent(),
    this.emi = const Value.absent(),
    this.annualRate = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String id,
    required LoanType type,
    this.label = const Value.absent(),
    required double outstanding,
    this.emi = const Value.absent(),
    this.annualRate = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       outstanding = Value(outstanding);
  static Insertable<LoanRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? label,
    Expression<double>? outstanding,
    Expression<double>? emi,
    Expression<double>? annualRate,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (label != null) 'label': label,
      if (outstanding != null) 'outstanding': outstanding,
      if (emi != null) 'emi': emi,
      if (annualRate != null) 'annual_rate': annualRate,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith({
    Value<String>? id,
    Value<LoanType>? type,
    Value<String>? label,
    Value<double>? outstanding,
    Value<double>? emi,
    Value<double?>? annualRate,
    Value<int>? position,
    Value<int>? rowid,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      label: label ?? this.label,
      outstanding: outstanding ?? this.outstanding,
      emi: emi ?? this.emi,
      annualRate: annualRate ?? this.annualRate,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $LoansTable.$convertertype.toSql(type.value),
      );
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (outstanding.present) {
      map['outstanding'] = Variable<double>(outstanding.value);
    }
    if (emi.present) {
      map['emi'] = Variable<double>(emi.value);
    }
    if (annualRate.present) {
      map['annual_rate'] = Variable<double>(annualRate.value);
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
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('label: $label, ')
          ..write('outstanding: $outstanding, ')
          ..write('emi: $emi, ')
          ..write('annualRate: $annualRate, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    goals,
    settings,
    assets,
    loans,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  required int age,
  required double monthlyIncome,
  required double monthlyExpenses,
  Value<double> monthlyEmi,
  Value<double> savings,
  Value<double> investments,
  Value<double> loanOutstanding,
  Value<int> dependents,
  Value<bool> hasHealthInsurance,
  Value<bool> hasTermInsurance,
  Value<String?> expenseBreakdown,
  Value<DateTime> updatedAt,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<int> id,
  Value<int> age,
  Value<double> monthlyIncome,
  Value<double> monthlyExpenses,
  Value<double> monthlyEmi,
  Value<double> savings,
  Value<double> investments,
  Value<double> loanOutstanding,
  Value<int> dependents,
  Value<bool> hasHealthInsurance,
  Value<bool> hasTermInsurance,
  Value<String?> expenseBreakdown,
  Value<DateTime> updatedAt,
});

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyExpenses => $composableBuilder(
    column: $table.monthlyExpenses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get savings => $composableBuilder(
    column: $table.savings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get investments => $composableBuilder(
    column: $table.investments,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loanOutstanding => $composableBuilder(
    column: $table.loanOutstanding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dependents => $composableBuilder(
    column: $table.dependents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasHealthInsurance => $composableBuilder(
    column: $table.hasHealthInsurance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasTermInsurance => $composableBuilder(
    column: $table.hasTermInsurance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseBreakdown => $composableBuilder(
    column: $table.expenseBreakdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get age => $composableBuilder(
    column: $table.age,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyExpenses => $composableBuilder(
    column: $table.monthlyExpenses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get savings => $composableBuilder(
    column: $table.savings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get investments => $composableBuilder(
    column: $table.investments,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loanOutstanding => $composableBuilder(
    column: $table.loanOutstanding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dependents => $composableBuilder(
    column: $table.dependents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasHealthInsurance => $composableBuilder(
    column: $table.hasHealthInsurance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasTermInsurance => $composableBuilder(
    column: $table.hasTermInsurance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseBreakdown => $composableBuilder(
    column: $table.expenseBreakdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<double> get monthlyIncome => $composableBuilder(
    column: $table.monthlyIncome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyExpenses => $composableBuilder(
    column: $table.monthlyExpenses,
    builder: (column) => column,
  );

  GeneratedColumn<double> get monthlyEmi => $composableBuilder(
    column: $table.monthlyEmi,
    builder: (column) => column,
  );

  GeneratedColumn<double> get savings =>
      $composableBuilder(column: $table.savings, builder: (column) => column);

  GeneratedColumn<double> get investments => $composableBuilder(
    column: $table.investments,
    builder: (column) => column,
  );

  GeneratedColumn<double> get loanOutstanding => $composableBuilder(
    column: $table.loanOutstanding,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dependents => $composableBuilder(
    column: $table.dependents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasHealthInsurance => $composableBuilder(
    column: $table.hasHealthInsurance,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasTermInsurance => $composableBuilder(
    column: $table.hasTermInsurance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expenseBreakdown => $composableBuilder(
    column: $table.expenseBreakdown,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> age = const Value.absent(),
                Value<double> monthlyIncome = const Value.absent(),
                Value<double> monthlyExpenses = const Value.absent(),
                Value<double> monthlyEmi = const Value.absent(),
                Value<double> savings = const Value.absent(),
                Value<double> investments = const Value.absent(),
                Value<double> loanOutstanding = const Value.absent(),
                Value<int> dependents = const Value.absent(),
                Value<bool> hasHealthInsurance = const Value.absent(),
                Value<bool> hasTermInsurance = const Value.absent(),
                Value<String?> expenseBreakdown = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                age: age,
                monthlyIncome: monthlyIncome,
                monthlyExpenses: monthlyExpenses,
                monthlyEmi: monthlyEmi,
                savings: savings,
                investments: investments,
                loanOutstanding: loanOutstanding,
                dependents: dependents,
                hasHealthInsurance: hasHealthInsurance,
                hasTermInsurance: hasTermInsurance,
                expenseBreakdown: expenseBreakdown,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int age,
                required double monthlyIncome,
                required double monthlyExpenses,
                Value<double> monthlyEmi = const Value.absent(),
                Value<double> savings = const Value.absent(),
                Value<double> investments = const Value.absent(),
                Value<double> loanOutstanding = const Value.absent(),
                Value<int> dependents = const Value.absent(),
                Value<bool> hasHealthInsurance = const Value.absent(),
                Value<bool> hasTermInsurance = const Value.absent(),
                Value<String?> expenseBreakdown = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                age: age,
                monthlyIncome: monthlyIncome,
                monthlyExpenses: monthlyExpenses,
                monthlyEmi: monthlyEmi,
                savings: savings,
                investments: investments,
                loanOutstanding: loanOutstanding,
                dependents: dependents,
                hasHealthInsurance: hasHealthInsurance,
                hasTermInsurance: hasTermInsurance,
                expenseBreakdown: expenseBreakdown,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String name,
  required GoalType type,
  required double todayCost,
  required double years,
  Value<double> alreadySaved,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<GoalType> type,
  Value<double> todayCost,
  Value<double> years,
  Value<double> alreadySaved,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<GoalType, GoalType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get todayCost => $composableBuilder(
    column: $table.todayCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get years => $composableBuilder(
    column: $table.years,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get alreadySaved => $composableBuilder(
    column: $table.alreadySaved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get todayCost => $composableBuilder(
    column: $table.todayCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get years => $composableBuilder(
    column: $table.years,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get alreadySaved => $composableBuilder(
    column: $table.alreadySaved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
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

  GeneratedColumnWithTypeConverter<GoalType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get todayCost =>
      $composableBuilder(column: $table.todayCost, builder: (column) => column);

  GeneratedColumn<double> get years =>
      $composableBuilder(column: $table.years, builder: (column) => column);

  GeneratedColumn<double> get alreadySaved => $composableBuilder(
    column: $table.alreadySaved,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GoalType> type = const Value.absent(),
                Value<double> todayCost = const Value.absent(),
                Value<double> years = const Value.absent(),
                Value<double> alreadySaved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                type: type,
                todayCost: todayCost,
                years: years,
                alreadySaved: alreadySaved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required GoalType type,
                required double todayCost,
                required double years,
                Value<double> alreadySaved = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                type: type,
                todayCost: todayCost,
                years: years,
                alreadySaved: alreadySaved,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  required String id,
  required AssetType type,
  Value<String> label,
  required double value,
  Value<int> position,
  Value<int> rowid,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<String> id,
  Value<AssetType> type,
  Value<String> label,
  Value<double> value,
  Value<int> position,
  Value<int> rowid,
});

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
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

  ColumnWithTypeConverterFilters<AssetType, AssetType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          AssetRow,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (AssetRow, BaseReferences<_$AppDatabase, $AssetsTable, AssetRow>),
          AssetRow,
          PrefetchHooks Function()
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<AssetType> type = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                type: type,
                label: label,
                value: value,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required AssetType type,
                Value<String> label = const Value.absent(),
                required double value,
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                type: type,
                label: label,
                value: value,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetsTable, AssetRow>(table),
                  BaseReferences<_$AppDatabase, $AssetsTable, AssetRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      AssetRow,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (AssetRow, BaseReferences<_$AppDatabase, $AssetsTable, AssetRow>),
      AssetRow,
      PrefetchHooks Function()
    >;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  required String id,
  required LoanType type,
  Value<String> label,
  required double outstanding,
  Value<double> emi,
  Value<double?> annualRate,
  Value<int> position,
  Value<int> rowid,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  Value<LoanType> type,
  Value<String> label,
  Value<double> outstanding,
  Value<double> emi,
  Value<double?> annualRate,
  Value<int> position,
  Value<int> rowid,
});

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
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

  ColumnWithTypeConverterFilters<LoanType, LoanType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get emi => $composableBuilder(
    column: $table.emi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get emi => $composableBuilder(
    column: $table.emi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoanType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get outstanding => $composableBuilder(
    column: $table.outstanding,
    builder: (column) => column,
  );

  GeneratedColumn<double> get emi =>
      $composableBuilder(column: $table.emi, builder: (column) => column);

  GeneratedColumn<double> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          LoanRow,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (LoanRow, BaseReferences<_$AppDatabase, $LoansTable, LoanRow>),
          LoanRow,
          PrefetchHooks Function()
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<LoanType> type = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<double> outstanding = const Value.absent(),
                Value<double> emi = const Value.absent(),
                Value<double?> annualRate = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                type: type,
                label: label,
                outstanding: outstanding,
                emi: emi,
                annualRate: annualRate,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required LoanType type,
                Value<String> label = const Value.absent(),
                required double outstanding,
                Value<double> emi = const Value.absent(),
                Value<double?> annualRate = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                type: type,
                label: label,
                outstanding: outstanding,
                emi: emi,
                annualRate: annualRate,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoansTable, LoanRow>(table),
                  BaseReferences<_$AppDatabase, $LoansTable, LoanRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      LoanRow,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (LoanRow, BaseReferences<_$AppDatabase, $LoansTable, LoanRow>),
      LoanRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
}
