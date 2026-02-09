// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MedicinesTypesTable extends MedicinesTypes
    with TableInfo<$MedicinesTypesTable, MedicinesType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicinesType> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicinesType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicinesType(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $MedicinesTypesTable createAlias(String alias) {
    return $MedicinesTypesTable(attachedDatabase, alias);
  }
}

class MedicinesType extends DataClass implements Insertable<MedicinesType> {
  final int id;
  final String name;
  const MedicinesType({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  MedicinesTypesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesTypesCompanion(id: Value(id), name: Value(name));
  }

  factory MedicinesType.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicinesType(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  MedicinesType copyWith({int? id, String? name}) =>
      MedicinesType(id: id ?? this.id, name: name ?? this.name);
  MedicinesType copyWithCompanion(MedicinesTypesCompanion data) {
    return MedicinesType(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesType(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicinesType &&
          other.id == this.id &&
          other.name == this.name);
}

class MedicinesTypesCompanion extends UpdateCompanion<MedicinesType> {
  final Value<int> id;
  final Value<String> name;
  const MedicinesTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  MedicinesTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<MedicinesType> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  MedicinesTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return MedicinesTypesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $MedicinesTable extends Medicines
    with TableInfo<$MedicinesTable, Medicine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines_types (id)',
    ),
  );
  static const VerificationMeta _totalQuantityMeta = const VerificationMeta(
    'totalQuantity',
  );
  @override
  late final GeneratedColumn<int> totalQuantity = GeneratedColumn<int>(
    'total_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lowStockAlertMeta = const VerificationMeta(
    'lowStockAlert',
  );
  @override
  late final GeneratedColumn<bool> lowStockAlert = GeneratedColumn<bool>(
    'low_stock_alert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("low_stock_alert" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    typeId,
    totalQuantity,
    lowStockAlert,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Medicine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('total_quantity')) {
      context.handle(
        _totalQuantityMeta,
        totalQuantity.isAcceptableOrUnknown(
          data['total_quantity']!,
          _totalQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuantityMeta);
    }
    if (data.containsKey('low_stock_alert')) {
      context.handle(
        _lowStockAlertMeta,
        lowStockAlert.isAcceptableOrUnknown(
          data['low_stock_alert']!,
          _lowStockAlertMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lowStockAlertMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Medicine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Medicine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type_id'],
      )!,
      totalQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_quantity'],
      )!,
      lowStockAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}low_stock_alert'],
      )!,
    );
  }

  @override
  $MedicinesTable createAlias(String alias) {
    return $MedicinesTable(attachedDatabase, alias);
  }
}

class Medicine extends DataClass implements Insertable<Medicine> {
  final int id;
  final String name;
  final int typeId;
  final int totalQuantity;
  final bool lowStockAlert;
  const Medicine({
    required this.id,
    required this.name,
    required this.typeId,
    required this.totalQuantity,
    required this.lowStockAlert,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type_id'] = Variable<int>(typeId);
    map['total_quantity'] = Variable<int>(totalQuantity);
    map['low_stock_alert'] = Variable<bool>(lowStockAlert);
    return map;
  }

  MedicinesCompanion toCompanion(bool nullToAbsent) {
    return MedicinesCompanion(
      id: Value(id),
      name: Value(name),
      typeId: Value(typeId),
      totalQuantity: Value(totalQuantity),
      lowStockAlert: Value(lowStockAlert),
    );
  }

  factory Medicine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Medicine(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      typeId: serializer.fromJson<int>(json['typeId']),
      totalQuantity: serializer.fromJson<int>(json['totalQuantity']),
      lowStockAlert: serializer.fromJson<bool>(json['lowStockAlert']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'typeId': serializer.toJson<int>(typeId),
      'totalQuantity': serializer.toJson<int>(totalQuantity),
      'lowStockAlert': serializer.toJson<bool>(lowStockAlert),
    };
  }

  Medicine copyWith({
    int? id,
    String? name,
    int? typeId,
    int? totalQuantity,
    bool? lowStockAlert,
  }) => Medicine(
    id: id ?? this.id,
    name: name ?? this.name,
    typeId: typeId ?? this.typeId,
    totalQuantity: totalQuantity ?? this.totalQuantity,
    lowStockAlert: lowStockAlert ?? this.lowStockAlert,
  );
  Medicine copyWithCompanion(MedicinesCompanion data) {
    return Medicine(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      totalQuantity: data.totalQuantity.present
          ? data.totalQuantity.value
          : this.totalQuantity,
      lowStockAlert: data.lowStockAlert.present
          ? data.lowStockAlert.value
          : this.lowStockAlert,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Medicine(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeId: $typeId, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('lowStockAlert: $lowStockAlert')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, typeId, totalQuantity, lowStockAlert);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Medicine &&
          other.id == this.id &&
          other.name == this.name &&
          other.typeId == this.typeId &&
          other.totalQuantity == this.totalQuantity &&
          other.lowStockAlert == this.lowStockAlert);
}

class MedicinesCompanion extends UpdateCompanion<Medicine> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> typeId;
  final Value<int> totalQuantity;
  final Value<bool> lowStockAlert;
  const MedicinesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.typeId = const Value.absent(),
    this.totalQuantity = const Value.absent(),
    this.lowStockAlert = const Value.absent(),
  });
  MedicinesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int typeId,
    required int totalQuantity,
    required bool lowStockAlert,
  }) : name = Value(name),
       typeId = Value(typeId),
       totalQuantity = Value(totalQuantity),
       lowStockAlert = Value(lowStockAlert);
  static Insertable<Medicine> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? typeId,
    Expression<int>? totalQuantity,
    Expression<bool>? lowStockAlert,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (typeId != null) 'type_id': typeId,
      if (totalQuantity != null) 'total_quantity': totalQuantity,
      if (lowStockAlert != null) 'low_stock_alert': lowStockAlert,
    });
  }

  MedicinesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? typeId,
    Value<int>? totalQuantity,
    Value<bool>? lowStockAlert,
  }) {
    return MedicinesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      lowStockAlert: lowStockAlert ?? this.lowStockAlert,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (totalQuantity.present) {
      map['total_quantity'] = Variable<int>(totalQuantity.value);
    }
    if (lowStockAlert.present) {
      map['low_stock_alert'] = Variable<bool>(lowStockAlert.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeId: $typeId, ')
          ..write('totalQuantity: $totalQuantity, ')
          ..write('lowStockAlert: $lowStockAlert')
          ..write(')'))
        .toString();
  }
}

class $MedicinesDoseTable extends MedicinesDose
    with TableInfo<$MedicinesDoseTable, MedicinesDoseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesDoseTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _doseValueMeta = const VerificationMeta(
    'doseValue',
  );
  @override
  late final GeneratedColumn<double> doseValue = GeneratedColumn<double>(
    'dose_value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, doseValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines_dose';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicinesDoseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dose_value')) {
      context.handle(
        _doseValueMeta,
        doseValue.isAcceptableOrUnknown(data['dose_value']!, _doseValueMeta),
      );
    } else if (isInserting) {
      context.missing(_doseValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicinesDoseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicinesDoseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      doseValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_value'],
      )!,
    );
  }

  @override
  $MedicinesDoseTable createAlias(String alias) {
    return $MedicinesDoseTable(attachedDatabase, alias);
  }
}

class MedicinesDoseData extends DataClass
    implements Insertable<MedicinesDoseData> {
  final int id;
  final String name;
  final double doseValue;
  const MedicinesDoseData({
    required this.id,
    required this.name,
    required this.doseValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['dose_value'] = Variable<double>(doseValue);
    return map;
  }

  MedicinesDoseCompanion toCompanion(bool nullToAbsent) {
    return MedicinesDoseCompanion(
      id: Value(id),
      name: Value(name),
      doseValue: Value(doseValue),
    );
  }

  factory MedicinesDoseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicinesDoseData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      doseValue: serializer.fromJson<double>(json['doseValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'doseValue': serializer.toJson<double>(doseValue),
    };
  }

  MedicinesDoseData copyWith({int? id, String? name, double? doseValue}) =>
      MedicinesDoseData(
        id: id ?? this.id,
        name: name ?? this.name,
        doseValue: doseValue ?? this.doseValue,
      );
  MedicinesDoseData copyWithCompanion(MedicinesDoseCompanion data) {
    return MedicinesDoseData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      doseValue: data.doseValue.present ? data.doseValue.value : this.doseValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesDoseData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('doseValue: $doseValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, doseValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicinesDoseData &&
          other.id == this.id &&
          other.name == this.name &&
          other.doseValue == this.doseValue);
}

class MedicinesDoseCompanion extends UpdateCompanion<MedicinesDoseData> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> doseValue;
  const MedicinesDoseCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.doseValue = const Value.absent(),
  });
  MedicinesDoseCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required double doseValue,
  }) : name = Value(name),
       doseValue = Value(doseValue);
  static Insertable<MedicinesDoseData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? doseValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (doseValue != null) 'dose_value': doseValue,
    });
  }

  MedicinesDoseCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<double>? doseValue,
  }) {
    return MedicinesDoseCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      doseValue: doseValue ?? this.doseValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (doseValue.present) {
      map['dose_value'] = Variable<double>(doseValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesDoseCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('doseValue: $doseValue')
          ..write(')'))
        .toString();
  }
}

class $MedicinesRepeatTable extends MedicinesRepeat
    with TableInfo<$MedicinesRepeatTable, MedicinesRepeatData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicinesRepeatTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
    'meta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, meta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines_repeat';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicinesRepeatData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
        _metaMeta,
        meta.isAcceptableOrUnknown(data['meta']!, _metaMeta),
      );
    } else if (isInserting) {
      context.missing(_metaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicinesRepeatData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicinesRepeatData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      meta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meta'],
      )!,
    );
  }

  @override
  $MedicinesRepeatTable createAlias(String alias) {
    return $MedicinesRepeatTable(attachedDatabase, alias);
  }
}

class MedicinesRepeatData extends DataClass
    implements Insertable<MedicinesRepeatData> {
  final int id;
  final String name;
  final String meta;
  const MedicinesRepeatData({
    required this.id,
    required this.name,
    required this.meta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['meta'] = Variable<String>(meta);
    return map;
  }

  MedicinesRepeatCompanion toCompanion(bool nullToAbsent) {
    return MedicinesRepeatCompanion(
      id: Value(id),
      name: Value(name),
      meta: Value(meta),
    );
  }

  factory MedicinesRepeatData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicinesRepeatData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      meta: serializer.fromJson<String>(json['meta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'meta': serializer.toJson<String>(meta),
    };
  }

  MedicinesRepeatData copyWith({int? id, String? name, String? meta}) =>
      MedicinesRepeatData(
        id: id ?? this.id,
        name: name ?? this.name,
        meta: meta ?? this.meta,
      );
  MedicinesRepeatData copyWithCompanion(MedicinesRepeatCompanion data) {
    return MedicinesRepeatData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      meta: data.meta.present ? data.meta.value : this.meta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesRepeatData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, meta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicinesRepeatData &&
          other.id == this.id &&
          other.name == this.name &&
          other.meta == this.meta);
}

class MedicinesRepeatCompanion extends UpdateCompanion<MedicinesRepeatData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> meta;
  const MedicinesRepeatCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.meta = const Value.absent(),
  });
  MedicinesRepeatCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String meta,
  }) : name = Value(name),
       meta = Value(meta);
  static Insertable<MedicinesRepeatData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? meta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (meta != null) 'meta': meta,
    });
  }

  MedicinesRepeatCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? meta,
  }) {
    return MedicinesRepeatCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      meta: meta ?? this.meta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicinesRepeatCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses with TableInfo<$ExpensesTable, Expense> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _quantityBoughtMeta = const VerificationMeta(
    'quantityBought',
  );
  @override
  late final GeneratedColumn<int> quantityBought = GeneratedColumn<int>(
    'quantity_bought',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePaidMeta = const VerificationMeta(
    'pricePaid',
  );
  @override
  late final GeneratedColumn<double> pricePaid = GeneratedColumn<double>(
    'price_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerUnitMeta = const VerificationMeta(
    'pricePerUnit',
  );
  @override
  late final GeneratedColumn<double> pricePerUnit = GeneratedColumn<double>(
    'price_per_unit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    quantityBought,
    pricePaid,
    pricePerUnit,
    purchaseDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Expense> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('quantity_bought')) {
      context.handle(
        _quantityBoughtMeta,
        quantityBought.isAcceptableOrUnknown(
          data['quantity_bought']!,
          _quantityBoughtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityBoughtMeta);
    }
    if (data.containsKey('price_paid')) {
      context.handle(
        _pricePaidMeta,
        pricePaid.isAcceptableOrUnknown(data['price_paid']!, _pricePaidMeta),
      );
    } else if (isInserting) {
      context.missing(_pricePaidMeta);
    }
    if (data.containsKey('price_per_unit')) {
      context.handle(
        _pricePerUnitMeta,
        pricePerUnit.isAcceptableOrUnknown(
          data['price_per_unit']!,
          _pricePerUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerUnitMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Expense map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Expense(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medicine_id'],
      )!,
      quantityBought: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_bought'],
      )!,
      pricePaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_paid'],
      )!,
      pricePerUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_unit'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class Expense extends DataClass implements Insertable<Expense> {
  final int id;
  final int medicineId;
  final int quantityBought;
  final double pricePaid;
  final double pricePerUnit;
  final DateTime purchaseDate;
  const Expense({
    required this.id,
    required this.medicineId,
    required this.quantityBought,
    required this.pricePaid,
    required this.pricePerUnit,
    required this.purchaseDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medicine_id'] = Variable<int>(medicineId);
    map['quantity_bought'] = Variable<int>(quantityBought);
    map['price_paid'] = Variable<double>(pricePaid);
    map['price_per_unit'] = Variable<double>(pricePerUnit);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      quantityBought: Value(quantityBought),
      pricePaid: Value(pricePaid),
      pricePerUnit: Value(pricePerUnit),
      purchaseDate: Value(purchaseDate),
    );
  }

  factory Expense.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Expense(
      id: serializer.fromJson<int>(json['id']),
      medicineId: serializer.fromJson<int>(json['medicineId']),
      quantityBought: serializer.fromJson<int>(json['quantityBought']),
      pricePaid: serializer.fromJson<double>(json['pricePaid']),
      pricePerUnit: serializer.fromJson<double>(json['pricePerUnit']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineId': serializer.toJson<int>(medicineId),
      'quantityBought': serializer.toJson<int>(quantityBought),
      'pricePaid': serializer.toJson<double>(pricePaid),
      'pricePerUnit': serializer.toJson<double>(pricePerUnit),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
    };
  }

  Expense copyWith({
    int? id,
    int? medicineId,
    int? quantityBought,
    double? pricePaid,
    double? pricePerUnit,
    DateTime? purchaseDate,
  }) => Expense(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    quantityBought: quantityBought ?? this.quantityBought,
    pricePaid: pricePaid ?? this.pricePaid,
    pricePerUnit: pricePerUnit ?? this.pricePerUnit,
    purchaseDate: purchaseDate ?? this.purchaseDate,
  );
  Expense copyWithCompanion(ExpensesCompanion data) {
    return Expense(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      quantityBought: data.quantityBought.present
          ? data.quantityBought.value
          : this.quantityBought,
      pricePaid: data.pricePaid.present ? data.pricePaid.value : this.pricePaid,
      pricePerUnit: data.pricePerUnit.present
          ? data.pricePerUnit.value
          : this.pricePerUnit,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Expense(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('quantityBought: $quantityBought, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('purchaseDate: $purchaseDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    medicineId,
    quantityBought,
    pricePaid,
    pricePerUnit,
    purchaseDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Expense &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.quantityBought == this.quantityBought &&
          other.pricePaid == this.pricePaid &&
          other.pricePerUnit == this.pricePerUnit &&
          other.purchaseDate == this.purchaseDate);
}

class ExpensesCompanion extends UpdateCompanion<Expense> {
  final Value<int> id;
  final Value<int> medicineId;
  final Value<int> quantityBought;
  final Value<double> pricePaid;
  final Value<double> pricePerUnit;
  final Value<DateTime> purchaseDate;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.quantityBought = const Value.absent(),
    this.pricePaid = const Value.absent(),
    this.pricePerUnit = const Value.absent(),
    this.purchaseDate = const Value.absent(),
  });
  ExpensesCompanion.insert({
    this.id = const Value.absent(),
    required int medicineId,
    required int quantityBought,
    required double pricePaid,
    required double pricePerUnit,
    required DateTime purchaseDate,
  }) : medicineId = Value(medicineId),
       quantityBought = Value(quantityBought),
       pricePaid = Value(pricePaid),
       pricePerUnit = Value(pricePerUnit),
       purchaseDate = Value(purchaseDate);
  static Insertable<Expense> custom({
    Expression<int>? id,
    Expression<int>? medicineId,
    Expression<int>? quantityBought,
    Expression<double>? pricePaid,
    Expression<double>? pricePerUnit,
    Expression<DateTime>? purchaseDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (quantityBought != null) 'quantity_bought': quantityBought,
      if (pricePaid != null) 'price_paid': pricePaid,
      if (pricePerUnit != null) 'price_per_unit': pricePerUnit,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
    });
  }

  ExpensesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicineId,
    Value<int>? quantityBought,
    Value<double>? pricePaid,
    Value<double>? pricePerUnit,
    Value<DateTime>? purchaseDate,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      quantityBought: quantityBought ?? this.quantityBought,
      pricePaid: pricePaid ?? this.pricePaid,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (quantityBought.present) {
      map['quantity_bought'] = Variable<int>(quantityBought.value);
    }
    if (pricePaid.present) {
      map['price_paid'] = Variable<double>(pricePaid.value);
    }
    if (pricePerUnit.present) {
      map['price_per_unit'] = Variable<double>(pricePerUnit.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('quantityBought: $quantityBought, ')
          ..write('pricePaid: $pricePaid, ')
          ..write('pricePerUnit: $pricePerUnit, ')
          ..write('purchaseDate: $purchaseDate')
          ..write(')'))
        .toString();
  }
}

class $IntakeHistoriesTable extends IntakeHistories
    with TableInfo<$IntakeHistoriesTable, IntakeHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntakeHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _medicineIdMeta = const VerificationMeta(
    'medicineId',
  );
  @override
  late final GeneratedColumn<int> medicineId = GeneratedColumn<int>(
    'medicine_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines (id)',
    ),
  );
  static const VerificationMeta _intakeTimeMeta = const VerificationMeta(
    'intakeTime',
  );
  @override
  late final GeneratedColumn<DateTime> intakeTime = GeneratedColumn<DateTime>(
    'intake_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatTypeMeta = const VerificationMeta(
    'repeatType',
  );
  @override
  late final GeneratedColumn<int> repeatType = GeneratedColumn<int>(
    'repeat_type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES medicines_repeat (id)',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseValueMeta = const VerificationMeta(
    'doseValue',
  );
  @override
  late final GeneratedColumn<double> doseValue = GeneratedColumn<double>(
    'dose_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    medicineId,
    intakeTime,
    repeatType,
    status,
    doseValue,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intake_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntakeHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('medicine_id')) {
      context.handle(
        _medicineIdMeta,
        medicineId.isAcceptableOrUnknown(data['medicine_id']!, _medicineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_medicineIdMeta);
    }
    if (data.containsKey('intake_time')) {
      context.handle(
        _intakeTimeMeta,
        intakeTime.isAcceptableOrUnknown(data['intake_time']!, _intakeTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_intakeTimeMeta);
    }
    if (data.containsKey('repeat_type')) {
      context.handle(
        _repeatTypeMeta,
        repeatType.isAcceptableOrUnknown(data['repeat_type']!, _repeatTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_repeatTypeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('dose_value')) {
      context.handle(
        _doseValueMeta,
        doseValue.isAcceptableOrUnknown(data['dose_value']!, _doseValueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntakeHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntakeHistory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      medicineId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}medicine_id'],
      )!,
      intakeTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}intake_time'],
      )!,
      repeatType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      doseValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_value'],
      ),
    );
  }

  @override
  $IntakeHistoriesTable createAlias(String alias) {
    return $IntakeHistoriesTable(attachedDatabase, alias);
  }
}

class IntakeHistory extends DataClass implements Insertable<IntakeHistory> {
  final int id;
  final int medicineId;
  final DateTime intakeTime;
  final int repeatType;
  final String status;
  final double? doseValue;
  const IntakeHistory({
    required this.id,
    required this.medicineId,
    required this.intakeTime,
    required this.repeatType,
    required this.status,
    this.doseValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['medicine_id'] = Variable<int>(medicineId);
    map['intake_time'] = Variable<DateTime>(intakeTime);
    map['repeat_type'] = Variable<int>(repeatType);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || doseValue != null) {
      map['dose_value'] = Variable<double>(doseValue);
    }
    return map;
  }

  IntakeHistoriesCompanion toCompanion(bool nullToAbsent) {
    return IntakeHistoriesCompanion(
      id: Value(id),
      medicineId: Value(medicineId),
      intakeTime: Value(intakeTime),
      repeatType: Value(repeatType),
      status: Value(status),
      doseValue: doseValue == null && nullToAbsent
          ? const Value.absent()
          : Value(doseValue),
    );
  }

  factory IntakeHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntakeHistory(
      id: serializer.fromJson<int>(json['id']),
      medicineId: serializer.fromJson<int>(json['medicineId']),
      intakeTime: serializer.fromJson<DateTime>(json['intakeTime']),
      repeatType: serializer.fromJson<int>(json['repeatType']),
      status: serializer.fromJson<String>(json['status']),
      doseValue: serializer.fromJson<double?>(json['doseValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'medicineId': serializer.toJson<int>(medicineId),
      'intakeTime': serializer.toJson<DateTime>(intakeTime),
      'repeatType': serializer.toJson<int>(repeatType),
      'status': serializer.toJson<String>(status),
      'doseValue': serializer.toJson<double?>(doseValue),
    };
  }

  IntakeHistory copyWith({
    int? id,
    int? medicineId,
    DateTime? intakeTime,
    int? repeatType,
    String? status,
    Value<double?> doseValue = const Value.absent(),
  }) => IntakeHistory(
    id: id ?? this.id,
    medicineId: medicineId ?? this.medicineId,
    intakeTime: intakeTime ?? this.intakeTime,
    repeatType: repeatType ?? this.repeatType,
    status: status ?? this.status,
    doseValue: doseValue.present ? doseValue.value : this.doseValue,
  );
  IntakeHistory copyWithCompanion(IntakeHistoriesCompanion data) {
    return IntakeHistory(
      id: data.id.present ? data.id.value : this.id,
      medicineId: data.medicineId.present
          ? data.medicineId.value
          : this.medicineId,
      intakeTime: data.intakeTime.present
          ? data.intakeTime.value
          : this.intakeTime,
      repeatType: data.repeatType.present
          ? data.repeatType.value
          : this.repeatType,
      status: data.status.present ? data.status.value : this.status,
      doseValue: data.doseValue.present ? data.doseValue.value : this.doseValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntakeHistory(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('intakeTime: $intakeTime, ')
          ..write('repeatType: $repeatType, ')
          ..write('status: $status, ')
          ..write('doseValue: $doseValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, medicineId, intakeTime, repeatType, status, doseValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntakeHistory &&
          other.id == this.id &&
          other.medicineId == this.medicineId &&
          other.intakeTime == this.intakeTime &&
          other.repeatType == this.repeatType &&
          other.status == this.status &&
          other.doseValue == this.doseValue);
}

class IntakeHistoriesCompanion extends UpdateCompanion<IntakeHistory> {
  final Value<int> id;
  final Value<int> medicineId;
  final Value<DateTime> intakeTime;
  final Value<int> repeatType;
  final Value<String> status;
  final Value<double?> doseValue;
  const IntakeHistoriesCompanion({
    this.id = const Value.absent(),
    this.medicineId = const Value.absent(),
    this.intakeTime = const Value.absent(),
    this.repeatType = const Value.absent(),
    this.status = const Value.absent(),
    this.doseValue = const Value.absent(),
  });
  IntakeHistoriesCompanion.insert({
    this.id = const Value.absent(),
    required int medicineId,
    required DateTime intakeTime,
    required int repeatType,
    required String status,
    this.doseValue = const Value.absent(),
  }) : medicineId = Value(medicineId),
       intakeTime = Value(intakeTime),
       repeatType = Value(repeatType),
       status = Value(status);
  static Insertable<IntakeHistory> custom({
    Expression<int>? id,
    Expression<int>? medicineId,
    Expression<DateTime>? intakeTime,
    Expression<int>? repeatType,
    Expression<String>? status,
    Expression<double>? doseValue,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (medicineId != null) 'medicine_id': medicineId,
      if (intakeTime != null) 'intake_time': intakeTime,
      if (repeatType != null) 'repeat_type': repeatType,
      if (status != null) 'status': status,
      if (doseValue != null) 'dose_value': doseValue,
    });
  }

  IntakeHistoriesCompanion copyWith({
    Value<int>? id,
    Value<int>? medicineId,
    Value<DateTime>? intakeTime,
    Value<int>? repeatType,
    Value<String>? status,
    Value<double?>? doseValue,
  }) {
    return IntakeHistoriesCompanion(
      id: id ?? this.id,
      medicineId: medicineId ?? this.medicineId,
      intakeTime: intakeTime ?? this.intakeTime,
      repeatType: repeatType ?? this.repeatType,
      status: status ?? this.status,
      doseValue: doseValue ?? this.doseValue,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (medicineId.present) {
      map['medicine_id'] = Variable<int>(medicineId.value);
    }
    if (intakeTime.present) {
      map['intake_time'] = Variable<DateTime>(intakeTime.value);
    }
    if (repeatType.present) {
      map['repeat_type'] = Variable<int>(repeatType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (doseValue.present) {
      map['dose_value'] = Variable<double>(doseValue.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntakeHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('medicineId: $medicineId, ')
          ..write('intakeTime: $intakeTime, ')
          ..write('repeatType: $repeatType, ')
          ..write('status: $status, ')
          ..write('doseValue: $doseValue')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MedicinesTypesTable medicinesTypes = $MedicinesTypesTable(this);
  late final $MedicinesTable medicines = $MedicinesTable(this);
  late final $MedicinesDoseTable medicinesDose = $MedicinesDoseTable(this);
  late final $MedicinesRepeatTable medicinesRepeat = $MedicinesRepeatTable(
    this,
  );
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $IntakeHistoriesTable intakeHistories = $IntakeHistoriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    medicinesTypes,
    medicines,
    medicinesDose,
    medicinesRepeat,
    expenses,
    intakeHistories,
  ];
}

typedef $$MedicinesTypesTableCreateCompanionBuilder =
    MedicinesTypesCompanion Function({Value<int> id, required String name});
typedef $$MedicinesTypesTableUpdateCompanionBuilder =
    MedicinesTypesCompanion Function({Value<int> id, Value<String> name});

final class $$MedicinesTypesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTypesTable, MedicinesType> {
  $$MedicinesTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$MedicinesTable, List<Medicine>>
  _medicinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.medicines,
    aliasName: $_aliasNameGenerator(db.medicinesTypes.id, db.medicines.typeId),
  );

  $$MedicinesTableProcessedTableManager get medicinesRefs {
    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.typeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_medicinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesTypesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTypesTable> {
  $$MedicinesTypesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> medicinesRefs(
    Expression<bool> Function($$MedicinesTableFilterComposer f) f,
  ) {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTypesTable> {
  $$MedicinesTypesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTypesTable> {
  $$MedicinesTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> medicinesRefs<T extends Object>(
    Expression<T> Function($$MedicinesTableAnnotationComposer a) f,
  ) {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.typeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTypesTable,
          MedicinesType,
          $$MedicinesTypesTableFilterComposer,
          $$MedicinesTypesTableOrderingComposer,
          $$MedicinesTypesTableAnnotationComposer,
          $$MedicinesTypesTableCreateCompanionBuilder,
          $$MedicinesTypesTableUpdateCompanionBuilder,
          (MedicinesType, $$MedicinesTypesTableReferences),
          MedicinesType,
          PrefetchHooks Function({bool medicinesRefs})
        > {
  $$MedicinesTypesTableTableManager(
    _$AppDatabase db,
    $MedicinesTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => MedicinesTypesCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  MedicinesTypesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicinesTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicinesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (medicinesRefs) db.medicines],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (medicinesRefs)
                    await $_getPrefetchedData<
                      MedicinesType,
                      $MedicinesTypesTable,
                      Medicine
                    >(
                      currentTable: table,
                      referencedTable: $$MedicinesTypesTableReferences
                          ._medicinesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicinesTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).medicinesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.typeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicinesTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTypesTable,
      MedicinesType,
      $$MedicinesTypesTableFilterComposer,
      $$MedicinesTypesTableOrderingComposer,
      $$MedicinesTypesTableAnnotationComposer,
      $$MedicinesTypesTableCreateCompanionBuilder,
      $$MedicinesTypesTableUpdateCompanionBuilder,
      (MedicinesType, $$MedicinesTypesTableReferences),
      MedicinesType,
      PrefetchHooks Function({bool medicinesRefs})
    >;
typedef $$MedicinesTableCreateCompanionBuilder =
    MedicinesCompanion Function({
      Value<int> id,
      required String name,
      required int typeId,
      required int totalQuantity,
      required bool lowStockAlert,
    });
typedef $$MedicinesTableUpdateCompanionBuilder =
    MedicinesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> typeId,
      Value<int> totalQuantity,
      Value<bool> lowStockAlert,
    });

final class $$MedicinesTableReferences
    extends BaseReferences<_$AppDatabase, $MedicinesTable, Medicine> {
  $$MedicinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTypesTable _typeIdTable(_$AppDatabase db) =>
      db.medicinesTypes.createAlias(
        $_aliasNameGenerator(db.medicines.typeId, db.medicinesTypes.id),
      );

  $$MedicinesTypesTableProcessedTableManager get typeId {
    final $_column = $_itemColumn<int>('type_id')!;

    final manager = $$MedicinesTypesTableTableManager(
      $_db,
      $_db.medicinesTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_typeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<Expense>> _expensesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: $_aliasNameGenerator(db.medicines.id, db.expenses.medicineId),
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$IntakeHistoriesTable, List<IntakeHistory>>
  _intakeHistoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakeHistories,
    aliasName: $_aliasNameGenerator(
      db.medicines.id,
      db.intakeHistories.medicineId,
    ),
  );

  $$IntakeHistoriesTableProcessedTableManager get intakeHistoriesRefs {
    final manager = $$IntakeHistoriesTableTableManager(
      $_db,
      $_db.intakeHistories,
    ).filter((f) => f.medicineId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _intakeHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lowStockAlert => $composableBuilder(
    column: $table.lowStockAlert,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTypesTableFilterComposer get typeId {
    final $$MedicinesTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.medicinesTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTypesTableFilterComposer(
            $db: $db,
            $table: $db.medicinesTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> intakeHistoriesRefs(
    Expression<bool> Function($$IntakeHistoriesTableFilterComposer f) f,
  ) {
    final $$IntakeHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeHistories,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.intakeHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lowStockAlert => $composableBuilder(
    column: $table.lowStockAlert,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTypesTableOrderingComposer get typeId {
    final $$MedicinesTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.medicinesTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTypesTableOrderingComposer(
            $db: $db,
            $table: $db.medicinesTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MedicinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesTable> {
  $$MedicinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get totalQuantity => $composableBuilder(
    column: $table.totalQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lowStockAlert => $composableBuilder(
    column: $table.lowStockAlert,
    builder: (column) => column,
  );

  $$MedicinesTypesTableAnnotationComposer get typeId {
    final $$MedicinesTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.typeId,
      referencedTable: $db.medicinesTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicinesTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> intakeHistoriesRefs<T extends Object>(
    Expression<T> Function($$IntakeHistoriesTableAnnotationComposer a) f,
  ) {
    final $$IntakeHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeHistories,
      getReferencedColumn: (t) => t.medicineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesTable,
          Medicine,
          $$MedicinesTableFilterComposer,
          $$MedicinesTableOrderingComposer,
          $$MedicinesTableAnnotationComposer,
          $$MedicinesTableCreateCompanionBuilder,
          $$MedicinesTableUpdateCompanionBuilder,
          (Medicine, $$MedicinesTableReferences),
          Medicine,
          PrefetchHooks Function({
            bool typeId,
            bool expensesRefs,
            bool intakeHistoriesRefs,
          })
        > {
  $$MedicinesTableTableManager(_$AppDatabase db, $MedicinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> typeId = const Value.absent(),
                Value<int> totalQuantity = const Value.absent(),
                Value<bool> lowStockAlert = const Value.absent(),
              }) => MedicinesCompanion(
                id: id,
                name: name,
                typeId: typeId,
                totalQuantity: totalQuantity,
                lowStockAlert: lowStockAlert,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int typeId,
                required int totalQuantity,
                required bool lowStockAlert,
              }) => MedicinesCompanion.insert(
                id: id,
                name: name,
                typeId: typeId,
                totalQuantity: totalQuantity,
                lowStockAlert: lowStockAlert,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                typeId = false,
                expensesRefs = false,
                intakeHistoriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (expensesRefs) db.expenses,
                    if (intakeHistoriesRefs) db.intakeHistories,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (typeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.typeId,
                                    referencedTable: $$MedicinesTableReferences
                                        ._typeIdTable(db),
                                    referencedColumn: $$MedicinesTableReferences
                                        ._typeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (expensesRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          Expense
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (intakeHistoriesRefs)
                        await $_getPrefetchedData<
                          Medicine,
                          $MedicinesTable,
                          IntakeHistory
                        >(
                          currentTable: table,
                          referencedTable: $$MedicinesTableReferences
                              ._intakeHistoriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MedicinesTableReferences(
                                db,
                                table,
                                p0,
                              ).intakeHistoriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.medicineId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MedicinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesTable,
      Medicine,
      $$MedicinesTableFilterComposer,
      $$MedicinesTableOrderingComposer,
      $$MedicinesTableAnnotationComposer,
      $$MedicinesTableCreateCompanionBuilder,
      $$MedicinesTableUpdateCompanionBuilder,
      (Medicine, $$MedicinesTableReferences),
      Medicine,
      PrefetchHooks Function({
        bool typeId,
        bool expensesRefs,
        bool intakeHistoriesRefs,
      })
    >;
typedef $$MedicinesDoseTableCreateCompanionBuilder =
    MedicinesDoseCompanion Function({
      Value<int> id,
      required String name,
      required double doseValue,
    });
typedef $$MedicinesDoseTableUpdateCompanionBuilder =
    MedicinesDoseCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<double> doseValue,
    });

class $$MedicinesDoseTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesDoseTable> {
  $$MedicinesDoseTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicinesDoseTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesDoseTable> {
  $$MedicinesDoseTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesDoseTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesDoseTable> {
  $$MedicinesDoseTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get doseValue =>
      $composableBuilder(column: $table.doseValue, builder: (column) => column);
}

class $$MedicinesDoseTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesDoseTable,
          MedicinesDoseData,
          $$MedicinesDoseTableFilterComposer,
          $$MedicinesDoseTableOrderingComposer,
          $$MedicinesDoseTableAnnotationComposer,
          $$MedicinesDoseTableCreateCompanionBuilder,
          $$MedicinesDoseTableUpdateCompanionBuilder,
          (
            MedicinesDoseData,
            BaseReferences<
              _$AppDatabase,
              $MedicinesDoseTable,
              MedicinesDoseData
            >,
          ),
          MedicinesDoseData,
          PrefetchHooks Function()
        > {
  $$MedicinesDoseTableTableManager(_$AppDatabase db, $MedicinesDoseTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesDoseTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesDoseTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesDoseTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> doseValue = const Value.absent(),
              }) => MedicinesDoseCompanion(
                id: id,
                name: name,
                doseValue: doseValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required double doseValue,
              }) => MedicinesDoseCompanion.insert(
                id: id,
                name: name,
                doseValue: doseValue,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicinesDoseTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesDoseTable,
      MedicinesDoseData,
      $$MedicinesDoseTableFilterComposer,
      $$MedicinesDoseTableOrderingComposer,
      $$MedicinesDoseTableAnnotationComposer,
      $$MedicinesDoseTableCreateCompanionBuilder,
      $$MedicinesDoseTableUpdateCompanionBuilder,
      (
        MedicinesDoseData,
        BaseReferences<_$AppDatabase, $MedicinesDoseTable, MedicinesDoseData>,
      ),
      MedicinesDoseData,
      PrefetchHooks Function()
    >;
typedef $$MedicinesRepeatTableCreateCompanionBuilder =
    MedicinesRepeatCompanion Function({
      Value<int> id,
      required String name,
      required String meta,
    });
typedef $$MedicinesRepeatTableUpdateCompanionBuilder =
    MedicinesRepeatCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> meta,
    });

final class $$MedicinesRepeatTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MedicinesRepeatTable,
          MedicinesRepeatData
        > {
  $$MedicinesRepeatTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$IntakeHistoriesTable, List<IntakeHistory>>
  _intakeHistoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.intakeHistories,
    aliasName: $_aliasNameGenerator(
      db.medicinesRepeat.id,
      db.intakeHistories.repeatType,
    ),
  );

  $$IntakeHistoriesTableProcessedTableManager get intakeHistoriesRefs {
    final manager = $$IntakeHistoriesTableTableManager(
      $_db,
      $_db.intakeHistories,
    ).filter((f) => f.repeatType.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _intakeHistoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MedicinesRepeatTableFilterComposer
    extends Composer<_$AppDatabase, $MedicinesRepeatTable> {
  $$MedicinesRepeatTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> intakeHistoriesRefs(
    Expression<bool> Function($$IntakeHistoriesTableFilterComposer f) f,
  ) {
    final $$IntakeHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeHistories,
      getReferencedColumn: (t) => t.repeatType,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.intakeHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesRepeatTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicinesRepeatTable> {
  $$MedicinesRepeatTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meta => $composableBuilder(
    column: $table.meta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicinesRepeatTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicinesRepeatTable> {
  $$MedicinesRepeatTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get meta =>
      $composableBuilder(column: $table.meta, builder: (column) => column);

  Expression<T> intakeHistoriesRefs<T extends Object>(
    Expression<T> Function($$IntakeHistoriesTableAnnotationComposer a) f,
  ) {
    final $$IntakeHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.intakeHistories,
      getReferencedColumn: (t) => t.repeatType,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$IntakeHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.intakeHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MedicinesRepeatTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicinesRepeatTable,
          MedicinesRepeatData,
          $$MedicinesRepeatTableFilterComposer,
          $$MedicinesRepeatTableOrderingComposer,
          $$MedicinesRepeatTableAnnotationComposer,
          $$MedicinesRepeatTableCreateCompanionBuilder,
          $$MedicinesRepeatTableUpdateCompanionBuilder,
          (MedicinesRepeatData, $$MedicinesRepeatTableReferences),
          MedicinesRepeatData,
          PrefetchHooks Function({bool intakeHistoriesRefs})
        > {
  $$MedicinesRepeatTableTableManager(
    _$AppDatabase db,
    $MedicinesRepeatTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicinesRepeatTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicinesRepeatTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicinesRepeatTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> meta = const Value.absent(),
              }) => MedicinesRepeatCompanion(id: id, name: name, meta: meta),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String meta,
              }) => MedicinesRepeatCompanion.insert(
                id: id,
                name: name,
                meta: meta,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MedicinesRepeatTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({intakeHistoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (intakeHistoriesRefs) db.intakeHistories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (intakeHistoriesRefs)
                    await $_getPrefetchedData<
                      MedicinesRepeatData,
                      $MedicinesRepeatTable,
                      IntakeHistory
                    >(
                      currentTable: table,
                      referencedTable: $$MedicinesRepeatTableReferences
                          ._intakeHistoriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MedicinesRepeatTableReferences(
                            db,
                            table,
                            p0,
                          ).intakeHistoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.repeatType == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MedicinesRepeatTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicinesRepeatTable,
      MedicinesRepeatData,
      $$MedicinesRepeatTableFilterComposer,
      $$MedicinesRepeatTableOrderingComposer,
      $$MedicinesRepeatTableAnnotationComposer,
      $$MedicinesRepeatTableCreateCompanionBuilder,
      $$MedicinesRepeatTableUpdateCompanionBuilder,
      (MedicinesRepeatData, $$MedicinesRepeatTableReferences),
      MedicinesRepeatData,
      PrefetchHooks Function({bool intakeHistoriesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      required int medicineId,
      required int quantityBought,
      required double pricePaid,
      required double pricePerUnit,
      required DateTime purchaseDate,
    });
typedef $$ExpensesTableUpdateCompanionBuilder =
    ExpensesCompanion Function({
      Value<int> id,
      Value<int> medicineId,
      Value<int> quantityBought,
      Value<double> pricePaid,
      Value<double> pricePerUnit,
      Value<DateTime> purchaseDate,
    });

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, Expense> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias(
        $_aliasNameGenerator(db.expenses.medicineId, db.medicines.id),
      );

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<int>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<int> get quantityBought => $composableBuilder(
    column: $table.quantityBought,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<int> get quantityBought => $composableBuilder(
    column: $table.quantityBought,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePaid => $composableBuilder(
    column: $table.pricePaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get quantityBought => $composableBuilder(
    column: $table.quantityBought,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePaid =>
      $composableBuilder(column: $table.pricePaid, builder: (column) => column);

  GeneratedColumn<double> get pricePerUnit => $composableBuilder(
    column: $table.pricePerUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          Expense,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (Expense, $$ExpensesTableReferences),
          Expense,
          PrefetchHooks Function({bool medicineId})
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicineId = const Value.absent(),
                Value<int> quantityBought = const Value.absent(),
                Value<double> pricePaid = const Value.absent(),
                Value<double> pricePerUnit = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                medicineId: medicineId,
                quantityBought: quantityBought,
                pricePaid: pricePaid,
                pricePerUnit: pricePerUnit,
                purchaseDate: purchaseDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicineId,
                required int quantityBought,
                required double pricePaid,
                required double pricePerUnit,
                required DateTime purchaseDate,
              }) => ExpensesCompanion.insert(
                id: id,
                medicineId: medicineId,
                quantityBought: quantityBought,
                pricePaid: pricePaid,
                pricePerUnit: pricePerUnit,
                purchaseDate: purchaseDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicineId,
                                referencedTable: $$ExpensesTableReferences
                                    ._medicineIdTable(db),
                                referencedColumn: $$ExpensesTableReferences
                                    ._medicineIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      Expense,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (Expense, $$ExpensesTableReferences),
      Expense,
      PrefetchHooks Function({bool medicineId})
    >;
typedef $$IntakeHistoriesTableCreateCompanionBuilder =
    IntakeHistoriesCompanion Function({
      Value<int> id,
      required int medicineId,
      required DateTime intakeTime,
      required int repeatType,
      required String status,
      Value<double?> doseValue,
    });
typedef $$IntakeHistoriesTableUpdateCompanionBuilder =
    IntakeHistoriesCompanion Function({
      Value<int> id,
      Value<int> medicineId,
      Value<DateTime> intakeTime,
      Value<int> repeatType,
      Value<String> status,
      Value<double?> doseValue,
    });

final class $$IntakeHistoriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $IntakeHistoriesTable, IntakeHistory> {
  $$IntakeHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MedicinesTable _medicineIdTable(_$AppDatabase db) =>
      db.medicines.createAlias(
        $_aliasNameGenerator(db.intakeHistories.medicineId, db.medicines.id),
      );

  $$MedicinesTableProcessedTableManager get medicineId {
    final $_column = $_itemColumn<int>('medicine_id')!;

    final manager = $$MedicinesTableTableManager(
      $_db,
      $_db.medicines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_medicineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MedicinesRepeatTable _repeatTypeTable(_$AppDatabase db) =>
      db.medicinesRepeat.createAlias(
        $_aliasNameGenerator(
          db.intakeHistories.repeatType,
          db.medicinesRepeat.id,
        ),
      );

  $$MedicinesRepeatTableProcessedTableManager get repeatType {
    final $_column = $_itemColumn<int>('repeat_type')!;

    final manager = $$MedicinesRepeatTableTableManager(
      $_db,
      $_db.medicinesRepeat,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_repeatTypeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$IntakeHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $IntakeHistoriesTable> {
  $$IntakeHistoriesTableFilterComposer({
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

  ColumnFilters<DateTime> get intakeTime => $composableBuilder(
    column: $table.intakeTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnFilters(column),
  );

  $$MedicinesTableFilterComposer get medicineId {
    final $$MedicinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableFilterComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinesRepeatTableFilterComposer get repeatType {
    final $$MedicinesRepeatTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeatType,
      referencedTable: $db.medicinesRepeat,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesRepeatTableFilterComposer(
            $db: $db,
            $table: $db.medicinesRepeat,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IntakeHistoriesTable> {
  $$IntakeHistoriesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get intakeTime => $composableBuilder(
    column: $table.intakeTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnOrderings(column),
  );

  $$MedicinesTableOrderingComposer get medicineId {
    final $$MedicinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableOrderingComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinesRepeatTableOrderingComposer get repeatType {
    final $$MedicinesRepeatTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeatType,
      referencedTable: $db.medicinesRepeat,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesRepeatTableOrderingComposer(
            $db: $db,
            $table: $db.medicinesRepeat,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntakeHistoriesTable> {
  $$IntakeHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get intakeTime => $composableBuilder(
    column: $table.intakeTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get doseValue =>
      $composableBuilder(column: $table.doseValue, builder: (column) => column);

  $$MedicinesTableAnnotationComposer get medicineId {
    final $$MedicinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.medicineId,
      referencedTable: $db.medicines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesTableAnnotationComposer(
            $db: $db,
            $table: $db.medicines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MedicinesRepeatTableAnnotationComposer get repeatType {
    final $$MedicinesRepeatTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.repeatType,
      referencedTable: $db.medicinesRepeat,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MedicinesRepeatTableAnnotationComposer(
            $db: $db,
            $table: $db.medicinesRepeat,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$IntakeHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntakeHistoriesTable,
          IntakeHistory,
          $$IntakeHistoriesTableFilterComposer,
          $$IntakeHistoriesTableOrderingComposer,
          $$IntakeHistoriesTableAnnotationComposer,
          $$IntakeHistoriesTableCreateCompanionBuilder,
          $$IntakeHistoriesTableUpdateCompanionBuilder,
          (IntakeHistory, $$IntakeHistoriesTableReferences),
          IntakeHistory,
          PrefetchHooks Function({bool medicineId, bool repeatType})
        > {
  $$IntakeHistoriesTableTableManager(
    _$AppDatabase db,
    $IntakeHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntakeHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntakeHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntakeHistoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> medicineId = const Value.absent(),
                Value<DateTime> intakeTime = const Value.absent(),
                Value<int> repeatType = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double?> doseValue = const Value.absent(),
              }) => IntakeHistoriesCompanion(
                id: id,
                medicineId: medicineId,
                intakeTime: intakeTime,
                repeatType: repeatType,
                status: status,
                doseValue: doseValue,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int medicineId,
                required DateTime intakeTime,
                required int repeatType,
                required String status,
                Value<double?> doseValue = const Value.absent(),
              }) => IntakeHistoriesCompanion.insert(
                id: id,
                medicineId: medicineId,
                intakeTime: intakeTime,
                repeatType: repeatType,
                status: status,
                doseValue: doseValue,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$IntakeHistoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({medicineId = false, repeatType = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (medicineId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.medicineId,
                                referencedTable:
                                    $$IntakeHistoriesTableReferences
                                        ._medicineIdTable(db),
                                referencedColumn:
                                    $$IntakeHistoriesTableReferences
                                        ._medicineIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (repeatType) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.repeatType,
                                referencedTable:
                                    $$IntakeHistoriesTableReferences
                                        ._repeatTypeTable(db),
                                referencedColumn:
                                    $$IntakeHistoriesTableReferences
                                        ._repeatTypeTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$IntakeHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntakeHistoriesTable,
      IntakeHistory,
      $$IntakeHistoriesTableFilterComposer,
      $$IntakeHistoriesTableOrderingComposer,
      $$IntakeHistoriesTableAnnotationComposer,
      $$IntakeHistoriesTableCreateCompanionBuilder,
      $$IntakeHistoriesTableUpdateCompanionBuilder,
      (IntakeHistory, $$IntakeHistoriesTableReferences),
      IntakeHistory,
      PrefetchHooks Function({bool medicineId, bool repeatType})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MedicinesTypesTableTableManager get medicinesTypes =>
      $$MedicinesTypesTableTableManager(_db, _db.medicinesTypes);
  $$MedicinesTableTableManager get medicines =>
      $$MedicinesTableTableManager(_db, _db.medicines);
  $$MedicinesDoseTableTableManager get medicinesDose =>
      $$MedicinesDoseTableTableManager(_db, _db.medicinesDose);
  $$MedicinesRepeatTableTableManager get medicinesRepeat =>
      $$MedicinesRepeatTableTableManager(_db, _db.medicinesRepeat);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$IntakeHistoriesTableTableManager get intakeHistories =>
      $$IntakeHistoriesTableTableManager(_db, _db.intakeHistories);
}
