// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signalflow_database.dart';

// ignore_for_file: type=lint
class $BaselineProfilesTableTable extends BaselineProfilesTable
    with TableInfo<$BaselineProfilesTableTable, BaselineProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BaselineProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _restingHeartRateMeta = const VerificationMeta(
    'restingHeartRate',
  );
  @override
  late final GeneratedColumn<double> restingHeartRate = GeneratedColumn<double>(
    'resting_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrvRmssdMeta = const VerificationMeta(
    'hrvRmssd',
  );
  @override
  late final GeneratedColumn<double> hrvRmssd = GeneratedColumn<double>(
    'hrv_rmssd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<double> respiratoryRate = GeneratedColumn<double>(
    'respiratory_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementIntensityMeta = const VerificationMeta(
    'movementIntensity',
  );
  @override
  late final GeneratedColumn<double> movementIntensity =
      GeneratedColumn<double>(
        'movement_intensity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    restingHeartRate,
    hrvRmssd,
    respiratoryRate,
    movementIntensity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'baseline_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BaselineProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('resting_heart_rate')) {
      context.handle(
        _restingHeartRateMeta,
        restingHeartRate.isAcceptableOrUnknown(
          data['resting_heart_rate']!,
          _restingHeartRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restingHeartRateMeta);
    }
    if (data.containsKey('hrv_rmssd')) {
      context.handle(
        _hrvRmssdMeta,
        hrvRmssd.isAcceptableOrUnknown(data['hrv_rmssd']!, _hrvRmssdMeta),
      );
    } else if (isInserting) {
      context.missing(_hrvRmssdMeta);
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respiratoryRateMeta);
    }
    if (data.containsKey('movement_intensity')) {
      context.handle(
        _movementIntensityMeta,
        movementIntensity.isAcceptableOrUnknown(
          data['movement_intensity']!,
          _movementIntensityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementIntensityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BaselineProfilesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BaselineProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      restingHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_heart_rate'],
      )!,
      hrvRmssd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_rmssd'],
      )!,
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate'],
      )!,
      movementIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}movement_intensity'],
      )!,
    );
  }

  @override
  $BaselineProfilesTableTable createAlias(String alias) {
    return $BaselineProfilesTableTable(attachedDatabase, alias);
  }
}

class BaselineProfilesTableData extends DataClass
    implements Insertable<BaselineProfilesTableData> {
  final String id;
  final DateTime createdAt;
  final double restingHeartRate;
  final double hrvRmssd;
  final double respiratoryRate;
  final double movementIntensity;
  const BaselineProfilesTableData({
    required this.id,
    required this.createdAt,
    required this.restingHeartRate,
    required this.hrvRmssd,
    required this.respiratoryRate,
    required this.movementIntensity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['resting_heart_rate'] = Variable<double>(restingHeartRate);
    map['hrv_rmssd'] = Variable<double>(hrvRmssd);
    map['respiratory_rate'] = Variable<double>(respiratoryRate);
    map['movement_intensity'] = Variable<double>(movementIntensity);
    return map;
  }

  BaselineProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return BaselineProfilesTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      restingHeartRate: Value(restingHeartRate),
      hrvRmssd: Value(hrvRmssd),
      respiratoryRate: Value(respiratoryRate),
      movementIntensity: Value(movementIntensity),
    );
  }

  factory BaselineProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BaselineProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      restingHeartRate: serializer.fromJson<double>(json['restingHeartRate']),
      hrvRmssd: serializer.fromJson<double>(json['hrvRmssd']),
      respiratoryRate: serializer.fromJson<double>(json['respiratoryRate']),
      movementIntensity: serializer.fromJson<double>(json['movementIntensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'restingHeartRate': serializer.toJson<double>(restingHeartRate),
      'hrvRmssd': serializer.toJson<double>(hrvRmssd),
      'respiratoryRate': serializer.toJson<double>(respiratoryRate),
      'movementIntensity': serializer.toJson<double>(movementIntensity),
    };
  }

  BaselineProfilesTableData copyWith({
    String? id,
    DateTime? createdAt,
    double? restingHeartRate,
    double? hrvRmssd,
    double? respiratoryRate,
    double? movementIntensity,
  }) => BaselineProfilesTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    restingHeartRate: restingHeartRate ?? this.restingHeartRate,
    hrvRmssd: hrvRmssd ?? this.hrvRmssd,
    respiratoryRate: respiratoryRate ?? this.respiratoryRate,
    movementIntensity: movementIntensity ?? this.movementIntensity,
  );
  BaselineProfilesTableData copyWithCompanion(
    BaselineProfilesTableCompanion data,
  ) {
    return BaselineProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      restingHeartRate: data.restingHeartRate.present
          ? data.restingHeartRate.value
          : this.restingHeartRate,
      hrvRmssd: data.hrvRmssd.present ? data.hrvRmssd.value : this.hrvRmssd,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      movementIntensity: data.movementIntensity.present
          ? data.movementIntensity.value
          : this.movementIntensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BaselineProfilesTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('movementIntensity: $movementIntensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    restingHeartRate,
    hrvRmssd,
    respiratoryRate,
    movementIntensity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BaselineProfilesTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.restingHeartRate == this.restingHeartRate &&
          other.hrvRmssd == this.hrvRmssd &&
          other.respiratoryRate == this.respiratoryRate &&
          other.movementIntensity == this.movementIntensity);
}

class BaselineProfilesTableCompanion
    extends UpdateCompanion<BaselineProfilesTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<double> restingHeartRate;
  final Value<double> hrvRmssd;
  final Value<double> respiratoryRate;
  final Value<double> movementIntensity;
  final Value<int> rowid;
  const BaselineProfilesTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.hrvRmssd = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.movementIntensity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BaselineProfilesTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required double restingHeartRate,
    required double hrvRmssd,
    required double respiratoryRate,
    required double movementIntensity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       restingHeartRate = Value(restingHeartRate),
       hrvRmssd = Value(hrvRmssd),
       respiratoryRate = Value(respiratoryRate),
       movementIntensity = Value(movementIntensity);
  static Insertable<BaselineProfilesTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<double>? restingHeartRate,
    Expression<double>? hrvRmssd,
    Expression<double>? respiratoryRate,
    Expression<double>? movementIntensity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (restingHeartRate != null) 'resting_heart_rate': restingHeartRate,
      if (hrvRmssd != null) 'hrv_rmssd': hrvRmssd,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (movementIntensity != null) 'movement_intensity': movementIntensity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BaselineProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<double>? restingHeartRate,
    Value<double>? hrvRmssd,
    Value<double>? respiratoryRate,
    Value<double>? movementIntensity,
    Value<int>? rowid,
  }) {
    return BaselineProfilesTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      movementIntensity: movementIntensity ?? this.movementIntensity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (restingHeartRate.present) {
      map['resting_heart_rate'] = Variable<double>(restingHeartRate.value);
    }
    if (hrvRmssd.present) {
      map['hrv_rmssd'] = Variable<double>(hrvRmssd.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate.value);
    }
    if (movementIntensity.present) {
      map['movement_intensity'] = Variable<double>(movementIntensity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BaselineProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('movementIntensity: $movementIntensity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CrisisRiskEventsTableTable extends CrisisRiskEventsTable
    with TableInfo<$CrisisRiskEventsTableTable, CrisisRiskEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CrisisRiskEventsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonCodesJsonMeta = const VerificationMeta(
    'reasonCodesJson',
  );
  @override
  late final GeneratedColumn<String> reasonCodesJson = GeneratedColumn<String>(
    'reason_codes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendedActionMeta = const VerificationMeta(
    'recommendedAction',
  );
  @override
  late final GeneratedColumn<String> recommendedAction =
      GeneratedColumn<String>(
        'recommended_action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _cognitiveResponseMeta = const VerificationMeta(
    'cognitiveResponse',
  );
  @override
  late final GeneratedColumn<String> cognitiveResponse =
      GeneratedColumn<String>(
        'cognitive_response',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timestamp,
    score,
    level,
    reasonCodesJson,
    recommendedAction,
    cognitiveResponse,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'crisis_risk_events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CrisisRiskEventsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('reason_codes_json')) {
      context.handle(
        _reasonCodesJsonMeta,
        reasonCodesJson.isAcceptableOrUnknown(
          data['reason_codes_json']!,
          _reasonCodesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reasonCodesJsonMeta);
    }
    if (data.containsKey('recommended_action')) {
      context.handle(
        _recommendedActionMeta,
        recommendedAction.isAcceptableOrUnknown(
          data['recommended_action']!,
          _recommendedActionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendedActionMeta);
    }
    if (data.containsKey('cognitive_response')) {
      context.handle(
        _cognitiveResponseMeta,
        cognitiveResponse.isAcceptableOrUnknown(
          data['cognitive_response']!,
          _cognitiveResponseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cognitiveResponseMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CrisisRiskEventsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CrisisRiskEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      reasonCodesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_codes_json'],
      )!,
      recommendedAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommended_action'],
      )!,
      cognitiveResponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cognitive_response'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $CrisisRiskEventsTableTable createAlias(String alias) {
    return $CrisisRiskEventsTableTable(attachedDatabase, alias);
  }
}

class CrisisRiskEventsTableData extends DataClass
    implements Insertable<CrisisRiskEventsTableData> {
  final String id;
  final DateTime timestamp;
  final int score;
  final String level;
  final String reasonCodesJson;
  final String recommendedAction;
  final String cognitiveResponse;
  final String source;
  const CrisisRiskEventsTableData({
    required this.id,
    required this.timestamp,
    required this.score,
    required this.level,
    required this.reasonCodesJson,
    required this.recommendedAction,
    required this.cognitiveResponse,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['score'] = Variable<int>(score);
    map['level'] = Variable<String>(level);
    map['reason_codes_json'] = Variable<String>(reasonCodesJson);
    map['recommended_action'] = Variable<String>(recommendedAction);
    map['cognitive_response'] = Variable<String>(cognitiveResponse);
    map['source'] = Variable<String>(source);
    return map;
  }

  CrisisRiskEventsTableCompanion toCompanion(bool nullToAbsent) {
    return CrisisRiskEventsTableCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      score: Value(score),
      level: Value(level),
      reasonCodesJson: Value(reasonCodesJson),
      recommendedAction: Value(recommendedAction),
      cognitiveResponse: Value(cognitiveResponse),
      source: Value(source),
    );
  }

  factory CrisisRiskEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CrisisRiskEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      score: serializer.fromJson<int>(json['score']),
      level: serializer.fromJson<String>(json['level']),
      reasonCodesJson: serializer.fromJson<String>(json['reasonCodesJson']),
      recommendedAction: serializer.fromJson<String>(json['recommendedAction']),
      cognitiveResponse: serializer.fromJson<String>(json['cognitiveResponse']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'score': serializer.toJson<int>(score),
      'level': serializer.toJson<String>(level),
      'reasonCodesJson': serializer.toJson<String>(reasonCodesJson),
      'recommendedAction': serializer.toJson<String>(recommendedAction),
      'cognitiveResponse': serializer.toJson<String>(cognitiveResponse),
      'source': serializer.toJson<String>(source),
    };
  }

  CrisisRiskEventsTableData copyWith({
    String? id,
    DateTime? timestamp,
    int? score,
    String? level,
    String? reasonCodesJson,
    String? recommendedAction,
    String? cognitiveResponse,
    String? source,
  }) => CrisisRiskEventsTableData(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    score: score ?? this.score,
    level: level ?? this.level,
    reasonCodesJson: reasonCodesJson ?? this.reasonCodesJson,
    recommendedAction: recommendedAction ?? this.recommendedAction,
    cognitiveResponse: cognitiveResponse ?? this.cognitiveResponse,
    source: source ?? this.source,
  );
  CrisisRiskEventsTableData copyWithCompanion(
    CrisisRiskEventsTableCompanion data,
  ) {
    return CrisisRiskEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      score: data.score.present ? data.score.value : this.score,
      level: data.level.present ? data.level.value : this.level,
      reasonCodesJson: data.reasonCodesJson.present
          ? data.reasonCodesJson.value
          : this.reasonCodesJson,
      recommendedAction: data.recommendedAction.present
          ? data.recommendedAction.value
          : this.recommendedAction,
      cognitiveResponse: data.cognitiveResponse.present
          ? data.cognitiveResponse.value
          : this.cognitiveResponse,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CrisisRiskEventsTableData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('reasonCodesJson: $reasonCodesJson, ')
          ..write('recommendedAction: $recommendedAction, ')
          ..write('cognitiveResponse: $cognitiveResponse, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    score,
    level,
    reasonCodesJson,
    recommendedAction,
    cognitiveResponse,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CrisisRiskEventsTableData &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.score == this.score &&
          other.level == this.level &&
          other.reasonCodesJson == this.reasonCodesJson &&
          other.recommendedAction == this.recommendedAction &&
          other.cognitiveResponse == this.cognitiveResponse &&
          other.source == this.source);
}

class CrisisRiskEventsTableCompanion
    extends UpdateCompanion<CrisisRiskEventsTableData> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<int> score;
  final Value<String> level;
  final Value<String> reasonCodesJson;
  final Value<String> recommendedAction;
  final Value<String> cognitiveResponse;
  final Value<String> source;
  final Value<int> rowid;
  const CrisisRiskEventsTableCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.score = const Value.absent(),
    this.level = const Value.absent(),
    this.reasonCodesJson = const Value.absent(),
    this.recommendedAction = const Value.absent(),
    this.cognitiveResponse = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CrisisRiskEventsTableCompanion.insert({
    required String id,
    required DateTime timestamp,
    required int score,
    required String level,
    required String reasonCodesJson,
    required String recommendedAction,
    required String cognitiveResponse,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       score = Value(score),
       level = Value(level),
       reasonCodesJson = Value(reasonCodesJson),
       recommendedAction = Value(recommendedAction),
       cognitiveResponse = Value(cognitiveResponse),
       source = Value(source);
  static Insertable<CrisisRiskEventsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? score,
    Expression<String>? level,
    Expression<String>? reasonCodesJson,
    Expression<String>? recommendedAction,
    Expression<String>? cognitiveResponse,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (score != null) 'score': score,
      if (level != null) 'level': level,
      if (reasonCodesJson != null) 'reason_codes_json': reasonCodesJson,
      if (recommendedAction != null) 'recommended_action': recommendedAction,
      if (cognitiveResponse != null) 'cognitive_response': cognitiveResponse,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CrisisRiskEventsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? timestamp,
    Value<int>? score,
    Value<String>? level,
    Value<String>? reasonCodesJson,
    Value<String>? recommendedAction,
    Value<String>? cognitiveResponse,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return CrisisRiskEventsTableCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      level: level ?? this.level,
      reasonCodesJson: reasonCodesJson ?? this.reasonCodesJson,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      cognitiveResponse: cognitiveResponse ?? this.cognitiveResponse,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (reasonCodesJson.present) {
      map['reason_codes_json'] = Variable<String>(reasonCodesJson.value);
    }
    if (recommendedAction.present) {
      map['recommended_action'] = Variable<String>(recommendedAction.value);
    }
    if (cognitiveResponse.present) {
      map['cognitive_response'] = Variable<String>(cognitiveResponse.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CrisisRiskEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('score: $score, ')
          ..write('level: $level, ')
          ..write('reasonCodesJson: $reasonCodesJson, ')
          ..write('recommendedAction: $recommendedAction, ')
          ..write('cognitiveResponse: $cognitiveResponse, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterventionHistoryTableTable extends InterventionHistoryTable
    with
        TableInfo<
          $InterventionHistoryTableTable,
          InterventionHistoryTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterventionHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _protocolIdMeta = const VerificationMeta(
    'protocolId',
  );
  @override
  late final GeneratedColumn<String> protocolId = GeneratedColumn<String>(
    'protocol_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _userReportedImprovementMeta =
      const VerificationMeta('userReportedImprovement');
  @override
  late final GeneratedColumn<bool> userReportedImprovement =
      GeneratedColumn<bool>(
        'user_reported_improvement',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("user_reported_improvement" IN (0, 1))',
        ),
      );
  static const VerificationMeta _finalResponseMeta = const VerificationMeta(
    'finalResponse',
  );
  @override
  late final GeneratedColumn<String> finalResponse = GeneratedColumn<String>(
    'final_response',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preScoreMeta = const VerificationMeta(
    'preScore',
  );
  @override
  late final GeneratedColumn<int> preScore = GeneratedColumn<int>(
    'pre_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postScoreMeta = const VerificationMeta(
    'postScore',
  );
  @override
  late final GeneratedColumn<int> postScore = GeneratedColumn<int>(
    'post_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreDeltaMeta = const VerificationMeta(
    'scoreDelta',
  );
  @override
  late final GeneratedColumn<int> scoreDelta = GeneratedColumn<int>(
    'score_delta',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    protocolId,
    startedAt,
    completedAt,
    durationSeconds,
    completed,
    userReportedImprovement,
    finalResponse,
    preScore,
    postScore,
    scoreDelta,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervention_history_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterventionHistoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('protocol_id')) {
      context.handle(
        _protocolIdMeta,
        protocolId.isAcceptableOrUnknown(data['protocol_id']!, _protocolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_protocolIdMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_durationSecondsMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('user_reported_improvement')) {
      context.handle(
        _userReportedImprovementMeta,
        userReportedImprovement.isAcceptableOrUnknown(
          data['user_reported_improvement']!,
          _userReportedImprovementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_userReportedImprovementMeta);
    }
    if (data.containsKey('final_response')) {
      context.handle(
        _finalResponseMeta,
        finalResponse.isAcceptableOrUnknown(
          data['final_response']!,
          _finalResponseMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_finalResponseMeta);
    }
    if (data.containsKey('pre_score')) {
      context.handle(
        _preScoreMeta,
        preScore.isAcceptableOrUnknown(data['pre_score']!, _preScoreMeta),
      );
    }
    if (data.containsKey('post_score')) {
      context.handle(
        _postScoreMeta,
        postScore.isAcceptableOrUnknown(data['post_score']!, _postScoreMeta),
      );
    }
    if (data.containsKey('score_delta')) {
      context.handle(
        _scoreDeltaMeta,
        scoreDelta.isAcceptableOrUnknown(data['score_delta']!, _scoreDeltaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterventionHistoryTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterventionHistoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      protocolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}protocol_id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      userReportedImprovement: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}user_reported_improvement'],
      )!,
      finalResponse: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}final_response'],
      )!,
      preScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pre_score'],
      ),
      postScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}post_score'],
      ),
      scoreDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_delta'],
      ),
    );
  }

  @override
  $InterventionHistoryTableTable createAlias(String alias) {
    return $InterventionHistoryTableTable(attachedDatabase, alias);
  }
}

class InterventionHistoryTableData extends DataClass
    implements Insertable<InterventionHistoryTableData> {
  final String id;
  final String protocolId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationSeconds;
  final bool completed;
  final bool userReportedImprovement;
  final String finalResponse;
  final int? preScore;
  final int? postScore;
  final int? scoreDelta;
  const InterventionHistoryTableData({
    required this.id,
    required this.protocolId,
    required this.startedAt,
    required this.completedAt,
    required this.durationSeconds,
    required this.completed,
    required this.userReportedImprovement,
    required this.finalResponse,
    this.preScore,
    this.postScore,
    this.scoreDelta,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['protocol_id'] = Variable<String>(protocolId);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed'] = Variable<bool>(completed);
    map['user_reported_improvement'] = Variable<bool>(userReportedImprovement);
    map['final_response'] = Variable<String>(finalResponse);
    if (!nullToAbsent || preScore != null) {
      map['pre_score'] = Variable<int>(preScore);
    }
    if (!nullToAbsent || postScore != null) {
      map['post_score'] = Variable<int>(postScore);
    }
    if (!nullToAbsent || scoreDelta != null) {
      map['score_delta'] = Variable<int>(scoreDelta);
    }
    return map;
  }

  InterventionHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return InterventionHistoryTableCompanion(
      id: Value(id),
      protocolId: Value(protocolId),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      durationSeconds: Value(durationSeconds),
      completed: Value(completed),
      userReportedImprovement: Value(userReportedImprovement),
      finalResponse: Value(finalResponse),
      preScore: preScore == null && nullToAbsent
          ? const Value.absent()
          : Value(preScore),
      postScore: postScore == null && nullToAbsent
          ? const Value.absent()
          : Value(postScore),
      scoreDelta: scoreDelta == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreDelta),
    );
  }

  factory InterventionHistoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterventionHistoryTableData(
      id: serializer.fromJson<String>(json['id']),
      protocolId: serializer.fromJson<String>(json['protocolId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
      userReportedImprovement: serializer.fromJson<bool>(
        json['userReportedImprovement'],
      ),
      finalResponse: serializer.fromJson<String>(json['finalResponse']),
      preScore: serializer.fromJson<int?>(json['preScore']),
      postScore: serializer.fromJson<int?>(json['postScore']),
      scoreDelta: serializer.fromJson<int?>(json['scoreDelta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'protocolId': serializer.toJson<String>(protocolId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'completed': serializer.toJson<bool>(completed),
      'userReportedImprovement': serializer.toJson<bool>(
        userReportedImprovement,
      ),
      'finalResponse': serializer.toJson<String>(finalResponse),
      'preScore': serializer.toJson<int?>(preScore),
      'postScore': serializer.toJson<int?>(postScore),
      'scoreDelta': serializer.toJson<int?>(scoreDelta),
    };
  }

  InterventionHistoryTableData copyWith({
    String? id,
    String? protocolId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? durationSeconds,
    bool? completed,
    bool? userReportedImprovement,
    String? finalResponse,
    Value<int?> preScore = const Value.absent(),
    Value<int?> postScore = const Value.absent(),
    Value<int?> scoreDelta = const Value.absent(),
  }) => InterventionHistoryTableData(
    id: id ?? this.id,
    protocolId: protocolId ?? this.protocolId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completed: completed ?? this.completed,
    userReportedImprovement:
        userReportedImprovement ?? this.userReportedImprovement,
    finalResponse: finalResponse ?? this.finalResponse,
    preScore: preScore.present ? preScore.value : this.preScore,
    postScore: postScore.present ? postScore.value : this.postScore,
    scoreDelta: scoreDelta.present ? scoreDelta.value : this.scoreDelta,
  );
  InterventionHistoryTableData copyWithCompanion(
    InterventionHistoryTableCompanion data,
  ) {
    return InterventionHistoryTableData(
      id: data.id.present ? data.id.value : this.id,
      protocolId: data.protocolId.present
          ? data.protocolId.value
          : this.protocolId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
      userReportedImprovement: data.userReportedImprovement.present
          ? data.userReportedImprovement.value
          : this.userReportedImprovement,
      finalResponse: data.finalResponse.present
          ? data.finalResponse.value
          : this.finalResponse,
      preScore: data.preScore.present ? data.preScore.value : this.preScore,
      postScore: data.postScore.present ? data.postScore.value : this.postScore,
      scoreDelta: data.scoreDelta.present
          ? data.scoreDelta.value
          : this.scoreDelta,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterventionHistoryTableData(')
          ..write('id: $id, ')
          ..write('protocolId: $protocolId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('userReportedImprovement: $userReportedImprovement, ')
          ..write('finalResponse: $finalResponse, ')
          ..write('preScore: $preScore, ')
          ..write('postScore: $postScore, ')
          ..write('scoreDelta: $scoreDelta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    protocolId,
    startedAt,
    completedAt,
    durationSeconds,
    completed,
    userReportedImprovement,
    finalResponse,
    preScore,
    postScore,
    scoreDelta,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterventionHistoryTableData &&
          other.id == this.id &&
          other.protocolId == this.protocolId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.completed == this.completed &&
          other.userReportedImprovement == this.userReportedImprovement &&
          other.finalResponse == this.finalResponse &&
          other.preScore == this.preScore &&
          other.postScore == this.postScore &&
          other.scoreDelta == this.scoreDelta);
}

class InterventionHistoryTableCompanion
    extends UpdateCompanion<InterventionHistoryTableData> {
  final Value<String> id;
  final Value<String> protocolId;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<int> durationSeconds;
  final Value<bool> completed;
  final Value<bool> userReportedImprovement;
  final Value<String> finalResponse;
  final Value<int?> preScore;
  final Value<int?> postScore;
  final Value<int?> scoreDelta;
  final Value<int> rowid;
  const InterventionHistoryTableCompanion({
    this.id = const Value.absent(),
    this.protocolId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.userReportedImprovement = const Value.absent(),
    this.finalResponse = const Value.absent(),
    this.preScore = const Value.absent(),
    this.postScore = const Value.absent(),
    this.scoreDelta = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterventionHistoryTableCompanion.insert({
    required String id,
    required String protocolId,
    required DateTime startedAt,
    required DateTime completedAt,
    required int durationSeconds,
    required bool completed,
    required bool userReportedImprovement,
    required String finalResponse,
    this.preScore = const Value.absent(),
    this.postScore = const Value.absent(),
    this.scoreDelta = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       protocolId = Value(protocolId),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt),
       durationSeconds = Value(durationSeconds),
       completed = Value(completed),
       userReportedImprovement = Value(userReportedImprovement),
       finalResponse = Value(finalResponse);
  static Insertable<InterventionHistoryTableData> custom({
    Expression<String>? id,
    Expression<String>? protocolId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? durationSeconds,
    Expression<bool>? completed,
    Expression<bool>? userReportedImprovement,
    Expression<String>? finalResponse,
    Expression<int>? preScore,
    Expression<int>? postScore,
    Expression<int>? scoreDelta,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (protocolId != null) 'protocol_id': protocolId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completed != null) 'completed': completed,
      if (userReportedImprovement != null)
        'user_reported_improvement': userReportedImprovement,
      if (finalResponse != null) 'final_response': finalResponse,
      if (preScore != null) 'pre_score': preScore,
      if (postScore != null) 'post_score': postScore,
      if (scoreDelta != null) 'score_delta': scoreDelta,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterventionHistoryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? protocolId,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<int>? durationSeconds,
    Value<bool>? completed,
    Value<bool>? userReportedImprovement,
    Value<String>? finalResponse,
    Value<int?>? preScore,
    Value<int?>? postScore,
    Value<int?>? scoreDelta,
    Value<int>? rowid,
  }) {
    return InterventionHistoryTableCompanion(
      id: id ?? this.id,
      protocolId: protocolId ?? this.protocolId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completed: completed ?? this.completed,
      userReportedImprovement:
          userReportedImprovement ?? this.userReportedImprovement,
      finalResponse: finalResponse ?? this.finalResponse,
      preScore: preScore ?? this.preScore,
      postScore: postScore ?? this.postScore,
      scoreDelta: scoreDelta ?? this.scoreDelta,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (protocolId.present) {
      map['protocol_id'] = Variable<String>(protocolId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (userReportedImprovement.present) {
      map['user_reported_improvement'] = Variable<bool>(
        userReportedImprovement.value,
      );
    }
    if (finalResponse.present) {
      map['final_response'] = Variable<String>(finalResponse.value);
    }
    if (preScore.present) {
      map['pre_score'] = Variable<int>(preScore.value);
    }
    if (postScore.present) {
      map['post_score'] = Variable<int>(postScore.value);
    }
    if (scoreDelta.present) {
      map['score_delta'] = Variable<int>(scoreDelta.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterventionHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('protocolId: $protocolId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completed: $completed, ')
          ..write('userReportedImprovement: $userReportedImprovement, ')
          ..write('finalResponse: $finalResponse, ')
          ..write('preScore: $preScore, ')
          ..write('postScore: $postScore, ')
          ..write('scoreDelta: $scoreDelta, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchConsentTableTable extends ResearchConsentTable
    with TableInfo<$ResearchConsentTableTable, ResearchConsentTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchConsentTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _acceptedMeta = const VerificationMeta(
    'accepted',
  );
  @override
  late final GeneratedColumn<bool> accepted = GeneratedColumn<bool>(
    'accepted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("accepted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _acceptedAtMeta = const VerificationMeta(
    'acceptedAt',
  );
  @override
  late final GeneratedColumn<DateTime> acceptedAt = GeneratedColumn<DateTime>(
    'accepted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _allowsPhysiologicalCollectionMeta =
      const VerificationMeta('allowsPhysiologicalCollection');
  @override
  late final GeneratedColumn<bool> allowsPhysiologicalCollection =
      GeneratedColumn<bool>(
        'allows_physiological_collection',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("allows_physiological_collection" IN (0, 1))',
        ),
      );
  static const VerificationMeta _allowsResearchExportMeta =
      const VerificationMeta('allowsResearchExport');
  @override
  late final GeneratedColumn<bool> allowsResearchExport = GeneratedColumn<bool>(
    'allows_research_export',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allows_research_export" IN (0, 1))',
    ),
  );
  static const VerificationMeta _allowsReplayAnalysisMeta =
      const VerificationMeta('allowsReplayAnalysis');
  @override
  late final GeneratedColumn<bool> allowsReplayAnalysis = GeneratedColumn<bool>(
    'allows_replay_analysis',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("allows_replay_analysis" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    accepted,
    acceptedAt,
    version,
    allowsPhysiologicalCollection,
    allowsResearchExport,
    allowsReplayAnalysis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_consent_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchConsentTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('accepted')) {
      context.handle(
        _acceptedMeta,
        accepted.isAcceptableOrUnknown(data['accepted']!, _acceptedMeta),
      );
    } else if (isInserting) {
      context.missing(_acceptedMeta);
    }
    if (data.containsKey('accepted_at')) {
      context.handle(
        _acceptedAtMeta,
        acceptedAt.isAcceptableOrUnknown(data['accepted_at']!, _acceptedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('allows_physiological_collection')) {
      context.handle(
        _allowsPhysiologicalCollectionMeta,
        allowsPhysiologicalCollection.isAcceptableOrUnknown(
          data['allows_physiological_collection']!,
          _allowsPhysiologicalCollectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowsPhysiologicalCollectionMeta);
    }
    if (data.containsKey('allows_research_export')) {
      context.handle(
        _allowsResearchExportMeta,
        allowsResearchExport.isAcceptableOrUnknown(
          data['allows_research_export']!,
          _allowsResearchExportMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowsResearchExportMeta);
    }
    if (data.containsKey('allows_replay_analysis')) {
      context.handle(
        _allowsReplayAnalysisMeta,
        allowsReplayAnalysis.isAcceptableOrUnknown(
          data['allows_replay_analysis']!,
          _allowsReplayAnalysisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_allowsReplayAnalysisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchConsentTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchConsentTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      accepted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}accepted'],
      )!,
      acceptedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}accepted_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      allowsPhysiologicalCollection: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_physiological_collection'],
      )!,
      allowsResearchExport: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_research_export'],
      )!,
      allowsReplayAnalysis: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}allows_replay_analysis'],
      )!,
    );
  }

  @override
  $ResearchConsentTableTable createAlias(String alias) {
    return $ResearchConsentTableTable(attachedDatabase, alias);
  }
}

class ResearchConsentTableData extends DataClass
    implements Insertable<ResearchConsentTableData> {
  final String id;
  final bool accepted;
  final DateTime? acceptedAt;
  final String version;
  final bool allowsPhysiologicalCollection;
  final bool allowsResearchExport;
  final bool allowsReplayAnalysis;
  const ResearchConsentTableData({
    required this.id,
    required this.accepted,
    this.acceptedAt,
    required this.version,
    required this.allowsPhysiologicalCollection,
    required this.allowsResearchExport,
    required this.allowsReplayAnalysis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['accepted'] = Variable<bool>(accepted);
    if (!nullToAbsent || acceptedAt != null) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt);
    }
    map['version'] = Variable<String>(version);
    map['allows_physiological_collection'] = Variable<bool>(
      allowsPhysiologicalCollection,
    );
    map['allows_research_export'] = Variable<bool>(allowsResearchExport);
    map['allows_replay_analysis'] = Variable<bool>(allowsReplayAnalysis);
    return map;
  }

  ResearchConsentTableCompanion toCompanion(bool nullToAbsent) {
    return ResearchConsentTableCompanion(
      id: Value(id),
      accepted: Value(accepted),
      acceptedAt: acceptedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(acceptedAt),
      version: Value(version),
      allowsPhysiologicalCollection: Value(allowsPhysiologicalCollection),
      allowsResearchExport: Value(allowsResearchExport),
      allowsReplayAnalysis: Value(allowsReplayAnalysis),
    );
  }

  factory ResearchConsentTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchConsentTableData(
      id: serializer.fromJson<String>(json['id']),
      accepted: serializer.fromJson<bool>(json['accepted']),
      acceptedAt: serializer.fromJson<DateTime?>(json['acceptedAt']),
      version: serializer.fromJson<String>(json['version']),
      allowsPhysiologicalCollection: serializer.fromJson<bool>(
        json['allowsPhysiologicalCollection'],
      ),
      allowsResearchExport: serializer.fromJson<bool>(
        json['allowsResearchExport'],
      ),
      allowsReplayAnalysis: serializer.fromJson<bool>(
        json['allowsReplayAnalysis'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accepted': serializer.toJson<bool>(accepted),
      'acceptedAt': serializer.toJson<DateTime?>(acceptedAt),
      'version': serializer.toJson<String>(version),
      'allowsPhysiologicalCollection': serializer.toJson<bool>(
        allowsPhysiologicalCollection,
      ),
      'allowsResearchExport': serializer.toJson<bool>(allowsResearchExport),
      'allowsReplayAnalysis': serializer.toJson<bool>(allowsReplayAnalysis),
    };
  }

  ResearchConsentTableData copyWith({
    String? id,
    bool? accepted,
    Value<DateTime?> acceptedAt = const Value.absent(),
    String? version,
    bool? allowsPhysiologicalCollection,
    bool? allowsResearchExport,
    bool? allowsReplayAnalysis,
  }) => ResearchConsentTableData(
    id: id ?? this.id,
    accepted: accepted ?? this.accepted,
    acceptedAt: acceptedAt.present ? acceptedAt.value : this.acceptedAt,
    version: version ?? this.version,
    allowsPhysiologicalCollection:
        allowsPhysiologicalCollection ?? this.allowsPhysiologicalCollection,
    allowsResearchExport: allowsResearchExport ?? this.allowsResearchExport,
    allowsReplayAnalysis: allowsReplayAnalysis ?? this.allowsReplayAnalysis,
  );
  ResearchConsentTableData copyWithCompanion(
    ResearchConsentTableCompanion data,
  ) {
    return ResearchConsentTableData(
      id: data.id.present ? data.id.value : this.id,
      accepted: data.accepted.present ? data.accepted.value : this.accepted,
      acceptedAt: data.acceptedAt.present
          ? data.acceptedAt.value
          : this.acceptedAt,
      version: data.version.present ? data.version.value : this.version,
      allowsPhysiologicalCollection: data.allowsPhysiologicalCollection.present
          ? data.allowsPhysiologicalCollection.value
          : this.allowsPhysiologicalCollection,
      allowsResearchExport: data.allowsResearchExport.present
          ? data.allowsResearchExport.value
          : this.allowsResearchExport,
      allowsReplayAnalysis: data.allowsReplayAnalysis.present
          ? data.allowsReplayAnalysis.value
          : this.allowsReplayAnalysis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchConsentTableData(')
          ..write('id: $id, ')
          ..write('accepted: $accepted, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('version: $version, ')
          ..write(
            'allowsPhysiologicalCollection: $allowsPhysiologicalCollection, ',
          )
          ..write('allowsResearchExport: $allowsResearchExport, ')
          ..write('allowsReplayAnalysis: $allowsReplayAnalysis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    accepted,
    acceptedAt,
    version,
    allowsPhysiologicalCollection,
    allowsResearchExport,
    allowsReplayAnalysis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchConsentTableData &&
          other.id == this.id &&
          other.accepted == this.accepted &&
          other.acceptedAt == this.acceptedAt &&
          other.version == this.version &&
          other.allowsPhysiologicalCollection ==
              this.allowsPhysiologicalCollection &&
          other.allowsResearchExport == this.allowsResearchExport &&
          other.allowsReplayAnalysis == this.allowsReplayAnalysis);
}

class ResearchConsentTableCompanion
    extends UpdateCompanion<ResearchConsentTableData> {
  final Value<String> id;
  final Value<bool> accepted;
  final Value<DateTime?> acceptedAt;
  final Value<String> version;
  final Value<bool> allowsPhysiologicalCollection;
  final Value<bool> allowsResearchExport;
  final Value<bool> allowsReplayAnalysis;
  final Value<int> rowid;
  const ResearchConsentTableCompanion({
    this.id = const Value.absent(),
    this.accepted = const Value.absent(),
    this.acceptedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.allowsPhysiologicalCollection = const Value.absent(),
    this.allowsResearchExport = const Value.absent(),
    this.allowsReplayAnalysis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchConsentTableCompanion.insert({
    required String id,
    required bool accepted,
    this.acceptedAt = const Value.absent(),
    required String version,
    required bool allowsPhysiologicalCollection,
    required bool allowsResearchExport,
    required bool allowsReplayAnalysis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       accepted = Value(accepted),
       version = Value(version),
       allowsPhysiologicalCollection = Value(allowsPhysiologicalCollection),
       allowsResearchExport = Value(allowsResearchExport),
       allowsReplayAnalysis = Value(allowsReplayAnalysis);
  static Insertable<ResearchConsentTableData> custom({
    Expression<String>? id,
    Expression<bool>? accepted,
    Expression<DateTime>? acceptedAt,
    Expression<String>? version,
    Expression<bool>? allowsPhysiologicalCollection,
    Expression<bool>? allowsResearchExport,
    Expression<bool>? allowsReplayAnalysis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accepted != null) 'accepted': accepted,
      if (acceptedAt != null) 'accepted_at': acceptedAt,
      if (version != null) 'version': version,
      if (allowsPhysiologicalCollection != null)
        'allows_physiological_collection': allowsPhysiologicalCollection,
      if (allowsResearchExport != null)
        'allows_research_export': allowsResearchExport,
      if (allowsReplayAnalysis != null)
        'allows_replay_analysis': allowsReplayAnalysis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchConsentTableCompanion copyWith({
    Value<String>? id,
    Value<bool>? accepted,
    Value<DateTime?>? acceptedAt,
    Value<String>? version,
    Value<bool>? allowsPhysiologicalCollection,
    Value<bool>? allowsResearchExport,
    Value<bool>? allowsReplayAnalysis,
    Value<int>? rowid,
  }) {
    return ResearchConsentTableCompanion(
      id: id ?? this.id,
      accepted: accepted ?? this.accepted,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      version: version ?? this.version,
      allowsPhysiologicalCollection:
          allowsPhysiologicalCollection ?? this.allowsPhysiologicalCollection,
      allowsResearchExport: allowsResearchExport ?? this.allowsResearchExport,
      allowsReplayAnalysis: allowsReplayAnalysis ?? this.allowsReplayAnalysis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accepted.present) {
      map['accepted'] = Variable<bool>(accepted.value);
    }
    if (acceptedAt.present) {
      map['accepted_at'] = Variable<DateTime>(acceptedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (allowsPhysiologicalCollection.present) {
      map['allows_physiological_collection'] = Variable<bool>(
        allowsPhysiologicalCollection.value,
      );
    }
    if (allowsResearchExport.present) {
      map['allows_research_export'] = Variable<bool>(
        allowsResearchExport.value,
      );
    }
    if (allowsReplayAnalysis.present) {
      map['allows_replay_analysis'] = Variable<bool>(
        allowsReplayAnalysis.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchConsentTableCompanion(')
          ..write('id: $id, ')
          ..write('accepted: $accepted, ')
          ..write('acceptedAt: $acceptedAt, ')
          ..write('version: $version, ')
          ..write(
            'allowsPhysiologicalCollection: $allowsPhysiologicalCollection, ',
          )
          ..write('allowsResearchExport: $allowsResearchExport, ')
          ..write('allowsReplayAnalysis: $allowsReplayAnalysis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdaptiveBaselineStateTableTable extends AdaptiveBaselineStateTable
    with
        TableInfo<
          $AdaptiveBaselineStateTableTable,
          AdaptiveBaselineStateTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdaptiveBaselineStateTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _totalSamplesMeta = const VerificationMeta(
    'totalSamples',
  );
  @override
  late final GeneratedColumn<int> totalSamples = GeneratedColumn<int>(
    'total_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _restingHeartRateMeta = const VerificationMeta(
    'restingHeartRate',
  );
  @override
  late final GeneratedColumn<double> restingHeartRate = GeneratedColumn<double>(
    'resting_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrvRmssdMeta = const VerificationMeta(
    'hrvRmssd',
  );
  @override
  late final GeneratedColumn<double> hrvRmssd = GeneratedColumn<double>(
    'hrv_rmssd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respiratoryRateMeta = const VerificationMeta(
    'respiratoryRate',
  );
  @override
  late final GeneratedColumn<double> respiratoryRate = GeneratedColumn<double>(
    'respiratory_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementIntensityMeta = const VerificationMeta(
    'movementIntensity',
  );
  @override
  late final GeneratedColumn<double> movementIntensity =
      GeneratedColumn<double>(
        'movement_intensity',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    totalSamples,
    restingHeartRate,
    hrvRmssd,
    respiratoryRate,
    movementIntensity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adaptive_baseline_state_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdaptiveBaselineStateTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('total_samples')) {
      context.handle(
        _totalSamplesMeta,
        totalSamples.isAcceptableOrUnknown(
          data['total_samples']!,
          _totalSamplesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalSamplesMeta);
    }
    if (data.containsKey('resting_heart_rate')) {
      context.handle(
        _restingHeartRateMeta,
        restingHeartRate.isAcceptableOrUnknown(
          data['resting_heart_rate']!,
          _restingHeartRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_restingHeartRateMeta);
    }
    if (data.containsKey('hrv_rmssd')) {
      context.handle(
        _hrvRmssdMeta,
        hrvRmssd.isAcceptableOrUnknown(data['hrv_rmssd']!, _hrvRmssdMeta),
      );
    } else if (isInserting) {
      context.missing(_hrvRmssdMeta);
    }
    if (data.containsKey('respiratory_rate')) {
      context.handle(
        _respiratoryRateMeta,
        respiratoryRate.isAcceptableOrUnknown(
          data['respiratory_rate']!,
          _respiratoryRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respiratoryRateMeta);
    }
    if (data.containsKey('movement_intensity')) {
      context.handle(
        _movementIntensityMeta,
        movementIntensity.isAcceptableOrUnknown(
          data['movement_intensity']!,
          _movementIntensityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementIntensityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdaptiveBaselineStateTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdaptiveBaselineStateTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      totalSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_samples'],
      )!,
      restingHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}resting_heart_rate'],
      )!,
      hrvRmssd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_rmssd'],
      )!,
      respiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}respiratory_rate'],
      )!,
      movementIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}movement_intensity'],
      )!,
    );
  }

  @override
  $AdaptiveBaselineStateTableTable createAlias(String alias) {
    return $AdaptiveBaselineStateTableTable(attachedDatabase, alias);
  }
}

class AdaptiveBaselineStateTableData extends DataClass
    implements Insertable<AdaptiveBaselineStateTableData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalSamples;
  final double restingHeartRate;
  final double hrvRmssd;
  final double respiratoryRate;
  final double movementIntensity;
  const AdaptiveBaselineStateTableData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.totalSamples,
    required this.restingHeartRate,
    required this.hrvRmssd,
    required this.respiratoryRate,
    required this.movementIntensity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['total_samples'] = Variable<int>(totalSamples);
    map['resting_heart_rate'] = Variable<double>(restingHeartRate);
    map['hrv_rmssd'] = Variable<double>(hrvRmssd);
    map['respiratory_rate'] = Variable<double>(respiratoryRate);
    map['movement_intensity'] = Variable<double>(movementIntensity);
    return map;
  }

  AdaptiveBaselineStateTableCompanion toCompanion(bool nullToAbsent) {
    return AdaptiveBaselineStateTableCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      totalSamples: Value(totalSamples),
      restingHeartRate: Value(restingHeartRate),
      hrvRmssd: Value(hrvRmssd),
      respiratoryRate: Value(respiratoryRate),
      movementIntensity: Value(movementIntensity),
    );
  }

  factory AdaptiveBaselineStateTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdaptiveBaselineStateTableData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      totalSamples: serializer.fromJson<int>(json['totalSamples']),
      restingHeartRate: serializer.fromJson<double>(json['restingHeartRate']),
      hrvRmssd: serializer.fromJson<double>(json['hrvRmssd']),
      respiratoryRate: serializer.fromJson<double>(json['respiratoryRate']),
      movementIntensity: serializer.fromJson<double>(json['movementIntensity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'totalSamples': serializer.toJson<int>(totalSamples),
      'restingHeartRate': serializer.toJson<double>(restingHeartRate),
      'hrvRmssd': serializer.toJson<double>(hrvRmssd),
      'respiratoryRate': serializer.toJson<double>(respiratoryRate),
      'movementIntensity': serializer.toJson<double>(movementIntensity),
    };
  }

  AdaptiveBaselineStateTableData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalSamples,
    double? restingHeartRate,
    double? hrvRmssd,
    double? respiratoryRate,
    double? movementIntensity,
  }) => AdaptiveBaselineStateTableData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    totalSamples: totalSamples ?? this.totalSamples,
    restingHeartRate: restingHeartRate ?? this.restingHeartRate,
    hrvRmssd: hrvRmssd ?? this.hrvRmssd,
    respiratoryRate: respiratoryRate ?? this.respiratoryRate,
    movementIntensity: movementIntensity ?? this.movementIntensity,
  );
  AdaptiveBaselineStateTableData copyWithCompanion(
    AdaptiveBaselineStateTableCompanion data,
  ) {
    return AdaptiveBaselineStateTableData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      totalSamples: data.totalSamples.present
          ? data.totalSamples.value
          : this.totalSamples,
      restingHeartRate: data.restingHeartRate.present
          ? data.restingHeartRate.value
          : this.restingHeartRate,
      hrvRmssd: data.hrvRmssd.present ? data.hrvRmssd.value : this.hrvRmssd,
      respiratoryRate: data.respiratoryRate.present
          ? data.respiratoryRate.value
          : this.respiratoryRate,
      movementIntensity: data.movementIntensity.present
          ? data.movementIntensity.value
          : this.movementIntensity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdaptiveBaselineStateTableData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('movementIntensity: $movementIntensity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    totalSamples,
    restingHeartRate,
    hrvRmssd,
    respiratoryRate,
    movementIntensity,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdaptiveBaselineStateTableData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.totalSamples == this.totalSamples &&
          other.restingHeartRate == this.restingHeartRate &&
          other.hrvRmssd == this.hrvRmssd &&
          other.respiratoryRate == this.respiratoryRate &&
          other.movementIntensity == this.movementIntensity);
}

class AdaptiveBaselineStateTableCompanion
    extends UpdateCompanion<AdaptiveBaselineStateTableData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> totalSamples;
  final Value<double> restingHeartRate;
  final Value<double> hrvRmssd;
  final Value<double> respiratoryRate;
  final Value<double> movementIntensity;
  final Value<int> rowid;
  const AdaptiveBaselineStateTableCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.restingHeartRate = const Value.absent(),
    this.hrvRmssd = const Value.absent(),
    this.respiratoryRate = const Value.absent(),
    this.movementIntensity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdaptiveBaselineStateTableCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int totalSamples,
    required double restingHeartRate,
    required double hrvRmssd,
    required double respiratoryRate,
    required double movementIntensity,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       totalSamples = Value(totalSamples),
       restingHeartRate = Value(restingHeartRate),
       hrvRmssd = Value(hrvRmssd),
       respiratoryRate = Value(respiratoryRate),
       movementIntensity = Value(movementIntensity);
  static Insertable<AdaptiveBaselineStateTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? totalSamples,
    Expression<double>? restingHeartRate,
    Expression<double>? hrvRmssd,
    Expression<double>? respiratoryRate,
    Expression<double>? movementIntensity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (totalSamples != null) 'total_samples': totalSamples,
      if (restingHeartRate != null) 'resting_heart_rate': restingHeartRate,
      if (hrvRmssd != null) 'hrv_rmssd': hrvRmssd,
      if (respiratoryRate != null) 'respiratory_rate': respiratoryRate,
      if (movementIntensity != null) 'movement_intensity': movementIntensity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdaptiveBaselineStateTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? totalSamples,
    Value<double>? restingHeartRate,
    Value<double>? hrvRmssd,
    Value<double>? respiratoryRate,
    Value<double>? movementIntensity,
    Value<int>? rowid,
  }) {
    return AdaptiveBaselineStateTableCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalSamples: totalSamples ?? this.totalSamples,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      hrvRmssd: hrvRmssd ?? this.hrvRmssd,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      movementIntensity: movementIntensity ?? this.movementIntensity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (totalSamples.present) {
      map['total_samples'] = Variable<int>(totalSamples.value);
    }
    if (restingHeartRate.present) {
      map['resting_heart_rate'] = Variable<double>(restingHeartRate.value);
    }
    if (hrvRmssd.present) {
      map['hrv_rmssd'] = Variable<double>(hrvRmssd.value);
    }
    if (respiratoryRate.present) {
      map['respiratory_rate'] = Variable<double>(respiratoryRate.value);
    }
    if (movementIntensity.present) {
      map['movement_intensity'] = Variable<double>(movementIntensity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdaptiveBaselineStateTableCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('restingHeartRate: $restingHeartRate, ')
          ..write('hrvRmssd: $hrvRmssd, ')
          ..write('respiratoryRate: $respiratoryRate, ')
          ..write('movementIntensity: $movementIntensity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CircadianProfilesTableTable extends CircadianProfilesTable
    with TableInfo<$CircadianProfilesTableTable, CircadianProfilesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CircadianProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baselineIdMeta = const VerificationMeta(
    'baselineId',
  );
  @override
  late final GeneratedColumn<String> baselineId = GeneratedColumn<String>(
    'baseline_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowLabelMeta = const VerificationMeta(
    'windowLabel',
  );
  @override
  late final GeneratedColumn<String> windowLabel = GeneratedColumn<String>(
    'window_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startHourMeta = const VerificationMeta(
    'startHour',
  );
  @override
  late final GeneratedColumn<int> startHour = GeneratedColumn<int>(
    'start_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endHourMeta = const VerificationMeta(
    'endHour',
  );
  @override
  late final GeneratedColumn<int> endHour = GeneratedColumn<int>(
    'end_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageHeartRateMeta = const VerificationMeta(
    'averageHeartRate',
  );
  @override
  late final GeneratedColumn<double> averageHeartRate = GeneratedColumn<double>(
    'average_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageHrvMeta = const VerificationMeta(
    'averageHrv',
  );
  @override
  late final GeneratedColumn<double> averageHrv = GeneratedColumn<double>(
    'average_hrv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageRespiratoryRateMeta =
      const VerificationMeta('averageRespiratoryRate');
  @override
  late final GeneratedColumn<double> averageRespiratoryRate =
      GeneratedColumn<double>(
        'average_respiratory_rate',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sampleCountMeta = const VerificationMeta(
    'sampleCount',
  );
  @override
  late final GeneratedColumn<int> sampleCount = GeneratedColumn<int>(
    'sample_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    id,
    baselineId,
    windowLabel,
    startHour,
    endHour,
    averageHeartRate,
    averageHrv,
    averageRespiratoryRate,
    sampleCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'circadian_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CircadianProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('baseline_id')) {
      context.handle(
        _baselineIdMeta,
        baselineId.isAcceptableOrUnknown(data['baseline_id']!, _baselineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_baselineIdMeta);
    }
    if (data.containsKey('window_label')) {
      context.handle(
        _windowLabelMeta,
        windowLabel.isAcceptableOrUnknown(
          data['window_label']!,
          _windowLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_windowLabelMeta);
    }
    if (data.containsKey('start_hour')) {
      context.handle(
        _startHourMeta,
        startHour.isAcceptableOrUnknown(data['start_hour']!, _startHourMeta),
      );
    } else if (isInserting) {
      context.missing(_startHourMeta);
    }
    if (data.containsKey('end_hour')) {
      context.handle(
        _endHourMeta,
        endHour.isAcceptableOrUnknown(data['end_hour']!, _endHourMeta),
      );
    } else if (isInserting) {
      context.missing(_endHourMeta);
    }
    if (data.containsKey('average_heart_rate')) {
      context.handle(
        _averageHeartRateMeta,
        averageHeartRate.isAcceptableOrUnknown(
          data['average_heart_rate']!,
          _averageHeartRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageHeartRateMeta);
    }
    if (data.containsKey('average_hrv')) {
      context.handle(
        _averageHrvMeta,
        averageHrv.isAcceptableOrUnknown(data['average_hrv']!, _averageHrvMeta),
      );
    }
    if (data.containsKey('average_respiratory_rate')) {
      context.handle(
        _averageRespiratoryRateMeta,
        averageRespiratoryRate.isAcceptableOrUnknown(
          data['average_respiratory_rate']!,
          _averageRespiratoryRateMeta,
        ),
      );
    }
    if (data.containsKey('sample_count')) {
      context.handle(
        _sampleCountMeta,
        sampleCount.isAcceptableOrUnknown(
          data['sample_count']!,
          _sampleCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sampleCountMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CircadianProfilesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CircadianProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      baselineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_id'],
      )!,
      windowLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_label'],
      )!,
      startHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_hour'],
      )!,
      endHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_hour'],
      )!,
      averageHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_heart_rate'],
      )!,
      averageHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_hrv'],
      ),
      averageRespiratoryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_respiratory_rate'],
      ),
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CircadianProfilesTableTable createAlias(String alias) {
    return $CircadianProfilesTableTable(attachedDatabase, alias);
  }
}

class CircadianProfilesTableData extends DataClass
    implements Insertable<CircadianProfilesTableData> {
  final String id;
  final String baselineId;
  final String windowLabel;
  final int startHour;
  final int endHour;
  final double averageHeartRate;
  final double? averageHrv;
  final double? averageRespiratoryRate;
  final int sampleCount;
  final DateTime updatedAt;
  const CircadianProfilesTableData({
    required this.id,
    required this.baselineId,
    required this.windowLabel,
    required this.startHour,
    required this.endHour,
    required this.averageHeartRate,
    this.averageHrv,
    this.averageRespiratoryRate,
    required this.sampleCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['baseline_id'] = Variable<String>(baselineId);
    map['window_label'] = Variable<String>(windowLabel);
    map['start_hour'] = Variable<int>(startHour);
    map['end_hour'] = Variable<int>(endHour);
    map['average_heart_rate'] = Variable<double>(averageHeartRate);
    if (!nullToAbsent || averageHrv != null) {
      map['average_hrv'] = Variable<double>(averageHrv);
    }
    if (!nullToAbsent || averageRespiratoryRate != null) {
      map['average_respiratory_rate'] = Variable<double>(
        averageRespiratoryRate,
      );
    }
    map['sample_count'] = Variable<int>(sampleCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CircadianProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return CircadianProfilesTableCompanion(
      id: Value(id),
      baselineId: Value(baselineId),
      windowLabel: Value(windowLabel),
      startHour: Value(startHour),
      endHour: Value(endHour),
      averageHeartRate: Value(averageHeartRate),
      averageHrv: averageHrv == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHrv),
      averageRespiratoryRate: averageRespiratoryRate == null && nullToAbsent
          ? const Value.absent()
          : Value(averageRespiratoryRate),
      sampleCount: Value(sampleCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory CircadianProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CircadianProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      baselineId: serializer.fromJson<String>(json['baselineId']),
      windowLabel: serializer.fromJson<String>(json['windowLabel']),
      startHour: serializer.fromJson<int>(json['startHour']),
      endHour: serializer.fromJson<int>(json['endHour']),
      averageHeartRate: serializer.fromJson<double>(json['averageHeartRate']),
      averageHrv: serializer.fromJson<double?>(json['averageHrv']),
      averageRespiratoryRate: serializer.fromJson<double?>(
        json['averageRespiratoryRate'],
      ),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'baselineId': serializer.toJson<String>(baselineId),
      'windowLabel': serializer.toJson<String>(windowLabel),
      'startHour': serializer.toJson<int>(startHour),
      'endHour': serializer.toJson<int>(endHour),
      'averageHeartRate': serializer.toJson<double>(averageHeartRate),
      'averageHrv': serializer.toJson<double?>(averageHrv),
      'averageRespiratoryRate': serializer.toJson<double?>(
        averageRespiratoryRate,
      ),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CircadianProfilesTableData copyWith({
    String? id,
    String? baselineId,
    String? windowLabel,
    int? startHour,
    int? endHour,
    double? averageHeartRate,
    Value<double?> averageHrv = const Value.absent(),
    Value<double?> averageRespiratoryRate = const Value.absent(),
    int? sampleCount,
    DateTime? updatedAt,
  }) => CircadianProfilesTableData(
    id: id ?? this.id,
    baselineId: baselineId ?? this.baselineId,
    windowLabel: windowLabel ?? this.windowLabel,
    startHour: startHour ?? this.startHour,
    endHour: endHour ?? this.endHour,
    averageHeartRate: averageHeartRate ?? this.averageHeartRate,
    averageHrv: averageHrv.present ? averageHrv.value : this.averageHrv,
    averageRespiratoryRate: averageRespiratoryRate.present
        ? averageRespiratoryRate.value
        : this.averageRespiratoryRate,
    sampleCount: sampleCount ?? this.sampleCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CircadianProfilesTableData copyWithCompanion(
    CircadianProfilesTableCompanion data,
  ) {
    return CircadianProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      baselineId: data.baselineId.present
          ? data.baselineId.value
          : this.baselineId,
      windowLabel: data.windowLabel.present
          ? data.windowLabel.value
          : this.windowLabel,
      startHour: data.startHour.present ? data.startHour.value : this.startHour,
      endHour: data.endHour.present ? data.endHour.value : this.endHour,
      averageHeartRate: data.averageHeartRate.present
          ? data.averageHeartRate.value
          : this.averageHeartRate,
      averageHrv: data.averageHrv.present
          ? data.averageHrv.value
          : this.averageHrv,
      averageRespiratoryRate: data.averageRespiratoryRate.present
          ? data.averageRespiratoryRate.value
          : this.averageRespiratoryRate,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CircadianProfilesTableData(')
          ..write('id: $id, ')
          ..write('baselineId: $baselineId, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('startHour: $startHour, ')
          ..write('endHour: $endHour, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('averageRespiratoryRate: $averageRespiratoryRate, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    baselineId,
    windowLabel,
    startHour,
    endHour,
    averageHeartRate,
    averageHrv,
    averageRespiratoryRate,
    sampleCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CircadianProfilesTableData &&
          other.id == this.id &&
          other.baselineId == this.baselineId &&
          other.windowLabel == this.windowLabel &&
          other.startHour == this.startHour &&
          other.endHour == this.endHour &&
          other.averageHeartRate == this.averageHeartRate &&
          other.averageHrv == this.averageHrv &&
          other.averageRespiratoryRate == this.averageRespiratoryRate &&
          other.sampleCount == this.sampleCount &&
          other.updatedAt == this.updatedAt);
}

class CircadianProfilesTableCompanion
    extends UpdateCompanion<CircadianProfilesTableData> {
  final Value<String> id;
  final Value<String> baselineId;
  final Value<String> windowLabel;
  final Value<int> startHour;
  final Value<int> endHour;
  final Value<double> averageHeartRate;
  final Value<double?> averageHrv;
  final Value<double?> averageRespiratoryRate;
  final Value<int> sampleCount;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CircadianProfilesTableCompanion({
    this.id = const Value.absent(),
    this.baselineId = const Value.absent(),
    this.windowLabel = const Value.absent(),
    this.startHour = const Value.absent(),
    this.endHour = const Value.absent(),
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    this.averageRespiratoryRate = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CircadianProfilesTableCompanion.insert({
    required String id,
    required String baselineId,
    required String windowLabel,
    required int startHour,
    required int endHour,
    required double averageHeartRate,
    this.averageHrv = const Value.absent(),
    this.averageRespiratoryRate = const Value.absent(),
    required int sampleCount,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       baselineId = Value(baselineId),
       windowLabel = Value(windowLabel),
       startHour = Value(startHour),
       endHour = Value(endHour),
       averageHeartRate = Value(averageHeartRate),
       sampleCount = Value(sampleCount),
       updatedAt = Value(updatedAt);
  static Insertable<CircadianProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? baselineId,
    Expression<String>? windowLabel,
    Expression<int>? startHour,
    Expression<int>? endHour,
    Expression<double>? averageHeartRate,
    Expression<double>? averageHrv,
    Expression<double>? averageRespiratoryRate,
    Expression<int>? sampleCount,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (baselineId != null) 'baseline_id': baselineId,
      if (windowLabel != null) 'window_label': windowLabel,
      if (startHour != null) 'start_hour': startHour,
      if (endHour != null) 'end_hour': endHour,
      if (averageHeartRate != null) 'average_heart_rate': averageHeartRate,
      if (averageHrv != null) 'average_hrv': averageHrv,
      if (averageRespiratoryRate != null)
        'average_respiratory_rate': averageRespiratoryRate,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CircadianProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? baselineId,
    Value<String>? windowLabel,
    Value<int>? startHour,
    Value<int>? endHour,
    Value<double>? averageHeartRate,
    Value<double?>? averageHrv,
    Value<double?>? averageRespiratoryRate,
    Value<int>? sampleCount,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CircadianProfilesTableCompanion(
      id: id ?? this.id,
      baselineId: baselineId ?? this.baselineId,
      windowLabel: windowLabel ?? this.windowLabel,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageHrv: averageHrv ?? this.averageHrv,
      averageRespiratoryRate:
          averageRespiratoryRate ?? this.averageRespiratoryRate,
      sampleCount: sampleCount ?? this.sampleCount,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (baselineId.present) {
      map['baseline_id'] = Variable<String>(baselineId.value);
    }
    if (windowLabel.present) {
      map['window_label'] = Variable<String>(windowLabel.value);
    }
    if (startHour.present) {
      map['start_hour'] = Variable<int>(startHour.value);
    }
    if (endHour.present) {
      map['end_hour'] = Variable<int>(endHour.value);
    }
    if (averageHeartRate.present) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate.value);
    }
    if (averageHrv.present) {
      map['average_hrv'] = Variable<double>(averageHrv.value);
    }
    if (averageRespiratoryRate.present) {
      map['average_respiratory_rate'] = Variable<double>(
        averageRespiratoryRate.value,
      );
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
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
    return (StringBuffer('CircadianProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('baselineId: $baselineId, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('startHour: $startHour, ')
          ..write('endHour: $endHour, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('averageRespiratoryRate: $averageRespiratoryRate, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionTimelineTableTable extends SessionTimelineTable
    with TableInfo<$SessionTimelineTableTable, SessionTimelineTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionTimelineTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalSamplesMeta = const VerificationMeta(
    'totalSamples',
  );
  @override
  late final GeneratedColumn<int> totalSamples = GeneratedColumn<int>(
    'total_samples',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalEventsMeta = const VerificationMeta(
    'totalEvents',
  );
  @override
  late final GeneratedColumn<int> totalEvents = GeneratedColumn<int>(
    'total_events',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageHeartRateMeta = const VerificationMeta(
    'averageHeartRate',
  );
  @override
  late final GeneratedColumn<double> averageHeartRate = GeneratedColumn<double>(
    'average_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageHrvMeta = const VerificationMeta(
    'averageHrv',
  );
  @override
  late final GeneratedColumn<double> averageHrv = GeneratedColumn<double>(
    'average_hrv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _maxHeartRateMeta = const VerificationMeta(
    'maxHeartRate',
  );
  @override
  late final GeneratedColumn<double> maxHeartRate = GeneratedColumn<double>(
    'max_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minHrvMeta = const VerificationMeta('minHrv');
  @override
  late final GeneratedColumn<double> minHrv = GeneratedColumn<double>(
    'min_hrv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    totalSamples,
    totalEvents,
    averageHeartRate,
    averageHrv,
    maxHeartRate,
    minHrv,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_timeline_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionTimelineTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('total_samples')) {
      context.handle(
        _totalSamplesMeta,
        totalSamples.isAcceptableOrUnknown(
          data['total_samples']!,
          _totalSamplesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalSamplesMeta);
    }
    if (data.containsKey('total_events')) {
      context.handle(
        _totalEventsMeta,
        totalEvents.isAcceptableOrUnknown(
          data['total_events']!,
          _totalEventsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalEventsMeta);
    }
    if (data.containsKey('average_heart_rate')) {
      context.handle(
        _averageHeartRateMeta,
        averageHeartRate.isAcceptableOrUnknown(
          data['average_heart_rate']!,
          _averageHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('average_hrv')) {
      context.handle(
        _averageHrvMeta,
        averageHrv.isAcceptableOrUnknown(data['average_hrv']!, _averageHrvMeta),
      );
    }
    if (data.containsKey('max_heart_rate')) {
      context.handle(
        _maxHeartRateMeta,
        maxHeartRate.isAcceptableOrUnknown(
          data['max_heart_rate']!,
          _maxHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('min_hrv')) {
      context.handle(
        _minHrvMeta,
        minHrv.isAcceptableOrUnknown(data['min_hrv']!, _minHrvMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionTimelineTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionTimelineTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      totalSamples: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_samples'],
      )!,
      totalEvents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_events'],
      )!,
      averageHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_heart_rate'],
      ),
      averageHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_hrv'],
      ),
      maxHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_heart_rate'],
      ),
      minHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_hrv'],
      ),
    );
  }

  @override
  $SessionTimelineTableTable createAlias(String alias) {
    return $SessionTimelineTableTable(attachedDatabase, alias);
  }
}

class SessionTimelineTableData extends DataClass
    implements Insertable<SessionTimelineTableData> {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int totalSamples;
  final int totalEvents;
  final double? averageHeartRate;
  final double? averageHrv;
  final double? maxHeartRate;
  final double? minHrv;
  const SessionTimelineTableData({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.totalSamples,
    required this.totalEvents,
    this.averageHeartRate,
    this.averageHrv,
    this.maxHeartRate,
    this.minHrv,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['total_samples'] = Variable<int>(totalSamples);
    map['total_events'] = Variable<int>(totalEvents);
    if (!nullToAbsent || averageHeartRate != null) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate);
    }
    if (!nullToAbsent || averageHrv != null) {
      map['average_hrv'] = Variable<double>(averageHrv);
    }
    if (!nullToAbsent || maxHeartRate != null) {
      map['max_heart_rate'] = Variable<double>(maxHeartRate);
    }
    if (!nullToAbsent || minHrv != null) {
      map['min_hrv'] = Variable<double>(minHrv);
    }
    return map;
  }

  SessionTimelineTableCompanion toCompanion(bool nullToAbsent) {
    return SessionTimelineTableCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      totalSamples: Value(totalSamples),
      totalEvents: Value(totalEvents),
      averageHeartRate: averageHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHeartRate),
      averageHrv: averageHrv == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHrv),
      maxHeartRate: maxHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(maxHeartRate),
      minHrv: minHrv == null && nullToAbsent
          ? const Value.absent()
          : Value(minHrv),
    );
  }

  factory SessionTimelineTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionTimelineTableData(
      id: serializer.fromJson<String>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      totalSamples: serializer.fromJson<int>(json['totalSamples']),
      totalEvents: serializer.fromJson<int>(json['totalEvents']),
      averageHeartRate: serializer.fromJson<double?>(json['averageHeartRate']),
      averageHrv: serializer.fromJson<double?>(json['averageHrv']),
      maxHeartRate: serializer.fromJson<double?>(json['maxHeartRate']),
      minHrv: serializer.fromJson<double?>(json['minHrv']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'totalSamples': serializer.toJson<int>(totalSamples),
      'totalEvents': serializer.toJson<int>(totalEvents),
      'averageHeartRate': serializer.toJson<double?>(averageHeartRate),
      'averageHrv': serializer.toJson<double?>(averageHrv),
      'maxHeartRate': serializer.toJson<double?>(maxHeartRate),
      'minHrv': serializer.toJson<double?>(minHrv),
    };
  }

  SessionTimelineTableData copyWith({
    String? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? totalSamples,
    int? totalEvents,
    Value<double?> averageHeartRate = const Value.absent(),
    Value<double?> averageHrv = const Value.absent(),
    Value<double?> maxHeartRate = const Value.absent(),
    Value<double?> minHrv = const Value.absent(),
  }) => SessionTimelineTableData(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    totalSamples: totalSamples ?? this.totalSamples,
    totalEvents: totalEvents ?? this.totalEvents,
    averageHeartRate: averageHeartRate.present
        ? averageHeartRate.value
        : this.averageHeartRate,
    averageHrv: averageHrv.present ? averageHrv.value : this.averageHrv,
    maxHeartRate: maxHeartRate.present ? maxHeartRate.value : this.maxHeartRate,
    minHrv: minHrv.present ? minHrv.value : this.minHrv,
  );
  SessionTimelineTableData copyWithCompanion(
    SessionTimelineTableCompanion data,
  ) {
    return SessionTimelineTableData(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      totalSamples: data.totalSamples.present
          ? data.totalSamples.value
          : this.totalSamples,
      totalEvents: data.totalEvents.present
          ? data.totalEvents.value
          : this.totalEvents,
      averageHeartRate: data.averageHeartRate.present
          ? data.averageHeartRate.value
          : this.averageHeartRate,
      averageHrv: data.averageHrv.present
          ? data.averageHrv.value
          : this.averageHrv,
      maxHeartRate: data.maxHeartRate.present
          ? data.maxHeartRate.value
          : this.maxHeartRate,
      minHrv: data.minHrv.present ? data.minHrv.value : this.minHrv,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimelineTableData(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('totalEvents: $totalEvents, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('minHrv: $minHrv')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    totalSamples,
    totalEvents,
    averageHeartRate,
    averageHrv,
    maxHeartRate,
    minHrv,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionTimelineTableData &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.totalSamples == this.totalSamples &&
          other.totalEvents == this.totalEvents &&
          other.averageHeartRate == this.averageHeartRate &&
          other.averageHrv == this.averageHrv &&
          other.maxHeartRate == this.maxHeartRate &&
          other.minHrv == this.minHrv);
}

class SessionTimelineTableCompanion
    extends UpdateCompanion<SessionTimelineTableData> {
  final Value<String> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> totalSamples;
  final Value<int> totalEvents;
  final Value<double?> averageHeartRate;
  final Value<double?> averageHrv;
  final Value<double?> maxHeartRate;
  final Value<double?> minHrv;
  final Value<int> rowid;
  const SessionTimelineTableCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.totalSamples = const Value.absent(),
    this.totalEvents = const Value.absent(),
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.minHrv = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionTimelineTableCompanion.insert({
    required String id,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int totalSamples,
    required int totalEvents,
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    this.maxHeartRate = const Value.absent(),
    this.minHrv = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       startedAt = Value(startedAt),
       totalSamples = Value(totalSamples),
       totalEvents = Value(totalEvents);
  static Insertable<SessionTimelineTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? totalSamples,
    Expression<int>? totalEvents,
    Expression<double>? averageHeartRate,
    Expression<double>? averageHrv,
    Expression<double>? maxHeartRate,
    Expression<double>? minHrv,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (totalSamples != null) 'total_samples': totalSamples,
      if (totalEvents != null) 'total_events': totalEvents,
      if (averageHeartRate != null) 'average_heart_rate': averageHeartRate,
      if (averageHrv != null) 'average_hrv': averageHrv,
      if (maxHeartRate != null) 'max_heart_rate': maxHeartRate,
      if (minHrv != null) 'min_hrv': minHrv,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionTimelineTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? totalSamples,
    Value<int>? totalEvents,
    Value<double?>? averageHeartRate,
    Value<double?>? averageHrv,
    Value<double?>? maxHeartRate,
    Value<double?>? minHrv,
    Value<int>? rowid,
  }) {
    return SessionTimelineTableCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      totalSamples: totalSamples ?? this.totalSamples,
      totalEvents: totalEvents ?? this.totalEvents,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageHrv: averageHrv ?? this.averageHrv,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      minHrv: minHrv ?? this.minHrv,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (totalSamples.present) {
      map['total_samples'] = Variable<int>(totalSamples.value);
    }
    if (totalEvents.present) {
      map['total_events'] = Variable<int>(totalEvents.value);
    }
    if (averageHeartRate.present) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate.value);
    }
    if (averageHrv.present) {
      map['average_hrv'] = Variable<double>(averageHrv.value);
    }
    if (maxHeartRate.present) {
      map['max_heart_rate'] = Variable<double>(maxHeartRate.value);
    }
    if (minHrv.present) {
      map['min_hrv'] = Variable<double>(minHrv.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionTimelineTableCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('totalSamples: $totalSamples, ')
          ..write('totalEvents: $totalEvents, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('maxHeartRate: $maxHeartRate, ')
          ..write('minHrv: $minHrv, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysiologicalEventMarkersTableTable
    extends PhysiologicalEventMarkersTable
    with
        TableInfo<
          $PhysiologicalEventMarkersTableTable,
          PhysiologicalEventMarkersTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysiologicalEventMarkersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timelineIdMeta = const VerificationMeta(
    'timelineId',
  );
  @override
  late final GeneratedColumn<String> timelineId = GeneratedColumn<String>(
    'timeline_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
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
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<String> severity = GeneratedColumn<String>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timelineId,
    timestamp,
    type,
    title,
    description,
    severity,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physiological_event_markers_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysiologicalEventMarkersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timeline_id')) {
      context.handle(
        _timelineIdMeta,
        timelineId.isAcceptableOrUnknown(data['timeline_id']!, _timelineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_timelineIdMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysiologicalEventMarkersTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysiologicalEventMarkersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timelineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeline_id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}severity'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $PhysiologicalEventMarkersTableTable createAlias(String alias) {
    return $PhysiologicalEventMarkersTableTable(attachedDatabase, alias);
  }
}

class PhysiologicalEventMarkersTableData extends DataClass
    implements Insertable<PhysiologicalEventMarkersTableData> {
  final String id;
  final String timelineId;
  final DateTime timestamp;
  final String type;
  final String title;
  final String description;
  final String severity;
  final String source;
  const PhysiologicalEventMarkersTableData({
    required this.id,
    required this.timelineId,
    required this.timestamp,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timeline_id'] = Variable<String>(timelineId);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['severity'] = Variable<String>(severity);
    map['source'] = Variable<String>(source);
    return map;
  }

  PhysiologicalEventMarkersTableCompanion toCompanion(bool nullToAbsent) {
    return PhysiologicalEventMarkersTableCompanion(
      id: Value(id),
      timelineId: Value(timelineId),
      timestamp: Value(timestamp),
      type: Value(type),
      title: Value(title),
      description: Value(description),
      severity: Value(severity),
      source: Value(source),
    );
  }

  factory PhysiologicalEventMarkersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysiologicalEventMarkersTableData(
      id: serializer.fromJson<String>(json['id']),
      timelineId: serializer.fromJson<String>(json['timelineId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      severity: serializer.fromJson<String>(json['severity']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timelineId': serializer.toJson<String>(timelineId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'severity': serializer.toJson<String>(severity),
      'source': serializer.toJson<String>(source),
    };
  }

  PhysiologicalEventMarkersTableData copyWith({
    String? id,
    String? timelineId,
    DateTime? timestamp,
    String? type,
    String? title,
    String? description,
    String? severity,
    String? source,
  }) => PhysiologicalEventMarkersTableData(
    id: id ?? this.id,
    timelineId: timelineId ?? this.timelineId,
    timestamp: timestamp ?? this.timestamp,
    type: type ?? this.type,
    title: title ?? this.title,
    description: description ?? this.description,
    severity: severity ?? this.severity,
    source: source ?? this.source,
  );
  PhysiologicalEventMarkersTableData copyWithCompanion(
    PhysiologicalEventMarkersTableCompanion data,
  ) {
    return PhysiologicalEventMarkersTableData(
      id: data.id.present ? data.id.value : this.id,
      timelineId: data.timelineId.present
          ? data.timelineId.value
          : this.timelineId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      severity: data.severity.present ? data.severity.value : this.severity,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalEventMarkersTableData(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timelineId,
    timestamp,
    type,
    title,
    description,
    severity,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysiologicalEventMarkersTableData &&
          other.id == this.id &&
          other.timelineId == this.timelineId &&
          other.timestamp == this.timestamp &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.severity == this.severity &&
          other.source == this.source);
}

class PhysiologicalEventMarkersTableCompanion
    extends UpdateCompanion<PhysiologicalEventMarkersTableData> {
  final Value<String> id;
  final Value<String> timelineId;
  final Value<DateTime> timestamp;
  final Value<String> type;
  final Value<String> title;
  final Value<String> description;
  final Value<String> severity;
  final Value<String> source;
  final Value<int> rowid;
  const PhysiologicalEventMarkersTableCompanion({
    this.id = const Value.absent(),
    this.timelineId = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.severity = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysiologicalEventMarkersTableCompanion.insert({
    required String id,
    required String timelineId,
    required DateTime timestamp,
    required String type,
    required String title,
    required String description,
    required String severity,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timelineId = Value(timelineId),
       timestamp = Value(timestamp),
       type = Value(type),
       title = Value(title),
       description = Value(description),
       severity = Value(severity),
       source = Value(source);
  static Insertable<PhysiologicalEventMarkersTableData> custom({
    Expression<String>? id,
    Expression<String>? timelineId,
    Expression<DateTime>? timestamp,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? severity,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timelineId != null) 'timeline_id': timelineId,
      if (timestamp != null) 'timestamp': timestamp,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (severity != null) 'severity': severity,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysiologicalEventMarkersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? timelineId,
    Value<DateTime>? timestamp,
    Value<String>? type,
    Value<String>? title,
    Value<String>? description,
    Value<String>? severity,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return PhysiologicalEventMarkersTableCompanion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timelineId.present) {
      map['timeline_id'] = Variable<String>(timelineId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (severity.present) {
      map['severity'] = Variable<String>(severity.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalEventMarkersTableCompanion(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('timestamp: $timestamp, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('severity: $severity, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysiologicalTrendsTableTable extends PhysiologicalTrendsTable
    with
        TableInfo<
          $PhysiologicalTrendsTableTable,
          PhysiologicalTrendsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysiologicalTrendsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timelineIdMeta = const VerificationMeta(
    'timelineId',
  );
  @override
  late final GeneratedColumn<String> timelineId = GeneratedColumn<String>(
    'timeline_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedAtMeta = const VerificationMeta(
    'generatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
    'generated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowLabelMeta = const VerificationMeta(
    'windowLabel',
  );
  @override
  late final GeneratedColumn<String> windowLabel = GeneratedColumn<String>(
    'window_label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _windowSecondsMeta = const VerificationMeta(
    'windowSeconds',
  );
  @override
  late final GeneratedColumn<int> windowSeconds = GeneratedColumn<int>(
    'window_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageHeartRateMeta = const VerificationMeta(
    'averageHeartRate',
  );
  @override
  late final GeneratedColumn<double> averageHeartRate = GeneratedColumn<double>(
    'average_heart_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _averageHrvMeta = const VerificationMeta(
    'averageHrv',
  );
  @override
  late final GeneratedColumn<double> averageHrv = GeneratedColumn<double>(
    'average_hrv',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hrvSlopeMeta = const VerificationMeta(
    'hrvSlope',
  );
  @override
  late final GeneratedColumn<double> hrvSlope = GeneratedColumn<double>(
    'hrv_slope',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateSlopeMeta = const VerificationMeta(
    'heartRateSlope',
  );
  @override
  late final GeneratedColumn<double> heartRateSlope = GeneratedColumn<double>(
    'heart_rate_slope',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activationDensityMeta = const VerificationMeta(
    'activationDensity',
  );
  @override
  late final GeneratedColumn<double> activationDensity =
      GeneratedColumn<double>(
        'activation_density',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _escalationScoreMeta = const VerificationMeta(
    'escalationScore',
  );
  @override
  late final GeneratedColumn<int> escalationScore = GeneratedColumn<int>(
    'escalation_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timelineId,
    generatedAt,
    windowLabel,
    windowSeconds,
    averageHeartRate,
    averageHrv,
    hrvSlope,
    heartRateSlope,
    activationDensity,
    escalationScore,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physiological_trends_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysiologicalTrendsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timeline_id')) {
      context.handle(
        _timelineIdMeta,
        timelineId.isAcceptableOrUnknown(data['timeline_id']!, _timelineIdMeta),
      );
    } else if (isInserting) {
      context.missing(_timelineIdMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
        _generatedAtMeta,
        generatedAt.isAcceptableOrUnknown(
          data['generated_at']!,
          _generatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('window_label')) {
      context.handle(
        _windowLabelMeta,
        windowLabel.isAcceptableOrUnknown(
          data['window_label']!,
          _windowLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_windowLabelMeta);
    }
    if (data.containsKey('window_seconds')) {
      context.handle(
        _windowSecondsMeta,
        windowSeconds.isAcceptableOrUnknown(
          data['window_seconds']!,
          _windowSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_windowSecondsMeta);
    }
    if (data.containsKey('average_heart_rate')) {
      context.handle(
        _averageHeartRateMeta,
        averageHeartRate.isAcceptableOrUnknown(
          data['average_heart_rate']!,
          _averageHeartRateMeta,
        ),
      );
    }
    if (data.containsKey('average_hrv')) {
      context.handle(
        _averageHrvMeta,
        averageHrv.isAcceptableOrUnknown(data['average_hrv']!, _averageHrvMeta),
      );
    }
    if (data.containsKey('hrv_slope')) {
      context.handle(
        _hrvSlopeMeta,
        hrvSlope.isAcceptableOrUnknown(data['hrv_slope']!, _hrvSlopeMeta),
      );
    } else if (isInserting) {
      context.missing(_hrvSlopeMeta);
    }
    if (data.containsKey('heart_rate_slope')) {
      context.handle(
        _heartRateSlopeMeta,
        heartRateSlope.isAcceptableOrUnknown(
          data['heart_rate_slope']!,
          _heartRateSlopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heartRateSlopeMeta);
    }
    if (data.containsKey('activation_density')) {
      context.handle(
        _activationDensityMeta,
        activationDensity.isAcceptableOrUnknown(
          data['activation_density']!,
          _activationDensityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activationDensityMeta);
    }
    if (data.containsKey('escalation_score')) {
      context.handle(
        _escalationScoreMeta,
        escalationScore.isAcceptableOrUnknown(
          data['escalation_score']!,
          _escalationScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysiologicalTrendsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysiologicalTrendsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timelineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timeline_id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      windowLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}window_label'],
      )!,
      windowSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}window_seconds'],
      )!,
      averageHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_heart_rate'],
      ),
      averageHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_hrv'],
      ),
      hrvSlope: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_slope'],
      )!,
      heartRateSlope: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heart_rate_slope'],
      )!,
      activationDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}activation_density'],
      )!,
      escalationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}escalation_score'],
      )!,
    );
  }

  @override
  $PhysiologicalTrendsTableTable createAlias(String alias) {
    return $PhysiologicalTrendsTableTable(attachedDatabase, alias);
  }
}

class PhysiologicalTrendsTableData extends DataClass
    implements Insertable<PhysiologicalTrendsTableData> {
  final String id;
  final String timelineId;
  final DateTime generatedAt;
  final String windowLabel;
  final int windowSeconds;
  final double? averageHeartRate;
  final double? averageHrv;
  final double hrvSlope;
  final double heartRateSlope;
  final double activationDensity;
  final int escalationScore;
  const PhysiologicalTrendsTableData({
    required this.id,
    required this.timelineId,
    required this.generatedAt,
    required this.windowLabel,
    required this.windowSeconds,
    this.averageHeartRate,
    this.averageHrv,
    required this.hrvSlope,
    required this.heartRateSlope,
    required this.activationDensity,
    required this.escalationScore,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timeline_id'] = Variable<String>(timelineId);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['window_label'] = Variable<String>(windowLabel);
    map['window_seconds'] = Variable<int>(windowSeconds);
    if (!nullToAbsent || averageHeartRate != null) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate);
    }
    if (!nullToAbsent || averageHrv != null) {
      map['average_hrv'] = Variable<double>(averageHrv);
    }
    map['hrv_slope'] = Variable<double>(hrvSlope);
    map['heart_rate_slope'] = Variable<double>(heartRateSlope);
    map['activation_density'] = Variable<double>(activationDensity);
    map['escalation_score'] = Variable<int>(escalationScore);
    return map;
  }

  PhysiologicalTrendsTableCompanion toCompanion(bool nullToAbsent) {
    return PhysiologicalTrendsTableCompanion(
      id: Value(id),
      timelineId: Value(timelineId),
      generatedAt: Value(generatedAt),
      windowLabel: Value(windowLabel),
      windowSeconds: Value(windowSeconds),
      averageHeartRate: averageHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHeartRate),
      averageHrv: averageHrv == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHrv),
      hrvSlope: Value(hrvSlope),
      heartRateSlope: Value(heartRateSlope),
      activationDensity: Value(activationDensity),
      escalationScore: Value(escalationScore),
    );
  }

  factory PhysiologicalTrendsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysiologicalTrendsTableData(
      id: serializer.fromJson<String>(json['id']),
      timelineId: serializer.fromJson<String>(json['timelineId']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      windowLabel: serializer.fromJson<String>(json['windowLabel']),
      windowSeconds: serializer.fromJson<int>(json['windowSeconds']),
      averageHeartRate: serializer.fromJson<double?>(json['averageHeartRate']),
      averageHrv: serializer.fromJson<double?>(json['averageHrv']),
      hrvSlope: serializer.fromJson<double>(json['hrvSlope']),
      heartRateSlope: serializer.fromJson<double>(json['heartRateSlope']),
      activationDensity: serializer.fromJson<double>(json['activationDensity']),
      escalationScore: serializer.fromJson<int>(json['escalationScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timelineId': serializer.toJson<String>(timelineId),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'windowLabel': serializer.toJson<String>(windowLabel),
      'windowSeconds': serializer.toJson<int>(windowSeconds),
      'averageHeartRate': serializer.toJson<double?>(averageHeartRate),
      'averageHrv': serializer.toJson<double?>(averageHrv),
      'hrvSlope': serializer.toJson<double>(hrvSlope),
      'heartRateSlope': serializer.toJson<double>(heartRateSlope),
      'activationDensity': serializer.toJson<double>(activationDensity),
      'escalationScore': serializer.toJson<int>(escalationScore),
    };
  }

  PhysiologicalTrendsTableData copyWith({
    String? id,
    String? timelineId,
    DateTime? generatedAt,
    String? windowLabel,
    int? windowSeconds,
    Value<double?> averageHeartRate = const Value.absent(),
    Value<double?> averageHrv = const Value.absent(),
    double? hrvSlope,
    double? heartRateSlope,
    double? activationDensity,
    int? escalationScore,
  }) => PhysiologicalTrendsTableData(
    id: id ?? this.id,
    timelineId: timelineId ?? this.timelineId,
    generatedAt: generatedAt ?? this.generatedAt,
    windowLabel: windowLabel ?? this.windowLabel,
    windowSeconds: windowSeconds ?? this.windowSeconds,
    averageHeartRate: averageHeartRate.present
        ? averageHeartRate.value
        : this.averageHeartRate,
    averageHrv: averageHrv.present ? averageHrv.value : this.averageHrv,
    hrvSlope: hrvSlope ?? this.hrvSlope,
    heartRateSlope: heartRateSlope ?? this.heartRateSlope,
    activationDensity: activationDensity ?? this.activationDensity,
    escalationScore: escalationScore ?? this.escalationScore,
  );
  PhysiologicalTrendsTableData copyWithCompanion(
    PhysiologicalTrendsTableCompanion data,
  ) {
    return PhysiologicalTrendsTableData(
      id: data.id.present ? data.id.value : this.id,
      timelineId: data.timelineId.present
          ? data.timelineId.value
          : this.timelineId,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      windowLabel: data.windowLabel.present
          ? data.windowLabel.value
          : this.windowLabel,
      windowSeconds: data.windowSeconds.present
          ? data.windowSeconds.value
          : this.windowSeconds,
      averageHeartRate: data.averageHeartRate.present
          ? data.averageHeartRate.value
          : this.averageHeartRate,
      averageHrv: data.averageHrv.present
          ? data.averageHrv.value
          : this.averageHrv,
      hrvSlope: data.hrvSlope.present ? data.hrvSlope.value : this.hrvSlope,
      heartRateSlope: data.heartRateSlope.present
          ? data.heartRateSlope.value
          : this.heartRateSlope,
      activationDensity: data.activationDensity.present
          ? data.activationDensity.value
          : this.activationDensity,
      escalationScore: data.escalationScore.present
          ? data.escalationScore.value
          : this.escalationScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalTrendsTableData(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('windowSeconds: $windowSeconds, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('hrvSlope: $hrvSlope, ')
          ..write('heartRateSlope: $heartRateSlope, ')
          ..write('activationDensity: $activationDensity, ')
          ..write('escalationScore: $escalationScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timelineId,
    generatedAt,
    windowLabel,
    windowSeconds,
    averageHeartRate,
    averageHrv,
    hrvSlope,
    heartRateSlope,
    activationDensity,
    escalationScore,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysiologicalTrendsTableData &&
          other.id == this.id &&
          other.timelineId == this.timelineId &&
          other.generatedAt == this.generatedAt &&
          other.windowLabel == this.windowLabel &&
          other.windowSeconds == this.windowSeconds &&
          other.averageHeartRate == this.averageHeartRate &&
          other.averageHrv == this.averageHrv &&
          other.hrvSlope == this.hrvSlope &&
          other.heartRateSlope == this.heartRateSlope &&
          other.activationDensity == this.activationDensity &&
          other.escalationScore == this.escalationScore);
}

class PhysiologicalTrendsTableCompanion
    extends UpdateCompanion<PhysiologicalTrendsTableData> {
  final Value<String> id;
  final Value<String> timelineId;
  final Value<DateTime> generatedAt;
  final Value<String> windowLabel;
  final Value<int> windowSeconds;
  final Value<double?> averageHeartRate;
  final Value<double?> averageHrv;
  final Value<double> hrvSlope;
  final Value<double> heartRateSlope;
  final Value<double> activationDensity;
  final Value<int> escalationScore;
  final Value<int> rowid;
  const PhysiologicalTrendsTableCompanion({
    this.id = const Value.absent(),
    this.timelineId = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.windowLabel = const Value.absent(),
    this.windowSeconds = const Value.absent(),
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    this.hrvSlope = const Value.absent(),
    this.heartRateSlope = const Value.absent(),
    this.activationDensity = const Value.absent(),
    this.escalationScore = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysiologicalTrendsTableCompanion.insert({
    required String id,
    required String timelineId,
    required DateTime generatedAt,
    required String windowLabel,
    required int windowSeconds,
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    required double hrvSlope,
    required double heartRateSlope,
    required double activationDensity,
    required int escalationScore,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timelineId = Value(timelineId),
       generatedAt = Value(generatedAt),
       windowLabel = Value(windowLabel),
       windowSeconds = Value(windowSeconds),
       hrvSlope = Value(hrvSlope),
       heartRateSlope = Value(heartRateSlope),
       activationDensity = Value(activationDensity),
       escalationScore = Value(escalationScore);
  static Insertable<PhysiologicalTrendsTableData> custom({
    Expression<String>? id,
    Expression<String>? timelineId,
    Expression<DateTime>? generatedAt,
    Expression<String>? windowLabel,
    Expression<int>? windowSeconds,
    Expression<double>? averageHeartRate,
    Expression<double>? averageHrv,
    Expression<double>? hrvSlope,
    Expression<double>? heartRateSlope,
    Expression<double>? activationDensity,
    Expression<int>? escalationScore,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timelineId != null) 'timeline_id': timelineId,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (windowLabel != null) 'window_label': windowLabel,
      if (windowSeconds != null) 'window_seconds': windowSeconds,
      if (averageHeartRate != null) 'average_heart_rate': averageHeartRate,
      if (averageHrv != null) 'average_hrv': averageHrv,
      if (hrvSlope != null) 'hrv_slope': hrvSlope,
      if (heartRateSlope != null) 'heart_rate_slope': heartRateSlope,
      if (activationDensity != null) 'activation_density': activationDensity,
      if (escalationScore != null) 'escalation_score': escalationScore,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysiologicalTrendsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? timelineId,
    Value<DateTime>? generatedAt,
    Value<String>? windowLabel,
    Value<int>? windowSeconds,
    Value<double?>? averageHeartRate,
    Value<double?>? averageHrv,
    Value<double>? hrvSlope,
    Value<double>? heartRateSlope,
    Value<double>? activationDensity,
    Value<int>? escalationScore,
    Value<int>? rowid,
  }) {
    return PhysiologicalTrendsTableCompanion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      generatedAt: generatedAt ?? this.generatedAt,
      windowLabel: windowLabel ?? this.windowLabel,
      windowSeconds: windowSeconds ?? this.windowSeconds,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageHrv: averageHrv ?? this.averageHrv,
      hrvSlope: hrvSlope ?? this.hrvSlope,
      heartRateSlope: heartRateSlope ?? this.heartRateSlope,
      activationDensity: activationDensity ?? this.activationDensity,
      escalationScore: escalationScore ?? this.escalationScore,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timelineId.present) {
      map['timeline_id'] = Variable<String>(timelineId.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (windowLabel.present) {
      map['window_label'] = Variable<String>(windowLabel.value);
    }
    if (windowSeconds.present) {
      map['window_seconds'] = Variable<int>(windowSeconds.value);
    }
    if (averageHeartRate.present) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate.value);
    }
    if (averageHrv.present) {
      map['average_hrv'] = Variable<double>(averageHrv.value);
    }
    if (hrvSlope.present) {
      map['hrv_slope'] = Variable<double>(hrvSlope.value);
    }
    if (heartRateSlope.present) {
      map['heart_rate_slope'] = Variable<double>(heartRateSlope.value);
    }
    if (activationDensity.present) {
      map['activation_density'] = Variable<double>(activationDensity.value);
    }
    if (escalationScore.present) {
      map['escalation_score'] = Variable<int>(escalationScore.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalTrendsTableCompanion(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('windowSeconds: $windowSeconds, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('hrvSlope: $hrvSlope, ')
          ..write('heartRateSlope: $heartRateSlope, ')
          ..write('activationDensity: $activationDensity, ')
          ..write('escalationScore: $escalationScore, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SignalFlowDatabase extends GeneratedDatabase {
  _$SignalFlowDatabase(QueryExecutor e) : super(e);
  $SignalFlowDatabaseManager get managers => $SignalFlowDatabaseManager(this);
  late final $BaselineProfilesTableTable baselineProfilesTable =
      $BaselineProfilesTableTable(this);
  late final $CrisisRiskEventsTableTable crisisRiskEventsTable =
      $CrisisRiskEventsTableTable(this);
  late final $InterventionHistoryTableTable interventionHistoryTable =
      $InterventionHistoryTableTable(this);
  late final $ResearchConsentTableTable researchConsentTable =
      $ResearchConsentTableTable(this);
  late final $AdaptiveBaselineStateTableTable adaptiveBaselineStateTable =
      $AdaptiveBaselineStateTableTable(this);
  late final $CircadianProfilesTableTable circadianProfilesTable =
      $CircadianProfilesTableTable(this);
  late final $SessionTimelineTableTable sessionTimelineTable =
      $SessionTimelineTableTable(this);
  late final $PhysiologicalEventMarkersTableTable
  physiologicalEventMarkersTable = $PhysiologicalEventMarkersTableTable(this);
  late final $PhysiologicalTrendsTableTable physiologicalTrendsTable =
      $PhysiologicalTrendsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    baselineProfilesTable,
    crisisRiskEventsTable,
    interventionHistoryTable,
    researchConsentTable,
    adaptiveBaselineStateTable,
    circadianProfilesTable,
    sessionTimelineTable,
    physiologicalEventMarkersTable,
    physiologicalTrendsTable,
  ];
}

typedef $$BaselineProfilesTableTableCreateCompanionBuilder =
    BaselineProfilesTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required double restingHeartRate,
      required double hrvRmssd,
      required double respiratoryRate,
      required double movementIntensity,
      Value<int> rowid,
    });
typedef $$BaselineProfilesTableTableUpdateCompanionBuilder =
    BaselineProfilesTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<double> restingHeartRate,
      Value<double> hrvRmssd,
      Value<double> respiratoryRate,
      Value<double> movementIntensity,
      Value<int> rowid,
    });

class $$BaselineProfilesTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $BaselineProfilesTableTable> {
  $$BaselineProfilesTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BaselineProfilesTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $BaselineProfilesTableTable> {
  $$BaselineProfilesTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BaselineProfilesTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $BaselineProfilesTableTable> {
  $$BaselineProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvRmssd =>
      $composableBuilder(column: $table.hrvRmssd, builder: (column) => column);

  GeneratedColumn<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => column,
  );
}

class $$BaselineProfilesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $BaselineProfilesTableTable,
          BaselineProfilesTableData,
          $$BaselineProfilesTableTableFilterComposer,
          $$BaselineProfilesTableTableOrderingComposer,
          $$BaselineProfilesTableTableAnnotationComposer,
          $$BaselineProfilesTableTableCreateCompanionBuilder,
          $$BaselineProfilesTableTableUpdateCompanionBuilder,
          (
            BaselineProfilesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $BaselineProfilesTableTable,
              BaselineProfilesTableData
            >,
          ),
          BaselineProfilesTableData,
          PrefetchHooks Function()
        > {
  $$BaselineProfilesTableTableTableManager(
    _$SignalFlowDatabase db,
    $BaselineProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BaselineProfilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BaselineProfilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BaselineProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<double> restingHeartRate = const Value.absent(),
                Value<double> hrvRmssd = const Value.absent(),
                Value<double> respiratoryRate = const Value.absent(),
                Value<double> movementIntensity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BaselineProfilesTableCompanion(
                id: id,
                createdAt: createdAt,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                respiratoryRate: respiratoryRate,
                movementIntensity: movementIntensity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required double restingHeartRate,
                required double hrvRmssd,
                required double respiratoryRate,
                required double movementIntensity,
                Value<int> rowid = const Value.absent(),
              }) => BaselineProfilesTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                respiratoryRate: respiratoryRate,
                movementIntensity: movementIntensity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BaselineProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $BaselineProfilesTableTable,
      BaselineProfilesTableData,
      $$BaselineProfilesTableTableFilterComposer,
      $$BaselineProfilesTableTableOrderingComposer,
      $$BaselineProfilesTableTableAnnotationComposer,
      $$BaselineProfilesTableTableCreateCompanionBuilder,
      $$BaselineProfilesTableTableUpdateCompanionBuilder,
      (
        BaselineProfilesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $BaselineProfilesTableTable,
          BaselineProfilesTableData
        >,
      ),
      BaselineProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$CrisisRiskEventsTableTableCreateCompanionBuilder =
    CrisisRiskEventsTableCompanion Function({
      required String id,
      required DateTime timestamp,
      required int score,
      required String level,
      required String reasonCodesJson,
      required String recommendedAction,
      required String cognitiveResponse,
      required String source,
      Value<int> rowid,
    });
typedef $$CrisisRiskEventsTableTableUpdateCompanionBuilder =
    CrisisRiskEventsTableCompanion Function({
      Value<String> id,
      Value<DateTime> timestamp,
      Value<int> score,
      Value<String> level,
      Value<String> reasonCodesJson,
      Value<String> recommendedAction,
      Value<String> cognitiveResponse,
      Value<String> source,
      Value<int> rowid,
    });

class $$CrisisRiskEventsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $CrisisRiskEventsTableTable> {
  $$CrisisRiskEventsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonCodesJson => $composableBuilder(
    column: $table.reasonCodesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendedAction => $composableBuilder(
    column: $table.recommendedAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cognitiveResponse => $composableBuilder(
    column: $table.cognitiveResponse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CrisisRiskEventsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $CrisisRiskEventsTableTable> {
  $$CrisisRiskEventsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonCodesJson => $composableBuilder(
    column: $table.reasonCodesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendedAction => $composableBuilder(
    column: $table.recommendedAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cognitiveResponse => $composableBuilder(
    column: $table.cognitiveResponse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CrisisRiskEventsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $CrisisRiskEventsTableTable> {
  $$CrisisRiskEventsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get reasonCodesJson => $composableBuilder(
    column: $table.reasonCodesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recommendedAction => $composableBuilder(
    column: $table.recommendedAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cognitiveResponse => $composableBuilder(
    column: $table.cognitiveResponse,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$CrisisRiskEventsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $CrisisRiskEventsTableTable,
          CrisisRiskEventsTableData,
          $$CrisisRiskEventsTableTableFilterComposer,
          $$CrisisRiskEventsTableTableOrderingComposer,
          $$CrisisRiskEventsTableTableAnnotationComposer,
          $$CrisisRiskEventsTableTableCreateCompanionBuilder,
          $$CrisisRiskEventsTableTableUpdateCompanionBuilder,
          (
            CrisisRiskEventsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $CrisisRiskEventsTableTable,
              CrisisRiskEventsTableData
            >,
          ),
          CrisisRiskEventsTableData,
          PrefetchHooks Function()
        > {
  $$CrisisRiskEventsTableTableTableManager(
    _$SignalFlowDatabase db,
    $CrisisRiskEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CrisisRiskEventsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CrisisRiskEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CrisisRiskEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> reasonCodesJson = const Value.absent(),
                Value<String> recommendedAction = const Value.absent(),
                Value<String> cognitiveResponse = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CrisisRiskEventsTableCompanion(
                id: id,
                timestamp: timestamp,
                score: score,
                level: level,
                reasonCodesJson: reasonCodesJson,
                recommendedAction: recommendedAction,
                cognitiveResponse: cognitiveResponse,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime timestamp,
                required int score,
                required String level,
                required String reasonCodesJson,
                required String recommendedAction,
                required String cognitiveResponse,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => CrisisRiskEventsTableCompanion.insert(
                id: id,
                timestamp: timestamp,
                score: score,
                level: level,
                reasonCodesJson: reasonCodesJson,
                recommendedAction: recommendedAction,
                cognitiveResponse: cognitiveResponse,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CrisisRiskEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $CrisisRiskEventsTableTable,
      CrisisRiskEventsTableData,
      $$CrisisRiskEventsTableTableFilterComposer,
      $$CrisisRiskEventsTableTableOrderingComposer,
      $$CrisisRiskEventsTableTableAnnotationComposer,
      $$CrisisRiskEventsTableTableCreateCompanionBuilder,
      $$CrisisRiskEventsTableTableUpdateCompanionBuilder,
      (
        CrisisRiskEventsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $CrisisRiskEventsTableTable,
          CrisisRiskEventsTableData
        >,
      ),
      CrisisRiskEventsTableData,
      PrefetchHooks Function()
    >;
typedef $$InterventionHistoryTableTableCreateCompanionBuilder =
    InterventionHistoryTableCompanion Function({
      required String id,
      required String protocolId,
      required DateTime startedAt,
      required DateTime completedAt,
      required int durationSeconds,
      required bool completed,
      required bool userReportedImprovement,
      required String finalResponse,
      Value<int?> preScore,
      Value<int?> postScore,
      Value<int?> scoreDelta,
      Value<int> rowid,
    });
typedef $$InterventionHistoryTableTableUpdateCompanionBuilder =
    InterventionHistoryTableCompanion Function({
      Value<String> id,
      Value<String> protocolId,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<int> durationSeconds,
      Value<bool> completed,
      Value<bool> userReportedImprovement,
      Value<String> finalResponse,
      Value<int?> preScore,
      Value<int?> postScore,
      Value<int?> scoreDelta,
      Value<int> rowid,
    });

class $$InterventionHistoryTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $InterventionHistoryTableTable> {
  $$InterventionHistoryTableTableFilterComposer({
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

  ColumnFilters<String> get protocolId => $composableBuilder(
    column: $table.protocolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get userReportedImprovement => $composableBuilder(
    column: $table.userReportedImprovement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finalResponse => $composableBuilder(
    column: $table.finalResponse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get preScore => $composableBuilder(
    column: $table.preScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postScore => $composableBuilder(
    column: $table.postScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreDelta => $composableBuilder(
    column: $table.scoreDelta,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterventionHistoryTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $InterventionHistoryTableTable> {
  $$InterventionHistoryTableTableOrderingComposer({
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

  ColumnOrderings<String> get protocolId => $composableBuilder(
    column: $table.protocolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get userReportedImprovement => $composableBuilder(
    column: $table.userReportedImprovement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finalResponse => $composableBuilder(
    column: $table.finalResponse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get preScore => $composableBuilder(
    column: $table.preScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postScore => $composableBuilder(
    column: $table.postScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreDelta => $composableBuilder(
    column: $table.scoreDelta,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterventionHistoryTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $InterventionHistoryTableTable> {
  $$InterventionHistoryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get protocolId => $composableBuilder(
    column: $table.protocolId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get userReportedImprovement => $composableBuilder(
    column: $table.userReportedImprovement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finalResponse => $composableBuilder(
    column: $table.finalResponse,
    builder: (column) => column,
  );

  GeneratedColumn<int> get preScore =>
      $composableBuilder(column: $table.preScore, builder: (column) => column);

  GeneratedColumn<int> get postScore =>
      $composableBuilder(column: $table.postScore, builder: (column) => column);

  GeneratedColumn<int> get scoreDelta => $composableBuilder(
    column: $table.scoreDelta,
    builder: (column) => column,
  );
}

class $$InterventionHistoryTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $InterventionHistoryTableTable,
          InterventionHistoryTableData,
          $$InterventionHistoryTableTableFilterComposer,
          $$InterventionHistoryTableTableOrderingComposer,
          $$InterventionHistoryTableTableAnnotationComposer,
          $$InterventionHistoryTableTableCreateCompanionBuilder,
          $$InterventionHistoryTableTableUpdateCompanionBuilder,
          (
            InterventionHistoryTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $InterventionHistoryTableTable,
              InterventionHistoryTableData
            >,
          ),
          InterventionHistoryTableData,
          PrefetchHooks Function()
        > {
  $$InterventionHistoryTableTableTableManager(
    _$SignalFlowDatabase db,
    $InterventionHistoryTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterventionHistoryTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InterventionHistoryTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InterventionHistoryTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> protocolId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> userReportedImprovement = const Value.absent(),
                Value<String> finalResponse = const Value.absent(),
                Value<int?> preScore = const Value.absent(),
                Value<int?> postScore = const Value.absent(),
                Value<int?> scoreDelta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionHistoryTableCompanion(
                id: id,
                protocolId: protocolId,
                startedAt: startedAt,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                completed: completed,
                userReportedImprovement: userReportedImprovement,
                finalResponse: finalResponse,
                preScore: preScore,
                postScore: postScore,
                scoreDelta: scoreDelta,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String protocolId,
                required DateTime startedAt,
                required DateTime completedAt,
                required int durationSeconds,
                required bool completed,
                required bool userReportedImprovement,
                required String finalResponse,
                Value<int?> preScore = const Value.absent(),
                Value<int?> postScore = const Value.absent(),
                Value<int?> scoreDelta = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionHistoryTableCompanion.insert(
                id: id,
                protocolId: protocolId,
                startedAt: startedAt,
                completedAt: completedAt,
                durationSeconds: durationSeconds,
                completed: completed,
                userReportedImprovement: userReportedImprovement,
                finalResponse: finalResponse,
                preScore: preScore,
                postScore: postScore,
                scoreDelta: scoreDelta,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterventionHistoryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $InterventionHistoryTableTable,
      InterventionHistoryTableData,
      $$InterventionHistoryTableTableFilterComposer,
      $$InterventionHistoryTableTableOrderingComposer,
      $$InterventionHistoryTableTableAnnotationComposer,
      $$InterventionHistoryTableTableCreateCompanionBuilder,
      $$InterventionHistoryTableTableUpdateCompanionBuilder,
      (
        InterventionHistoryTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $InterventionHistoryTableTable,
          InterventionHistoryTableData
        >,
      ),
      InterventionHistoryTableData,
      PrefetchHooks Function()
    >;
typedef $$ResearchConsentTableTableCreateCompanionBuilder =
    ResearchConsentTableCompanion Function({
      required String id,
      required bool accepted,
      Value<DateTime?> acceptedAt,
      required String version,
      required bool allowsPhysiologicalCollection,
      required bool allowsResearchExport,
      required bool allowsReplayAnalysis,
      Value<int> rowid,
    });
typedef $$ResearchConsentTableTableUpdateCompanionBuilder =
    ResearchConsentTableCompanion Function({
      Value<String> id,
      Value<bool> accepted,
      Value<DateTime?> acceptedAt,
      Value<String> version,
      Value<bool> allowsPhysiologicalCollection,
      Value<bool> allowsResearchExport,
      Value<bool> allowsReplayAnalysis,
      Value<int> rowid,
    });

class $$ResearchConsentTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $ResearchConsentTableTable> {
  $$ResearchConsentTableTableFilterComposer({
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

  ColumnFilters<bool> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsPhysiologicalCollection => $composableBuilder(
    column: $table.allowsPhysiologicalCollection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsResearchExport => $composableBuilder(
    column: $table.allowsResearchExport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get allowsReplayAnalysis => $composableBuilder(
    column: $table.allowsReplayAnalysis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchConsentTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $ResearchConsentTableTable> {
  $$ResearchConsentTableTableOrderingComposer({
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

  ColumnOrderings<bool> get accepted => $composableBuilder(
    column: $table.accepted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsPhysiologicalCollection => $composableBuilder(
    column: $table.allowsPhysiologicalCollection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsResearchExport => $composableBuilder(
    column: $table.allowsResearchExport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get allowsReplayAnalysis => $composableBuilder(
    column: $table.allowsReplayAnalysis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchConsentTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $ResearchConsentTableTable> {
  $$ResearchConsentTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get accepted =>
      $composableBuilder(column: $table.accepted, builder: (column) => column);

  GeneratedColumn<DateTime> get acceptedAt => $composableBuilder(
    column: $table.acceptedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<bool> get allowsPhysiologicalCollection => $composableBuilder(
    column: $table.allowsPhysiologicalCollection,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowsResearchExport => $composableBuilder(
    column: $table.allowsResearchExport,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get allowsReplayAnalysis => $composableBuilder(
    column: $table.allowsReplayAnalysis,
    builder: (column) => column,
  );
}

class $$ResearchConsentTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ResearchConsentTableTable,
          ResearchConsentTableData,
          $$ResearchConsentTableTableFilterComposer,
          $$ResearchConsentTableTableOrderingComposer,
          $$ResearchConsentTableTableAnnotationComposer,
          $$ResearchConsentTableTableCreateCompanionBuilder,
          $$ResearchConsentTableTableUpdateCompanionBuilder,
          (
            ResearchConsentTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ResearchConsentTableTable,
              ResearchConsentTableData
            >,
          ),
          ResearchConsentTableData,
          PrefetchHooks Function()
        > {
  $$ResearchConsentTableTableTableManager(
    _$SignalFlowDatabase db,
    $ResearchConsentTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchConsentTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResearchConsentTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ResearchConsentTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<bool> accepted = const Value.absent(),
                Value<DateTime?> acceptedAt = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<bool> allowsPhysiologicalCollection =
                    const Value.absent(),
                Value<bool> allowsResearchExport = const Value.absent(),
                Value<bool> allowsReplayAnalysis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchConsentTableCompanion(
                id: id,
                accepted: accepted,
                acceptedAt: acceptedAt,
                version: version,
                allowsPhysiologicalCollection: allowsPhysiologicalCollection,
                allowsResearchExport: allowsResearchExport,
                allowsReplayAnalysis: allowsReplayAnalysis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required bool accepted,
                Value<DateTime?> acceptedAt = const Value.absent(),
                required String version,
                required bool allowsPhysiologicalCollection,
                required bool allowsResearchExport,
                required bool allowsReplayAnalysis,
                Value<int> rowid = const Value.absent(),
              }) => ResearchConsentTableCompanion.insert(
                id: id,
                accepted: accepted,
                acceptedAt: acceptedAt,
                version: version,
                allowsPhysiologicalCollection: allowsPhysiologicalCollection,
                allowsResearchExport: allowsResearchExport,
                allowsReplayAnalysis: allowsReplayAnalysis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchConsentTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ResearchConsentTableTable,
      ResearchConsentTableData,
      $$ResearchConsentTableTableFilterComposer,
      $$ResearchConsentTableTableOrderingComposer,
      $$ResearchConsentTableTableAnnotationComposer,
      $$ResearchConsentTableTableCreateCompanionBuilder,
      $$ResearchConsentTableTableUpdateCompanionBuilder,
      (
        ResearchConsentTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ResearchConsentTableTable,
          ResearchConsentTableData
        >,
      ),
      ResearchConsentTableData,
      PrefetchHooks Function()
    >;
typedef $$AdaptiveBaselineStateTableTableCreateCompanionBuilder =
    AdaptiveBaselineStateTableCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required int totalSamples,
      required double restingHeartRate,
      required double hrvRmssd,
      required double respiratoryRate,
      required double movementIntensity,
      Value<int> rowid,
    });
typedef $$AdaptiveBaselineStateTableTableUpdateCompanionBuilder =
    AdaptiveBaselineStateTableCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> totalSamples,
      Value<double> restingHeartRate,
      Value<double> hrvRmssd,
      Value<double> respiratoryRate,
      Value<double> movementIntensity,
      Value<int> rowid,
    });

class $$AdaptiveBaselineStateTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $AdaptiveBaselineStateTableTable> {
  $$AdaptiveBaselineStateTableTableFilterComposer({
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdaptiveBaselineStateTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $AdaptiveBaselineStateTableTable> {
  $$AdaptiveBaselineStateTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvRmssd => $composableBuilder(
    column: $table.hrvRmssd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdaptiveBaselineStateTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $AdaptiveBaselineStateTableTable> {
  $$AdaptiveBaselineStateTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => column,
  );

  GeneratedColumn<double> get restingHeartRate => $composableBuilder(
    column: $table.restingHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvRmssd =>
      $composableBuilder(column: $table.hrvRmssd, builder: (column) => column);

  GeneratedColumn<double> get respiratoryRate => $composableBuilder(
    column: $table.respiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get movementIntensity => $composableBuilder(
    column: $table.movementIntensity,
    builder: (column) => column,
  );
}

class $$AdaptiveBaselineStateTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $AdaptiveBaselineStateTableTable,
          AdaptiveBaselineStateTableData,
          $$AdaptiveBaselineStateTableTableFilterComposer,
          $$AdaptiveBaselineStateTableTableOrderingComposer,
          $$AdaptiveBaselineStateTableTableAnnotationComposer,
          $$AdaptiveBaselineStateTableTableCreateCompanionBuilder,
          $$AdaptiveBaselineStateTableTableUpdateCompanionBuilder,
          (
            AdaptiveBaselineStateTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $AdaptiveBaselineStateTableTable,
              AdaptiveBaselineStateTableData
            >,
          ),
          AdaptiveBaselineStateTableData,
          PrefetchHooks Function()
        > {
  $$AdaptiveBaselineStateTableTableTableManager(
    _$SignalFlowDatabase db,
    $AdaptiveBaselineStateTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdaptiveBaselineStateTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AdaptiveBaselineStateTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AdaptiveBaselineStateTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<double> restingHeartRate = const Value.absent(),
                Value<double> hrvRmssd = const Value.absent(),
                Value<double> respiratoryRate = const Value.absent(),
                Value<double> movementIntensity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdaptiveBaselineStateTableCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                totalSamples: totalSamples,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                respiratoryRate: respiratoryRate,
                movementIntensity: movementIntensity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required int totalSamples,
                required double restingHeartRate,
                required double hrvRmssd,
                required double respiratoryRate,
                required double movementIntensity,
                Value<int> rowid = const Value.absent(),
              }) => AdaptiveBaselineStateTableCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                totalSamples: totalSamples,
                restingHeartRate: restingHeartRate,
                hrvRmssd: hrvRmssd,
                respiratoryRate: respiratoryRate,
                movementIntensity: movementIntensity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdaptiveBaselineStateTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $AdaptiveBaselineStateTableTable,
      AdaptiveBaselineStateTableData,
      $$AdaptiveBaselineStateTableTableFilterComposer,
      $$AdaptiveBaselineStateTableTableOrderingComposer,
      $$AdaptiveBaselineStateTableTableAnnotationComposer,
      $$AdaptiveBaselineStateTableTableCreateCompanionBuilder,
      $$AdaptiveBaselineStateTableTableUpdateCompanionBuilder,
      (
        AdaptiveBaselineStateTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $AdaptiveBaselineStateTableTable,
          AdaptiveBaselineStateTableData
        >,
      ),
      AdaptiveBaselineStateTableData,
      PrefetchHooks Function()
    >;
typedef $$CircadianProfilesTableTableCreateCompanionBuilder =
    CircadianProfilesTableCompanion Function({
      required String id,
      required String baselineId,
      required String windowLabel,
      required int startHour,
      required int endHour,
      required double averageHeartRate,
      Value<double?> averageHrv,
      Value<double?> averageRespiratoryRate,
      required int sampleCount,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CircadianProfilesTableTableUpdateCompanionBuilder =
    CircadianProfilesTableCompanion Function({
      Value<String> id,
      Value<String> baselineId,
      Value<String> windowLabel,
      Value<int> startHour,
      Value<int> endHour,
      Value<double> averageHeartRate,
      Value<double?> averageHrv,
      Value<double?> averageRespiratoryRate,
      Value<int> sampleCount,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$CircadianProfilesTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $CircadianProfilesTableTable> {
  $$CircadianProfilesTableTableFilterComposer({
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

  ColumnFilters<String> get baselineId => $composableBuilder(
    column: $table.baselineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRespiratoryRate => $composableBuilder(
    column: $table.averageRespiratoryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CircadianProfilesTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $CircadianProfilesTableTable> {
  $$CircadianProfilesTableTableOrderingComposer({
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

  ColumnOrderings<String> get baselineId => $composableBuilder(
    column: $table.baselineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startHour => $composableBuilder(
    column: $table.startHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endHour => $composableBuilder(
    column: $table.endHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRespiratoryRate => $composableBuilder(
    column: $table.averageRespiratoryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CircadianProfilesTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $CircadianProfilesTableTable> {
  $$CircadianProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get baselineId => $composableBuilder(
    column: $table.baselineId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startHour =>
      $composableBuilder(column: $table.startHour, builder: (column) => column);

  GeneratedColumn<int> get endHour =>
      $composableBuilder(column: $table.endHour, builder: (column) => column);

  GeneratedColumn<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRespiratoryRate => $composableBuilder(
    column: $table.averageRespiratoryRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CircadianProfilesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $CircadianProfilesTableTable,
          CircadianProfilesTableData,
          $$CircadianProfilesTableTableFilterComposer,
          $$CircadianProfilesTableTableOrderingComposer,
          $$CircadianProfilesTableTableAnnotationComposer,
          $$CircadianProfilesTableTableCreateCompanionBuilder,
          $$CircadianProfilesTableTableUpdateCompanionBuilder,
          (
            CircadianProfilesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $CircadianProfilesTableTable,
              CircadianProfilesTableData
            >,
          ),
          CircadianProfilesTableData,
          PrefetchHooks Function()
        > {
  $$CircadianProfilesTableTableTableManager(
    _$SignalFlowDatabase db,
    $CircadianProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CircadianProfilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CircadianProfilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CircadianProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> baselineId = const Value.absent(),
                Value<String> windowLabel = const Value.absent(),
                Value<int> startHour = const Value.absent(),
                Value<int> endHour = const Value.absent(),
                Value<double> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                Value<double?> averageRespiratoryRate = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CircadianProfilesTableCompanion(
                id: id,
                baselineId: baselineId,
                windowLabel: windowLabel,
                startHour: startHour,
                endHour: endHour,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                averageRespiratoryRate: averageRespiratoryRate,
                sampleCount: sampleCount,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String baselineId,
                required String windowLabel,
                required int startHour,
                required int endHour,
                required double averageHeartRate,
                Value<double?> averageHrv = const Value.absent(),
                Value<double?> averageRespiratoryRate = const Value.absent(),
                required int sampleCount,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CircadianProfilesTableCompanion.insert(
                id: id,
                baselineId: baselineId,
                windowLabel: windowLabel,
                startHour: startHour,
                endHour: endHour,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                averageRespiratoryRate: averageRespiratoryRate,
                sampleCount: sampleCount,
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

typedef $$CircadianProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $CircadianProfilesTableTable,
      CircadianProfilesTableData,
      $$CircadianProfilesTableTableFilterComposer,
      $$CircadianProfilesTableTableOrderingComposer,
      $$CircadianProfilesTableTableAnnotationComposer,
      $$CircadianProfilesTableTableCreateCompanionBuilder,
      $$CircadianProfilesTableTableUpdateCompanionBuilder,
      (
        CircadianProfilesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $CircadianProfilesTableTable,
          CircadianProfilesTableData
        >,
      ),
      CircadianProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$SessionTimelineTableTableCreateCompanionBuilder =
    SessionTimelineTableCompanion Function({
      required String id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required int totalSamples,
      required int totalEvents,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      Value<double?> maxHeartRate,
      Value<double?> minHrv,
      Value<int> rowid,
    });
typedef $$SessionTimelineTableTableUpdateCompanionBuilder =
    SessionTimelineTableCompanion Function({
      Value<String> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> totalSamples,
      Value<int> totalEvents,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      Value<double?> maxHeartRate,
      Value<double?> minHrv,
      Value<int> rowid,
    });

class $$SessionTimelineTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $SessionTimelineTableTable> {
  $$SessionTimelineTableTableFilterComposer({
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

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEvents => $composableBuilder(
    column: $table.totalEvents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minHrv => $composableBuilder(
    column: $table.minHrv,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionTimelineTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $SessionTimelineTableTable> {
  $$SessionTimelineTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEvents => $composableBuilder(
    column: $table.totalEvents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minHrv => $composableBuilder(
    column: $table.minHrv,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionTimelineTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $SessionTimelineTableTable> {
  $$SessionTimelineTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get totalSamples => $composableBuilder(
    column: $table.totalSamples,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalEvents => $composableBuilder(
    column: $table.totalEvents,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxHeartRate => $composableBuilder(
    column: $table.maxHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minHrv =>
      $composableBuilder(column: $table.minHrv, builder: (column) => column);
}

class $$SessionTimelineTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $SessionTimelineTableTable,
          SessionTimelineTableData,
          $$SessionTimelineTableTableFilterComposer,
          $$SessionTimelineTableTableOrderingComposer,
          $$SessionTimelineTableTableAnnotationComposer,
          $$SessionTimelineTableTableCreateCompanionBuilder,
          $$SessionTimelineTableTableUpdateCompanionBuilder,
          (
            SessionTimelineTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $SessionTimelineTableTable,
              SessionTimelineTableData
            >,
          ),
          SessionTimelineTableData,
          PrefetchHooks Function()
        > {
  $$SessionTimelineTableTableTableManager(
    _$SignalFlowDatabase db,
    $SessionTimelineTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionTimelineTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionTimelineTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SessionTimelineTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> totalSamples = const Value.absent(),
                Value<int> totalEvents = const Value.absent(),
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                Value<double?> maxHeartRate = const Value.absent(),
                Value<double?> minHrv = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionTimelineTableCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                totalSamples: totalSamples,
                totalEvents: totalEvents,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                maxHeartRate: maxHeartRate,
                minHrv: minHrv,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int totalSamples,
                required int totalEvents,
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                Value<double?> maxHeartRate = const Value.absent(),
                Value<double?> minHrv = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionTimelineTableCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                totalSamples: totalSamples,
                totalEvents: totalEvents,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                maxHeartRate: maxHeartRate,
                minHrv: minHrv,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionTimelineTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $SessionTimelineTableTable,
      SessionTimelineTableData,
      $$SessionTimelineTableTableFilterComposer,
      $$SessionTimelineTableTableOrderingComposer,
      $$SessionTimelineTableTableAnnotationComposer,
      $$SessionTimelineTableTableCreateCompanionBuilder,
      $$SessionTimelineTableTableUpdateCompanionBuilder,
      (
        SessionTimelineTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $SessionTimelineTableTable,
          SessionTimelineTableData
        >,
      ),
      SessionTimelineTableData,
      PrefetchHooks Function()
    >;
typedef $$PhysiologicalEventMarkersTableTableCreateCompanionBuilder =
    PhysiologicalEventMarkersTableCompanion Function({
      required String id,
      required String timelineId,
      required DateTime timestamp,
      required String type,
      required String title,
      required String description,
      required String severity,
      required String source,
      Value<int> rowid,
    });
typedef $$PhysiologicalEventMarkersTableTableUpdateCompanionBuilder =
    PhysiologicalEventMarkersTableCompanion Function({
      Value<String> id,
      Value<String> timelineId,
      Value<DateTime> timestamp,
      Value<String> type,
      Value<String> title,
      Value<String> description,
      Value<String> severity,
      Value<String> source,
      Value<int> rowid,
    });

class $$PhysiologicalEventMarkersTableTableFilterComposer
    extends
        Composer<_$SignalFlowDatabase, $PhysiologicalEventMarkersTableTable> {
  $$PhysiologicalEventMarkersTableTableFilterComposer({
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

  ColumnFilters<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhysiologicalEventMarkersTableTableOrderingComposer
    extends
        Composer<_$SignalFlowDatabase, $PhysiologicalEventMarkersTableTable> {
  $$PhysiologicalEventMarkersTableTableOrderingComposer({
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

  ColumnOrderings<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhysiologicalEventMarkersTableTableAnnotationComposer
    extends
        Composer<_$SignalFlowDatabase, $PhysiologicalEventMarkersTableTable> {
  $$PhysiologicalEventMarkersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$PhysiologicalEventMarkersTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $PhysiologicalEventMarkersTableTable,
          PhysiologicalEventMarkersTableData,
          $$PhysiologicalEventMarkersTableTableFilterComposer,
          $$PhysiologicalEventMarkersTableTableOrderingComposer,
          $$PhysiologicalEventMarkersTableTableAnnotationComposer,
          $$PhysiologicalEventMarkersTableTableCreateCompanionBuilder,
          $$PhysiologicalEventMarkersTableTableUpdateCompanionBuilder,
          (
            PhysiologicalEventMarkersTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $PhysiologicalEventMarkersTableTable,
              PhysiologicalEventMarkersTableData
            >,
          ),
          PhysiologicalEventMarkersTableData,
          PrefetchHooks Function()
        > {
  $$PhysiologicalEventMarkersTableTableTableManager(
    _$SignalFlowDatabase db,
    $PhysiologicalEventMarkersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysiologicalEventMarkersTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PhysiologicalEventMarkersTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PhysiologicalEventMarkersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> timelineId = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> severity = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalEventMarkersTableCompanion(
                id: id,
                timelineId: timelineId,
                timestamp: timestamp,
                type: type,
                title: title,
                description: description,
                severity: severity,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String timelineId,
                required DateTime timestamp,
                required String type,
                required String title,
                required String description,
                required String severity,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalEventMarkersTableCompanion.insert(
                id: id,
                timelineId: timelineId,
                timestamp: timestamp,
                type: type,
                title: title,
                description: description,
                severity: severity,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhysiologicalEventMarkersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $PhysiologicalEventMarkersTableTable,
      PhysiologicalEventMarkersTableData,
      $$PhysiologicalEventMarkersTableTableFilterComposer,
      $$PhysiologicalEventMarkersTableTableOrderingComposer,
      $$PhysiologicalEventMarkersTableTableAnnotationComposer,
      $$PhysiologicalEventMarkersTableTableCreateCompanionBuilder,
      $$PhysiologicalEventMarkersTableTableUpdateCompanionBuilder,
      (
        PhysiologicalEventMarkersTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $PhysiologicalEventMarkersTableTable,
          PhysiologicalEventMarkersTableData
        >,
      ),
      PhysiologicalEventMarkersTableData,
      PrefetchHooks Function()
    >;
typedef $$PhysiologicalTrendsTableTableCreateCompanionBuilder =
    PhysiologicalTrendsTableCompanion Function({
      required String id,
      required String timelineId,
      required DateTime generatedAt,
      required String windowLabel,
      required int windowSeconds,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      required double hrvSlope,
      required double heartRateSlope,
      required double activationDensity,
      required int escalationScore,
      Value<int> rowid,
    });
typedef $$PhysiologicalTrendsTableTableUpdateCompanionBuilder =
    PhysiologicalTrendsTableCompanion Function({
      Value<String> id,
      Value<String> timelineId,
      Value<DateTime> generatedAt,
      Value<String> windowLabel,
      Value<int> windowSeconds,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      Value<double> hrvSlope,
      Value<double> heartRateSlope,
      Value<double> activationDensity,
      Value<int> escalationScore,
      Value<int> rowid,
    });

class $$PhysiologicalTrendsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $PhysiologicalTrendsTableTable> {
  $$PhysiologicalTrendsTableTableFilterComposer({
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

  ColumnFilters<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get windowSeconds => $composableBuilder(
    column: $table.windowSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvSlope => $composableBuilder(
    column: $table.hrvSlope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heartRateSlope => $composableBuilder(
    column: $table.heartRateSlope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get escalationScore => $composableBuilder(
    column: $table.escalationScore,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhysiologicalTrendsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $PhysiologicalTrendsTableTable> {
  $$PhysiologicalTrendsTableTableOrderingComposer({
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

  ColumnOrderings<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get windowSeconds => $composableBuilder(
    column: $table.windowSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvSlope => $composableBuilder(
    column: $table.hrvSlope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heartRateSlope => $composableBuilder(
    column: $table.heartRateSlope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get escalationScore => $composableBuilder(
    column: $table.escalationScore,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhysiologicalTrendsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $PhysiologicalTrendsTableTable> {
  $$PhysiologicalTrendsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get timelineId => $composableBuilder(
    column: $table.timelineId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get windowLabel => $composableBuilder(
    column: $table.windowLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get windowSeconds => $composableBuilder(
    column: $table.windowSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageHeartRate => $composableBuilder(
    column: $table.averageHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageHrv => $composableBuilder(
    column: $table.averageHrv,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvSlope =>
      $composableBuilder(column: $table.hrvSlope, builder: (column) => column);

  GeneratedColumn<double> get heartRateSlope => $composableBuilder(
    column: $table.heartRateSlope,
    builder: (column) => column,
  );

  GeneratedColumn<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get escalationScore => $composableBuilder(
    column: $table.escalationScore,
    builder: (column) => column,
  );
}

class $$PhysiologicalTrendsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $PhysiologicalTrendsTableTable,
          PhysiologicalTrendsTableData,
          $$PhysiologicalTrendsTableTableFilterComposer,
          $$PhysiologicalTrendsTableTableOrderingComposer,
          $$PhysiologicalTrendsTableTableAnnotationComposer,
          $$PhysiologicalTrendsTableTableCreateCompanionBuilder,
          $$PhysiologicalTrendsTableTableUpdateCompanionBuilder,
          (
            PhysiologicalTrendsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $PhysiologicalTrendsTableTable,
              PhysiologicalTrendsTableData
            >,
          ),
          PhysiologicalTrendsTableData,
          PrefetchHooks Function()
        > {
  $$PhysiologicalTrendsTableTableTableManager(
    _$SignalFlowDatabase db,
    $PhysiologicalTrendsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysiologicalTrendsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PhysiologicalTrendsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PhysiologicalTrendsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> timelineId = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> windowLabel = const Value.absent(),
                Value<int> windowSeconds = const Value.absent(),
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                Value<double> hrvSlope = const Value.absent(),
                Value<double> heartRateSlope = const Value.absent(),
                Value<double> activationDensity = const Value.absent(),
                Value<int> escalationScore = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalTrendsTableCompanion(
                id: id,
                timelineId: timelineId,
                generatedAt: generatedAt,
                windowLabel: windowLabel,
                windowSeconds: windowSeconds,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                hrvSlope: hrvSlope,
                heartRateSlope: heartRateSlope,
                activationDensity: activationDensity,
                escalationScore: escalationScore,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String timelineId,
                required DateTime generatedAt,
                required String windowLabel,
                required int windowSeconds,
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                required double hrvSlope,
                required double heartRateSlope,
                required double activationDensity,
                required int escalationScore,
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalTrendsTableCompanion.insert(
                id: id,
                timelineId: timelineId,
                generatedAt: generatedAt,
                windowLabel: windowLabel,
                windowSeconds: windowSeconds,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                hrvSlope: hrvSlope,
                heartRateSlope: heartRateSlope,
                activationDensity: activationDensity,
                escalationScore: escalationScore,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhysiologicalTrendsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $PhysiologicalTrendsTableTable,
      PhysiologicalTrendsTableData,
      $$PhysiologicalTrendsTableTableFilterComposer,
      $$PhysiologicalTrendsTableTableOrderingComposer,
      $$PhysiologicalTrendsTableTableAnnotationComposer,
      $$PhysiologicalTrendsTableTableCreateCompanionBuilder,
      $$PhysiologicalTrendsTableTableUpdateCompanionBuilder,
      (
        PhysiologicalTrendsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $PhysiologicalTrendsTableTable,
          PhysiologicalTrendsTableData
        >,
      ),
      PhysiologicalTrendsTableData,
      PrefetchHooks Function()
    >;

class $SignalFlowDatabaseManager {
  final _$SignalFlowDatabase _db;
  $SignalFlowDatabaseManager(this._db);
  $$BaselineProfilesTableTableTableManager get baselineProfilesTable =>
      $$BaselineProfilesTableTableTableManager(_db, _db.baselineProfilesTable);
  $$CrisisRiskEventsTableTableTableManager get crisisRiskEventsTable =>
      $$CrisisRiskEventsTableTableTableManager(_db, _db.crisisRiskEventsTable);
  $$InterventionHistoryTableTableTableManager get interventionHistoryTable =>
      $$InterventionHistoryTableTableTableManager(
        _db,
        _db.interventionHistoryTable,
      );
  $$ResearchConsentTableTableTableManager get researchConsentTable =>
      $$ResearchConsentTableTableTableManager(_db, _db.researchConsentTable);
  $$AdaptiveBaselineStateTableTableTableManager
  get adaptiveBaselineStateTable =>
      $$AdaptiveBaselineStateTableTableTableManager(
        _db,
        _db.adaptiveBaselineStateTable,
      );
  $$CircadianProfilesTableTableTableManager get circadianProfilesTable =>
      $$CircadianProfilesTableTableTableManager(
        _db,
        _db.circadianProfilesTable,
      );
  $$SessionTimelineTableTableTableManager get sessionTimelineTable =>
      $$SessionTimelineTableTableTableManager(_db, _db.sessionTimelineTable);
  $$PhysiologicalEventMarkersTableTableTableManager
  get physiologicalEventMarkersTable =>
      $$PhysiologicalEventMarkersTableTableTableManager(
        _db,
        _db.physiologicalEventMarkersTable,
      );
  $$PhysiologicalTrendsTableTableTableManager get physiologicalTrendsTable =>
      $$PhysiologicalTrendsTableTableTableManager(
        _db,
        _db.physiologicalTrendsTable,
      );
}
