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

class $AutonomicRecoveryProfilesTableTable
    extends AutonomicRecoveryProfilesTable
    with
        TableInfo<
          $AutonomicRecoveryProfilesTableTable,
          AutonomicRecoveryProfilesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AutonomicRecoveryProfilesTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recoveryRateMeta = const VerificationMeta(
    'recoveryRate',
  );
  @override
  late final GeneratedColumn<double> recoveryRate = GeneratedColumn<double>(
    'recovery_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hrvRecoverySlopeMeta = const VerificationMeta(
    'hrvRecoverySlope',
  );
  @override
  late final GeneratedColumn<double> hrvRecoverySlope = GeneratedColumn<double>(
    'hrv_recovery_slope',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heartRateNormalizationMeta =
      const VerificationMeta('heartRateNormalization');
  @override
  late final GeneratedColumn<double> heartRateNormalization =
      GeneratedColumn<double>(
        'heart_rate_normalization',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _baselineReturnSecondsMeta =
      const VerificationMeta('baselineReturnSeconds');
  @override
  late final GeneratedColumn<int> baselineReturnSeconds = GeneratedColumn<int>(
    'baseline_return_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _resilienceScoreMeta = const VerificationMeta(
    'resilienceScore',
  );
  @override
  late final GeneratedColumn<int> resilienceScore = GeneratedColumn<int>(
    'resilience_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatigueScoreMeta = const VerificationMeta(
    'fatigueScore',
  );
  @override
  late final GeneratedColumn<int> fatigueScore = GeneratedColumn<int>(
    'fatigue_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stressCarryoverMeta = const VerificationMeta(
    'stressCarryover',
  );
  @override
  late final GeneratedColumn<double> stressCarryover = GeneratedColumn<double>(
    'stress_carryover',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resilienceLevelMeta = const VerificationMeta(
    'resilienceLevel',
  );
  @override
  late final GeneratedColumn<String> resilienceLevel = GeneratedColumn<String>(
    'resilience_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    timelineId,
    generatedAt,
    windowLabel,
    windowSeconds,
    recoveryRate,
    hrvRecoverySlope,
    heartRateNormalization,
    baselineReturnSeconds,
    resilienceScore,
    fatigueScore,
    stressCarryover,
    resilienceLevel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'autonomic_recovery_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AutonomicRecoveryProfilesTableData> instance, {
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
    if (data.containsKey('recovery_rate')) {
      context.handle(
        _recoveryRateMeta,
        recoveryRate.isAcceptableOrUnknown(
          data['recovery_rate']!,
          _recoveryRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryRateMeta);
    }
    if (data.containsKey('hrv_recovery_slope')) {
      context.handle(
        _hrvRecoverySlopeMeta,
        hrvRecoverySlope.isAcceptableOrUnknown(
          data['hrv_recovery_slope']!,
          _hrvRecoverySlopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_hrvRecoverySlopeMeta);
    }
    if (data.containsKey('heart_rate_normalization')) {
      context.handle(
        _heartRateNormalizationMeta,
        heartRateNormalization.isAcceptableOrUnknown(
          data['heart_rate_normalization']!,
          _heartRateNormalizationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_heartRateNormalizationMeta);
    }
    if (data.containsKey('baseline_return_seconds')) {
      context.handle(
        _baselineReturnSecondsMeta,
        baselineReturnSeconds.isAcceptableOrUnknown(
          data['baseline_return_seconds']!,
          _baselineReturnSecondsMeta,
        ),
      );
    }
    if (data.containsKey('resilience_score')) {
      context.handle(
        _resilienceScoreMeta,
        resilienceScore.isAcceptableOrUnknown(
          data['resilience_score']!,
          _resilienceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resilienceScoreMeta);
    }
    if (data.containsKey('fatigue_score')) {
      context.handle(
        _fatigueScoreMeta,
        fatigueScore.isAcceptableOrUnknown(
          data['fatigue_score']!,
          _fatigueScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatigueScoreMeta);
    }
    if (data.containsKey('stress_carryover')) {
      context.handle(
        _stressCarryoverMeta,
        stressCarryover.isAcceptableOrUnknown(
          data['stress_carryover']!,
          _stressCarryoverMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stressCarryoverMeta);
    }
    if (data.containsKey('resilience_level')) {
      context.handle(
        _resilienceLevelMeta,
        resilienceLevel.isAcceptableOrUnknown(
          data['resilience_level']!,
          _resilienceLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resilienceLevelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AutonomicRecoveryProfilesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AutonomicRecoveryProfilesTableData(
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
      recoveryRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_rate'],
      )!,
      hrvRecoverySlope: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hrv_recovery_slope'],
      )!,
      heartRateNormalization: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heart_rate_normalization'],
      )!,
      baselineReturnSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}baseline_return_seconds'],
      ),
      resilienceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resilience_score'],
      )!,
      fatigueScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatigue_score'],
      )!,
      stressCarryover: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stress_carryover'],
      )!,
      resilienceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resilience_level'],
      )!,
    );
  }

  @override
  $AutonomicRecoveryProfilesTableTable createAlias(String alias) {
    return $AutonomicRecoveryProfilesTableTable(attachedDatabase, alias);
  }
}

class AutonomicRecoveryProfilesTableData extends DataClass
    implements Insertable<AutonomicRecoveryProfilesTableData> {
  final String id;
  final String timelineId;
  final DateTime generatedAt;
  final String windowLabel;
  final int windowSeconds;
  final double recoveryRate;
  final double hrvRecoverySlope;
  final double heartRateNormalization;
  final int? baselineReturnSeconds;
  final int resilienceScore;
  final int fatigueScore;
  final double stressCarryover;
  final String resilienceLevel;
  const AutonomicRecoveryProfilesTableData({
    required this.id,
    required this.timelineId,
    required this.generatedAt,
    required this.windowLabel,
    required this.windowSeconds,
    required this.recoveryRate,
    required this.hrvRecoverySlope,
    required this.heartRateNormalization,
    this.baselineReturnSeconds,
    required this.resilienceScore,
    required this.fatigueScore,
    required this.stressCarryover,
    required this.resilienceLevel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timeline_id'] = Variable<String>(timelineId);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['window_label'] = Variable<String>(windowLabel);
    map['window_seconds'] = Variable<int>(windowSeconds);
    map['recovery_rate'] = Variable<double>(recoveryRate);
    map['hrv_recovery_slope'] = Variable<double>(hrvRecoverySlope);
    map['heart_rate_normalization'] = Variable<double>(heartRateNormalization);
    if (!nullToAbsent || baselineReturnSeconds != null) {
      map['baseline_return_seconds'] = Variable<int>(baselineReturnSeconds);
    }
    map['resilience_score'] = Variable<int>(resilienceScore);
    map['fatigue_score'] = Variable<int>(fatigueScore);
    map['stress_carryover'] = Variable<double>(stressCarryover);
    map['resilience_level'] = Variable<String>(resilienceLevel);
    return map;
  }

  AutonomicRecoveryProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return AutonomicRecoveryProfilesTableCompanion(
      id: Value(id),
      timelineId: Value(timelineId),
      generatedAt: Value(generatedAt),
      windowLabel: Value(windowLabel),
      windowSeconds: Value(windowSeconds),
      recoveryRate: Value(recoveryRate),
      hrvRecoverySlope: Value(hrvRecoverySlope),
      heartRateNormalization: Value(heartRateNormalization),
      baselineReturnSeconds: baselineReturnSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(baselineReturnSeconds),
      resilienceScore: Value(resilienceScore),
      fatigueScore: Value(fatigueScore),
      stressCarryover: Value(stressCarryover),
      resilienceLevel: Value(resilienceLevel),
    );
  }

  factory AutonomicRecoveryProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AutonomicRecoveryProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      timelineId: serializer.fromJson<String>(json['timelineId']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      windowLabel: serializer.fromJson<String>(json['windowLabel']),
      windowSeconds: serializer.fromJson<int>(json['windowSeconds']),
      recoveryRate: serializer.fromJson<double>(json['recoveryRate']),
      hrvRecoverySlope: serializer.fromJson<double>(json['hrvRecoverySlope']),
      heartRateNormalization: serializer.fromJson<double>(
        json['heartRateNormalization'],
      ),
      baselineReturnSeconds: serializer.fromJson<int?>(
        json['baselineReturnSeconds'],
      ),
      resilienceScore: serializer.fromJson<int>(json['resilienceScore']),
      fatigueScore: serializer.fromJson<int>(json['fatigueScore']),
      stressCarryover: serializer.fromJson<double>(json['stressCarryover']),
      resilienceLevel: serializer.fromJson<String>(json['resilienceLevel']),
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
      'recoveryRate': serializer.toJson<double>(recoveryRate),
      'hrvRecoverySlope': serializer.toJson<double>(hrvRecoverySlope),
      'heartRateNormalization': serializer.toJson<double>(
        heartRateNormalization,
      ),
      'baselineReturnSeconds': serializer.toJson<int?>(baselineReturnSeconds),
      'resilienceScore': serializer.toJson<int>(resilienceScore),
      'fatigueScore': serializer.toJson<int>(fatigueScore),
      'stressCarryover': serializer.toJson<double>(stressCarryover),
      'resilienceLevel': serializer.toJson<String>(resilienceLevel),
    };
  }

  AutonomicRecoveryProfilesTableData copyWith({
    String? id,
    String? timelineId,
    DateTime? generatedAt,
    String? windowLabel,
    int? windowSeconds,
    double? recoveryRate,
    double? hrvRecoverySlope,
    double? heartRateNormalization,
    Value<int?> baselineReturnSeconds = const Value.absent(),
    int? resilienceScore,
    int? fatigueScore,
    double? stressCarryover,
    String? resilienceLevel,
  }) => AutonomicRecoveryProfilesTableData(
    id: id ?? this.id,
    timelineId: timelineId ?? this.timelineId,
    generatedAt: generatedAt ?? this.generatedAt,
    windowLabel: windowLabel ?? this.windowLabel,
    windowSeconds: windowSeconds ?? this.windowSeconds,
    recoveryRate: recoveryRate ?? this.recoveryRate,
    hrvRecoverySlope: hrvRecoverySlope ?? this.hrvRecoverySlope,
    heartRateNormalization:
        heartRateNormalization ?? this.heartRateNormalization,
    baselineReturnSeconds: baselineReturnSeconds.present
        ? baselineReturnSeconds.value
        : this.baselineReturnSeconds,
    resilienceScore: resilienceScore ?? this.resilienceScore,
    fatigueScore: fatigueScore ?? this.fatigueScore,
    stressCarryover: stressCarryover ?? this.stressCarryover,
    resilienceLevel: resilienceLevel ?? this.resilienceLevel,
  );
  AutonomicRecoveryProfilesTableData copyWithCompanion(
    AutonomicRecoveryProfilesTableCompanion data,
  ) {
    return AutonomicRecoveryProfilesTableData(
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
      recoveryRate: data.recoveryRate.present
          ? data.recoveryRate.value
          : this.recoveryRate,
      hrvRecoverySlope: data.hrvRecoverySlope.present
          ? data.hrvRecoverySlope.value
          : this.hrvRecoverySlope,
      heartRateNormalization: data.heartRateNormalization.present
          ? data.heartRateNormalization.value
          : this.heartRateNormalization,
      baselineReturnSeconds: data.baselineReturnSeconds.present
          ? data.baselineReturnSeconds.value
          : this.baselineReturnSeconds,
      resilienceScore: data.resilienceScore.present
          ? data.resilienceScore.value
          : this.resilienceScore,
      fatigueScore: data.fatigueScore.present
          ? data.fatigueScore.value
          : this.fatigueScore,
      stressCarryover: data.stressCarryover.present
          ? data.stressCarryover.value
          : this.stressCarryover,
      resilienceLevel: data.resilienceLevel.present
          ? data.resilienceLevel.value
          : this.resilienceLevel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AutonomicRecoveryProfilesTableData(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('windowSeconds: $windowSeconds, ')
          ..write('recoveryRate: $recoveryRate, ')
          ..write('hrvRecoverySlope: $hrvRecoverySlope, ')
          ..write('heartRateNormalization: $heartRateNormalization, ')
          ..write('baselineReturnSeconds: $baselineReturnSeconds, ')
          ..write('resilienceScore: $resilienceScore, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('stressCarryover: $stressCarryover, ')
          ..write('resilienceLevel: $resilienceLevel')
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
    recoveryRate,
    hrvRecoverySlope,
    heartRateNormalization,
    baselineReturnSeconds,
    resilienceScore,
    fatigueScore,
    stressCarryover,
    resilienceLevel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AutonomicRecoveryProfilesTableData &&
          other.id == this.id &&
          other.timelineId == this.timelineId &&
          other.generatedAt == this.generatedAt &&
          other.windowLabel == this.windowLabel &&
          other.windowSeconds == this.windowSeconds &&
          other.recoveryRate == this.recoveryRate &&
          other.hrvRecoverySlope == this.hrvRecoverySlope &&
          other.heartRateNormalization == this.heartRateNormalization &&
          other.baselineReturnSeconds == this.baselineReturnSeconds &&
          other.resilienceScore == this.resilienceScore &&
          other.fatigueScore == this.fatigueScore &&
          other.stressCarryover == this.stressCarryover &&
          other.resilienceLevel == this.resilienceLevel);
}

class AutonomicRecoveryProfilesTableCompanion
    extends UpdateCompanion<AutonomicRecoveryProfilesTableData> {
  final Value<String> id;
  final Value<String> timelineId;
  final Value<DateTime> generatedAt;
  final Value<String> windowLabel;
  final Value<int> windowSeconds;
  final Value<double> recoveryRate;
  final Value<double> hrvRecoverySlope;
  final Value<double> heartRateNormalization;
  final Value<int?> baselineReturnSeconds;
  final Value<int> resilienceScore;
  final Value<int> fatigueScore;
  final Value<double> stressCarryover;
  final Value<String> resilienceLevel;
  final Value<int> rowid;
  const AutonomicRecoveryProfilesTableCompanion({
    this.id = const Value.absent(),
    this.timelineId = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.windowLabel = const Value.absent(),
    this.windowSeconds = const Value.absent(),
    this.recoveryRate = const Value.absent(),
    this.hrvRecoverySlope = const Value.absent(),
    this.heartRateNormalization = const Value.absent(),
    this.baselineReturnSeconds = const Value.absent(),
    this.resilienceScore = const Value.absent(),
    this.fatigueScore = const Value.absent(),
    this.stressCarryover = const Value.absent(),
    this.resilienceLevel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AutonomicRecoveryProfilesTableCompanion.insert({
    required String id,
    required String timelineId,
    required DateTime generatedAt,
    required String windowLabel,
    required int windowSeconds,
    required double recoveryRate,
    required double hrvRecoverySlope,
    required double heartRateNormalization,
    this.baselineReturnSeconds = const Value.absent(),
    required int resilienceScore,
    required int fatigueScore,
    required double stressCarryover,
    required String resilienceLevel,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timelineId = Value(timelineId),
       generatedAt = Value(generatedAt),
       windowLabel = Value(windowLabel),
       windowSeconds = Value(windowSeconds),
       recoveryRate = Value(recoveryRate),
       hrvRecoverySlope = Value(hrvRecoverySlope),
       heartRateNormalization = Value(heartRateNormalization),
       resilienceScore = Value(resilienceScore),
       fatigueScore = Value(fatigueScore),
       stressCarryover = Value(stressCarryover),
       resilienceLevel = Value(resilienceLevel);
  static Insertable<AutonomicRecoveryProfilesTableData> custom({
    Expression<String>? id,
    Expression<String>? timelineId,
    Expression<DateTime>? generatedAt,
    Expression<String>? windowLabel,
    Expression<int>? windowSeconds,
    Expression<double>? recoveryRate,
    Expression<double>? hrvRecoverySlope,
    Expression<double>? heartRateNormalization,
    Expression<int>? baselineReturnSeconds,
    Expression<int>? resilienceScore,
    Expression<int>? fatigueScore,
    Expression<double>? stressCarryover,
    Expression<String>? resilienceLevel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timelineId != null) 'timeline_id': timelineId,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (windowLabel != null) 'window_label': windowLabel,
      if (windowSeconds != null) 'window_seconds': windowSeconds,
      if (recoveryRate != null) 'recovery_rate': recoveryRate,
      if (hrvRecoverySlope != null) 'hrv_recovery_slope': hrvRecoverySlope,
      if (heartRateNormalization != null)
        'heart_rate_normalization': heartRateNormalization,
      if (baselineReturnSeconds != null)
        'baseline_return_seconds': baselineReturnSeconds,
      if (resilienceScore != null) 'resilience_score': resilienceScore,
      if (fatigueScore != null) 'fatigue_score': fatigueScore,
      if (stressCarryover != null) 'stress_carryover': stressCarryover,
      if (resilienceLevel != null) 'resilience_level': resilienceLevel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AutonomicRecoveryProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? timelineId,
    Value<DateTime>? generatedAt,
    Value<String>? windowLabel,
    Value<int>? windowSeconds,
    Value<double>? recoveryRate,
    Value<double>? hrvRecoverySlope,
    Value<double>? heartRateNormalization,
    Value<int?>? baselineReturnSeconds,
    Value<int>? resilienceScore,
    Value<int>? fatigueScore,
    Value<double>? stressCarryover,
    Value<String>? resilienceLevel,
    Value<int>? rowid,
  }) {
    return AutonomicRecoveryProfilesTableCompanion(
      id: id ?? this.id,
      timelineId: timelineId ?? this.timelineId,
      generatedAt: generatedAt ?? this.generatedAt,
      windowLabel: windowLabel ?? this.windowLabel,
      windowSeconds: windowSeconds ?? this.windowSeconds,
      recoveryRate: recoveryRate ?? this.recoveryRate,
      hrvRecoverySlope: hrvRecoverySlope ?? this.hrvRecoverySlope,
      heartRateNormalization:
          heartRateNormalization ?? this.heartRateNormalization,
      baselineReturnSeconds:
          baselineReturnSeconds ?? this.baselineReturnSeconds,
      resilienceScore: resilienceScore ?? this.resilienceScore,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      stressCarryover: stressCarryover ?? this.stressCarryover,
      resilienceLevel: resilienceLevel ?? this.resilienceLevel,
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
    if (recoveryRate.present) {
      map['recovery_rate'] = Variable<double>(recoveryRate.value);
    }
    if (hrvRecoverySlope.present) {
      map['hrv_recovery_slope'] = Variable<double>(hrvRecoverySlope.value);
    }
    if (heartRateNormalization.present) {
      map['heart_rate_normalization'] = Variable<double>(
        heartRateNormalization.value,
      );
    }
    if (baselineReturnSeconds.present) {
      map['baseline_return_seconds'] = Variable<int>(
        baselineReturnSeconds.value,
      );
    }
    if (resilienceScore.present) {
      map['resilience_score'] = Variable<int>(resilienceScore.value);
    }
    if (fatigueScore.present) {
      map['fatigue_score'] = Variable<int>(fatigueScore.value);
    }
    if (stressCarryover.present) {
      map['stress_carryover'] = Variable<double>(stressCarryover.value);
    }
    if (resilienceLevel.present) {
      map['resilience_level'] = Variable<String>(resilienceLevel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AutonomicRecoveryProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('timelineId: $timelineId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('windowLabel: $windowLabel, ')
          ..write('windowSeconds: $windowSeconds, ')
          ..write('recoveryRate: $recoveryRate, ')
          ..write('hrvRecoverySlope: $hrvRecoverySlope, ')
          ..write('heartRateNormalization: $heartRateNormalization, ')
          ..write('baselineReturnSeconds: $baselineReturnSeconds, ')
          ..write('resilienceScore: $resilienceScore, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('stressCarryover: $stressCarryover, ')
          ..write('resilienceLevel: $resilienceLevel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResearchDashboardSnapshotsTableTable
    extends ResearchDashboardSnapshotsTable
    with
        TableInfo<
          $ResearchDashboardSnapshotsTableTable,
          ResearchDashboardSnapshotsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResearchDashboardSnapshotsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _averageConfidenceMeta = const VerificationMeta(
    'averageConfidence',
  );
  @override
  late final GeneratedColumn<double> averageConfidence =
      GeneratedColumn<double>(
        'average_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _escalationCountMeta = const VerificationMeta(
    'escalationCount',
  );
  @override
  late final GeneratedColumn<int> escalationCount = GeneratedColumn<int>(
    'escalation_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _interventionCountMeta = const VerificationMeta(
    'interventionCount',
  );
  @override
  late final GeneratedColumn<int> interventionCount = GeneratedColumn<int>(
    'intervention_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoveryEfficiencyMeta =
      const VerificationMeta('recoveryEfficiency');
  @override
  late final GeneratedColumn<double> recoveryEfficiency =
      GeneratedColumn<double>(
        'recovery_efficiency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _resilienceScoreMeta = const VerificationMeta(
    'resilienceScore',
  );
  @override
  late final GeneratedColumn<int> resilienceScore = GeneratedColumn<int>(
    'resilience_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatigueScoreMeta = const VerificationMeta(
    'fatigueScore',
  );
  @override
  late final GeneratedColumn<int> fatigueScore = GeneratedColumn<int>(
    'fatigue_score',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _baselineStabilityMeta = const VerificationMeta(
    'baselineStability',
  );
  @override
  late final GeneratedColumn<double> baselineStability =
      GeneratedColumn<double>(
        'baseline_stability',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stressCarryoverMeta = const VerificationMeta(
    'stressCarryover',
  );
  @override
  late final GeneratedColumn<double> stressCarryover = GeneratedColumn<double>(
    'stress_carryover',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _improvingTrendMeta = const VerificationMeta(
    'improvingTrend',
  );
  @override
  late final GeneratedColumn<bool> improvingTrend = GeneratedColumn<bool>(
    'improving_trend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("improving_trend" IN (0, 1))',
    ),
  );
  static const VerificationMeta _worseningTrendMeta = const VerificationMeta(
    'worseningTrend',
  );
  @override
  late final GeneratedColumn<bool> worseningTrend = GeneratedColumn<bool>(
    'worsening_trend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("worsening_trend" IN (0, 1))',
    ),
  );
  static const VerificationMeta _recoveryTrendMeta = const VerificationMeta(
    'recoveryTrend',
  );
  @override
  late final GeneratedColumn<bool> recoveryTrend = GeneratedColumn<bool>(
    'recovery_trend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("recovery_trend" IN (0, 1))',
    ),
  );
  static const VerificationMeta _confidenceTrendMeta = const VerificationMeta(
    'confidenceTrend',
  );
  @override
  late final GeneratedColumn<bool> confidenceTrend = GeneratedColumn<bool>(
    'confidence_trend',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confidence_trend" IN (0, 1))',
    ),
  );
  static const VerificationMeta _circadianStabilityMeta =
      const VerificationMeta('circadianStability');
  @override
  late final GeneratedColumn<bool> circadianStability = GeneratedColumn<bool>(
    'circadian_stability',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("circadian_stability" IN (0, 1))',
    ),
  );
  static const VerificationMeta _autonomicLoadMeta = const VerificationMeta(
    'autonomicLoad',
  );
  @override
  late final GeneratedColumn<double> autonomicLoad = GeneratedColumn<double>(
    'autonomic_load',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    averageHeartRate,
    averageHrv,
    averageConfidence,
    escalationCount,
    interventionCount,
    recoveryEfficiency,
    resilienceScore,
    fatigueScore,
    activationDensity,
    baselineStability,
    stressCarryover,
    improvingTrend,
    worseningTrend,
    recoveryTrend,
    confidenceTrend,
    circadianStability,
    autonomicLoad,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'research_dashboard_snapshots_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ResearchDashboardSnapshotsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('average_confidence')) {
      context.handle(
        _averageConfidenceMeta,
        averageConfidence.isAcceptableOrUnknown(
          data['average_confidence']!,
          _averageConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageConfidenceMeta);
    }
    if (data.containsKey('escalation_count')) {
      context.handle(
        _escalationCountMeta,
        escalationCount.isAcceptableOrUnknown(
          data['escalation_count']!,
          _escalationCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationCountMeta);
    }
    if (data.containsKey('intervention_count')) {
      context.handle(
        _interventionCountMeta,
        interventionCount.isAcceptableOrUnknown(
          data['intervention_count']!,
          _interventionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interventionCountMeta);
    }
    if (data.containsKey('recovery_efficiency')) {
      context.handle(
        _recoveryEfficiencyMeta,
        recoveryEfficiency.isAcceptableOrUnknown(
          data['recovery_efficiency']!,
          _recoveryEfficiencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryEfficiencyMeta);
    }
    if (data.containsKey('resilience_score')) {
      context.handle(
        _resilienceScoreMeta,
        resilienceScore.isAcceptableOrUnknown(
          data['resilience_score']!,
          _resilienceScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resilienceScoreMeta);
    }
    if (data.containsKey('fatigue_score')) {
      context.handle(
        _fatigueScoreMeta,
        fatigueScore.isAcceptableOrUnknown(
          data['fatigue_score']!,
          _fatigueScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatigueScoreMeta);
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
    if (data.containsKey('baseline_stability')) {
      context.handle(
        _baselineStabilityMeta,
        baselineStability.isAcceptableOrUnknown(
          data['baseline_stability']!,
          _baselineStabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineStabilityMeta);
    }
    if (data.containsKey('stress_carryover')) {
      context.handle(
        _stressCarryoverMeta,
        stressCarryover.isAcceptableOrUnknown(
          data['stress_carryover']!,
          _stressCarryoverMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stressCarryoverMeta);
    }
    if (data.containsKey('improving_trend')) {
      context.handle(
        _improvingTrendMeta,
        improvingTrend.isAcceptableOrUnknown(
          data['improving_trend']!,
          _improvingTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_improvingTrendMeta);
    }
    if (data.containsKey('worsening_trend')) {
      context.handle(
        _worseningTrendMeta,
        worseningTrend.isAcceptableOrUnknown(
          data['worsening_trend']!,
          _worseningTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_worseningTrendMeta);
    }
    if (data.containsKey('recovery_trend')) {
      context.handle(
        _recoveryTrendMeta,
        recoveryTrend.isAcceptableOrUnknown(
          data['recovery_trend']!,
          _recoveryTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryTrendMeta);
    }
    if (data.containsKey('confidence_trend')) {
      context.handle(
        _confidenceTrendMeta,
        confidenceTrend.isAcceptableOrUnknown(
          data['confidence_trend']!,
          _confidenceTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_confidenceTrendMeta);
    }
    if (data.containsKey('circadian_stability')) {
      context.handle(
        _circadianStabilityMeta,
        circadianStability.isAcceptableOrUnknown(
          data['circadian_stability']!,
          _circadianStabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_circadianStabilityMeta);
    }
    if (data.containsKey('autonomic_load')) {
      context.handle(
        _autonomicLoadMeta,
        autonomicLoad.isAcceptableOrUnknown(
          data['autonomic_load']!,
          _autonomicLoadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autonomicLoadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ResearchDashboardSnapshotsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ResearchDashboardSnapshotsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      averageHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_heart_rate'],
      ),
      averageHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_hrv'],
      ),
      averageConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_confidence'],
      )!,
      escalationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}escalation_count'],
      )!,
      interventionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intervention_count'],
      )!,
      recoveryEfficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_efficiency'],
      )!,
      resilienceScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resilience_score'],
      )!,
      fatigueScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatigue_score'],
      )!,
      activationDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}activation_density'],
      )!,
      baselineStability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}baseline_stability'],
      )!,
      stressCarryover: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stress_carryover'],
      )!,
      improvingTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}improving_trend'],
      )!,
      worseningTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}worsening_trend'],
      )!,
      recoveryTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}recovery_trend'],
      )!,
      confidenceTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confidence_trend'],
      )!,
      circadianStability: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}circadian_stability'],
      )!,
      autonomicLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}autonomic_load'],
      )!,
    );
  }

  @override
  $ResearchDashboardSnapshotsTableTable createAlias(String alias) {
    return $ResearchDashboardSnapshotsTableTable(attachedDatabase, alias);
  }
}

class ResearchDashboardSnapshotsTableData extends DataClass
    implements Insertable<ResearchDashboardSnapshotsTableData> {
  final String id;
  final DateTime generatedAt;
  final double? averageHeartRate;
  final double? averageHrv;
  final double averageConfidence;
  final int escalationCount;
  final int interventionCount;
  final double recoveryEfficiency;
  final int resilienceScore;
  final int fatigueScore;
  final double activationDensity;
  final double baselineStability;
  final double stressCarryover;
  final bool improvingTrend;
  final bool worseningTrend;
  final bool recoveryTrend;
  final bool confidenceTrend;
  final bool circadianStability;
  final double autonomicLoad;
  const ResearchDashboardSnapshotsTableData({
    required this.id,
    required this.generatedAt,
    this.averageHeartRate,
    this.averageHrv,
    required this.averageConfidence,
    required this.escalationCount,
    required this.interventionCount,
    required this.recoveryEfficiency,
    required this.resilienceScore,
    required this.fatigueScore,
    required this.activationDensity,
    required this.baselineStability,
    required this.stressCarryover,
    required this.improvingTrend,
    required this.worseningTrend,
    required this.recoveryTrend,
    required this.confidenceTrend,
    required this.circadianStability,
    required this.autonomicLoad,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    if (!nullToAbsent || averageHeartRate != null) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate);
    }
    if (!nullToAbsent || averageHrv != null) {
      map['average_hrv'] = Variable<double>(averageHrv);
    }
    map['average_confidence'] = Variable<double>(averageConfidence);
    map['escalation_count'] = Variable<int>(escalationCount);
    map['intervention_count'] = Variable<int>(interventionCount);
    map['recovery_efficiency'] = Variable<double>(recoveryEfficiency);
    map['resilience_score'] = Variable<int>(resilienceScore);
    map['fatigue_score'] = Variable<int>(fatigueScore);
    map['activation_density'] = Variable<double>(activationDensity);
    map['baseline_stability'] = Variable<double>(baselineStability);
    map['stress_carryover'] = Variable<double>(stressCarryover);
    map['improving_trend'] = Variable<bool>(improvingTrend);
    map['worsening_trend'] = Variable<bool>(worseningTrend);
    map['recovery_trend'] = Variable<bool>(recoveryTrend);
    map['confidence_trend'] = Variable<bool>(confidenceTrend);
    map['circadian_stability'] = Variable<bool>(circadianStability);
    map['autonomic_load'] = Variable<double>(autonomicLoad);
    return map;
  }

  ResearchDashboardSnapshotsTableCompanion toCompanion(bool nullToAbsent) {
    return ResearchDashboardSnapshotsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      averageHeartRate: averageHeartRate == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHeartRate),
      averageHrv: averageHrv == null && nullToAbsent
          ? const Value.absent()
          : Value(averageHrv),
      averageConfidence: Value(averageConfidence),
      escalationCount: Value(escalationCount),
      interventionCount: Value(interventionCount),
      recoveryEfficiency: Value(recoveryEfficiency),
      resilienceScore: Value(resilienceScore),
      fatigueScore: Value(fatigueScore),
      activationDensity: Value(activationDensity),
      baselineStability: Value(baselineStability),
      stressCarryover: Value(stressCarryover),
      improvingTrend: Value(improvingTrend),
      worseningTrend: Value(worseningTrend),
      recoveryTrend: Value(recoveryTrend),
      confidenceTrend: Value(confidenceTrend),
      circadianStability: Value(circadianStability),
      autonomicLoad: Value(autonomicLoad),
    );
  }

  factory ResearchDashboardSnapshotsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ResearchDashboardSnapshotsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      averageHeartRate: serializer.fromJson<double?>(json['averageHeartRate']),
      averageHrv: serializer.fromJson<double?>(json['averageHrv']),
      averageConfidence: serializer.fromJson<double>(json['averageConfidence']),
      escalationCount: serializer.fromJson<int>(json['escalationCount']),
      interventionCount: serializer.fromJson<int>(json['interventionCount']),
      recoveryEfficiency: serializer.fromJson<double>(
        json['recoveryEfficiency'],
      ),
      resilienceScore: serializer.fromJson<int>(json['resilienceScore']),
      fatigueScore: serializer.fromJson<int>(json['fatigueScore']),
      activationDensity: serializer.fromJson<double>(json['activationDensity']),
      baselineStability: serializer.fromJson<double>(json['baselineStability']),
      stressCarryover: serializer.fromJson<double>(json['stressCarryover']),
      improvingTrend: serializer.fromJson<bool>(json['improvingTrend']),
      worseningTrend: serializer.fromJson<bool>(json['worseningTrend']),
      recoveryTrend: serializer.fromJson<bool>(json['recoveryTrend']),
      confidenceTrend: serializer.fromJson<bool>(json['confidenceTrend']),
      circadianStability: serializer.fromJson<bool>(json['circadianStability']),
      autonomicLoad: serializer.fromJson<double>(json['autonomicLoad']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'averageHeartRate': serializer.toJson<double?>(averageHeartRate),
      'averageHrv': serializer.toJson<double?>(averageHrv),
      'averageConfidence': serializer.toJson<double>(averageConfidence),
      'escalationCount': serializer.toJson<int>(escalationCount),
      'interventionCount': serializer.toJson<int>(interventionCount),
      'recoveryEfficiency': serializer.toJson<double>(recoveryEfficiency),
      'resilienceScore': serializer.toJson<int>(resilienceScore),
      'fatigueScore': serializer.toJson<int>(fatigueScore),
      'activationDensity': serializer.toJson<double>(activationDensity),
      'baselineStability': serializer.toJson<double>(baselineStability),
      'stressCarryover': serializer.toJson<double>(stressCarryover),
      'improvingTrend': serializer.toJson<bool>(improvingTrend),
      'worseningTrend': serializer.toJson<bool>(worseningTrend),
      'recoveryTrend': serializer.toJson<bool>(recoveryTrend),
      'confidenceTrend': serializer.toJson<bool>(confidenceTrend),
      'circadianStability': serializer.toJson<bool>(circadianStability),
      'autonomicLoad': serializer.toJson<double>(autonomicLoad),
    };
  }

  ResearchDashboardSnapshotsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    Value<double?> averageHeartRate = const Value.absent(),
    Value<double?> averageHrv = const Value.absent(),
    double? averageConfidence,
    int? escalationCount,
    int? interventionCount,
    double? recoveryEfficiency,
    int? resilienceScore,
    int? fatigueScore,
    double? activationDensity,
    double? baselineStability,
    double? stressCarryover,
    bool? improvingTrend,
    bool? worseningTrend,
    bool? recoveryTrend,
    bool? confidenceTrend,
    bool? circadianStability,
    double? autonomicLoad,
  }) => ResearchDashboardSnapshotsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    averageHeartRate: averageHeartRate.present
        ? averageHeartRate.value
        : this.averageHeartRate,
    averageHrv: averageHrv.present ? averageHrv.value : this.averageHrv,
    averageConfidence: averageConfidence ?? this.averageConfidence,
    escalationCount: escalationCount ?? this.escalationCount,
    interventionCount: interventionCount ?? this.interventionCount,
    recoveryEfficiency: recoveryEfficiency ?? this.recoveryEfficiency,
    resilienceScore: resilienceScore ?? this.resilienceScore,
    fatigueScore: fatigueScore ?? this.fatigueScore,
    activationDensity: activationDensity ?? this.activationDensity,
    baselineStability: baselineStability ?? this.baselineStability,
    stressCarryover: stressCarryover ?? this.stressCarryover,
    improvingTrend: improvingTrend ?? this.improvingTrend,
    worseningTrend: worseningTrend ?? this.worseningTrend,
    recoveryTrend: recoveryTrend ?? this.recoveryTrend,
    confidenceTrend: confidenceTrend ?? this.confidenceTrend,
    circadianStability: circadianStability ?? this.circadianStability,
    autonomicLoad: autonomicLoad ?? this.autonomicLoad,
  );
  ResearchDashboardSnapshotsTableData copyWithCompanion(
    ResearchDashboardSnapshotsTableCompanion data,
  ) {
    return ResearchDashboardSnapshotsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      averageHeartRate: data.averageHeartRate.present
          ? data.averageHeartRate.value
          : this.averageHeartRate,
      averageHrv: data.averageHrv.present
          ? data.averageHrv.value
          : this.averageHrv,
      averageConfidence: data.averageConfidence.present
          ? data.averageConfidence.value
          : this.averageConfidence,
      escalationCount: data.escalationCount.present
          ? data.escalationCount.value
          : this.escalationCount,
      interventionCount: data.interventionCount.present
          ? data.interventionCount.value
          : this.interventionCount,
      recoveryEfficiency: data.recoveryEfficiency.present
          ? data.recoveryEfficiency.value
          : this.recoveryEfficiency,
      resilienceScore: data.resilienceScore.present
          ? data.resilienceScore.value
          : this.resilienceScore,
      fatigueScore: data.fatigueScore.present
          ? data.fatigueScore.value
          : this.fatigueScore,
      activationDensity: data.activationDensity.present
          ? data.activationDensity.value
          : this.activationDensity,
      baselineStability: data.baselineStability.present
          ? data.baselineStability.value
          : this.baselineStability,
      stressCarryover: data.stressCarryover.present
          ? data.stressCarryover.value
          : this.stressCarryover,
      improvingTrend: data.improvingTrend.present
          ? data.improvingTrend.value
          : this.improvingTrend,
      worseningTrend: data.worseningTrend.present
          ? data.worseningTrend.value
          : this.worseningTrend,
      recoveryTrend: data.recoveryTrend.present
          ? data.recoveryTrend.value
          : this.recoveryTrend,
      confidenceTrend: data.confidenceTrend.present
          ? data.confidenceTrend.value
          : this.confidenceTrend,
      circadianStability: data.circadianStability.present
          ? data.circadianStability.value
          : this.circadianStability,
      autonomicLoad: data.autonomicLoad.present
          ? data.autonomicLoad.value
          : this.autonomicLoad,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ResearchDashboardSnapshotsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('escalationCount: $escalationCount, ')
          ..write('interventionCount: $interventionCount, ')
          ..write('recoveryEfficiency: $recoveryEfficiency, ')
          ..write('resilienceScore: $resilienceScore, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('activationDensity: $activationDensity, ')
          ..write('baselineStability: $baselineStability, ')
          ..write('stressCarryover: $stressCarryover, ')
          ..write('improvingTrend: $improvingTrend, ')
          ..write('worseningTrend: $worseningTrend, ')
          ..write('recoveryTrend: $recoveryTrend, ')
          ..write('confidenceTrend: $confidenceTrend, ')
          ..write('circadianStability: $circadianStability, ')
          ..write('autonomicLoad: $autonomicLoad')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    averageHeartRate,
    averageHrv,
    averageConfidence,
    escalationCount,
    interventionCount,
    recoveryEfficiency,
    resilienceScore,
    fatigueScore,
    activationDensity,
    baselineStability,
    stressCarryover,
    improvingTrend,
    worseningTrend,
    recoveryTrend,
    confidenceTrend,
    circadianStability,
    autonomicLoad,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ResearchDashboardSnapshotsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.averageHeartRate == this.averageHeartRate &&
          other.averageHrv == this.averageHrv &&
          other.averageConfidence == this.averageConfidence &&
          other.escalationCount == this.escalationCount &&
          other.interventionCount == this.interventionCount &&
          other.recoveryEfficiency == this.recoveryEfficiency &&
          other.resilienceScore == this.resilienceScore &&
          other.fatigueScore == this.fatigueScore &&
          other.activationDensity == this.activationDensity &&
          other.baselineStability == this.baselineStability &&
          other.stressCarryover == this.stressCarryover &&
          other.improvingTrend == this.improvingTrend &&
          other.worseningTrend == this.worseningTrend &&
          other.recoveryTrend == this.recoveryTrend &&
          other.confidenceTrend == this.confidenceTrend &&
          other.circadianStability == this.circadianStability &&
          other.autonomicLoad == this.autonomicLoad);
}

class ResearchDashboardSnapshotsTableCompanion
    extends UpdateCompanion<ResearchDashboardSnapshotsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<double?> averageHeartRate;
  final Value<double?> averageHrv;
  final Value<double> averageConfidence;
  final Value<int> escalationCount;
  final Value<int> interventionCount;
  final Value<double> recoveryEfficiency;
  final Value<int> resilienceScore;
  final Value<int> fatigueScore;
  final Value<double> activationDensity;
  final Value<double> baselineStability;
  final Value<double> stressCarryover;
  final Value<bool> improvingTrend;
  final Value<bool> worseningTrend;
  final Value<bool> recoveryTrend;
  final Value<bool> confidenceTrend;
  final Value<bool> circadianStability;
  final Value<double> autonomicLoad;
  final Value<int> rowid;
  const ResearchDashboardSnapshotsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    this.averageConfidence = const Value.absent(),
    this.escalationCount = const Value.absent(),
    this.interventionCount = const Value.absent(),
    this.recoveryEfficiency = const Value.absent(),
    this.resilienceScore = const Value.absent(),
    this.fatigueScore = const Value.absent(),
    this.activationDensity = const Value.absent(),
    this.baselineStability = const Value.absent(),
    this.stressCarryover = const Value.absent(),
    this.improvingTrend = const Value.absent(),
    this.worseningTrend = const Value.absent(),
    this.recoveryTrend = const Value.absent(),
    this.confidenceTrend = const Value.absent(),
    this.circadianStability = const Value.absent(),
    this.autonomicLoad = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResearchDashboardSnapshotsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    this.averageHeartRate = const Value.absent(),
    this.averageHrv = const Value.absent(),
    required double averageConfidence,
    required int escalationCount,
    required int interventionCount,
    required double recoveryEfficiency,
    required int resilienceScore,
    required int fatigueScore,
    required double activationDensity,
    required double baselineStability,
    required double stressCarryover,
    required bool improvingTrend,
    required bool worseningTrend,
    required bool recoveryTrend,
    required bool confidenceTrend,
    required bool circadianStability,
    required double autonomicLoad,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       averageConfidence = Value(averageConfidence),
       escalationCount = Value(escalationCount),
       interventionCount = Value(interventionCount),
       recoveryEfficiency = Value(recoveryEfficiency),
       resilienceScore = Value(resilienceScore),
       fatigueScore = Value(fatigueScore),
       activationDensity = Value(activationDensity),
       baselineStability = Value(baselineStability),
       stressCarryover = Value(stressCarryover),
       improvingTrend = Value(improvingTrend),
       worseningTrend = Value(worseningTrend),
       recoveryTrend = Value(recoveryTrend),
       confidenceTrend = Value(confidenceTrend),
       circadianStability = Value(circadianStability),
       autonomicLoad = Value(autonomicLoad);
  static Insertable<ResearchDashboardSnapshotsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<double>? averageHeartRate,
    Expression<double>? averageHrv,
    Expression<double>? averageConfidence,
    Expression<int>? escalationCount,
    Expression<int>? interventionCount,
    Expression<double>? recoveryEfficiency,
    Expression<int>? resilienceScore,
    Expression<int>? fatigueScore,
    Expression<double>? activationDensity,
    Expression<double>? baselineStability,
    Expression<double>? stressCarryover,
    Expression<bool>? improvingTrend,
    Expression<bool>? worseningTrend,
    Expression<bool>? recoveryTrend,
    Expression<bool>? confidenceTrend,
    Expression<bool>? circadianStability,
    Expression<double>? autonomicLoad,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (averageHeartRate != null) 'average_heart_rate': averageHeartRate,
      if (averageHrv != null) 'average_hrv': averageHrv,
      if (averageConfidence != null) 'average_confidence': averageConfidence,
      if (escalationCount != null) 'escalation_count': escalationCount,
      if (interventionCount != null) 'intervention_count': interventionCount,
      if (recoveryEfficiency != null) 'recovery_efficiency': recoveryEfficiency,
      if (resilienceScore != null) 'resilience_score': resilienceScore,
      if (fatigueScore != null) 'fatigue_score': fatigueScore,
      if (activationDensity != null) 'activation_density': activationDensity,
      if (baselineStability != null) 'baseline_stability': baselineStability,
      if (stressCarryover != null) 'stress_carryover': stressCarryover,
      if (improvingTrend != null) 'improving_trend': improvingTrend,
      if (worseningTrend != null) 'worsening_trend': worseningTrend,
      if (recoveryTrend != null) 'recovery_trend': recoveryTrend,
      if (confidenceTrend != null) 'confidence_trend': confidenceTrend,
      if (circadianStability != null) 'circadian_stability': circadianStability,
      if (autonomicLoad != null) 'autonomic_load': autonomicLoad,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResearchDashboardSnapshotsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<double?>? averageHeartRate,
    Value<double?>? averageHrv,
    Value<double>? averageConfidence,
    Value<int>? escalationCount,
    Value<int>? interventionCount,
    Value<double>? recoveryEfficiency,
    Value<int>? resilienceScore,
    Value<int>? fatigueScore,
    Value<double>? activationDensity,
    Value<double>? baselineStability,
    Value<double>? stressCarryover,
    Value<bool>? improvingTrend,
    Value<bool>? worseningTrend,
    Value<bool>? recoveryTrend,
    Value<bool>? confidenceTrend,
    Value<bool>? circadianStability,
    Value<double>? autonomicLoad,
    Value<int>? rowid,
  }) {
    return ResearchDashboardSnapshotsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      averageHeartRate: averageHeartRate ?? this.averageHeartRate,
      averageHrv: averageHrv ?? this.averageHrv,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      escalationCount: escalationCount ?? this.escalationCount,
      interventionCount: interventionCount ?? this.interventionCount,
      recoveryEfficiency: recoveryEfficiency ?? this.recoveryEfficiency,
      resilienceScore: resilienceScore ?? this.resilienceScore,
      fatigueScore: fatigueScore ?? this.fatigueScore,
      activationDensity: activationDensity ?? this.activationDensity,
      baselineStability: baselineStability ?? this.baselineStability,
      stressCarryover: stressCarryover ?? this.stressCarryover,
      improvingTrend: improvingTrend ?? this.improvingTrend,
      worseningTrend: worseningTrend ?? this.worseningTrend,
      recoveryTrend: recoveryTrend ?? this.recoveryTrend,
      confidenceTrend: confidenceTrend ?? this.confidenceTrend,
      circadianStability: circadianStability ?? this.circadianStability,
      autonomicLoad: autonomicLoad ?? this.autonomicLoad,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (averageHeartRate.present) {
      map['average_heart_rate'] = Variable<double>(averageHeartRate.value);
    }
    if (averageHrv.present) {
      map['average_hrv'] = Variable<double>(averageHrv.value);
    }
    if (averageConfidence.present) {
      map['average_confidence'] = Variable<double>(averageConfidence.value);
    }
    if (escalationCount.present) {
      map['escalation_count'] = Variable<int>(escalationCount.value);
    }
    if (interventionCount.present) {
      map['intervention_count'] = Variable<int>(interventionCount.value);
    }
    if (recoveryEfficiency.present) {
      map['recovery_efficiency'] = Variable<double>(recoveryEfficiency.value);
    }
    if (resilienceScore.present) {
      map['resilience_score'] = Variable<int>(resilienceScore.value);
    }
    if (fatigueScore.present) {
      map['fatigue_score'] = Variable<int>(fatigueScore.value);
    }
    if (activationDensity.present) {
      map['activation_density'] = Variable<double>(activationDensity.value);
    }
    if (baselineStability.present) {
      map['baseline_stability'] = Variable<double>(baselineStability.value);
    }
    if (stressCarryover.present) {
      map['stress_carryover'] = Variable<double>(stressCarryover.value);
    }
    if (improvingTrend.present) {
      map['improving_trend'] = Variable<bool>(improvingTrend.value);
    }
    if (worseningTrend.present) {
      map['worsening_trend'] = Variable<bool>(worseningTrend.value);
    }
    if (recoveryTrend.present) {
      map['recovery_trend'] = Variable<bool>(recoveryTrend.value);
    }
    if (confidenceTrend.present) {
      map['confidence_trend'] = Variable<bool>(confidenceTrend.value);
    }
    if (circadianStability.present) {
      map['circadian_stability'] = Variable<bool>(circadianStability.value);
    }
    if (autonomicLoad.present) {
      map['autonomic_load'] = Variable<double>(autonomicLoad.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResearchDashboardSnapshotsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('averageHeartRate: $averageHeartRate, ')
          ..write('averageHrv: $averageHrv, ')
          ..write('averageConfidence: $averageConfidence, ')
          ..write('escalationCount: $escalationCount, ')
          ..write('interventionCount: $interventionCount, ')
          ..write('recoveryEfficiency: $recoveryEfficiency, ')
          ..write('resilienceScore: $resilienceScore, ')
          ..write('fatigueScore: $fatigueScore, ')
          ..write('activationDensity: $activationDensity, ')
          ..write('baselineStability: $baselineStability, ')
          ..write('stressCarryover: $stressCarryover, ')
          ..write('improvingTrend: $improvingTrend, ')
          ..write('worseningTrend: $worseningTrend, ')
          ..write('recoveryTrend: $recoveryTrend, ')
          ..write('confidenceTrend: $confidenceTrend, ')
          ..write('circadianStability: $circadianStability, ')
          ..write('autonomicLoad: $autonomicLoad, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EscalationForecastsTableTable extends EscalationForecastsTable
    with
        TableInfo<
          $EscalationForecastsTableTable,
          EscalationForecastsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EscalationForecastsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _forecastWindowSecondsMeta =
      const VerificationMeta('forecastWindowSeconds');
  @override
  late final GeneratedColumn<int> forecastWindowSeconds = GeneratedColumn<int>(
    'forecast_window_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _forecastWindowLabelMeta =
      const VerificationMeta('forecastWindowLabel');
  @override
  late final GeneratedColumn<String> forecastWindowLabel =
      GeneratedColumn<String>(
        'forecast_window_label',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _escalationProbabilityMeta =
      const VerificationMeta('escalationProbability');
  @override
  late final GeneratedColumn<double> escalationProbability =
      GeneratedColumn<double>(
        'escalation_probability',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _forecastConfidenceMeta =
      const VerificationMeta('forecastConfidence');
  @override
  late final GeneratedColumn<int> forecastConfidence = GeneratedColumn<int>(
    'forecast_confidence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _forecastConfidenceLevelMeta =
      const VerificationMeta('forecastConfidenceLevel');
  @override
  late final GeneratedColumn<String> forecastConfidenceLevel =
      GeneratedColumn<String>(
        'forecast_confidence_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _escalationRiskLevelMeta =
      const VerificationMeta('escalationRiskLevel');
  @override
  late final GeneratedColumn<String> escalationRiskLevel =
      GeneratedColumn<String>(
        'escalation_risk_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _contributingFactorsJsonMeta =
      const VerificationMeta('contributingFactorsJson');
  @override
  late final GeneratedColumn<String> contributingFactorsJson =
      GeneratedColumn<String>(
        'contributing_factors_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryProtectionMeta =
      const VerificationMeta('recoveryProtection');
  @override
  late final GeneratedColumn<double> recoveryProtection =
      GeneratedColumn<double>(
        'recovery_protection',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _autonomicLoadMeta = const VerificationMeta(
    'autonomicLoad',
  );
  @override
  late final GeneratedColumn<double> autonomicLoad = GeneratedColumn<double>(
    'autonomic_load',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    forecastWindowSeconds,
    forecastWindowLabel,
    escalationProbability,
    forecastConfidence,
    forecastConfidenceLevel,
    escalationRiskLevel,
    contributingFactorsJson,
    recoveryProtection,
    autonomicLoad,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'escalation_forecasts_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<EscalationForecastsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('forecast_window_seconds')) {
      context.handle(
        _forecastWindowSecondsMeta,
        forecastWindowSeconds.isAcceptableOrUnknown(
          data['forecast_window_seconds']!,
          _forecastWindowSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_forecastWindowSecondsMeta);
    }
    if (data.containsKey('forecast_window_label')) {
      context.handle(
        _forecastWindowLabelMeta,
        forecastWindowLabel.isAcceptableOrUnknown(
          data['forecast_window_label']!,
          _forecastWindowLabelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_forecastWindowLabelMeta);
    }
    if (data.containsKey('escalation_probability')) {
      context.handle(
        _escalationProbabilityMeta,
        escalationProbability.isAcceptableOrUnknown(
          data['escalation_probability']!,
          _escalationProbabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationProbabilityMeta);
    }
    if (data.containsKey('forecast_confidence')) {
      context.handle(
        _forecastConfidenceMeta,
        forecastConfidence.isAcceptableOrUnknown(
          data['forecast_confidence']!,
          _forecastConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_forecastConfidenceMeta);
    }
    if (data.containsKey('forecast_confidence_level')) {
      context.handle(
        _forecastConfidenceLevelMeta,
        forecastConfidenceLevel.isAcceptableOrUnknown(
          data['forecast_confidence_level']!,
          _forecastConfidenceLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_forecastConfidenceLevelMeta);
    }
    if (data.containsKey('escalation_risk_level')) {
      context.handle(
        _escalationRiskLevelMeta,
        escalationRiskLevel.isAcceptableOrUnknown(
          data['escalation_risk_level']!,
          _escalationRiskLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationRiskLevelMeta);
    }
    if (data.containsKey('contributing_factors_json')) {
      context.handle(
        _contributingFactorsJsonMeta,
        contributingFactorsJson.isAcceptableOrUnknown(
          data['contributing_factors_json']!,
          _contributingFactorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contributingFactorsJsonMeta);
    }
    if (data.containsKey('recovery_protection')) {
      context.handle(
        _recoveryProtectionMeta,
        recoveryProtection.isAcceptableOrUnknown(
          data['recovery_protection']!,
          _recoveryProtectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryProtectionMeta);
    }
    if (data.containsKey('autonomic_load')) {
      context.handle(
        _autonomicLoadMeta,
        autonomicLoad.isAcceptableOrUnknown(
          data['autonomic_load']!,
          _autonomicLoadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autonomicLoadMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EscalationForecastsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EscalationForecastsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      forecastWindowSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}forecast_window_seconds'],
      )!,
      forecastWindowLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forecast_window_label'],
      )!,
      escalationProbability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}escalation_probability'],
      )!,
      forecastConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}forecast_confidence'],
      )!,
      forecastConfidenceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}forecast_confidence_level'],
      )!,
      escalationRiskLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}escalation_risk_level'],
      )!,
      contributingFactorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contributing_factors_json'],
      )!,
      recoveryProtection: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_protection'],
      )!,
      autonomicLoad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}autonomic_load'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $EscalationForecastsTableTable createAlias(String alias) {
    return $EscalationForecastsTableTable(attachedDatabase, alias);
  }
}

class EscalationForecastsTableData extends DataClass
    implements Insertable<EscalationForecastsTableData> {
  final String id;
  final DateTime generatedAt;
  final int forecastWindowSeconds;
  final String forecastWindowLabel;
  final double escalationProbability;
  final int forecastConfidence;
  final String forecastConfidenceLevel;
  final String escalationRiskLevel;
  final String contributingFactorsJson;
  final double recoveryProtection;
  final double autonomicLoad;
  final String safetyCopy;
  const EscalationForecastsTableData({
    required this.id,
    required this.generatedAt,
    required this.forecastWindowSeconds,
    required this.forecastWindowLabel,
    required this.escalationProbability,
    required this.forecastConfidence,
    required this.forecastConfidenceLevel,
    required this.escalationRiskLevel,
    required this.contributingFactorsJson,
    required this.recoveryProtection,
    required this.autonomicLoad,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['forecast_window_seconds'] = Variable<int>(forecastWindowSeconds);
    map['forecast_window_label'] = Variable<String>(forecastWindowLabel);
    map['escalation_probability'] = Variable<double>(escalationProbability);
    map['forecast_confidence'] = Variable<int>(forecastConfidence);
    map['forecast_confidence_level'] = Variable<String>(
      forecastConfidenceLevel,
    );
    map['escalation_risk_level'] = Variable<String>(escalationRiskLevel);
    map['contributing_factors_json'] = Variable<String>(
      contributingFactorsJson,
    );
    map['recovery_protection'] = Variable<double>(recoveryProtection);
    map['autonomic_load'] = Variable<double>(autonomicLoad);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  EscalationForecastsTableCompanion toCompanion(bool nullToAbsent) {
    return EscalationForecastsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      forecastWindowSeconds: Value(forecastWindowSeconds),
      forecastWindowLabel: Value(forecastWindowLabel),
      escalationProbability: Value(escalationProbability),
      forecastConfidence: Value(forecastConfidence),
      forecastConfidenceLevel: Value(forecastConfidenceLevel),
      escalationRiskLevel: Value(escalationRiskLevel),
      contributingFactorsJson: Value(contributingFactorsJson),
      recoveryProtection: Value(recoveryProtection),
      autonomicLoad: Value(autonomicLoad),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory EscalationForecastsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EscalationForecastsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      forecastWindowSeconds: serializer.fromJson<int>(
        json['forecastWindowSeconds'],
      ),
      forecastWindowLabel: serializer.fromJson<String>(
        json['forecastWindowLabel'],
      ),
      escalationProbability: serializer.fromJson<double>(
        json['escalationProbability'],
      ),
      forecastConfidence: serializer.fromJson<int>(json['forecastConfidence']),
      forecastConfidenceLevel: serializer.fromJson<String>(
        json['forecastConfidenceLevel'],
      ),
      escalationRiskLevel: serializer.fromJson<String>(
        json['escalationRiskLevel'],
      ),
      contributingFactorsJson: serializer.fromJson<String>(
        json['contributingFactorsJson'],
      ),
      recoveryProtection: serializer.fromJson<double>(
        json['recoveryProtection'],
      ),
      autonomicLoad: serializer.fromJson<double>(json['autonomicLoad']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'forecastWindowSeconds': serializer.toJson<int>(forecastWindowSeconds),
      'forecastWindowLabel': serializer.toJson<String>(forecastWindowLabel),
      'escalationProbability': serializer.toJson<double>(escalationProbability),
      'forecastConfidence': serializer.toJson<int>(forecastConfidence),
      'forecastConfidenceLevel': serializer.toJson<String>(
        forecastConfidenceLevel,
      ),
      'escalationRiskLevel': serializer.toJson<String>(escalationRiskLevel),
      'contributingFactorsJson': serializer.toJson<String>(
        contributingFactorsJson,
      ),
      'recoveryProtection': serializer.toJson<double>(recoveryProtection),
      'autonomicLoad': serializer.toJson<double>(autonomicLoad),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  EscalationForecastsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    int? forecastWindowSeconds,
    String? forecastWindowLabel,
    double? escalationProbability,
    int? forecastConfidence,
    String? forecastConfidenceLevel,
    String? escalationRiskLevel,
    String? contributingFactorsJson,
    double? recoveryProtection,
    double? autonomicLoad,
    String? safetyCopy,
  }) => EscalationForecastsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    forecastWindowSeconds: forecastWindowSeconds ?? this.forecastWindowSeconds,
    forecastWindowLabel: forecastWindowLabel ?? this.forecastWindowLabel,
    escalationProbability: escalationProbability ?? this.escalationProbability,
    forecastConfidence: forecastConfidence ?? this.forecastConfidence,
    forecastConfidenceLevel:
        forecastConfidenceLevel ?? this.forecastConfidenceLevel,
    escalationRiskLevel: escalationRiskLevel ?? this.escalationRiskLevel,
    contributingFactorsJson:
        contributingFactorsJson ?? this.contributingFactorsJson,
    recoveryProtection: recoveryProtection ?? this.recoveryProtection,
    autonomicLoad: autonomicLoad ?? this.autonomicLoad,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  EscalationForecastsTableData copyWithCompanion(
    EscalationForecastsTableCompanion data,
  ) {
    return EscalationForecastsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      forecastWindowSeconds: data.forecastWindowSeconds.present
          ? data.forecastWindowSeconds.value
          : this.forecastWindowSeconds,
      forecastWindowLabel: data.forecastWindowLabel.present
          ? data.forecastWindowLabel.value
          : this.forecastWindowLabel,
      escalationProbability: data.escalationProbability.present
          ? data.escalationProbability.value
          : this.escalationProbability,
      forecastConfidence: data.forecastConfidence.present
          ? data.forecastConfidence.value
          : this.forecastConfidence,
      forecastConfidenceLevel: data.forecastConfidenceLevel.present
          ? data.forecastConfidenceLevel.value
          : this.forecastConfidenceLevel,
      escalationRiskLevel: data.escalationRiskLevel.present
          ? data.escalationRiskLevel.value
          : this.escalationRiskLevel,
      contributingFactorsJson: data.contributingFactorsJson.present
          ? data.contributingFactorsJson.value
          : this.contributingFactorsJson,
      recoveryProtection: data.recoveryProtection.present
          ? data.recoveryProtection.value
          : this.recoveryProtection,
      autonomicLoad: data.autonomicLoad.present
          ? data.autonomicLoad.value
          : this.autonomicLoad,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EscalationForecastsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('forecastWindowSeconds: $forecastWindowSeconds, ')
          ..write('forecastWindowLabel: $forecastWindowLabel, ')
          ..write('escalationProbability: $escalationProbability, ')
          ..write('forecastConfidence: $forecastConfidence, ')
          ..write('forecastConfidenceLevel: $forecastConfidenceLevel, ')
          ..write('escalationRiskLevel: $escalationRiskLevel, ')
          ..write('contributingFactorsJson: $contributingFactorsJson, ')
          ..write('recoveryProtection: $recoveryProtection, ')
          ..write('autonomicLoad: $autonomicLoad, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    forecastWindowSeconds,
    forecastWindowLabel,
    escalationProbability,
    forecastConfidence,
    forecastConfidenceLevel,
    escalationRiskLevel,
    contributingFactorsJson,
    recoveryProtection,
    autonomicLoad,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EscalationForecastsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.forecastWindowSeconds == this.forecastWindowSeconds &&
          other.forecastWindowLabel == this.forecastWindowLabel &&
          other.escalationProbability == this.escalationProbability &&
          other.forecastConfidence == this.forecastConfidence &&
          other.forecastConfidenceLevel == this.forecastConfidenceLevel &&
          other.escalationRiskLevel == this.escalationRiskLevel &&
          other.contributingFactorsJson == this.contributingFactorsJson &&
          other.recoveryProtection == this.recoveryProtection &&
          other.autonomicLoad == this.autonomicLoad &&
          other.safetyCopy == this.safetyCopy);
}

class EscalationForecastsTableCompanion
    extends UpdateCompanion<EscalationForecastsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<int> forecastWindowSeconds;
  final Value<String> forecastWindowLabel;
  final Value<double> escalationProbability;
  final Value<int> forecastConfidence;
  final Value<String> forecastConfidenceLevel;
  final Value<String> escalationRiskLevel;
  final Value<String> contributingFactorsJson;
  final Value<double> recoveryProtection;
  final Value<double> autonomicLoad;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const EscalationForecastsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.forecastWindowSeconds = const Value.absent(),
    this.forecastWindowLabel = const Value.absent(),
    this.escalationProbability = const Value.absent(),
    this.forecastConfidence = const Value.absent(),
    this.forecastConfidenceLevel = const Value.absent(),
    this.escalationRiskLevel = const Value.absent(),
    this.contributingFactorsJson = const Value.absent(),
    this.recoveryProtection = const Value.absent(),
    this.autonomicLoad = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EscalationForecastsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required int forecastWindowSeconds,
    required String forecastWindowLabel,
    required double escalationProbability,
    required int forecastConfidence,
    required String forecastConfidenceLevel,
    required String escalationRiskLevel,
    required String contributingFactorsJson,
    required double recoveryProtection,
    required double autonomicLoad,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       forecastWindowSeconds = Value(forecastWindowSeconds),
       forecastWindowLabel = Value(forecastWindowLabel),
       escalationProbability = Value(escalationProbability),
       forecastConfidence = Value(forecastConfidence),
       forecastConfidenceLevel = Value(forecastConfidenceLevel),
       escalationRiskLevel = Value(escalationRiskLevel),
       contributingFactorsJson = Value(contributingFactorsJson),
       recoveryProtection = Value(recoveryProtection),
       autonomicLoad = Value(autonomicLoad),
       safetyCopy = Value(safetyCopy);
  static Insertable<EscalationForecastsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<int>? forecastWindowSeconds,
    Expression<String>? forecastWindowLabel,
    Expression<double>? escalationProbability,
    Expression<int>? forecastConfidence,
    Expression<String>? forecastConfidenceLevel,
    Expression<String>? escalationRiskLevel,
    Expression<String>? contributingFactorsJson,
    Expression<double>? recoveryProtection,
    Expression<double>? autonomicLoad,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (forecastWindowSeconds != null)
        'forecast_window_seconds': forecastWindowSeconds,
      if (forecastWindowLabel != null)
        'forecast_window_label': forecastWindowLabel,
      if (escalationProbability != null)
        'escalation_probability': escalationProbability,
      if (forecastConfidence != null) 'forecast_confidence': forecastConfidence,
      if (forecastConfidenceLevel != null)
        'forecast_confidence_level': forecastConfidenceLevel,
      if (escalationRiskLevel != null)
        'escalation_risk_level': escalationRiskLevel,
      if (contributingFactorsJson != null)
        'contributing_factors_json': contributingFactorsJson,
      if (recoveryProtection != null) 'recovery_protection': recoveryProtection,
      if (autonomicLoad != null) 'autonomic_load': autonomicLoad,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EscalationForecastsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<int>? forecastWindowSeconds,
    Value<String>? forecastWindowLabel,
    Value<double>? escalationProbability,
    Value<int>? forecastConfidence,
    Value<String>? forecastConfidenceLevel,
    Value<String>? escalationRiskLevel,
    Value<String>? contributingFactorsJson,
    Value<double>? recoveryProtection,
    Value<double>? autonomicLoad,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return EscalationForecastsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      forecastWindowSeconds:
          forecastWindowSeconds ?? this.forecastWindowSeconds,
      forecastWindowLabel: forecastWindowLabel ?? this.forecastWindowLabel,
      escalationProbability:
          escalationProbability ?? this.escalationProbability,
      forecastConfidence: forecastConfidence ?? this.forecastConfidence,
      forecastConfidenceLevel:
          forecastConfidenceLevel ?? this.forecastConfidenceLevel,
      escalationRiskLevel: escalationRiskLevel ?? this.escalationRiskLevel,
      contributingFactorsJson:
          contributingFactorsJson ?? this.contributingFactorsJson,
      recoveryProtection: recoveryProtection ?? this.recoveryProtection,
      autonomicLoad: autonomicLoad ?? this.autonomicLoad,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (forecastWindowSeconds.present) {
      map['forecast_window_seconds'] = Variable<int>(
        forecastWindowSeconds.value,
      );
    }
    if (forecastWindowLabel.present) {
      map['forecast_window_label'] = Variable<String>(
        forecastWindowLabel.value,
      );
    }
    if (escalationProbability.present) {
      map['escalation_probability'] = Variable<double>(
        escalationProbability.value,
      );
    }
    if (forecastConfidence.present) {
      map['forecast_confidence'] = Variable<int>(forecastConfidence.value);
    }
    if (forecastConfidenceLevel.present) {
      map['forecast_confidence_level'] = Variable<String>(
        forecastConfidenceLevel.value,
      );
    }
    if (escalationRiskLevel.present) {
      map['escalation_risk_level'] = Variable<String>(
        escalationRiskLevel.value,
      );
    }
    if (contributingFactorsJson.present) {
      map['contributing_factors_json'] = Variable<String>(
        contributingFactorsJson.value,
      );
    }
    if (recoveryProtection.present) {
      map['recovery_protection'] = Variable<double>(recoveryProtection.value);
    }
    if (autonomicLoad.present) {
      map['autonomic_load'] = Variable<double>(autonomicLoad.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EscalationForecastsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('forecastWindowSeconds: $forecastWindowSeconds, ')
          ..write('forecastWindowLabel: $forecastWindowLabel, ')
          ..write('escalationProbability: $escalationProbability, ')
          ..write('forecastConfidence: $forecastConfidence, ')
          ..write('forecastConfidenceLevel: $forecastConfidenceLevel, ')
          ..write('escalationRiskLevel: $escalationRiskLevel, ')
          ..write('contributingFactorsJson: $contributingFactorsJson, ')
          ..write('recoveryProtection: $recoveryProtection, ')
          ..write('autonomicLoad: $autonomicLoad, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextualEventsTableTable extends ContextualEventsTable
    with TableInfo<$ContextualEventsTableTable, ContextualEventsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextualEventsTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
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
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<String> intensity = GeneratedColumn<String>(
    'intensity',
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
    category,
    label,
    description,
    intensity,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contextual_events_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContextualEventsTableData> instance, {
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
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
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    } else if (isInserting) {
      context.missing(_intensityMeta);
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
  ContextualEventsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextualEventsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intensity'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $ContextualEventsTableTable createAlias(String alias) {
    return $ContextualEventsTableTable(attachedDatabase, alias);
  }
}

class ContextualEventsTableData extends DataClass
    implements Insertable<ContextualEventsTableData> {
  final String id;
  final DateTime timestamp;
  final String category;
  final String label;
  final String description;
  final String intensity;
  final String source;
  const ContextualEventsTableData({
    required this.id,
    required this.timestamp,
    required this.category,
    required this.label,
    required this.description,
    required this.intensity,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['category'] = Variable<String>(category);
    map['label'] = Variable<String>(label);
    map['description'] = Variable<String>(description);
    map['intensity'] = Variable<String>(intensity);
    map['source'] = Variable<String>(source);
    return map;
  }

  ContextualEventsTableCompanion toCompanion(bool nullToAbsent) {
    return ContextualEventsTableCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
      category: Value(category),
      label: Value(label),
      description: Value(description),
      intensity: Value(intensity),
      source: Value(source),
    );
  }

  factory ContextualEventsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextualEventsTableData(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      category: serializer.fromJson<String>(json['category']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String>(json['description']),
      intensity: serializer.fromJson<String>(json['intensity']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'category': serializer.toJson<String>(category),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String>(description),
      'intensity': serializer.toJson<String>(intensity),
      'source': serializer.toJson<String>(source),
    };
  }

  ContextualEventsTableData copyWith({
    String? id,
    DateTime? timestamp,
    String? category,
    String? label,
    String? description,
    String? intensity,
    String? source,
  }) => ContextualEventsTableData(
    id: id ?? this.id,
    timestamp: timestamp ?? this.timestamp,
    category: category ?? this.category,
    label: label ?? this.label,
    description: description ?? this.description,
    intensity: intensity ?? this.intensity,
    source: source ?? this.source,
  );
  ContextualEventsTableData copyWithCompanion(
    ContextualEventsTableCompanion data,
  ) {
    return ContextualEventsTableData(
      id: data.id.present ? data.id.value : this.id,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextualEventsTableData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('intensity: $intensity, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    timestamp,
    category,
    label,
    description,
    intensity,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextualEventsTableData &&
          other.id == this.id &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.label == this.label &&
          other.description == this.description &&
          other.intensity == this.intensity &&
          other.source == this.source);
}

class ContextualEventsTableCompanion
    extends UpdateCompanion<ContextualEventsTableData> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<String> category;
  final Value<String> label;
  final Value<String> description;
  final Value<String> intensity;
  final Value<String> source;
  final Value<int> rowid;
  const ContextualEventsTableCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.intensity = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextualEventsTableCompanion.insert({
    required String id,
    required DateTime timestamp,
    required String category,
    required String label,
    required String description,
    required String intensity,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       timestamp = Value(timestamp),
       category = Value(category),
       label = Value(label),
       description = Value(description),
       intensity = Value(intensity),
       source = Value(source);
  static Insertable<ContextualEventsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<String>? category,
    Expression<String>? label,
    Expression<String>? description,
    Expression<String>? intensity,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (intensity != null) 'intensity': intensity,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextualEventsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? timestamp,
    Value<String>? category,
    Value<String>? label,
    Value<String>? description,
    Value<String>? intensity,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return ContextualEventsTableCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      label: label ?? this.label,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
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
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<String>(intensity.value);
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
    return (StringBuffer('ContextualEventsTableCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('intensity: $intensity, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextualTriggerCorrelationsTableTable
    extends ContextualTriggerCorrelationsTable
    with
        TableInfo<
          $ContextualTriggerCorrelationsTableTable,
          ContextualTriggerCorrelationsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextualTriggerCorrelationsTableTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceCountMeta = const VerificationMeta(
    'occurrenceCount',
  );
  @override
  late final GeneratedColumn<int> occurrenceCount = GeneratedColumn<int>(
    'occurrence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _escalationCorrelationMeta =
      const VerificationMeta('escalationCorrelation');
  @override
  late final GeneratedColumn<double> escalationCorrelation =
      GeneratedColumn<double>(
        'escalation_correlation',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryImpactMeta = const VerificationMeta(
    'recoveryImpact',
  );
  @override
  late final GeneratedColumn<double> recoveryImpact = GeneratedColumn<double>(
    'recovery_impact',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOccurrenceMeta = const VerificationMeta(
    'lastOccurrence',
  );
  @override
  late final GeneratedColumn<DateTime> lastOccurrence =
      GeneratedColumn<DateTime>(
        'last_occurrence',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _associatedMarkersJsonMeta =
      const VerificationMeta('associatedMarkersJson');
  @override
  late final GeneratedColumn<String> associatedMarkersJson =
      GeneratedColumn<String>(
        'associated_markers_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    category,
    occurrenceCount,
    escalationCorrelation,
    recoveryImpact,
    confidence,
    lastOccurrence,
    associatedMarkersJson,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contextual_trigger_correlations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContextualTriggerCorrelationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('occurrence_count')) {
      context.handle(
        _occurrenceCountMeta,
        occurrenceCount.isAcceptableOrUnknown(
          data['occurrence_count']!,
          _occurrenceCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceCountMeta);
    }
    if (data.containsKey('escalation_correlation')) {
      context.handle(
        _escalationCorrelationMeta,
        escalationCorrelation.isAcceptableOrUnknown(
          data['escalation_correlation']!,
          _escalationCorrelationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationCorrelationMeta);
    }
    if (data.containsKey('recovery_impact')) {
      context.handle(
        _recoveryImpactMeta,
        recoveryImpact.isAcceptableOrUnknown(
          data['recovery_impact']!,
          _recoveryImpactMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryImpactMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('last_occurrence')) {
      context.handle(
        _lastOccurrenceMeta,
        lastOccurrence.isAcceptableOrUnknown(
          data['last_occurrence']!,
          _lastOccurrenceMeta,
        ),
      );
    }
    if (data.containsKey('associated_markers_json')) {
      context.handle(
        _associatedMarkersJsonMeta,
        associatedMarkersJson.isAcceptableOrUnknown(
          data['associated_markers_json']!,
          _associatedMarkersJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_associatedMarkersJsonMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextualTriggerCorrelationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextualTriggerCorrelationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      occurrenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurrence_count'],
      )!,
      escalationCorrelation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}escalation_correlation'],
      )!,
      recoveryImpact: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_impact'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      lastOccurrence: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_occurrence'],
      ),
      associatedMarkersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}associated_markers_json'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $ContextualTriggerCorrelationsTableTable createAlias(String alias) {
    return $ContextualTriggerCorrelationsTableTable(attachedDatabase, alias);
  }
}

class ContextualTriggerCorrelationsTableData extends DataClass
    implements Insertable<ContextualTriggerCorrelationsTableData> {
  final String id;
  final DateTime generatedAt;
  final String category;
  final int occurrenceCount;
  final double escalationCorrelation;
  final double recoveryImpact;
  final double confidence;
  final DateTime? lastOccurrence;
  final String associatedMarkersJson;
  final String safetyCopy;
  const ContextualTriggerCorrelationsTableData({
    required this.id,
    required this.generatedAt,
    required this.category,
    required this.occurrenceCount,
    required this.escalationCorrelation,
    required this.recoveryImpact,
    required this.confidence,
    this.lastOccurrence,
    required this.associatedMarkersJson,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['category'] = Variable<String>(category);
    map['occurrence_count'] = Variable<int>(occurrenceCount);
    map['escalation_correlation'] = Variable<double>(escalationCorrelation);
    map['recovery_impact'] = Variable<double>(recoveryImpact);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || lastOccurrence != null) {
      map['last_occurrence'] = Variable<DateTime>(lastOccurrence);
    }
    map['associated_markers_json'] = Variable<String>(associatedMarkersJson);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  ContextualTriggerCorrelationsTableCompanion toCompanion(bool nullToAbsent) {
    return ContextualTriggerCorrelationsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      category: Value(category),
      occurrenceCount: Value(occurrenceCount),
      escalationCorrelation: Value(escalationCorrelation),
      recoveryImpact: Value(recoveryImpact),
      confidence: Value(confidence),
      lastOccurrence: lastOccurrence == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOccurrence),
      associatedMarkersJson: Value(associatedMarkersJson),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory ContextualTriggerCorrelationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextualTriggerCorrelationsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      category: serializer.fromJson<String>(json['category']),
      occurrenceCount: serializer.fromJson<int>(json['occurrenceCount']),
      escalationCorrelation: serializer.fromJson<double>(
        json['escalationCorrelation'],
      ),
      recoveryImpact: serializer.fromJson<double>(json['recoveryImpact']),
      confidence: serializer.fromJson<double>(json['confidence']),
      lastOccurrence: serializer.fromJson<DateTime?>(json['lastOccurrence']),
      associatedMarkersJson: serializer.fromJson<String>(
        json['associatedMarkersJson'],
      ),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'category': serializer.toJson<String>(category),
      'occurrenceCount': serializer.toJson<int>(occurrenceCount),
      'escalationCorrelation': serializer.toJson<double>(escalationCorrelation),
      'recoveryImpact': serializer.toJson<double>(recoveryImpact),
      'confidence': serializer.toJson<double>(confidence),
      'lastOccurrence': serializer.toJson<DateTime?>(lastOccurrence),
      'associatedMarkersJson': serializer.toJson<String>(associatedMarkersJson),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  ContextualTriggerCorrelationsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    String? category,
    int? occurrenceCount,
    double? escalationCorrelation,
    double? recoveryImpact,
    double? confidence,
    Value<DateTime?> lastOccurrence = const Value.absent(),
    String? associatedMarkersJson,
    String? safetyCopy,
  }) => ContextualTriggerCorrelationsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    category: category ?? this.category,
    occurrenceCount: occurrenceCount ?? this.occurrenceCount,
    escalationCorrelation: escalationCorrelation ?? this.escalationCorrelation,
    recoveryImpact: recoveryImpact ?? this.recoveryImpact,
    confidence: confidence ?? this.confidence,
    lastOccurrence: lastOccurrence.present
        ? lastOccurrence.value
        : this.lastOccurrence,
    associatedMarkersJson: associatedMarkersJson ?? this.associatedMarkersJson,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  ContextualTriggerCorrelationsTableData copyWithCompanion(
    ContextualTriggerCorrelationsTableCompanion data,
  ) {
    return ContextualTriggerCorrelationsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      category: data.category.present ? data.category.value : this.category,
      occurrenceCount: data.occurrenceCount.present
          ? data.occurrenceCount.value
          : this.occurrenceCount,
      escalationCorrelation: data.escalationCorrelation.present
          ? data.escalationCorrelation.value
          : this.escalationCorrelation,
      recoveryImpact: data.recoveryImpact.present
          ? data.recoveryImpact.value
          : this.recoveryImpact,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      lastOccurrence: data.lastOccurrence.present
          ? data.lastOccurrence.value
          : this.lastOccurrence,
      associatedMarkersJson: data.associatedMarkersJson.present
          ? data.associatedMarkersJson.value
          : this.associatedMarkersJson,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextualTriggerCorrelationsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('category: $category, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('escalationCorrelation: $escalationCorrelation, ')
          ..write('recoveryImpact: $recoveryImpact, ')
          ..write('confidence: $confidence, ')
          ..write('lastOccurrence: $lastOccurrence, ')
          ..write('associatedMarkersJson: $associatedMarkersJson, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    category,
    occurrenceCount,
    escalationCorrelation,
    recoveryImpact,
    confidence,
    lastOccurrence,
    associatedMarkersJson,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextualTriggerCorrelationsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.category == this.category &&
          other.occurrenceCount == this.occurrenceCount &&
          other.escalationCorrelation == this.escalationCorrelation &&
          other.recoveryImpact == this.recoveryImpact &&
          other.confidence == this.confidence &&
          other.lastOccurrence == this.lastOccurrence &&
          other.associatedMarkersJson == this.associatedMarkersJson &&
          other.safetyCopy == this.safetyCopy);
}

class ContextualTriggerCorrelationsTableCompanion
    extends UpdateCompanion<ContextualTriggerCorrelationsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<String> category;
  final Value<int> occurrenceCount;
  final Value<double> escalationCorrelation;
  final Value<double> recoveryImpact;
  final Value<double> confidence;
  final Value<DateTime?> lastOccurrence;
  final Value<String> associatedMarkersJson;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const ContextualTriggerCorrelationsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.occurrenceCount = const Value.absent(),
    this.escalationCorrelation = const Value.absent(),
    this.recoveryImpact = const Value.absent(),
    this.confidence = const Value.absent(),
    this.lastOccurrence = const Value.absent(),
    this.associatedMarkersJson = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextualTriggerCorrelationsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required String category,
    required int occurrenceCount,
    required double escalationCorrelation,
    required double recoveryImpact,
    required double confidence,
    this.lastOccurrence = const Value.absent(),
    required String associatedMarkersJson,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       category = Value(category),
       occurrenceCount = Value(occurrenceCount),
       escalationCorrelation = Value(escalationCorrelation),
       recoveryImpact = Value(recoveryImpact),
       confidence = Value(confidence),
       associatedMarkersJson = Value(associatedMarkersJson),
       safetyCopy = Value(safetyCopy);
  static Insertable<ContextualTriggerCorrelationsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<String>? category,
    Expression<int>? occurrenceCount,
    Expression<double>? escalationCorrelation,
    Expression<double>? recoveryImpact,
    Expression<double>? confidence,
    Expression<DateTime>? lastOccurrence,
    Expression<String>? associatedMarkersJson,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (category != null) 'category': category,
      if (occurrenceCount != null) 'occurrence_count': occurrenceCount,
      if (escalationCorrelation != null)
        'escalation_correlation': escalationCorrelation,
      if (recoveryImpact != null) 'recovery_impact': recoveryImpact,
      if (confidence != null) 'confidence': confidence,
      if (lastOccurrence != null) 'last_occurrence': lastOccurrence,
      if (associatedMarkersJson != null)
        'associated_markers_json': associatedMarkersJson,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextualTriggerCorrelationsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<String>? category,
    Value<int>? occurrenceCount,
    Value<double>? escalationCorrelation,
    Value<double>? recoveryImpact,
    Value<double>? confidence,
    Value<DateTime?>? lastOccurrence,
    Value<String>? associatedMarkersJson,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return ContextualTriggerCorrelationsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      category: category ?? this.category,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      escalationCorrelation:
          escalationCorrelation ?? this.escalationCorrelation,
      recoveryImpact: recoveryImpact ?? this.recoveryImpact,
      confidence: confidence ?? this.confidence,
      lastOccurrence: lastOccurrence ?? this.lastOccurrence,
      associatedMarkersJson:
          associatedMarkersJson ?? this.associatedMarkersJson,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (occurrenceCount.present) {
      map['occurrence_count'] = Variable<int>(occurrenceCount.value);
    }
    if (escalationCorrelation.present) {
      map['escalation_correlation'] = Variable<double>(
        escalationCorrelation.value,
      );
    }
    if (recoveryImpact.present) {
      map['recovery_impact'] = Variable<double>(recoveryImpact.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (lastOccurrence.present) {
      map['last_occurrence'] = Variable<DateTime>(lastOccurrence.value);
    }
    if (associatedMarkersJson.present) {
      map['associated_markers_json'] = Variable<String>(
        associatedMarkersJson.value,
      );
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextualTriggerCorrelationsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('category: $category, ')
          ..write('occurrenceCount: $occurrenceCount, ')
          ..write('escalationCorrelation: $escalationCorrelation, ')
          ..write('recoveryImpact: $recoveryImpact, ')
          ..write('confidence: $confidence, ')
          ..write('lastOccurrence: $lastOccurrence, ')
          ..write('associatedMarkersJson: $associatedMarkersJson, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterventionLearningProfilesTableTable
    extends InterventionLearningProfilesTable
    with
        TableInfo<
          $InterventionLearningProfilesTableTable,
          InterventionLearningProfilesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterventionLearningProfilesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _interventionTypeMeta = const VerificationMeta(
    'interventionType',
  );
  @override
  late final GeneratedColumn<String> interventionType = GeneratedColumn<String>(
    'intervention_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successRateMeta = const VerificationMeta(
    'successRate',
  );
  @override
  late final GeneratedColumn<double> successRate = GeneratedColumn<double>(
    'success_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageRecoveryTimeSecondsMeta =
      const VerificationMeta('averageRecoveryTimeSeconds');
  @override
  late final GeneratedColumn<int> averageRecoveryTimeSeconds =
      GeneratedColumn<int>(
        'average_recovery_time_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _averageRecoveryImprovementMeta =
      const VerificationMeta('averageRecoveryImprovement');
  @override
  late final GeneratedColumn<double> averageRecoveryImprovement =
      GeneratedColumn<double>(
        'average_recovery_improvement',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _contextualPerformanceJsonMeta =
      const VerificationMeta('contextualPerformanceJson');
  @override
  late final GeneratedColumn<String> contextualPerformanceJson =
      GeneratedColumn<String>(
        'contextual_performance_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _circadianPerformanceJsonMeta =
      const VerificationMeta('circadianPerformanceJson');
  @override
  late final GeneratedColumn<String> circadianPerformanceJson =
      GeneratedColumn<String>(
        'circadian_performance_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usageCountMeta = const VerificationMeta(
    'usageCount',
  );
  @override
  late final GeneratedColumn<int> usageCount = GeneratedColumn<int>(
    'usage_count',
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
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    interventionType,
    successRate,
    averageRecoveryTimeSeconds,
    averageRecoveryImprovement,
    contextualPerformanceJson,
    circadianPerformanceJson,
    confidence,
    usageCount,
    updatedAt,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervention_learning_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterventionLearningProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('intervention_type')) {
      context.handle(
        _interventionTypeMeta,
        interventionType.isAcceptableOrUnknown(
          data['intervention_type']!,
          _interventionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interventionTypeMeta);
    }
    if (data.containsKey('success_rate')) {
      context.handle(
        _successRateMeta,
        successRate.isAcceptableOrUnknown(
          data['success_rate']!,
          _successRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_successRateMeta);
    }
    if (data.containsKey('average_recovery_time_seconds')) {
      context.handle(
        _averageRecoveryTimeSecondsMeta,
        averageRecoveryTimeSeconds.isAcceptableOrUnknown(
          data['average_recovery_time_seconds']!,
          _averageRecoveryTimeSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageRecoveryTimeSecondsMeta);
    }
    if (data.containsKey('average_recovery_improvement')) {
      context.handle(
        _averageRecoveryImprovementMeta,
        averageRecoveryImprovement.isAcceptableOrUnknown(
          data['average_recovery_improvement']!,
          _averageRecoveryImprovementMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageRecoveryImprovementMeta);
    }
    if (data.containsKey('contextual_performance_json')) {
      context.handle(
        _contextualPerformanceJsonMeta,
        contextualPerformanceJson.isAcceptableOrUnknown(
          data['contextual_performance_json']!,
          _contextualPerformanceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextualPerformanceJsonMeta);
    }
    if (data.containsKey('circadian_performance_json')) {
      context.handle(
        _circadianPerformanceJsonMeta,
        circadianPerformanceJson.isAcceptableOrUnknown(
          data['circadian_performance_json']!,
          _circadianPerformanceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_circadianPerformanceJsonMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('usage_count')) {
      context.handle(
        _usageCountMeta,
        usageCount.isAcceptableOrUnknown(data['usage_count']!, _usageCountMeta),
      );
    } else if (isInserting) {
      context.missing(_usageCountMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {interventionType};
  @override
  InterventionLearningProfilesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterventionLearningProfilesTableData(
      interventionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervention_type'],
      )!,
      successRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}success_rate'],
      )!,
      averageRecoveryTimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}average_recovery_time_seconds'],
      )!,
      averageRecoveryImprovement: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_recovery_improvement'],
      )!,
      contextualPerformanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contextual_performance_json'],
      )!,
      circadianPerformanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circadian_performance_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      usageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $InterventionLearningProfilesTableTable createAlias(String alias) {
    return $InterventionLearningProfilesTableTable(attachedDatabase, alias);
  }
}

class InterventionLearningProfilesTableData extends DataClass
    implements Insertable<InterventionLearningProfilesTableData> {
  final String interventionType;
  final double successRate;
  final int averageRecoveryTimeSeconds;
  final double averageRecoveryImprovement;
  final String contextualPerformanceJson;
  final String circadianPerformanceJson;
  final double confidence;
  final int usageCount;
  final DateTime updatedAt;
  final String safetyCopy;
  const InterventionLearningProfilesTableData({
    required this.interventionType,
    required this.successRate,
    required this.averageRecoveryTimeSeconds,
    required this.averageRecoveryImprovement,
    required this.contextualPerformanceJson,
    required this.circadianPerformanceJson,
    required this.confidence,
    required this.usageCount,
    required this.updatedAt,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['intervention_type'] = Variable<String>(interventionType);
    map['success_rate'] = Variable<double>(successRate);
    map['average_recovery_time_seconds'] = Variable<int>(
      averageRecoveryTimeSeconds,
    );
    map['average_recovery_improvement'] = Variable<double>(
      averageRecoveryImprovement,
    );
    map['contextual_performance_json'] = Variable<String>(
      contextualPerformanceJson,
    );
    map['circadian_performance_json'] = Variable<String>(
      circadianPerformanceJson,
    );
    map['confidence'] = Variable<double>(confidence);
    map['usage_count'] = Variable<int>(usageCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  InterventionLearningProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return InterventionLearningProfilesTableCompanion(
      interventionType: Value(interventionType),
      successRate: Value(successRate),
      averageRecoveryTimeSeconds: Value(averageRecoveryTimeSeconds),
      averageRecoveryImprovement: Value(averageRecoveryImprovement),
      contextualPerformanceJson: Value(contextualPerformanceJson),
      circadianPerformanceJson: Value(circadianPerformanceJson),
      confidence: Value(confidence),
      usageCount: Value(usageCount),
      updatedAt: Value(updatedAt),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory InterventionLearningProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterventionLearningProfilesTableData(
      interventionType: serializer.fromJson<String>(json['interventionType']),
      successRate: serializer.fromJson<double>(json['successRate']),
      averageRecoveryTimeSeconds: serializer.fromJson<int>(
        json['averageRecoveryTimeSeconds'],
      ),
      averageRecoveryImprovement: serializer.fromJson<double>(
        json['averageRecoveryImprovement'],
      ),
      contextualPerformanceJson: serializer.fromJson<String>(
        json['contextualPerformanceJson'],
      ),
      circadianPerformanceJson: serializer.fromJson<String>(
        json['circadianPerformanceJson'],
      ),
      confidence: serializer.fromJson<double>(json['confidence']),
      usageCount: serializer.fromJson<int>(json['usageCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'interventionType': serializer.toJson<String>(interventionType),
      'successRate': serializer.toJson<double>(successRate),
      'averageRecoveryTimeSeconds': serializer.toJson<int>(
        averageRecoveryTimeSeconds,
      ),
      'averageRecoveryImprovement': serializer.toJson<double>(
        averageRecoveryImprovement,
      ),
      'contextualPerformanceJson': serializer.toJson<String>(
        contextualPerformanceJson,
      ),
      'circadianPerformanceJson': serializer.toJson<String>(
        circadianPerformanceJson,
      ),
      'confidence': serializer.toJson<double>(confidence),
      'usageCount': serializer.toJson<int>(usageCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  InterventionLearningProfilesTableData copyWith({
    String? interventionType,
    double? successRate,
    int? averageRecoveryTimeSeconds,
    double? averageRecoveryImprovement,
    String? contextualPerformanceJson,
    String? circadianPerformanceJson,
    double? confidence,
    int? usageCount,
    DateTime? updatedAt,
    String? safetyCopy,
  }) => InterventionLearningProfilesTableData(
    interventionType: interventionType ?? this.interventionType,
    successRate: successRate ?? this.successRate,
    averageRecoveryTimeSeconds:
        averageRecoveryTimeSeconds ?? this.averageRecoveryTimeSeconds,
    averageRecoveryImprovement:
        averageRecoveryImprovement ?? this.averageRecoveryImprovement,
    contextualPerformanceJson:
        contextualPerformanceJson ?? this.contextualPerformanceJson,
    circadianPerformanceJson:
        circadianPerformanceJson ?? this.circadianPerformanceJson,
    confidence: confidence ?? this.confidence,
    usageCount: usageCount ?? this.usageCount,
    updatedAt: updatedAt ?? this.updatedAt,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  InterventionLearningProfilesTableData copyWithCompanion(
    InterventionLearningProfilesTableCompanion data,
  ) {
    return InterventionLearningProfilesTableData(
      interventionType: data.interventionType.present
          ? data.interventionType.value
          : this.interventionType,
      successRate: data.successRate.present
          ? data.successRate.value
          : this.successRate,
      averageRecoveryTimeSeconds: data.averageRecoveryTimeSeconds.present
          ? data.averageRecoveryTimeSeconds.value
          : this.averageRecoveryTimeSeconds,
      averageRecoveryImprovement: data.averageRecoveryImprovement.present
          ? data.averageRecoveryImprovement.value
          : this.averageRecoveryImprovement,
      contextualPerformanceJson: data.contextualPerformanceJson.present
          ? data.contextualPerformanceJson.value
          : this.contextualPerformanceJson,
      circadianPerformanceJson: data.circadianPerformanceJson.present
          ? data.circadianPerformanceJson.value
          : this.circadianPerformanceJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      usageCount: data.usageCount.present
          ? data.usageCount.value
          : this.usageCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterventionLearningProfilesTableData(')
          ..write('interventionType: $interventionType, ')
          ..write('successRate: $successRate, ')
          ..write('averageRecoveryTimeSeconds: $averageRecoveryTimeSeconds, ')
          ..write('averageRecoveryImprovement: $averageRecoveryImprovement, ')
          ..write('contextualPerformanceJson: $contextualPerformanceJson, ')
          ..write('circadianPerformanceJson: $circadianPerformanceJson, ')
          ..write('confidence: $confidence, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    interventionType,
    successRate,
    averageRecoveryTimeSeconds,
    averageRecoveryImprovement,
    contextualPerformanceJson,
    circadianPerformanceJson,
    confidence,
    usageCount,
    updatedAt,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterventionLearningProfilesTableData &&
          other.interventionType == this.interventionType &&
          other.successRate == this.successRate &&
          other.averageRecoveryTimeSeconds == this.averageRecoveryTimeSeconds &&
          other.averageRecoveryImprovement == this.averageRecoveryImprovement &&
          other.contextualPerformanceJson == this.contextualPerformanceJson &&
          other.circadianPerformanceJson == this.circadianPerformanceJson &&
          other.confidence == this.confidence &&
          other.usageCount == this.usageCount &&
          other.updatedAt == this.updatedAt &&
          other.safetyCopy == this.safetyCopy);
}

class InterventionLearningProfilesTableCompanion
    extends UpdateCompanion<InterventionLearningProfilesTableData> {
  final Value<String> interventionType;
  final Value<double> successRate;
  final Value<int> averageRecoveryTimeSeconds;
  final Value<double> averageRecoveryImprovement;
  final Value<String> contextualPerformanceJson;
  final Value<String> circadianPerformanceJson;
  final Value<double> confidence;
  final Value<int> usageCount;
  final Value<DateTime> updatedAt;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const InterventionLearningProfilesTableCompanion({
    this.interventionType = const Value.absent(),
    this.successRate = const Value.absent(),
    this.averageRecoveryTimeSeconds = const Value.absent(),
    this.averageRecoveryImprovement = const Value.absent(),
    this.contextualPerformanceJson = const Value.absent(),
    this.circadianPerformanceJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.usageCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterventionLearningProfilesTableCompanion.insert({
    required String interventionType,
    required double successRate,
    required int averageRecoveryTimeSeconds,
    required double averageRecoveryImprovement,
    required String contextualPerformanceJson,
    required String circadianPerformanceJson,
    required double confidence,
    required int usageCount,
    required DateTime updatedAt,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : interventionType = Value(interventionType),
       successRate = Value(successRate),
       averageRecoveryTimeSeconds = Value(averageRecoveryTimeSeconds),
       averageRecoveryImprovement = Value(averageRecoveryImprovement),
       contextualPerformanceJson = Value(contextualPerformanceJson),
       circadianPerformanceJson = Value(circadianPerformanceJson),
       confidence = Value(confidence),
       usageCount = Value(usageCount),
       updatedAt = Value(updatedAt),
       safetyCopy = Value(safetyCopy);
  static Insertable<InterventionLearningProfilesTableData> custom({
    Expression<String>? interventionType,
    Expression<double>? successRate,
    Expression<int>? averageRecoveryTimeSeconds,
    Expression<double>? averageRecoveryImprovement,
    Expression<String>? contextualPerformanceJson,
    Expression<String>? circadianPerformanceJson,
    Expression<double>? confidence,
    Expression<int>? usageCount,
    Expression<DateTime>? updatedAt,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (interventionType != null) 'intervention_type': interventionType,
      if (successRate != null) 'success_rate': successRate,
      if (averageRecoveryTimeSeconds != null)
        'average_recovery_time_seconds': averageRecoveryTimeSeconds,
      if (averageRecoveryImprovement != null)
        'average_recovery_improvement': averageRecoveryImprovement,
      if (contextualPerformanceJson != null)
        'contextual_performance_json': contextualPerformanceJson,
      if (circadianPerformanceJson != null)
        'circadian_performance_json': circadianPerformanceJson,
      if (confidence != null) 'confidence': confidence,
      if (usageCount != null) 'usage_count': usageCount,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterventionLearningProfilesTableCompanion copyWith({
    Value<String>? interventionType,
    Value<double>? successRate,
    Value<int>? averageRecoveryTimeSeconds,
    Value<double>? averageRecoveryImprovement,
    Value<String>? contextualPerformanceJson,
    Value<String>? circadianPerformanceJson,
    Value<double>? confidence,
    Value<int>? usageCount,
    Value<DateTime>? updatedAt,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return InterventionLearningProfilesTableCompanion(
      interventionType: interventionType ?? this.interventionType,
      successRate: successRate ?? this.successRate,
      averageRecoveryTimeSeconds:
          averageRecoveryTimeSeconds ?? this.averageRecoveryTimeSeconds,
      averageRecoveryImprovement:
          averageRecoveryImprovement ?? this.averageRecoveryImprovement,
      contextualPerformanceJson:
          contextualPerformanceJson ?? this.contextualPerformanceJson,
      circadianPerformanceJson:
          circadianPerformanceJson ?? this.circadianPerformanceJson,
      confidence: confidence ?? this.confidence,
      usageCount: usageCount ?? this.usageCount,
      updatedAt: updatedAt ?? this.updatedAt,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (interventionType.present) {
      map['intervention_type'] = Variable<String>(interventionType.value);
    }
    if (successRate.present) {
      map['success_rate'] = Variable<double>(successRate.value);
    }
    if (averageRecoveryTimeSeconds.present) {
      map['average_recovery_time_seconds'] = Variable<int>(
        averageRecoveryTimeSeconds.value,
      );
    }
    if (averageRecoveryImprovement.present) {
      map['average_recovery_improvement'] = Variable<double>(
        averageRecoveryImprovement.value,
      );
    }
    if (contextualPerformanceJson.present) {
      map['contextual_performance_json'] = Variable<String>(
        contextualPerformanceJson.value,
      );
    }
    if (circadianPerformanceJson.present) {
      map['circadian_performance_json'] = Variable<String>(
        circadianPerformanceJson.value,
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (usageCount.present) {
      map['usage_count'] = Variable<int>(usageCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterventionLearningProfilesTableCompanion(')
          ..write('interventionType: $interventionType, ')
          ..write('successRate: $successRate, ')
          ..write('averageRecoveryTimeSeconds: $averageRecoveryTimeSeconds, ')
          ..write('averageRecoveryImprovement: $averageRecoveryImprovement, ')
          ..write('contextualPerformanceJson: $contextualPerformanceJson, ')
          ..write('circadianPerformanceJson: $circadianPerformanceJson, ')
          ..write('confidence: $confidence, ')
          ..write('usageCount: $usageCount, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContextualInterventionRecommendationsTableTable
    extends ContextualInterventionRecommendationsTable
    with
        TableInfo<
          $ContextualInterventionRecommendationsTableTable,
          ContextualInterventionRecommendationsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContextualInterventionRecommendationsTableTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _interventionTypeMeta = const VerificationMeta(
    'interventionType',
  );
  @override
  late final GeneratedColumn<String> interventionType = GeneratedColumn<String>(
    'intervention_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recommendationScoreMeta =
      const VerificationMeta('recommendationScore');
  @override
  late final GeneratedColumn<double> recommendationScore =
      GeneratedColumn<double>(
        'recommendation_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _expectedRecoveryBenefitMeta =
      const VerificationMeta('expectedRecoveryBenefit');
  @override
  late final GeneratedColumn<double> expectedRecoveryBenefit =
      GeneratedColumn<double>(
        'expected_recovery_benefit',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextualFactorsJsonMeta =
      const VerificationMeta('contextualFactorsJson');
  @override
  late final GeneratedColumn<String> contextualFactorsJson =
      GeneratedColumn<String>(
        'contextual_factors_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _physiologicalFactorsJsonMeta =
      const VerificationMeta('physiologicalFactorsJson');
  @override
  late final GeneratedColumn<String> physiologicalFactorsJson =
      GeneratedColumn<String>(
        'physiological_factors_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryFactorsJsonMeta =
      const VerificationMeta('recoveryFactorsJson');
  @override
  late final GeneratedColumn<String> recoveryFactorsJson =
      GeneratedColumn<String>(
        'recovery_factors_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    interventionType,
    recommendationScore,
    expectedRecoveryBenefit,
    confidence,
    contextualFactorsJson,
    physiologicalFactorsJson,
    recoveryFactorsJson,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contextual_intervention_recommendations_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContextualInterventionRecommendationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('intervention_type')) {
      context.handle(
        _interventionTypeMeta,
        interventionType.isAcceptableOrUnknown(
          data['intervention_type']!,
          _interventionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_interventionTypeMeta);
    }
    if (data.containsKey('recommendation_score')) {
      context.handle(
        _recommendationScoreMeta,
        recommendationScore.isAcceptableOrUnknown(
          data['recommendation_score']!,
          _recommendationScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recommendationScoreMeta);
    }
    if (data.containsKey('expected_recovery_benefit')) {
      context.handle(
        _expectedRecoveryBenefitMeta,
        expectedRecoveryBenefit.isAcceptableOrUnknown(
          data['expected_recovery_benefit']!,
          _expectedRecoveryBenefitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedRecoveryBenefitMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('contextual_factors_json')) {
      context.handle(
        _contextualFactorsJsonMeta,
        contextualFactorsJson.isAcceptableOrUnknown(
          data['contextual_factors_json']!,
          _contextualFactorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextualFactorsJsonMeta);
    }
    if (data.containsKey('physiological_factors_json')) {
      context.handle(
        _physiologicalFactorsJsonMeta,
        physiologicalFactorsJson.isAcceptableOrUnknown(
          data['physiological_factors_json']!,
          _physiologicalFactorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physiologicalFactorsJsonMeta);
    }
    if (data.containsKey('recovery_factors_json')) {
      context.handle(
        _recoveryFactorsJsonMeta,
        recoveryFactorsJson.isAcceptableOrUnknown(
          data['recovery_factors_json']!,
          _recoveryFactorsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryFactorsJsonMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContextualInterventionRecommendationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContextualInterventionRecommendationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      interventionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intervention_type'],
      )!,
      recommendationScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recommendation_score'],
      )!,
      expectedRecoveryBenefit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}expected_recovery_benefit'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      contextualFactorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contextual_factors_json'],
      )!,
      physiologicalFactorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}physiological_factors_json'],
      )!,
      recoveryFactorsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_factors_json'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $ContextualInterventionRecommendationsTableTable createAlias(String alias) {
    return $ContextualInterventionRecommendationsTableTable(
      attachedDatabase,
      alias,
    );
  }
}

class ContextualInterventionRecommendationsTableData extends DataClass
    implements Insertable<ContextualInterventionRecommendationsTableData> {
  final String id;
  final DateTime generatedAt;
  final String interventionType;
  final double recommendationScore;
  final double expectedRecoveryBenefit;
  final double confidence;
  final String contextualFactorsJson;
  final String physiologicalFactorsJson;
  final String recoveryFactorsJson;
  final String safetyCopy;
  const ContextualInterventionRecommendationsTableData({
    required this.id,
    required this.generatedAt,
    required this.interventionType,
    required this.recommendationScore,
    required this.expectedRecoveryBenefit,
    required this.confidence,
    required this.contextualFactorsJson,
    required this.physiologicalFactorsJson,
    required this.recoveryFactorsJson,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['intervention_type'] = Variable<String>(interventionType);
    map['recommendation_score'] = Variable<double>(recommendationScore);
    map['expected_recovery_benefit'] = Variable<double>(
      expectedRecoveryBenefit,
    );
    map['confidence'] = Variable<double>(confidence);
    map['contextual_factors_json'] = Variable<String>(contextualFactorsJson);
    map['physiological_factors_json'] = Variable<String>(
      physiologicalFactorsJson,
    );
    map['recovery_factors_json'] = Variable<String>(recoveryFactorsJson);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  ContextualInterventionRecommendationsTableCompanion toCompanion(
    bool nullToAbsent,
  ) {
    return ContextualInterventionRecommendationsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      interventionType: Value(interventionType),
      recommendationScore: Value(recommendationScore),
      expectedRecoveryBenefit: Value(expectedRecoveryBenefit),
      confidence: Value(confidence),
      contextualFactorsJson: Value(contextualFactorsJson),
      physiologicalFactorsJson: Value(physiologicalFactorsJson),
      recoveryFactorsJson: Value(recoveryFactorsJson),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory ContextualInterventionRecommendationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContextualInterventionRecommendationsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      interventionType: serializer.fromJson<String>(json['interventionType']),
      recommendationScore: serializer.fromJson<double>(
        json['recommendationScore'],
      ),
      expectedRecoveryBenefit: serializer.fromJson<double>(
        json['expectedRecoveryBenefit'],
      ),
      confidence: serializer.fromJson<double>(json['confidence']),
      contextualFactorsJson: serializer.fromJson<String>(
        json['contextualFactorsJson'],
      ),
      physiologicalFactorsJson: serializer.fromJson<String>(
        json['physiologicalFactorsJson'],
      ),
      recoveryFactorsJson: serializer.fromJson<String>(
        json['recoveryFactorsJson'],
      ),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'interventionType': serializer.toJson<String>(interventionType),
      'recommendationScore': serializer.toJson<double>(recommendationScore),
      'expectedRecoveryBenefit': serializer.toJson<double>(
        expectedRecoveryBenefit,
      ),
      'confidence': serializer.toJson<double>(confidence),
      'contextualFactorsJson': serializer.toJson<String>(contextualFactorsJson),
      'physiologicalFactorsJson': serializer.toJson<String>(
        physiologicalFactorsJson,
      ),
      'recoveryFactorsJson': serializer.toJson<String>(recoveryFactorsJson),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  ContextualInterventionRecommendationsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    String? interventionType,
    double? recommendationScore,
    double? expectedRecoveryBenefit,
    double? confidence,
    String? contextualFactorsJson,
    String? physiologicalFactorsJson,
    String? recoveryFactorsJson,
    String? safetyCopy,
  }) => ContextualInterventionRecommendationsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    interventionType: interventionType ?? this.interventionType,
    recommendationScore: recommendationScore ?? this.recommendationScore,
    expectedRecoveryBenefit:
        expectedRecoveryBenefit ?? this.expectedRecoveryBenefit,
    confidence: confidence ?? this.confidence,
    contextualFactorsJson: contextualFactorsJson ?? this.contextualFactorsJson,
    physiologicalFactorsJson:
        physiologicalFactorsJson ?? this.physiologicalFactorsJson,
    recoveryFactorsJson: recoveryFactorsJson ?? this.recoveryFactorsJson,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  ContextualInterventionRecommendationsTableData copyWithCompanion(
    ContextualInterventionRecommendationsTableCompanion data,
  ) {
    return ContextualInterventionRecommendationsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      interventionType: data.interventionType.present
          ? data.interventionType.value
          : this.interventionType,
      recommendationScore: data.recommendationScore.present
          ? data.recommendationScore.value
          : this.recommendationScore,
      expectedRecoveryBenefit: data.expectedRecoveryBenefit.present
          ? data.expectedRecoveryBenefit.value
          : this.expectedRecoveryBenefit,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      contextualFactorsJson: data.contextualFactorsJson.present
          ? data.contextualFactorsJson.value
          : this.contextualFactorsJson,
      physiologicalFactorsJson: data.physiologicalFactorsJson.present
          ? data.physiologicalFactorsJson.value
          : this.physiologicalFactorsJson,
      recoveryFactorsJson: data.recoveryFactorsJson.present
          ? data.recoveryFactorsJson.value
          : this.recoveryFactorsJson,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContextualInterventionRecommendationsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('interventionType: $interventionType, ')
          ..write('recommendationScore: $recommendationScore, ')
          ..write('expectedRecoveryBenefit: $expectedRecoveryBenefit, ')
          ..write('confidence: $confidence, ')
          ..write('contextualFactorsJson: $contextualFactorsJson, ')
          ..write('physiologicalFactorsJson: $physiologicalFactorsJson, ')
          ..write('recoveryFactorsJson: $recoveryFactorsJson, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    interventionType,
    recommendationScore,
    expectedRecoveryBenefit,
    confidence,
    contextualFactorsJson,
    physiologicalFactorsJson,
    recoveryFactorsJson,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContextualInterventionRecommendationsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.interventionType == this.interventionType &&
          other.recommendationScore == this.recommendationScore &&
          other.expectedRecoveryBenefit == this.expectedRecoveryBenefit &&
          other.confidence == this.confidence &&
          other.contextualFactorsJson == this.contextualFactorsJson &&
          other.physiologicalFactorsJson == this.physiologicalFactorsJson &&
          other.recoveryFactorsJson == this.recoveryFactorsJson &&
          other.safetyCopy == this.safetyCopy);
}

class ContextualInterventionRecommendationsTableCompanion
    extends UpdateCompanion<ContextualInterventionRecommendationsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<String> interventionType;
  final Value<double> recommendationScore;
  final Value<double> expectedRecoveryBenefit;
  final Value<double> confidence;
  final Value<String> contextualFactorsJson;
  final Value<String> physiologicalFactorsJson;
  final Value<String> recoveryFactorsJson;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const ContextualInterventionRecommendationsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.interventionType = const Value.absent(),
    this.recommendationScore = const Value.absent(),
    this.expectedRecoveryBenefit = const Value.absent(),
    this.confidence = const Value.absent(),
    this.contextualFactorsJson = const Value.absent(),
    this.physiologicalFactorsJson = const Value.absent(),
    this.recoveryFactorsJson = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContextualInterventionRecommendationsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required String interventionType,
    required double recommendationScore,
    required double expectedRecoveryBenefit,
    required double confidence,
    required String contextualFactorsJson,
    required String physiologicalFactorsJson,
    required String recoveryFactorsJson,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       interventionType = Value(interventionType),
       recommendationScore = Value(recommendationScore),
       expectedRecoveryBenefit = Value(expectedRecoveryBenefit),
       confidence = Value(confidence),
       contextualFactorsJson = Value(contextualFactorsJson),
       physiologicalFactorsJson = Value(physiologicalFactorsJson),
       recoveryFactorsJson = Value(recoveryFactorsJson),
       safetyCopy = Value(safetyCopy);
  static Insertable<ContextualInterventionRecommendationsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<String>? interventionType,
    Expression<double>? recommendationScore,
    Expression<double>? expectedRecoveryBenefit,
    Expression<double>? confidence,
    Expression<String>? contextualFactorsJson,
    Expression<String>? physiologicalFactorsJson,
    Expression<String>? recoveryFactorsJson,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (interventionType != null) 'intervention_type': interventionType,
      if (recommendationScore != null)
        'recommendation_score': recommendationScore,
      if (expectedRecoveryBenefit != null)
        'expected_recovery_benefit': expectedRecoveryBenefit,
      if (confidence != null) 'confidence': confidence,
      if (contextualFactorsJson != null)
        'contextual_factors_json': contextualFactorsJson,
      if (physiologicalFactorsJson != null)
        'physiological_factors_json': physiologicalFactorsJson,
      if (recoveryFactorsJson != null)
        'recovery_factors_json': recoveryFactorsJson,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContextualInterventionRecommendationsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<String>? interventionType,
    Value<double>? recommendationScore,
    Value<double>? expectedRecoveryBenefit,
    Value<double>? confidence,
    Value<String>? contextualFactorsJson,
    Value<String>? physiologicalFactorsJson,
    Value<String>? recoveryFactorsJson,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return ContextualInterventionRecommendationsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      interventionType: interventionType ?? this.interventionType,
      recommendationScore: recommendationScore ?? this.recommendationScore,
      expectedRecoveryBenefit:
          expectedRecoveryBenefit ?? this.expectedRecoveryBenefit,
      confidence: confidence ?? this.confidence,
      contextualFactorsJson:
          contextualFactorsJson ?? this.contextualFactorsJson,
      physiologicalFactorsJson:
          physiologicalFactorsJson ?? this.physiologicalFactorsJson,
      recoveryFactorsJson: recoveryFactorsJson ?? this.recoveryFactorsJson,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (interventionType.present) {
      map['intervention_type'] = Variable<String>(interventionType.value);
    }
    if (recommendationScore.present) {
      map['recommendation_score'] = Variable<double>(recommendationScore.value);
    }
    if (expectedRecoveryBenefit.present) {
      map['expected_recovery_benefit'] = Variable<double>(
        expectedRecoveryBenefit.value,
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (contextualFactorsJson.present) {
      map['contextual_factors_json'] = Variable<String>(
        contextualFactorsJson.value,
      );
    }
    if (physiologicalFactorsJson.present) {
      map['physiological_factors_json'] = Variable<String>(
        physiologicalFactorsJson.value,
      );
    }
    if (recoveryFactorsJson.present) {
      map['recovery_factors_json'] = Variable<String>(
        recoveryFactorsJson.value,
      );
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContextualInterventionRecommendationsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('interventionType: $interventionType, ')
          ..write('recommendationScore: $recommendationScore, ')
          ..write('expectedRecoveryBenefit: $expectedRecoveryBenefit, ')
          ..write('confidence: $confidence, ')
          ..write('contextualFactorsJson: $contextualFactorsJson, ')
          ..write('physiologicalFactorsJson: $physiologicalFactorsJson, ')
          ..write('recoveryFactorsJson: $recoveryFactorsJson, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CohortAnalysisResultsTableTable extends CohortAnalysisResultsTable
    with
        TableInfo<
          $CohortAnalysisResultsTableTable,
          CohortAnalysisResultsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CohortAnalysisResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _comparedSessionsMeta = const VerificationMeta(
    'comparedSessions',
  );
  @override
  late final GeneratedColumn<int> comparedSessions = GeneratedColumn<int>(
    'compared_sessions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _averageRecoveryEfficiencyMeta =
      const VerificationMeta('averageRecoveryEfficiency');
  @override
  late final GeneratedColumn<double> averageRecoveryEfficiency =
      GeneratedColumn<double>(
        'average_recovery_efficiency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _averageEscalationProbabilityMeta =
      const VerificationMeta('averageEscalationProbability');
  @override
  late final GeneratedColumn<double> averageEscalationProbability =
      GeneratedColumn<double>(
        'average_escalation_probability',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _averageResilienceMeta = const VerificationMeta(
    'averageResilience',
  );
  @override
  late final GeneratedColumn<double> averageResilience =
      GeneratedColumn<double>(
        'average_resilience',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _stabilityScoreMeta = const VerificationMeta(
    'stabilityScore',
  );
  @override
  late final GeneratedColumn<double> stabilityScore = GeneratedColumn<double>(
    'stability_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _variabilityScoreMeta = const VerificationMeta(
    'variabilityScore',
  );
  @override
  late final GeneratedColumn<double> variabilityScore = GeneratedColumn<double>(
    'variability_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextualConsistencyMeta =
      const VerificationMeta('contextualConsistency');
  @override
  late final GeneratedColumn<double> contextualConsistency =
      GeneratedColumn<double>(
        'contextual_consistency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _longitudinalConfidenceMeta =
      const VerificationMeta('longitudinalConfidence');
  @override
  late final GeneratedColumn<double> longitudinalConfidence =
      GeneratedColumn<double>(
        'longitudinal_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    comparedSessions,
    averageRecoveryEfficiency,
    averageEscalationProbability,
    averageResilience,
    stabilityScore,
    variabilityScore,
    contextualConsistency,
    longitudinalConfidence,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cohort_analysis_results_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<CohortAnalysisResultsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('compared_sessions')) {
      context.handle(
        _comparedSessionsMeta,
        comparedSessions.isAcceptableOrUnknown(
          data['compared_sessions']!,
          _comparedSessionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_comparedSessionsMeta);
    }
    if (data.containsKey('average_recovery_efficiency')) {
      context.handle(
        _averageRecoveryEfficiencyMeta,
        averageRecoveryEfficiency.isAcceptableOrUnknown(
          data['average_recovery_efficiency']!,
          _averageRecoveryEfficiencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageRecoveryEfficiencyMeta);
    }
    if (data.containsKey('average_escalation_probability')) {
      context.handle(
        _averageEscalationProbabilityMeta,
        averageEscalationProbability.isAcceptableOrUnknown(
          data['average_escalation_probability']!,
          _averageEscalationProbabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageEscalationProbabilityMeta);
    }
    if (data.containsKey('average_resilience')) {
      context.handle(
        _averageResilienceMeta,
        averageResilience.isAcceptableOrUnknown(
          data['average_resilience']!,
          _averageResilienceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_averageResilienceMeta);
    }
    if (data.containsKey('stability_score')) {
      context.handle(
        _stabilityScoreMeta,
        stabilityScore.isAcceptableOrUnknown(
          data['stability_score']!,
          _stabilityScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stabilityScoreMeta);
    }
    if (data.containsKey('variability_score')) {
      context.handle(
        _variabilityScoreMeta,
        variabilityScore.isAcceptableOrUnknown(
          data['variability_score']!,
          _variabilityScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_variabilityScoreMeta);
    }
    if (data.containsKey('contextual_consistency')) {
      context.handle(
        _contextualConsistencyMeta,
        contextualConsistency.isAcceptableOrUnknown(
          data['contextual_consistency']!,
          _contextualConsistencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextualConsistencyMeta);
    }
    if (data.containsKey('longitudinal_confidence')) {
      context.handle(
        _longitudinalConfidenceMeta,
        longitudinalConfidence.isAcceptableOrUnknown(
          data['longitudinal_confidence']!,
          _longitudinalConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_longitudinalConfidenceMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CohortAnalysisResultsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CohortAnalysisResultsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      comparedSessions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compared_sessions'],
      )!,
      averageRecoveryEfficiency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_recovery_efficiency'],
      )!,
      averageEscalationProbability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_escalation_probability'],
      )!,
      averageResilience: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_resilience'],
      )!,
      stabilityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stability_score'],
      )!,
      variabilityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}variability_score'],
      )!,
      contextualConsistency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}contextual_consistency'],
      )!,
      longitudinalConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitudinal_confidence'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $CohortAnalysisResultsTableTable createAlias(String alias) {
    return $CohortAnalysisResultsTableTable(attachedDatabase, alias);
  }
}

class CohortAnalysisResultsTableData extends DataClass
    implements Insertable<CohortAnalysisResultsTableData> {
  final String id;
  final DateTime generatedAt;
  final int comparedSessions;
  final double averageRecoveryEfficiency;
  final double averageEscalationProbability;
  final double averageResilience;
  final double stabilityScore;
  final double variabilityScore;
  final double contextualConsistency;
  final double longitudinalConfidence;
  final String safetyCopy;
  const CohortAnalysisResultsTableData({
    required this.id,
    required this.generatedAt,
    required this.comparedSessions,
    required this.averageRecoveryEfficiency,
    required this.averageEscalationProbability,
    required this.averageResilience,
    required this.stabilityScore,
    required this.variabilityScore,
    required this.contextualConsistency,
    required this.longitudinalConfidence,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['compared_sessions'] = Variable<int>(comparedSessions);
    map['average_recovery_efficiency'] = Variable<double>(
      averageRecoveryEfficiency,
    );
    map['average_escalation_probability'] = Variable<double>(
      averageEscalationProbability,
    );
    map['average_resilience'] = Variable<double>(averageResilience);
    map['stability_score'] = Variable<double>(stabilityScore);
    map['variability_score'] = Variable<double>(variabilityScore);
    map['contextual_consistency'] = Variable<double>(contextualConsistency);
    map['longitudinal_confidence'] = Variable<double>(longitudinalConfidence);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  CohortAnalysisResultsTableCompanion toCompanion(bool nullToAbsent) {
    return CohortAnalysisResultsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      comparedSessions: Value(comparedSessions),
      averageRecoveryEfficiency: Value(averageRecoveryEfficiency),
      averageEscalationProbability: Value(averageEscalationProbability),
      averageResilience: Value(averageResilience),
      stabilityScore: Value(stabilityScore),
      variabilityScore: Value(variabilityScore),
      contextualConsistency: Value(contextualConsistency),
      longitudinalConfidence: Value(longitudinalConfidence),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory CohortAnalysisResultsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CohortAnalysisResultsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      comparedSessions: serializer.fromJson<int>(json['comparedSessions']),
      averageRecoveryEfficiency: serializer.fromJson<double>(
        json['averageRecoveryEfficiency'],
      ),
      averageEscalationProbability: serializer.fromJson<double>(
        json['averageEscalationProbability'],
      ),
      averageResilience: serializer.fromJson<double>(json['averageResilience']),
      stabilityScore: serializer.fromJson<double>(json['stabilityScore']),
      variabilityScore: serializer.fromJson<double>(json['variabilityScore']),
      contextualConsistency: serializer.fromJson<double>(
        json['contextualConsistency'],
      ),
      longitudinalConfidence: serializer.fromJson<double>(
        json['longitudinalConfidence'],
      ),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'comparedSessions': serializer.toJson<int>(comparedSessions),
      'averageRecoveryEfficiency': serializer.toJson<double>(
        averageRecoveryEfficiency,
      ),
      'averageEscalationProbability': serializer.toJson<double>(
        averageEscalationProbability,
      ),
      'averageResilience': serializer.toJson<double>(averageResilience),
      'stabilityScore': serializer.toJson<double>(stabilityScore),
      'variabilityScore': serializer.toJson<double>(variabilityScore),
      'contextualConsistency': serializer.toJson<double>(contextualConsistency),
      'longitudinalConfidence': serializer.toJson<double>(
        longitudinalConfidence,
      ),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  CohortAnalysisResultsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    int? comparedSessions,
    double? averageRecoveryEfficiency,
    double? averageEscalationProbability,
    double? averageResilience,
    double? stabilityScore,
    double? variabilityScore,
    double? contextualConsistency,
    double? longitudinalConfidence,
    String? safetyCopy,
  }) => CohortAnalysisResultsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    comparedSessions: comparedSessions ?? this.comparedSessions,
    averageRecoveryEfficiency:
        averageRecoveryEfficiency ?? this.averageRecoveryEfficiency,
    averageEscalationProbability:
        averageEscalationProbability ?? this.averageEscalationProbability,
    averageResilience: averageResilience ?? this.averageResilience,
    stabilityScore: stabilityScore ?? this.stabilityScore,
    variabilityScore: variabilityScore ?? this.variabilityScore,
    contextualConsistency: contextualConsistency ?? this.contextualConsistency,
    longitudinalConfidence:
        longitudinalConfidence ?? this.longitudinalConfidence,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  CohortAnalysisResultsTableData copyWithCompanion(
    CohortAnalysisResultsTableCompanion data,
  ) {
    return CohortAnalysisResultsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      comparedSessions: data.comparedSessions.present
          ? data.comparedSessions.value
          : this.comparedSessions,
      averageRecoveryEfficiency: data.averageRecoveryEfficiency.present
          ? data.averageRecoveryEfficiency.value
          : this.averageRecoveryEfficiency,
      averageEscalationProbability: data.averageEscalationProbability.present
          ? data.averageEscalationProbability.value
          : this.averageEscalationProbability,
      averageResilience: data.averageResilience.present
          ? data.averageResilience.value
          : this.averageResilience,
      stabilityScore: data.stabilityScore.present
          ? data.stabilityScore.value
          : this.stabilityScore,
      variabilityScore: data.variabilityScore.present
          ? data.variabilityScore.value
          : this.variabilityScore,
      contextualConsistency: data.contextualConsistency.present
          ? data.contextualConsistency.value
          : this.contextualConsistency,
      longitudinalConfidence: data.longitudinalConfidence.present
          ? data.longitudinalConfidence.value
          : this.longitudinalConfidence,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CohortAnalysisResultsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('comparedSessions: $comparedSessions, ')
          ..write('averageRecoveryEfficiency: $averageRecoveryEfficiency, ')
          ..write(
            'averageEscalationProbability: $averageEscalationProbability, ',
          )
          ..write('averageResilience: $averageResilience, ')
          ..write('stabilityScore: $stabilityScore, ')
          ..write('variabilityScore: $variabilityScore, ')
          ..write('contextualConsistency: $contextualConsistency, ')
          ..write('longitudinalConfidence: $longitudinalConfidence, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    comparedSessions,
    averageRecoveryEfficiency,
    averageEscalationProbability,
    averageResilience,
    stabilityScore,
    variabilityScore,
    contextualConsistency,
    longitudinalConfidence,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CohortAnalysisResultsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.comparedSessions == this.comparedSessions &&
          other.averageRecoveryEfficiency == this.averageRecoveryEfficiency &&
          other.averageEscalationProbability ==
              this.averageEscalationProbability &&
          other.averageResilience == this.averageResilience &&
          other.stabilityScore == this.stabilityScore &&
          other.variabilityScore == this.variabilityScore &&
          other.contextualConsistency == this.contextualConsistency &&
          other.longitudinalConfidence == this.longitudinalConfidence &&
          other.safetyCopy == this.safetyCopy);
}

class CohortAnalysisResultsTableCompanion
    extends UpdateCompanion<CohortAnalysisResultsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<int> comparedSessions;
  final Value<double> averageRecoveryEfficiency;
  final Value<double> averageEscalationProbability;
  final Value<double> averageResilience;
  final Value<double> stabilityScore;
  final Value<double> variabilityScore;
  final Value<double> contextualConsistency;
  final Value<double> longitudinalConfidence;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const CohortAnalysisResultsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.comparedSessions = const Value.absent(),
    this.averageRecoveryEfficiency = const Value.absent(),
    this.averageEscalationProbability = const Value.absent(),
    this.averageResilience = const Value.absent(),
    this.stabilityScore = const Value.absent(),
    this.variabilityScore = const Value.absent(),
    this.contextualConsistency = const Value.absent(),
    this.longitudinalConfidence = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CohortAnalysisResultsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required int comparedSessions,
    required double averageRecoveryEfficiency,
    required double averageEscalationProbability,
    required double averageResilience,
    required double stabilityScore,
    required double variabilityScore,
    required double contextualConsistency,
    required double longitudinalConfidence,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       comparedSessions = Value(comparedSessions),
       averageRecoveryEfficiency = Value(averageRecoveryEfficiency),
       averageEscalationProbability = Value(averageEscalationProbability),
       averageResilience = Value(averageResilience),
       stabilityScore = Value(stabilityScore),
       variabilityScore = Value(variabilityScore),
       contextualConsistency = Value(contextualConsistency),
       longitudinalConfidence = Value(longitudinalConfidence),
       safetyCopy = Value(safetyCopy);
  static Insertable<CohortAnalysisResultsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<int>? comparedSessions,
    Expression<double>? averageRecoveryEfficiency,
    Expression<double>? averageEscalationProbability,
    Expression<double>? averageResilience,
    Expression<double>? stabilityScore,
    Expression<double>? variabilityScore,
    Expression<double>? contextualConsistency,
    Expression<double>? longitudinalConfidence,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (comparedSessions != null) 'compared_sessions': comparedSessions,
      if (averageRecoveryEfficiency != null)
        'average_recovery_efficiency': averageRecoveryEfficiency,
      if (averageEscalationProbability != null)
        'average_escalation_probability': averageEscalationProbability,
      if (averageResilience != null) 'average_resilience': averageResilience,
      if (stabilityScore != null) 'stability_score': stabilityScore,
      if (variabilityScore != null) 'variability_score': variabilityScore,
      if (contextualConsistency != null)
        'contextual_consistency': contextualConsistency,
      if (longitudinalConfidence != null)
        'longitudinal_confidence': longitudinalConfidence,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CohortAnalysisResultsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<int>? comparedSessions,
    Value<double>? averageRecoveryEfficiency,
    Value<double>? averageEscalationProbability,
    Value<double>? averageResilience,
    Value<double>? stabilityScore,
    Value<double>? variabilityScore,
    Value<double>? contextualConsistency,
    Value<double>? longitudinalConfidence,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return CohortAnalysisResultsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      comparedSessions: comparedSessions ?? this.comparedSessions,
      averageRecoveryEfficiency:
          averageRecoveryEfficiency ?? this.averageRecoveryEfficiency,
      averageEscalationProbability:
          averageEscalationProbability ?? this.averageEscalationProbability,
      averageResilience: averageResilience ?? this.averageResilience,
      stabilityScore: stabilityScore ?? this.stabilityScore,
      variabilityScore: variabilityScore ?? this.variabilityScore,
      contextualConsistency:
          contextualConsistency ?? this.contextualConsistency,
      longitudinalConfidence:
          longitudinalConfidence ?? this.longitudinalConfidence,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (comparedSessions.present) {
      map['compared_sessions'] = Variable<int>(comparedSessions.value);
    }
    if (averageRecoveryEfficiency.present) {
      map['average_recovery_efficiency'] = Variable<double>(
        averageRecoveryEfficiency.value,
      );
    }
    if (averageEscalationProbability.present) {
      map['average_escalation_probability'] = Variable<double>(
        averageEscalationProbability.value,
      );
    }
    if (averageResilience.present) {
      map['average_resilience'] = Variable<double>(averageResilience.value);
    }
    if (stabilityScore.present) {
      map['stability_score'] = Variable<double>(stabilityScore.value);
    }
    if (variabilityScore.present) {
      map['variability_score'] = Variable<double>(variabilityScore.value);
    }
    if (contextualConsistency.present) {
      map['contextual_consistency'] = Variable<double>(
        contextualConsistency.value,
      );
    }
    if (longitudinalConfidence.present) {
      map['longitudinal_confidence'] = Variable<double>(
        longitudinalConfidence.value,
      );
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CohortAnalysisResultsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('comparedSessions: $comparedSessions, ')
          ..write('averageRecoveryEfficiency: $averageRecoveryEfficiency, ')
          ..write(
            'averageEscalationProbability: $averageEscalationProbability, ',
          )
          ..write('averageResilience: $averageResilience, ')
          ..write('stabilityScore: $stabilityScore, ')
          ..write('variabilityScore: $variabilityScore, ')
          ..write('contextualConsistency: $contextualConsistency, ')
          ..write('longitudinalConfidence: $longitudinalConfidence, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhysiologicalEvolutionProfilesTableTable
    extends PhysiologicalEvolutionProfilesTable
    with
        TableInfo<
          $PhysiologicalEvolutionProfilesTableTable,
          PhysiologicalEvolutionProfilesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhysiologicalEvolutionProfilesTableTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _baselineTrendMeta = const VerificationMeta(
    'baselineTrend',
  );
  @override
  late final GeneratedColumn<String> baselineTrend = GeneratedColumn<String>(
    'baseline_trend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recoveryTrendMeta = const VerificationMeta(
    'recoveryTrend',
  );
  @override
  late final GeneratedColumn<String> recoveryTrend = GeneratedColumn<String>(
    'recovery_trend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resilienceTrendMeta = const VerificationMeta(
    'resilienceTrend',
  );
  @override
  late final GeneratedColumn<String> resilienceTrend = GeneratedColumn<String>(
    'resilience_trend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _escalationTrendMeta = const VerificationMeta(
    'escalationTrend',
  );
  @override
  late final GeneratedColumn<String> escalationTrend = GeneratedColumn<String>(
    'escalation_trend',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _autonomicLoadTrendMeta =
      const VerificationMeta('autonomicLoadTrend');
  @override
  late final GeneratedColumn<String> autonomicLoadTrend =
      GeneratedColumn<String>(
        'autonomic_load_trend',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _circadianStabilityTrendMeta =
      const VerificationMeta('circadianStabilityTrend');
  @override
  late final GeneratedColumn<String> circadianStabilityTrend =
      GeneratedColumn<String>(
        'circadian_stability_trend',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    baselineTrend,
    recoveryTrend,
    resilienceTrend,
    escalationTrend,
    autonomicLoadTrend,
    circadianStabilityTrend,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'physiological_evolution_profiles_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhysiologicalEvolutionProfilesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('baseline_trend')) {
      context.handle(
        _baselineTrendMeta,
        baselineTrend.isAcceptableOrUnknown(
          data['baseline_trend']!,
          _baselineTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baselineTrendMeta);
    }
    if (data.containsKey('recovery_trend')) {
      context.handle(
        _recoveryTrendMeta,
        recoveryTrend.isAcceptableOrUnknown(
          data['recovery_trend']!,
          _recoveryTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryTrendMeta);
    }
    if (data.containsKey('resilience_trend')) {
      context.handle(
        _resilienceTrendMeta,
        resilienceTrend.isAcceptableOrUnknown(
          data['resilience_trend']!,
          _resilienceTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resilienceTrendMeta);
    }
    if (data.containsKey('escalation_trend')) {
      context.handle(
        _escalationTrendMeta,
        escalationTrend.isAcceptableOrUnknown(
          data['escalation_trend']!,
          _escalationTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationTrendMeta);
    }
    if (data.containsKey('autonomic_load_trend')) {
      context.handle(
        _autonomicLoadTrendMeta,
        autonomicLoadTrend.isAcceptableOrUnknown(
          data['autonomic_load_trend']!,
          _autonomicLoadTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autonomicLoadTrendMeta);
    }
    if (data.containsKey('circadian_stability_trend')) {
      context.handle(
        _circadianStabilityTrendMeta,
        circadianStabilityTrend.isAcceptableOrUnknown(
          data['circadian_stability_trend']!,
          _circadianStabilityTrendMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_circadianStabilityTrendMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhysiologicalEvolutionProfilesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhysiologicalEvolutionProfilesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      baselineTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}baseline_trend'],
      )!,
      recoveryTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recovery_trend'],
      )!,
      resilienceTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resilience_trend'],
      )!,
      escalationTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}escalation_trend'],
      )!,
      autonomicLoadTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}autonomic_load_trend'],
      )!,
      circadianStabilityTrend: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}circadian_stability_trend'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $PhysiologicalEvolutionProfilesTableTable createAlias(String alias) {
    return $PhysiologicalEvolutionProfilesTableTable(attachedDatabase, alias);
  }
}

class PhysiologicalEvolutionProfilesTableData extends DataClass
    implements Insertable<PhysiologicalEvolutionProfilesTableData> {
  final String id;
  final DateTime generatedAt;
  final String baselineTrend;
  final String recoveryTrend;
  final String resilienceTrend;
  final String escalationTrend;
  final String autonomicLoadTrend;
  final String circadianStabilityTrend;
  final String safetyCopy;
  const PhysiologicalEvolutionProfilesTableData({
    required this.id,
    required this.generatedAt,
    required this.baselineTrend,
    required this.recoveryTrend,
    required this.resilienceTrend,
    required this.escalationTrend,
    required this.autonomicLoadTrend,
    required this.circadianStabilityTrend,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['baseline_trend'] = Variable<String>(baselineTrend);
    map['recovery_trend'] = Variable<String>(recoveryTrend);
    map['resilience_trend'] = Variable<String>(resilienceTrend);
    map['escalation_trend'] = Variable<String>(escalationTrend);
    map['autonomic_load_trend'] = Variable<String>(autonomicLoadTrend);
    map['circadian_stability_trend'] = Variable<String>(
      circadianStabilityTrend,
    );
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  PhysiologicalEvolutionProfilesTableCompanion toCompanion(bool nullToAbsent) {
    return PhysiologicalEvolutionProfilesTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      baselineTrend: Value(baselineTrend),
      recoveryTrend: Value(recoveryTrend),
      resilienceTrend: Value(resilienceTrend),
      escalationTrend: Value(escalationTrend),
      autonomicLoadTrend: Value(autonomicLoadTrend),
      circadianStabilityTrend: Value(circadianStabilityTrend),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory PhysiologicalEvolutionProfilesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhysiologicalEvolutionProfilesTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      baselineTrend: serializer.fromJson<String>(json['baselineTrend']),
      recoveryTrend: serializer.fromJson<String>(json['recoveryTrend']),
      resilienceTrend: serializer.fromJson<String>(json['resilienceTrend']),
      escalationTrend: serializer.fromJson<String>(json['escalationTrend']),
      autonomicLoadTrend: serializer.fromJson<String>(
        json['autonomicLoadTrend'],
      ),
      circadianStabilityTrend: serializer.fromJson<String>(
        json['circadianStabilityTrend'],
      ),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'baselineTrend': serializer.toJson<String>(baselineTrend),
      'recoveryTrend': serializer.toJson<String>(recoveryTrend),
      'resilienceTrend': serializer.toJson<String>(resilienceTrend),
      'escalationTrend': serializer.toJson<String>(escalationTrend),
      'autonomicLoadTrend': serializer.toJson<String>(autonomicLoadTrend),
      'circadianStabilityTrend': serializer.toJson<String>(
        circadianStabilityTrend,
      ),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  PhysiologicalEvolutionProfilesTableData copyWith({
    String? id,
    DateTime? generatedAt,
    String? baselineTrend,
    String? recoveryTrend,
    String? resilienceTrend,
    String? escalationTrend,
    String? autonomicLoadTrend,
    String? circadianStabilityTrend,
    String? safetyCopy,
  }) => PhysiologicalEvolutionProfilesTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    baselineTrend: baselineTrend ?? this.baselineTrend,
    recoveryTrend: recoveryTrend ?? this.recoveryTrend,
    resilienceTrend: resilienceTrend ?? this.resilienceTrend,
    escalationTrend: escalationTrend ?? this.escalationTrend,
    autonomicLoadTrend: autonomicLoadTrend ?? this.autonomicLoadTrend,
    circadianStabilityTrend:
        circadianStabilityTrend ?? this.circadianStabilityTrend,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  PhysiologicalEvolutionProfilesTableData copyWithCompanion(
    PhysiologicalEvolutionProfilesTableCompanion data,
  ) {
    return PhysiologicalEvolutionProfilesTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      baselineTrend: data.baselineTrend.present
          ? data.baselineTrend.value
          : this.baselineTrend,
      recoveryTrend: data.recoveryTrend.present
          ? data.recoveryTrend.value
          : this.recoveryTrend,
      resilienceTrend: data.resilienceTrend.present
          ? data.resilienceTrend.value
          : this.resilienceTrend,
      escalationTrend: data.escalationTrend.present
          ? data.escalationTrend.value
          : this.escalationTrend,
      autonomicLoadTrend: data.autonomicLoadTrend.present
          ? data.autonomicLoadTrend.value
          : this.autonomicLoadTrend,
      circadianStabilityTrend: data.circadianStabilityTrend.present
          ? data.circadianStabilityTrend.value
          : this.circadianStabilityTrend,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalEvolutionProfilesTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('baselineTrend: $baselineTrend, ')
          ..write('recoveryTrend: $recoveryTrend, ')
          ..write('resilienceTrend: $resilienceTrend, ')
          ..write('escalationTrend: $escalationTrend, ')
          ..write('autonomicLoadTrend: $autonomicLoadTrend, ')
          ..write('circadianStabilityTrend: $circadianStabilityTrend, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    baselineTrend,
    recoveryTrend,
    resilienceTrend,
    escalationTrend,
    autonomicLoadTrend,
    circadianStabilityTrend,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhysiologicalEvolutionProfilesTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.baselineTrend == this.baselineTrend &&
          other.recoveryTrend == this.recoveryTrend &&
          other.resilienceTrend == this.resilienceTrend &&
          other.escalationTrend == this.escalationTrend &&
          other.autonomicLoadTrend == this.autonomicLoadTrend &&
          other.circadianStabilityTrend == this.circadianStabilityTrend &&
          other.safetyCopy == this.safetyCopy);
}

class PhysiologicalEvolutionProfilesTableCompanion
    extends UpdateCompanion<PhysiologicalEvolutionProfilesTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<String> baselineTrend;
  final Value<String> recoveryTrend;
  final Value<String> resilienceTrend;
  final Value<String> escalationTrend;
  final Value<String> autonomicLoadTrend;
  final Value<String> circadianStabilityTrend;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const PhysiologicalEvolutionProfilesTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.baselineTrend = const Value.absent(),
    this.recoveryTrend = const Value.absent(),
    this.resilienceTrend = const Value.absent(),
    this.escalationTrend = const Value.absent(),
    this.autonomicLoadTrend = const Value.absent(),
    this.circadianStabilityTrend = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhysiologicalEvolutionProfilesTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required String baselineTrend,
    required String recoveryTrend,
    required String resilienceTrend,
    required String escalationTrend,
    required String autonomicLoadTrend,
    required String circadianStabilityTrend,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       baselineTrend = Value(baselineTrend),
       recoveryTrend = Value(recoveryTrend),
       resilienceTrend = Value(resilienceTrend),
       escalationTrend = Value(escalationTrend),
       autonomicLoadTrend = Value(autonomicLoadTrend),
       circadianStabilityTrend = Value(circadianStabilityTrend),
       safetyCopy = Value(safetyCopy);
  static Insertable<PhysiologicalEvolutionProfilesTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<String>? baselineTrend,
    Expression<String>? recoveryTrend,
    Expression<String>? resilienceTrend,
    Expression<String>? escalationTrend,
    Expression<String>? autonomicLoadTrend,
    Expression<String>? circadianStabilityTrend,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (baselineTrend != null) 'baseline_trend': baselineTrend,
      if (recoveryTrend != null) 'recovery_trend': recoveryTrend,
      if (resilienceTrend != null) 'resilience_trend': resilienceTrend,
      if (escalationTrend != null) 'escalation_trend': escalationTrend,
      if (autonomicLoadTrend != null)
        'autonomic_load_trend': autonomicLoadTrend,
      if (circadianStabilityTrend != null)
        'circadian_stability_trend': circadianStabilityTrend,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhysiologicalEvolutionProfilesTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<String>? baselineTrend,
    Value<String>? recoveryTrend,
    Value<String>? resilienceTrend,
    Value<String>? escalationTrend,
    Value<String>? autonomicLoadTrend,
    Value<String>? circadianStabilityTrend,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return PhysiologicalEvolutionProfilesTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      baselineTrend: baselineTrend ?? this.baselineTrend,
      recoveryTrend: recoveryTrend ?? this.recoveryTrend,
      resilienceTrend: resilienceTrend ?? this.resilienceTrend,
      escalationTrend: escalationTrend ?? this.escalationTrend,
      autonomicLoadTrend: autonomicLoadTrend ?? this.autonomicLoadTrend,
      circadianStabilityTrend:
          circadianStabilityTrend ?? this.circadianStabilityTrend,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (baselineTrend.present) {
      map['baseline_trend'] = Variable<String>(baselineTrend.value);
    }
    if (recoveryTrend.present) {
      map['recovery_trend'] = Variable<String>(recoveryTrend.value);
    }
    if (resilienceTrend.present) {
      map['resilience_trend'] = Variable<String>(resilienceTrend.value);
    }
    if (escalationTrend.present) {
      map['escalation_trend'] = Variable<String>(escalationTrend.value);
    }
    if (autonomicLoadTrend.present) {
      map['autonomic_load_trend'] = Variable<String>(autonomicLoadTrend.value);
    }
    if (circadianStabilityTrend.present) {
      map['circadian_stability_trend'] = Variable<String>(
        circadianStabilityTrend.value,
      );
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhysiologicalEvolutionProfilesTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('baselineTrend: $baselineTrend, ')
          ..write('recoveryTrend: $recoveryTrend, ')
          ..write('resilienceTrend: $resilienceTrend, ')
          ..write('escalationTrend: $escalationTrend, ')
          ..write('autonomicLoadTrend: $autonomicLoadTrend, ')
          ..write('circadianStabilityTrend: $circadianStabilityTrend, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RealtimePipelineSnapshotsTableTable
    extends RealtimePipelineSnapshotsTable
    with
        TableInfo<
          $RealtimePipelineSnapshotsTableTable,
          RealtimePipelineSnapshotsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RealtimePipelineSnapshotsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _bufferSizeMeta = const VerificationMeta(
    'bufferSize',
  );
  @override
  late final GeneratedColumn<int> bufferSize = GeneratedColumn<int>(
    'buffer_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rollingHeartRateMeta = const VerificationMeta(
    'rollingHeartRate',
  );
  @override
  late final GeneratedColumn<double> rollingHeartRate = GeneratedColumn<double>(
    'rolling_heart_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rollingHrvMeta = const VerificationMeta(
    'rollingHrv',
  );
  @override
  late final GeneratedColumn<double> rollingHrv = GeneratedColumn<double>(
    'rolling_hrv',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rollingConfidenceMeta = const VerificationMeta(
    'rollingConfidence',
  );
  @override
  late final GeneratedColumn<double> rollingConfidence =
      GeneratedColumn<double>(
        'rolling_confidence',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _rollingEscalationDensityMeta =
      const VerificationMeta('rollingEscalationDensity');
  @override
  late final GeneratedColumn<double> rollingEscalationDensity =
      GeneratedColumn<double>(
        'rolling_escalation_density',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _latestEscalationProbabilityMeta =
      const VerificationMeta('latestEscalationProbability');
  @override
  late final GeneratedColumn<double> latestEscalationProbability =
      GeneratedColumn<double>(
        'latest_escalation_probability',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _streamingStateMeta = const VerificationMeta(
    'streamingState',
  );
  @override
  late final GeneratedColumn<String> streamingState = GeneratedColumn<String>(
    'streaming_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    bufferSize,
    rollingHeartRate,
    rollingHrv,
    rollingConfidence,
    rollingEscalationDensity,
    latestEscalationProbability,
    streamingState,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'realtime_pipeline_snapshots_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<RealtimePipelineSnapshotsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('buffer_size')) {
      context.handle(
        _bufferSizeMeta,
        bufferSize.isAcceptableOrUnknown(data['buffer_size']!, _bufferSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_bufferSizeMeta);
    }
    if (data.containsKey('rolling_heart_rate')) {
      context.handle(
        _rollingHeartRateMeta,
        rollingHeartRate.isAcceptableOrUnknown(
          data['rolling_heart_rate']!,
          _rollingHeartRateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rollingHeartRateMeta);
    }
    if (data.containsKey('rolling_hrv')) {
      context.handle(
        _rollingHrvMeta,
        rollingHrv.isAcceptableOrUnknown(data['rolling_hrv']!, _rollingHrvMeta),
      );
    } else if (isInserting) {
      context.missing(_rollingHrvMeta);
    }
    if (data.containsKey('rolling_confidence')) {
      context.handle(
        _rollingConfidenceMeta,
        rollingConfidence.isAcceptableOrUnknown(
          data['rolling_confidence']!,
          _rollingConfidenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rollingConfidenceMeta);
    }
    if (data.containsKey('rolling_escalation_density')) {
      context.handle(
        _rollingEscalationDensityMeta,
        rollingEscalationDensity.isAcceptableOrUnknown(
          data['rolling_escalation_density']!,
          _rollingEscalationDensityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rollingEscalationDensityMeta);
    }
    if (data.containsKey('latest_escalation_probability')) {
      context.handle(
        _latestEscalationProbabilityMeta,
        latestEscalationProbability.isAcceptableOrUnknown(
          data['latest_escalation_probability']!,
          _latestEscalationProbabilityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_latestEscalationProbabilityMeta);
    }
    if (data.containsKey('streaming_state')) {
      context.handle(
        _streamingStateMeta,
        streamingState.isAcceptableOrUnknown(
          data['streaming_state']!,
          _streamingStateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streamingStateMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RealtimePipelineSnapshotsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RealtimePipelineSnapshotsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      bufferSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}buffer_size'],
      )!,
      rollingHeartRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rolling_heart_rate'],
      )!,
      rollingHrv: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rolling_hrv'],
      )!,
      rollingConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rolling_confidence'],
      )!,
      rollingEscalationDensity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rolling_escalation_density'],
      )!,
      latestEscalationProbability: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latest_escalation_probability'],
      )!,
      streamingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streaming_state'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $RealtimePipelineSnapshotsTableTable createAlias(String alias) {
    return $RealtimePipelineSnapshotsTableTable(attachedDatabase, alias);
  }
}

class RealtimePipelineSnapshotsTableData extends DataClass
    implements Insertable<RealtimePipelineSnapshotsTableData> {
  final String id;
  final DateTime generatedAt;
  final int bufferSize;
  final double rollingHeartRate;
  final double rollingHrv;
  final double rollingConfidence;
  final double rollingEscalationDensity;
  final double latestEscalationProbability;
  final String streamingState;
  final String safetyCopy;
  const RealtimePipelineSnapshotsTableData({
    required this.id,
    required this.generatedAt,
    required this.bufferSize,
    required this.rollingHeartRate,
    required this.rollingHrv,
    required this.rollingConfidence,
    required this.rollingEscalationDensity,
    required this.latestEscalationProbability,
    required this.streamingState,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['buffer_size'] = Variable<int>(bufferSize);
    map['rolling_heart_rate'] = Variable<double>(rollingHeartRate);
    map['rolling_hrv'] = Variable<double>(rollingHrv);
    map['rolling_confidence'] = Variable<double>(rollingConfidence);
    map['rolling_escalation_density'] = Variable<double>(
      rollingEscalationDensity,
    );
    map['latest_escalation_probability'] = Variable<double>(
      latestEscalationProbability,
    );
    map['streaming_state'] = Variable<String>(streamingState);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  RealtimePipelineSnapshotsTableCompanion toCompanion(bool nullToAbsent) {
    return RealtimePipelineSnapshotsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      bufferSize: Value(bufferSize),
      rollingHeartRate: Value(rollingHeartRate),
      rollingHrv: Value(rollingHrv),
      rollingConfidence: Value(rollingConfidence),
      rollingEscalationDensity: Value(rollingEscalationDensity),
      latestEscalationProbability: Value(latestEscalationProbability),
      streamingState: Value(streamingState),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory RealtimePipelineSnapshotsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RealtimePipelineSnapshotsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      bufferSize: serializer.fromJson<int>(json['bufferSize']),
      rollingHeartRate: serializer.fromJson<double>(json['rollingHeartRate']),
      rollingHrv: serializer.fromJson<double>(json['rollingHrv']),
      rollingConfidence: serializer.fromJson<double>(json['rollingConfidence']),
      rollingEscalationDensity: serializer.fromJson<double>(
        json['rollingEscalationDensity'],
      ),
      latestEscalationProbability: serializer.fromJson<double>(
        json['latestEscalationProbability'],
      ),
      streamingState: serializer.fromJson<String>(json['streamingState']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'bufferSize': serializer.toJson<int>(bufferSize),
      'rollingHeartRate': serializer.toJson<double>(rollingHeartRate),
      'rollingHrv': serializer.toJson<double>(rollingHrv),
      'rollingConfidence': serializer.toJson<double>(rollingConfidence),
      'rollingEscalationDensity': serializer.toJson<double>(
        rollingEscalationDensity,
      ),
      'latestEscalationProbability': serializer.toJson<double>(
        latestEscalationProbability,
      ),
      'streamingState': serializer.toJson<String>(streamingState),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  RealtimePipelineSnapshotsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    int? bufferSize,
    double? rollingHeartRate,
    double? rollingHrv,
    double? rollingConfidence,
    double? rollingEscalationDensity,
    double? latestEscalationProbability,
    String? streamingState,
    String? safetyCopy,
  }) => RealtimePipelineSnapshotsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    bufferSize: bufferSize ?? this.bufferSize,
    rollingHeartRate: rollingHeartRate ?? this.rollingHeartRate,
    rollingHrv: rollingHrv ?? this.rollingHrv,
    rollingConfidence: rollingConfidence ?? this.rollingConfidence,
    rollingEscalationDensity:
        rollingEscalationDensity ?? this.rollingEscalationDensity,
    latestEscalationProbability:
        latestEscalationProbability ?? this.latestEscalationProbability,
    streamingState: streamingState ?? this.streamingState,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  RealtimePipelineSnapshotsTableData copyWithCompanion(
    RealtimePipelineSnapshotsTableCompanion data,
  ) {
    return RealtimePipelineSnapshotsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      bufferSize: data.bufferSize.present
          ? data.bufferSize.value
          : this.bufferSize,
      rollingHeartRate: data.rollingHeartRate.present
          ? data.rollingHeartRate.value
          : this.rollingHeartRate,
      rollingHrv: data.rollingHrv.present
          ? data.rollingHrv.value
          : this.rollingHrv,
      rollingConfidence: data.rollingConfidence.present
          ? data.rollingConfidence.value
          : this.rollingConfidence,
      rollingEscalationDensity: data.rollingEscalationDensity.present
          ? data.rollingEscalationDensity.value
          : this.rollingEscalationDensity,
      latestEscalationProbability: data.latestEscalationProbability.present
          ? data.latestEscalationProbability.value
          : this.latestEscalationProbability,
      streamingState: data.streamingState.present
          ? data.streamingState.value
          : this.streamingState,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RealtimePipelineSnapshotsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('bufferSize: $bufferSize, ')
          ..write('rollingHeartRate: $rollingHeartRate, ')
          ..write('rollingHrv: $rollingHrv, ')
          ..write('rollingConfidence: $rollingConfidence, ')
          ..write('rollingEscalationDensity: $rollingEscalationDensity, ')
          ..write('latestEscalationProbability: $latestEscalationProbability, ')
          ..write('streamingState: $streamingState, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    bufferSize,
    rollingHeartRate,
    rollingHrv,
    rollingConfidence,
    rollingEscalationDensity,
    latestEscalationProbability,
    streamingState,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RealtimePipelineSnapshotsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.bufferSize == this.bufferSize &&
          other.rollingHeartRate == this.rollingHeartRate &&
          other.rollingHrv == this.rollingHrv &&
          other.rollingConfidence == this.rollingConfidence &&
          other.rollingEscalationDensity == this.rollingEscalationDensity &&
          other.latestEscalationProbability ==
              this.latestEscalationProbability &&
          other.streamingState == this.streamingState &&
          other.safetyCopy == this.safetyCopy);
}

class RealtimePipelineSnapshotsTableCompanion
    extends UpdateCompanion<RealtimePipelineSnapshotsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<int> bufferSize;
  final Value<double> rollingHeartRate;
  final Value<double> rollingHrv;
  final Value<double> rollingConfidence;
  final Value<double> rollingEscalationDensity;
  final Value<double> latestEscalationProbability;
  final Value<String> streamingState;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const RealtimePipelineSnapshotsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.bufferSize = const Value.absent(),
    this.rollingHeartRate = const Value.absent(),
    this.rollingHrv = const Value.absent(),
    this.rollingConfidence = const Value.absent(),
    this.rollingEscalationDensity = const Value.absent(),
    this.latestEscalationProbability = const Value.absent(),
    this.streamingState = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RealtimePipelineSnapshotsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required int bufferSize,
    required double rollingHeartRate,
    required double rollingHrv,
    required double rollingConfidence,
    required double rollingEscalationDensity,
    required double latestEscalationProbability,
    required String streamingState,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       bufferSize = Value(bufferSize),
       rollingHeartRate = Value(rollingHeartRate),
       rollingHrv = Value(rollingHrv),
       rollingConfidence = Value(rollingConfidence),
       rollingEscalationDensity = Value(rollingEscalationDensity),
       latestEscalationProbability = Value(latestEscalationProbability),
       streamingState = Value(streamingState),
       safetyCopy = Value(safetyCopy);
  static Insertable<RealtimePipelineSnapshotsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<int>? bufferSize,
    Expression<double>? rollingHeartRate,
    Expression<double>? rollingHrv,
    Expression<double>? rollingConfidence,
    Expression<double>? rollingEscalationDensity,
    Expression<double>? latestEscalationProbability,
    Expression<String>? streamingState,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (bufferSize != null) 'buffer_size': bufferSize,
      if (rollingHeartRate != null) 'rolling_heart_rate': rollingHeartRate,
      if (rollingHrv != null) 'rolling_hrv': rollingHrv,
      if (rollingConfidence != null) 'rolling_confidence': rollingConfidence,
      if (rollingEscalationDensity != null)
        'rolling_escalation_density': rollingEscalationDensity,
      if (latestEscalationProbability != null)
        'latest_escalation_probability': latestEscalationProbability,
      if (streamingState != null) 'streaming_state': streamingState,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RealtimePipelineSnapshotsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<int>? bufferSize,
    Value<double>? rollingHeartRate,
    Value<double>? rollingHrv,
    Value<double>? rollingConfidence,
    Value<double>? rollingEscalationDensity,
    Value<double>? latestEscalationProbability,
    Value<String>? streamingState,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return RealtimePipelineSnapshotsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      bufferSize: bufferSize ?? this.bufferSize,
      rollingHeartRate: rollingHeartRate ?? this.rollingHeartRate,
      rollingHrv: rollingHrv ?? this.rollingHrv,
      rollingConfidence: rollingConfidence ?? this.rollingConfidence,
      rollingEscalationDensity:
          rollingEscalationDensity ?? this.rollingEscalationDensity,
      latestEscalationProbability:
          latestEscalationProbability ?? this.latestEscalationProbability,
      streamingState: streamingState ?? this.streamingState,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (bufferSize.present) {
      map['buffer_size'] = Variable<int>(bufferSize.value);
    }
    if (rollingHeartRate.present) {
      map['rolling_heart_rate'] = Variable<double>(rollingHeartRate.value);
    }
    if (rollingHrv.present) {
      map['rolling_hrv'] = Variable<double>(rollingHrv.value);
    }
    if (rollingConfidence.present) {
      map['rolling_confidence'] = Variable<double>(rollingConfidence.value);
    }
    if (rollingEscalationDensity.present) {
      map['rolling_escalation_density'] = Variable<double>(
        rollingEscalationDensity.value,
      );
    }
    if (latestEscalationProbability.present) {
      map['latest_escalation_probability'] = Variable<double>(
        latestEscalationProbability.value,
      );
    }
    if (streamingState.present) {
      map['streaming_state'] = Variable<String>(streamingState.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RealtimePipelineSnapshotsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('bufferSize: $bufferSize, ')
          ..write('rollingHeartRate: $rollingHeartRate, ')
          ..write('rollingHrv: $rollingHrv, ')
          ..write('rollingConfidence: $rollingConfidence, ')
          ..write('rollingEscalationDensity: $rollingEscalationDensity, ')
          ..write('latestEscalationProbability: $latestEscalationProbability, ')
          ..write('streamingState: $streamingState, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReplayScenariosTableTable extends ReplayScenariosTable
    with TableInfo<$ReplayScenariosTableTable, ReplayScenariosTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReplayScenariosTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _scenarioTypeMeta = const VerificationMeta(
    'scenarioType',
  );
  @override
  late final GeneratedColumn<String> scenarioType = GeneratedColumn<String>(
    'scenario_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedEscalationLevelMeta =
      const VerificationMeta('expectedEscalationLevel');
  @override
  late final GeneratedColumn<String> expectedEscalationLevel =
      GeneratedColumn<String>(
        'expected_escalation_level',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _contextualFactorsMeta = const VerificationMeta(
    'contextualFactors',
  );
  @override
  late final GeneratedColumn<String> contextualFactors =
      GeneratedColumn<String>(
        'contextual_factors',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    generatedAt,
    durationSeconds,
    sampleCount,
    scenarioType,
    expectedEscalationLevel,
    contextualFactors,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'replay_scenarios_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReplayScenariosTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('scenario_type')) {
      context.handle(
        _scenarioTypeMeta,
        scenarioType.isAcceptableOrUnknown(
          data['scenario_type']!,
          _scenarioTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scenarioTypeMeta);
    }
    if (data.containsKey('expected_escalation_level')) {
      context.handle(
        _expectedEscalationLevelMeta,
        expectedEscalationLevel.isAcceptableOrUnknown(
          data['expected_escalation_level']!,
          _expectedEscalationLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedEscalationLevelMeta);
    }
    if (data.containsKey('contextual_factors')) {
      context.handle(
        _contextualFactorsMeta,
        contextualFactors.isAcceptableOrUnknown(
          data['contextual_factors']!,
          _contextualFactorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextualFactorsMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReplayScenariosTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReplayScenariosTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      sampleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_count'],
      )!,
      scenarioType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_type'],
      )!,
      expectedEscalationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_escalation_level'],
      )!,
      contextualFactors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contextual_factors'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $ReplayScenariosTableTable createAlias(String alias) {
    return $ReplayScenariosTableTable(attachedDatabase, alias);
  }
}

class ReplayScenariosTableData extends DataClass
    implements Insertable<ReplayScenariosTableData> {
  final String id;
  final String title;
  final String description;
  final DateTime generatedAt;
  final int durationSeconds;
  final int sampleCount;
  final String scenarioType;
  final String expectedEscalationLevel;
  final String contextualFactors;
  final String safetyCopy;
  const ReplayScenariosTableData({
    required this.id,
    required this.title,
    required this.description,
    required this.generatedAt,
    required this.durationSeconds,
    required this.sampleCount,
    required this.scenarioType,
    required this.expectedEscalationLevel,
    required this.contextualFactors,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['sample_count'] = Variable<int>(sampleCount);
    map['scenario_type'] = Variable<String>(scenarioType);
    map['expected_escalation_level'] = Variable<String>(
      expectedEscalationLevel,
    );
    map['contextual_factors'] = Variable<String>(contextualFactors);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  ReplayScenariosTableCompanion toCompanion(bool nullToAbsent) {
    return ReplayScenariosTableCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      generatedAt: Value(generatedAt),
      durationSeconds: Value(durationSeconds),
      sampleCount: Value(sampleCount),
      scenarioType: Value(scenarioType),
      expectedEscalationLevel: Value(expectedEscalationLevel),
      contextualFactors: Value(contextualFactors),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory ReplayScenariosTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReplayScenariosTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      sampleCount: serializer.fromJson<int>(json['sampleCount']),
      scenarioType: serializer.fromJson<String>(json['scenarioType']),
      expectedEscalationLevel: serializer.fromJson<String>(
        json['expectedEscalationLevel'],
      ),
      contextualFactors: serializer.fromJson<String>(json['contextualFactors']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'sampleCount': serializer.toJson<int>(sampleCount),
      'scenarioType': serializer.toJson<String>(scenarioType),
      'expectedEscalationLevel': serializer.toJson<String>(
        expectedEscalationLevel,
      ),
      'contextualFactors': serializer.toJson<String>(contextualFactors),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  ReplayScenariosTableData copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? generatedAt,
    int? durationSeconds,
    int? sampleCount,
    String? scenarioType,
    String? expectedEscalationLevel,
    String? contextualFactors,
    String? safetyCopy,
  }) => ReplayScenariosTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    generatedAt: generatedAt ?? this.generatedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    sampleCount: sampleCount ?? this.sampleCount,
    scenarioType: scenarioType ?? this.scenarioType,
    expectedEscalationLevel:
        expectedEscalationLevel ?? this.expectedEscalationLevel,
    contextualFactors: contextualFactors ?? this.contextualFactors,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  ReplayScenariosTableData copyWithCompanion(
    ReplayScenariosTableCompanion data,
  ) {
    return ReplayScenariosTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      sampleCount: data.sampleCount.present
          ? data.sampleCount.value
          : this.sampleCount,
      scenarioType: data.scenarioType.present
          ? data.scenarioType.value
          : this.scenarioType,
      expectedEscalationLevel: data.expectedEscalationLevel.present
          ? data.expectedEscalationLevel.value
          : this.expectedEscalationLevel,
      contextualFactors: data.contextualFactors.present
          ? data.contextualFactors.value
          : this.contextualFactors,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReplayScenariosTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('scenarioType: $scenarioType, ')
          ..write('expectedEscalationLevel: $expectedEscalationLevel, ')
          ..write('contextualFactors: $contextualFactors, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    generatedAt,
    durationSeconds,
    sampleCount,
    scenarioType,
    expectedEscalationLevel,
    contextualFactors,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReplayScenariosTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.generatedAt == this.generatedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.sampleCount == this.sampleCount &&
          other.scenarioType == this.scenarioType &&
          other.expectedEscalationLevel == this.expectedEscalationLevel &&
          other.contextualFactors == this.contextualFactors &&
          other.safetyCopy == this.safetyCopy);
}

class ReplayScenariosTableCompanion
    extends UpdateCompanion<ReplayScenariosTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> generatedAt;
  final Value<int> durationSeconds;
  final Value<int> sampleCount;
  final Value<String> scenarioType;
  final Value<String> expectedEscalationLevel;
  final Value<String> contextualFactors;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const ReplayScenariosTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.sampleCount = const Value.absent(),
    this.scenarioType = const Value.absent(),
    this.expectedEscalationLevel = const Value.absent(),
    this.contextualFactors = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReplayScenariosTableCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime generatedAt,
    required int durationSeconds,
    required int sampleCount,
    required String scenarioType,
    required String expectedEscalationLevel,
    required String contextualFactors,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       generatedAt = Value(generatedAt),
       durationSeconds = Value(durationSeconds),
       sampleCount = Value(sampleCount),
       scenarioType = Value(scenarioType),
       expectedEscalationLevel = Value(expectedEscalationLevel),
       contextualFactors = Value(contextualFactors),
       safetyCopy = Value(safetyCopy);
  static Insertable<ReplayScenariosTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? generatedAt,
    Expression<int>? durationSeconds,
    Expression<int>? sampleCount,
    Expression<String>? scenarioType,
    Expression<String>? expectedEscalationLevel,
    Expression<String>? contextualFactors,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (sampleCount != null) 'sample_count': sampleCount,
      if (scenarioType != null) 'scenario_type': scenarioType,
      if (expectedEscalationLevel != null)
        'expected_escalation_level': expectedEscalationLevel,
      if (contextualFactors != null) 'contextual_factors': contextualFactors,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReplayScenariosTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? generatedAt,
    Value<int>? durationSeconds,
    Value<int>? sampleCount,
    Value<String>? scenarioType,
    Value<String>? expectedEscalationLevel,
    Value<String>? contextualFactors,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return ReplayScenariosTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      generatedAt: generatedAt ?? this.generatedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      sampleCount: sampleCount ?? this.sampleCount,
      scenarioType: scenarioType ?? this.scenarioType,
      expectedEscalationLevel:
          expectedEscalationLevel ?? this.expectedEscalationLevel,
      contextualFactors: contextualFactors ?? this.contextualFactors,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (sampleCount.present) {
      map['sample_count'] = Variable<int>(sampleCount.value);
    }
    if (scenarioType.present) {
      map['scenario_type'] = Variable<String>(scenarioType.value);
    }
    if (expectedEscalationLevel.present) {
      map['expected_escalation_level'] = Variable<String>(
        expectedEscalationLevel.value,
      );
    }
    if (contextualFactors.present) {
      map['contextual_factors'] = Variable<String>(contextualFactors.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReplayScenariosTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('sampleCount: $sampleCount, ')
          ..write('scenarioType: $scenarioType, ')
          ..write('expectedEscalationLevel: $expectedEscalationLevel, ')
          ..write('contextualFactors: $contextualFactors, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReplayValidationResultsTableTable extends ReplayValidationResultsTable
    with
        TableInfo<
          $ReplayValidationResultsTableTable,
          ReplayValidationResultsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReplayValidationResultsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scenarioIdMeta = const VerificationMeta(
    'scenarioId',
  );
  @override
  late final GeneratedColumn<String> scenarioId = GeneratedColumn<String>(
    'scenario_id',
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
  static const VerificationMeta _replayConsistencyMeta = const VerificationMeta(
    'replayConsistency',
  );
  @override
  late final GeneratedColumn<double> replayConsistency =
      GeneratedColumn<double>(
        'replay_consistency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _timelineConsistencyMeta =
      const VerificationMeta('timelineConsistency');
  @override
  late final GeneratedColumn<double> timelineConsistency =
      GeneratedColumn<double>(
        'timeline_consistency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _forecastConsistencyMeta =
      const VerificationMeta('forecastConsistency');
  @override
  late final GeneratedColumn<double> forecastConsistency =
      GeneratedColumn<double>(
        'forecast_consistency',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _escalationDetectionScoreMeta =
      const VerificationMeta('escalationDetectionScore');
  @override
  late final GeneratedColumn<double> escalationDetectionScore =
      GeneratedColumn<double>(
        'escalation_detection_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _recoveryModelingScoreMeta =
      const VerificationMeta('recoveryModelingScore');
  @override
  late final GeneratedColumn<double> recoveryModelingScore =
      GeneratedColumn<double>(
        'recovery_modeling_score',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _findingsMeta = const VerificationMeta(
    'findings',
  );
  @override
  late final GeneratedColumn<String> findings = GeneratedColumn<String>(
    'findings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scenarioId,
    generatedAt,
    replayConsistency,
    timelineConsistency,
    forecastConsistency,
    escalationDetectionScore,
    recoveryModelingScore,
    findings,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'replay_validation_results_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReplayValidationResultsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scenario_id')) {
      context.handle(
        _scenarioIdMeta,
        scenarioId.isAcceptableOrUnknown(data['scenario_id']!, _scenarioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_scenarioIdMeta);
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
    if (data.containsKey('replay_consistency')) {
      context.handle(
        _replayConsistencyMeta,
        replayConsistency.isAcceptableOrUnknown(
          data['replay_consistency']!,
          _replayConsistencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_replayConsistencyMeta);
    }
    if (data.containsKey('timeline_consistency')) {
      context.handle(
        _timelineConsistencyMeta,
        timelineConsistency.isAcceptableOrUnknown(
          data['timeline_consistency']!,
          _timelineConsistencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timelineConsistencyMeta);
    }
    if (data.containsKey('forecast_consistency')) {
      context.handle(
        _forecastConsistencyMeta,
        forecastConsistency.isAcceptableOrUnknown(
          data['forecast_consistency']!,
          _forecastConsistencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_forecastConsistencyMeta);
    }
    if (data.containsKey('escalation_detection_score')) {
      context.handle(
        _escalationDetectionScoreMeta,
        escalationDetectionScore.isAcceptableOrUnknown(
          data['escalation_detection_score']!,
          _escalationDetectionScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_escalationDetectionScoreMeta);
    }
    if (data.containsKey('recovery_modeling_score')) {
      context.handle(
        _recoveryModelingScoreMeta,
        recoveryModelingScore.isAcceptableOrUnknown(
          data['recovery_modeling_score']!,
          _recoveryModelingScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_recoveryModelingScoreMeta);
    }
    if (data.containsKey('findings')) {
      context.handle(
        _findingsMeta,
        findings.isAcceptableOrUnknown(data['findings']!, _findingsMeta),
      );
    } else if (isInserting) {
      context.missing(_findingsMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReplayValidationResultsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReplayValidationResultsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scenarioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scenario_id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      replayConsistency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}replay_consistency'],
      )!,
      timelineConsistency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}timeline_consistency'],
      )!,
      forecastConsistency: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}forecast_consistency'],
      )!,
      escalationDetectionScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}escalation_detection_score'],
      )!,
      recoveryModelingScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}recovery_modeling_score'],
      )!,
      findings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}findings'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $ReplayValidationResultsTableTable createAlias(String alias) {
    return $ReplayValidationResultsTableTable(attachedDatabase, alias);
  }
}

class ReplayValidationResultsTableData extends DataClass
    implements Insertable<ReplayValidationResultsTableData> {
  final String id;
  final String scenarioId;
  final DateTime generatedAt;
  final double replayConsistency;
  final double timelineConsistency;
  final double forecastConsistency;
  final double escalationDetectionScore;
  final double recoveryModelingScore;
  final String findings;
  final String safetyCopy;
  const ReplayValidationResultsTableData({
    required this.id,
    required this.scenarioId,
    required this.generatedAt,
    required this.replayConsistency,
    required this.timelineConsistency,
    required this.forecastConsistency,
    required this.escalationDetectionScore,
    required this.recoveryModelingScore,
    required this.findings,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scenario_id'] = Variable<String>(scenarioId);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['replay_consistency'] = Variable<double>(replayConsistency);
    map['timeline_consistency'] = Variable<double>(timelineConsistency);
    map['forecast_consistency'] = Variable<double>(forecastConsistency);
    map['escalation_detection_score'] = Variable<double>(
      escalationDetectionScore,
    );
    map['recovery_modeling_score'] = Variable<double>(recoveryModelingScore);
    map['findings'] = Variable<String>(findings);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  ReplayValidationResultsTableCompanion toCompanion(bool nullToAbsent) {
    return ReplayValidationResultsTableCompanion(
      id: Value(id),
      scenarioId: Value(scenarioId),
      generatedAt: Value(generatedAt),
      replayConsistency: Value(replayConsistency),
      timelineConsistency: Value(timelineConsistency),
      forecastConsistency: Value(forecastConsistency),
      escalationDetectionScore: Value(escalationDetectionScore),
      recoveryModelingScore: Value(recoveryModelingScore),
      findings: Value(findings),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory ReplayValidationResultsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReplayValidationResultsTableData(
      id: serializer.fromJson<String>(json['id']),
      scenarioId: serializer.fromJson<String>(json['scenarioId']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      replayConsistency: serializer.fromJson<double>(json['replayConsistency']),
      timelineConsistency: serializer.fromJson<double>(
        json['timelineConsistency'],
      ),
      forecastConsistency: serializer.fromJson<double>(
        json['forecastConsistency'],
      ),
      escalationDetectionScore: serializer.fromJson<double>(
        json['escalationDetectionScore'],
      ),
      recoveryModelingScore: serializer.fromJson<double>(
        json['recoveryModelingScore'],
      ),
      findings: serializer.fromJson<String>(json['findings']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scenarioId': serializer.toJson<String>(scenarioId),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'replayConsistency': serializer.toJson<double>(replayConsistency),
      'timelineConsistency': serializer.toJson<double>(timelineConsistency),
      'forecastConsistency': serializer.toJson<double>(forecastConsistency),
      'escalationDetectionScore': serializer.toJson<double>(
        escalationDetectionScore,
      ),
      'recoveryModelingScore': serializer.toJson<double>(recoveryModelingScore),
      'findings': serializer.toJson<String>(findings),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  ReplayValidationResultsTableData copyWith({
    String? id,
    String? scenarioId,
    DateTime? generatedAt,
    double? replayConsistency,
    double? timelineConsistency,
    double? forecastConsistency,
    double? escalationDetectionScore,
    double? recoveryModelingScore,
    String? findings,
    String? safetyCopy,
  }) => ReplayValidationResultsTableData(
    id: id ?? this.id,
    scenarioId: scenarioId ?? this.scenarioId,
    generatedAt: generatedAt ?? this.generatedAt,
    replayConsistency: replayConsistency ?? this.replayConsistency,
    timelineConsistency: timelineConsistency ?? this.timelineConsistency,
    forecastConsistency: forecastConsistency ?? this.forecastConsistency,
    escalationDetectionScore:
        escalationDetectionScore ?? this.escalationDetectionScore,
    recoveryModelingScore: recoveryModelingScore ?? this.recoveryModelingScore,
    findings: findings ?? this.findings,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  ReplayValidationResultsTableData copyWithCompanion(
    ReplayValidationResultsTableCompanion data,
  ) {
    return ReplayValidationResultsTableData(
      id: data.id.present ? data.id.value : this.id,
      scenarioId: data.scenarioId.present
          ? data.scenarioId.value
          : this.scenarioId,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      replayConsistency: data.replayConsistency.present
          ? data.replayConsistency.value
          : this.replayConsistency,
      timelineConsistency: data.timelineConsistency.present
          ? data.timelineConsistency.value
          : this.timelineConsistency,
      forecastConsistency: data.forecastConsistency.present
          ? data.forecastConsistency.value
          : this.forecastConsistency,
      escalationDetectionScore: data.escalationDetectionScore.present
          ? data.escalationDetectionScore.value
          : this.escalationDetectionScore,
      recoveryModelingScore: data.recoveryModelingScore.present
          ? data.recoveryModelingScore.value
          : this.recoveryModelingScore,
      findings: data.findings.present ? data.findings.value : this.findings,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReplayValidationResultsTableData(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('replayConsistency: $replayConsistency, ')
          ..write('timelineConsistency: $timelineConsistency, ')
          ..write('forecastConsistency: $forecastConsistency, ')
          ..write('escalationDetectionScore: $escalationDetectionScore, ')
          ..write('recoveryModelingScore: $recoveryModelingScore, ')
          ..write('findings: $findings, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scenarioId,
    generatedAt,
    replayConsistency,
    timelineConsistency,
    forecastConsistency,
    escalationDetectionScore,
    recoveryModelingScore,
    findings,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReplayValidationResultsTableData &&
          other.id == this.id &&
          other.scenarioId == this.scenarioId &&
          other.generatedAt == this.generatedAt &&
          other.replayConsistency == this.replayConsistency &&
          other.timelineConsistency == this.timelineConsistency &&
          other.forecastConsistency == this.forecastConsistency &&
          other.escalationDetectionScore == this.escalationDetectionScore &&
          other.recoveryModelingScore == this.recoveryModelingScore &&
          other.findings == this.findings &&
          other.safetyCopy == this.safetyCopy);
}

class ReplayValidationResultsTableCompanion
    extends UpdateCompanion<ReplayValidationResultsTableData> {
  final Value<String> id;
  final Value<String> scenarioId;
  final Value<DateTime> generatedAt;
  final Value<double> replayConsistency;
  final Value<double> timelineConsistency;
  final Value<double> forecastConsistency;
  final Value<double> escalationDetectionScore;
  final Value<double> recoveryModelingScore;
  final Value<String> findings;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const ReplayValidationResultsTableCompanion({
    this.id = const Value.absent(),
    this.scenarioId = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.replayConsistency = const Value.absent(),
    this.timelineConsistency = const Value.absent(),
    this.forecastConsistency = const Value.absent(),
    this.escalationDetectionScore = const Value.absent(),
    this.recoveryModelingScore = const Value.absent(),
    this.findings = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReplayValidationResultsTableCompanion.insert({
    required String id,
    required String scenarioId,
    required DateTime generatedAt,
    required double replayConsistency,
    required double timelineConsistency,
    required double forecastConsistency,
    required double escalationDetectionScore,
    required double recoveryModelingScore,
    required String findings,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scenarioId = Value(scenarioId),
       generatedAt = Value(generatedAt),
       replayConsistency = Value(replayConsistency),
       timelineConsistency = Value(timelineConsistency),
       forecastConsistency = Value(forecastConsistency),
       escalationDetectionScore = Value(escalationDetectionScore),
       recoveryModelingScore = Value(recoveryModelingScore),
       findings = Value(findings),
       safetyCopy = Value(safetyCopy);
  static Insertable<ReplayValidationResultsTableData> custom({
    Expression<String>? id,
    Expression<String>? scenarioId,
    Expression<DateTime>? generatedAt,
    Expression<double>? replayConsistency,
    Expression<double>? timelineConsistency,
    Expression<double>? forecastConsistency,
    Expression<double>? escalationDetectionScore,
    Expression<double>? recoveryModelingScore,
    Expression<String>? findings,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scenarioId != null) 'scenario_id': scenarioId,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (replayConsistency != null) 'replay_consistency': replayConsistency,
      if (timelineConsistency != null)
        'timeline_consistency': timelineConsistency,
      if (forecastConsistency != null)
        'forecast_consistency': forecastConsistency,
      if (escalationDetectionScore != null)
        'escalation_detection_score': escalationDetectionScore,
      if (recoveryModelingScore != null)
        'recovery_modeling_score': recoveryModelingScore,
      if (findings != null) 'findings': findings,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReplayValidationResultsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? scenarioId,
    Value<DateTime>? generatedAt,
    Value<double>? replayConsistency,
    Value<double>? timelineConsistency,
    Value<double>? forecastConsistency,
    Value<double>? escalationDetectionScore,
    Value<double>? recoveryModelingScore,
    Value<String>? findings,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return ReplayValidationResultsTableCompanion(
      id: id ?? this.id,
      scenarioId: scenarioId ?? this.scenarioId,
      generatedAt: generatedAt ?? this.generatedAt,
      replayConsistency: replayConsistency ?? this.replayConsistency,
      timelineConsistency: timelineConsistency ?? this.timelineConsistency,
      forecastConsistency: forecastConsistency ?? this.forecastConsistency,
      escalationDetectionScore:
          escalationDetectionScore ?? this.escalationDetectionScore,
      recoveryModelingScore:
          recoveryModelingScore ?? this.recoveryModelingScore,
      findings: findings ?? this.findings,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scenarioId.present) {
      map['scenario_id'] = Variable<String>(scenarioId.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (replayConsistency.present) {
      map['replay_consistency'] = Variable<double>(replayConsistency.value);
    }
    if (timelineConsistency.present) {
      map['timeline_consistency'] = Variable<double>(timelineConsistency.value);
    }
    if (forecastConsistency.present) {
      map['forecast_consistency'] = Variable<double>(forecastConsistency.value);
    }
    if (escalationDetectionScore.present) {
      map['escalation_detection_score'] = Variable<double>(
        escalationDetectionScore.value,
      );
    }
    if (recoveryModelingScore.present) {
      map['recovery_modeling_score'] = Variable<double>(
        recoveryModelingScore.value,
      );
    }
    if (findings.present) {
      map['findings'] = Variable<String>(findings.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReplayValidationResultsTableCompanion(')
          ..write('id: $id, ')
          ..write('scenarioId: $scenarioId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('replayConsistency: $replayConsistency, ')
          ..write('timelineConsistency: $timelineConsistency, ')
          ..write('forecastConsistency: $forecastConsistency, ')
          ..write('escalationDetectionScore: $escalationDetectionScore, ')
          ..write('recoveryModelingScore: $recoveryModelingScore, ')
          ..write('findings: $findings, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExperimentalInsightsTableTable extends ExperimentalInsightsTable
    with
        TableInfo<
          $ExperimentalInsightsTableTable,
          ExperimentalInsightsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExperimentalInsightsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _insightTypeMeta = const VerificationMeta(
    'insightType',
  );
  @override
  late final GeneratedColumn<String> insightType = GeneratedColumn<String>(
    'insight_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contributingFactorsMeta =
      const VerificationMeta('contributingFactors');
  @override
  late final GeneratedColumn<String> contributingFactors =
      GeneratedColumn<String>(
        'contributing_factors',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _relatedMarkersMeta = const VerificationMeta(
    'relatedMarkers',
  );
  @override
  late final GeneratedColumn<String> relatedMarkers = GeneratedColumn<String>(
    'related_markers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedForecastsMeta = const VerificationMeta(
    'relatedForecasts',
  );
  @override
  late final GeneratedColumn<String> relatedForecasts = GeneratedColumn<String>(
    'related_forecasts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    title,
    summary,
    confidence,
    insightType,
    contributingFactors,
    relatedMarkers,
    relatedForecasts,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'experimental_insights_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExperimentalInsightsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('insight_type')) {
      context.handle(
        _insightTypeMeta,
        insightType.isAcceptableOrUnknown(
          data['insight_type']!,
          _insightTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_insightTypeMeta);
    }
    if (data.containsKey('contributing_factors')) {
      context.handle(
        _contributingFactorsMeta,
        contributingFactors.isAcceptableOrUnknown(
          data['contributing_factors']!,
          _contributingFactorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contributingFactorsMeta);
    }
    if (data.containsKey('related_markers')) {
      context.handle(
        _relatedMarkersMeta,
        relatedMarkers.isAcceptableOrUnknown(
          data['related_markers']!,
          _relatedMarkersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relatedMarkersMeta);
    }
    if (data.containsKey('related_forecasts')) {
      context.handle(
        _relatedForecastsMeta,
        relatedForecasts.isAcceptableOrUnknown(
          data['related_forecasts']!,
          _relatedForecastsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relatedForecastsMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExperimentalInsightsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExperimentalInsightsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      insightType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}insight_type'],
      )!,
      contributingFactors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contributing_factors'],
      )!,
      relatedMarkers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_markers'],
      )!,
      relatedForecasts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_forecasts'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $ExperimentalInsightsTableTable createAlias(String alias) {
    return $ExperimentalInsightsTableTable(attachedDatabase, alias);
  }
}

class ExperimentalInsightsTableData extends DataClass
    implements Insertable<ExperimentalInsightsTableData> {
  final String id;
  final DateTime generatedAt;
  final String title;
  final String summary;
  final double confidence;
  final String insightType;
  final String contributingFactors;
  final String relatedMarkers;
  final String relatedForecasts;
  final String safetyCopy;
  const ExperimentalInsightsTableData({
    required this.id,
    required this.generatedAt,
    required this.title,
    required this.summary,
    required this.confidence,
    required this.insightType,
    required this.contributingFactors,
    required this.relatedMarkers,
    required this.relatedForecasts,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['title'] = Variable<String>(title);
    map['summary'] = Variable<String>(summary);
    map['confidence'] = Variable<double>(confidence);
    map['insight_type'] = Variable<String>(insightType);
    map['contributing_factors'] = Variable<String>(contributingFactors);
    map['related_markers'] = Variable<String>(relatedMarkers);
    map['related_forecasts'] = Variable<String>(relatedForecasts);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  ExperimentalInsightsTableCompanion toCompanion(bool nullToAbsent) {
    return ExperimentalInsightsTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      title: Value(title),
      summary: Value(summary),
      confidence: Value(confidence),
      insightType: Value(insightType),
      contributingFactors: Value(contributingFactors),
      relatedMarkers: Value(relatedMarkers),
      relatedForecasts: Value(relatedForecasts),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory ExperimentalInsightsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExperimentalInsightsTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String>(json['summary']),
      confidence: serializer.fromJson<double>(json['confidence']),
      insightType: serializer.fromJson<String>(json['insightType']),
      contributingFactors: serializer.fromJson<String>(
        json['contributingFactors'],
      ),
      relatedMarkers: serializer.fromJson<String>(json['relatedMarkers']),
      relatedForecasts: serializer.fromJson<String>(json['relatedForecasts']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String>(summary),
      'confidence': serializer.toJson<double>(confidence),
      'insightType': serializer.toJson<String>(insightType),
      'contributingFactors': serializer.toJson<String>(contributingFactors),
      'relatedMarkers': serializer.toJson<String>(relatedMarkers),
      'relatedForecasts': serializer.toJson<String>(relatedForecasts),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  ExperimentalInsightsTableData copyWith({
    String? id,
    DateTime? generatedAt,
    String? title,
    String? summary,
    double? confidence,
    String? insightType,
    String? contributingFactors,
    String? relatedMarkers,
    String? relatedForecasts,
    String? safetyCopy,
  }) => ExperimentalInsightsTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    title: title ?? this.title,
    summary: summary ?? this.summary,
    confidence: confidence ?? this.confidence,
    insightType: insightType ?? this.insightType,
    contributingFactors: contributingFactors ?? this.contributingFactors,
    relatedMarkers: relatedMarkers ?? this.relatedMarkers,
    relatedForecasts: relatedForecasts ?? this.relatedForecasts,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  ExperimentalInsightsTableData copyWithCompanion(
    ExperimentalInsightsTableCompanion data,
  ) {
    return ExperimentalInsightsTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      insightType: data.insightType.present
          ? data.insightType.value
          : this.insightType,
      contributingFactors: data.contributingFactors.present
          ? data.contributingFactors.value
          : this.contributingFactors,
      relatedMarkers: data.relatedMarkers.present
          ? data.relatedMarkers.value
          : this.relatedMarkers,
      relatedForecasts: data.relatedForecasts.present
          ? data.relatedForecasts.value
          : this.relatedForecasts,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentalInsightsTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('confidence: $confidence, ')
          ..write('insightType: $insightType, ')
          ..write('contributingFactors: $contributingFactors, ')
          ..write('relatedMarkers: $relatedMarkers, ')
          ..write('relatedForecasts: $relatedForecasts, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    title,
    summary,
    confidence,
    insightType,
    contributingFactors,
    relatedMarkers,
    relatedForecasts,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExperimentalInsightsTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.confidence == this.confidence &&
          other.insightType == this.insightType &&
          other.contributingFactors == this.contributingFactors &&
          other.relatedMarkers == this.relatedMarkers &&
          other.relatedForecasts == this.relatedForecasts &&
          other.safetyCopy == this.safetyCopy);
}

class ExperimentalInsightsTableCompanion
    extends UpdateCompanion<ExperimentalInsightsTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<String> title;
  final Value<String> summary;
  final Value<double> confidence;
  final Value<String> insightType;
  final Value<String> contributingFactors;
  final Value<String> relatedMarkers;
  final Value<String> relatedForecasts;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const ExperimentalInsightsTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.confidence = const Value.absent(),
    this.insightType = const Value.absent(),
    this.contributingFactors = const Value.absent(),
    this.relatedMarkers = const Value.absent(),
    this.relatedForecasts = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExperimentalInsightsTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required String title,
    required String summary,
    required double confidence,
    required String insightType,
    required String contributingFactors,
    required String relatedMarkers,
    required String relatedForecasts,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       title = Value(title),
       summary = Value(summary),
       confidence = Value(confidence),
       insightType = Value(insightType),
       contributingFactors = Value(contributingFactors),
       relatedMarkers = Value(relatedMarkers),
       relatedForecasts = Value(relatedForecasts),
       safetyCopy = Value(safetyCopy);
  static Insertable<ExperimentalInsightsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<double>? confidence,
    Expression<String>? insightType,
    Expression<String>? contributingFactors,
    Expression<String>? relatedMarkers,
    Expression<String>? relatedForecasts,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (confidence != null) 'confidence': confidence,
      if (insightType != null) 'insight_type': insightType,
      if (contributingFactors != null)
        'contributing_factors': contributingFactors,
      if (relatedMarkers != null) 'related_markers': relatedMarkers,
      if (relatedForecasts != null) 'related_forecasts': relatedForecasts,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExperimentalInsightsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<String>? title,
    Value<String>? summary,
    Value<double>? confidence,
    Value<String>? insightType,
    Value<String>? contributingFactors,
    Value<String>? relatedMarkers,
    Value<String>? relatedForecasts,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return ExperimentalInsightsTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      confidence: confidence ?? this.confidence,
      insightType: insightType ?? this.insightType,
      contributingFactors: contributingFactors ?? this.contributingFactors,
      relatedMarkers: relatedMarkers ?? this.relatedMarkers,
      relatedForecasts: relatedForecasts ?? this.relatedForecasts,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (insightType.present) {
      map['insight_type'] = Variable<String>(insightType.value);
    }
    if (contributingFactors.present) {
      map['contributing_factors'] = Variable<String>(contributingFactors.value);
    }
    if (relatedMarkers.present) {
      map['related_markers'] = Variable<String>(relatedMarkers.value);
    }
    if (relatedForecasts.present) {
      map['related_forecasts'] = Variable<String>(relatedForecasts.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExperimentalInsightsTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('confidence: $confidence, ')
          ..write('insightType: $insightType, ')
          ..write('contributingFactors: $contributingFactors, ')
          ..write('relatedMarkers: $relatedMarkers, ')
          ..write('relatedForecasts: $relatedForecasts, ')
          ..write('safetyCopy: $safetyCopy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectiveFeedbackEntriesTableTable
    extends SubjectiveFeedbackEntriesTable
    with
        TableInfo<
          $SubjectiveFeedbackEntriesTableTable,
          SubjectiveFeedbackEntriesTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectiveFeedbackEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _perceivedTimestampMeta =
      const VerificationMeta('perceivedTimestamp');
  @override
  late final GeneratedColumn<DateTime> perceivedTimestamp =
      GeneratedColumn<DateTime>(
        'perceived_timestamp',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _perceivedStressMeta = const VerificationMeta(
    'perceivedStress',
  );
  @override
  late final GeneratedColumn<int> perceivedStress = GeneratedColumn<int>(
    'perceived_stress',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perceivedFatigueMeta = const VerificationMeta(
    'perceivedFatigue',
  );
  @override
  late final GeneratedColumn<int> perceivedFatigue = GeneratedColumn<int>(
    'perceived_fatigue',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perceivedControlMeta = const VerificationMeta(
    'perceivedControl',
  );
  @override
  late final GeneratedColumn<int> perceivedControl = GeneratedColumn<int>(
    'perceived_control',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _perceivedRecoveryMeta = const VerificationMeta(
    'perceivedRecovery',
  );
  @override
  late final GeneratedColumn<int> perceivedRecovery = GeneratedColumn<int>(
    'perceived_recovery',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emotionalIntensityMeta =
      const VerificationMeta('emotionalIntensity');
  @override
  late final GeneratedColumn<int> emotionalIntensity = GeneratedColumn<int>(
    'emotional_intensity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextualFactorsMeta = const VerificationMeta(
    'contextualFactors',
  );
  @override
  late final GeneratedColumn<String> contextualFactors =
      GeneratedColumn<String>(
        'contextual_factors',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _physiologicalCorrelationMeta =
      const VerificationMeta('physiologicalCorrelation');
  @override
  late final GeneratedColumn<double> physiologicalCorrelation =
      GeneratedColumn<double>(
        'physiological_correlation',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relatedMarkersMeta = const VerificationMeta(
    'relatedMarkers',
  );
  @override
  late final GeneratedColumn<String> relatedMarkers = GeneratedColumn<String>(
    'related_markers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _safetyCopyMeta = const VerificationMeta(
    'safetyCopy',
  );
  @override
  late final GeneratedColumn<String> safetyCopy = GeneratedColumn<String>(
    'safety_copy',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    generatedAt,
    perceivedTimestamp,
    perceivedStress,
    perceivedFatigue,
    perceivedControl,
    perceivedRecovery,
    emotionalIntensity,
    notes,
    contextualFactors,
    physiologicalCorrelation,
    confidence,
    relatedMarkers,
    safetyCopy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjective_feedback_entries_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubjectiveFeedbackEntriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
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
    if (data.containsKey('perceived_timestamp')) {
      context.handle(
        _perceivedTimestampMeta,
        perceivedTimestamp.isAcceptableOrUnknown(
          data['perceived_timestamp']!,
          _perceivedTimestampMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedTimestampMeta);
    }
    if (data.containsKey('perceived_stress')) {
      context.handle(
        _perceivedStressMeta,
        perceivedStress.isAcceptableOrUnknown(
          data['perceived_stress']!,
          _perceivedStressMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedStressMeta);
    }
    if (data.containsKey('perceived_fatigue')) {
      context.handle(
        _perceivedFatigueMeta,
        perceivedFatigue.isAcceptableOrUnknown(
          data['perceived_fatigue']!,
          _perceivedFatigueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedFatigueMeta);
    }
    if (data.containsKey('perceived_control')) {
      context.handle(
        _perceivedControlMeta,
        perceivedControl.isAcceptableOrUnknown(
          data['perceived_control']!,
          _perceivedControlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedControlMeta);
    }
    if (data.containsKey('perceived_recovery')) {
      context.handle(
        _perceivedRecoveryMeta,
        perceivedRecovery.isAcceptableOrUnknown(
          data['perceived_recovery']!,
          _perceivedRecoveryMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_perceivedRecoveryMeta);
    }
    if (data.containsKey('emotional_intensity')) {
      context.handle(
        _emotionalIntensityMeta,
        emotionalIntensity.isAcceptableOrUnknown(
          data['emotional_intensity']!,
          _emotionalIntensityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_emotionalIntensityMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('contextual_factors')) {
      context.handle(
        _contextualFactorsMeta,
        contextualFactors.isAcceptableOrUnknown(
          data['contextual_factors']!,
          _contextualFactorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contextualFactorsMeta);
    }
    if (data.containsKey('physiological_correlation')) {
      context.handle(
        _physiologicalCorrelationMeta,
        physiologicalCorrelation.isAcceptableOrUnknown(
          data['physiological_correlation']!,
          _physiologicalCorrelationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physiologicalCorrelationMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('related_markers')) {
      context.handle(
        _relatedMarkersMeta,
        relatedMarkers.isAcceptableOrUnknown(
          data['related_markers']!,
          _relatedMarkersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relatedMarkersMeta);
    }
    if (data.containsKey('safety_copy')) {
      context.handle(
        _safetyCopyMeta,
        safetyCopy.isAcceptableOrUnknown(data['safety_copy']!, _safetyCopyMeta),
      );
    } else if (isInserting) {
      context.missing(_safetyCopyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubjectiveFeedbackEntriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectiveFeedbackEntriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      generatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}generated_at'],
      )!,
      perceivedTimestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}perceived_timestamp'],
      )!,
      perceivedStress: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_stress'],
      )!,
      perceivedFatigue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_fatigue'],
      )!,
      perceivedControl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_control'],
      )!,
      perceivedRecovery: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}perceived_recovery'],
      )!,
      emotionalIntensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emotional_intensity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      contextualFactors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contextual_factors'],
      )!,
      physiologicalCorrelation: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}physiological_correlation'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      relatedMarkers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_markers'],
      )!,
      safetyCopy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}safety_copy'],
      )!,
    );
  }

  @override
  $SubjectiveFeedbackEntriesTableTable createAlias(String alias) {
    return $SubjectiveFeedbackEntriesTableTable(attachedDatabase, alias);
  }
}

class SubjectiveFeedbackEntriesTableData extends DataClass
    implements Insertable<SubjectiveFeedbackEntriesTableData> {
  final String id;
  final DateTime generatedAt;
  final DateTime perceivedTimestamp;
  final int perceivedStress;
  final int perceivedFatigue;
  final int perceivedControl;
  final int perceivedRecovery;
  final int emotionalIntensity;
  final String notes;
  final String contextualFactors;
  final double physiologicalCorrelation;
  final double confidence;
  final String relatedMarkers;
  final String safetyCopy;
  const SubjectiveFeedbackEntriesTableData({
    required this.id,
    required this.generatedAt,
    required this.perceivedTimestamp,
    required this.perceivedStress,
    required this.perceivedFatigue,
    required this.perceivedControl,
    required this.perceivedRecovery,
    required this.emotionalIntensity,
    required this.notes,
    required this.contextualFactors,
    required this.physiologicalCorrelation,
    required this.confidence,
    required this.relatedMarkers,
    required this.safetyCopy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['perceived_timestamp'] = Variable<DateTime>(perceivedTimestamp);
    map['perceived_stress'] = Variable<int>(perceivedStress);
    map['perceived_fatigue'] = Variable<int>(perceivedFatigue);
    map['perceived_control'] = Variable<int>(perceivedControl);
    map['perceived_recovery'] = Variable<int>(perceivedRecovery);
    map['emotional_intensity'] = Variable<int>(emotionalIntensity);
    map['notes'] = Variable<String>(notes);
    map['contextual_factors'] = Variable<String>(contextualFactors);
    map['physiological_correlation'] = Variable<double>(
      physiologicalCorrelation,
    );
    map['confidence'] = Variable<double>(confidence);
    map['related_markers'] = Variable<String>(relatedMarkers);
    map['safety_copy'] = Variable<String>(safetyCopy);
    return map;
  }

  SubjectiveFeedbackEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return SubjectiveFeedbackEntriesTableCompanion(
      id: Value(id),
      generatedAt: Value(generatedAt),
      perceivedTimestamp: Value(perceivedTimestamp),
      perceivedStress: Value(perceivedStress),
      perceivedFatigue: Value(perceivedFatigue),
      perceivedControl: Value(perceivedControl),
      perceivedRecovery: Value(perceivedRecovery),
      emotionalIntensity: Value(emotionalIntensity),
      notes: Value(notes),
      contextualFactors: Value(contextualFactors),
      physiologicalCorrelation: Value(physiologicalCorrelation),
      confidence: Value(confidence),
      relatedMarkers: Value(relatedMarkers),
      safetyCopy: Value(safetyCopy),
    );
  }

  factory SubjectiveFeedbackEntriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectiveFeedbackEntriesTableData(
      id: serializer.fromJson<String>(json['id']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      perceivedTimestamp: serializer.fromJson<DateTime>(
        json['perceivedTimestamp'],
      ),
      perceivedStress: serializer.fromJson<int>(json['perceivedStress']),
      perceivedFatigue: serializer.fromJson<int>(json['perceivedFatigue']),
      perceivedControl: serializer.fromJson<int>(json['perceivedControl']),
      perceivedRecovery: serializer.fromJson<int>(json['perceivedRecovery']),
      emotionalIntensity: serializer.fromJson<int>(json['emotionalIntensity']),
      notes: serializer.fromJson<String>(json['notes']),
      contextualFactors: serializer.fromJson<String>(json['contextualFactors']),
      physiologicalCorrelation: serializer.fromJson<double>(
        json['physiologicalCorrelation'],
      ),
      confidence: serializer.fromJson<double>(json['confidence']),
      relatedMarkers: serializer.fromJson<String>(json['relatedMarkers']),
      safetyCopy: serializer.fromJson<String>(json['safetyCopy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'perceivedTimestamp': serializer.toJson<DateTime>(perceivedTimestamp),
      'perceivedStress': serializer.toJson<int>(perceivedStress),
      'perceivedFatigue': serializer.toJson<int>(perceivedFatigue),
      'perceivedControl': serializer.toJson<int>(perceivedControl),
      'perceivedRecovery': serializer.toJson<int>(perceivedRecovery),
      'emotionalIntensity': serializer.toJson<int>(emotionalIntensity),
      'notes': serializer.toJson<String>(notes),
      'contextualFactors': serializer.toJson<String>(contextualFactors),
      'physiologicalCorrelation': serializer.toJson<double>(
        physiologicalCorrelation,
      ),
      'confidence': serializer.toJson<double>(confidence),
      'relatedMarkers': serializer.toJson<String>(relatedMarkers),
      'safetyCopy': serializer.toJson<String>(safetyCopy),
    };
  }

  SubjectiveFeedbackEntriesTableData copyWith({
    String? id,
    DateTime? generatedAt,
    DateTime? perceivedTimestamp,
    int? perceivedStress,
    int? perceivedFatigue,
    int? perceivedControl,
    int? perceivedRecovery,
    int? emotionalIntensity,
    String? notes,
    String? contextualFactors,
    double? physiologicalCorrelation,
    double? confidence,
    String? relatedMarkers,
    String? safetyCopy,
  }) => SubjectiveFeedbackEntriesTableData(
    id: id ?? this.id,
    generatedAt: generatedAt ?? this.generatedAt,
    perceivedTimestamp: perceivedTimestamp ?? this.perceivedTimestamp,
    perceivedStress: perceivedStress ?? this.perceivedStress,
    perceivedFatigue: perceivedFatigue ?? this.perceivedFatigue,
    perceivedControl: perceivedControl ?? this.perceivedControl,
    perceivedRecovery: perceivedRecovery ?? this.perceivedRecovery,
    emotionalIntensity: emotionalIntensity ?? this.emotionalIntensity,
    notes: notes ?? this.notes,
    contextualFactors: contextualFactors ?? this.contextualFactors,
    physiologicalCorrelation:
        physiologicalCorrelation ?? this.physiologicalCorrelation,
    confidence: confidence ?? this.confidence,
    relatedMarkers: relatedMarkers ?? this.relatedMarkers,
    safetyCopy: safetyCopy ?? this.safetyCopy,
  );
  SubjectiveFeedbackEntriesTableData copyWithCompanion(
    SubjectiveFeedbackEntriesTableCompanion data,
  ) {
    return SubjectiveFeedbackEntriesTableData(
      id: data.id.present ? data.id.value : this.id,
      generatedAt: data.generatedAt.present
          ? data.generatedAt.value
          : this.generatedAt,
      perceivedTimestamp: data.perceivedTimestamp.present
          ? data.perceivedTimestamp.value
          : this.perceivedTimestamp,
      perceivedStress: data.perceivedStress.present
          ? data.perceivedStress.value
          : this.perceivedStress,
      perceivedFatigue: data.perceivedFatigue.present
          ? data.perceivedFatigue.value
          : this.perceivedFatigue,
      perceivedControl: data.perceivedControl.present
          ? data.perceivedControl.value
          : this.perceivedControl,
      perceivedRecovery: data.perceivedRecovery.present
          ? data.perceivedRecovery.value
          : this.perceivedRecovery,
      emotionalIntensity: data.emotionalIntensity.present
          ? data.emotionalIntensity.value
          : this.emotionalIntensity,
      notes: data.notes.present ? data.notes.value : this.notes,
      contextualFactors: data.contextualFactors.present
          ? data.contextualFactors.value
          : this.contextualFactors,
      physiologicalCorrelation: data.physiologicalCorrelation.present
          ? data.physiologicalCorrelation.value
          : this.physiologicalCorrelation,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      relatedMarkers: data.relatedMarkers.present
          ? data.relatedMarkers.value
          : this.relatedMarkers,
      safetyCopy: data.safetyCopy.present
          ? data.safetyCopy.value
          : this.safetyCopy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectiveFeedbackEntriesTableData(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('perceivedTimestamp: $perceivedTimestamp, ')
          ..write('perceivedStress: $perceivedStress, ')
          ..write('perceivedFatigue: $perceivedFatigue, ')
          ..write('perceivedControl: $perceivedControl, ')
          ..write('perceivedRecovery: $perceivedRecovery, ')
          ..write('emotionalIntensity: $emotionalIntensity, ')
          ..write('notes: $notes, ')
          ..write('contextualFactors: $contextualFactors, ')
          ..write('physiologicalCorrelation: $physiologicalCorrelation, ')
          ..write('confidence: $confidence, ')
          ..write('relatedMarkers: $relatedMarkers, ')
          ..write('safetyCopy: $safetyCopy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    generatedAt,
    perceivedTimestamp,
    perceivedStress,
    perceivedFatigue,
    perceivedControl,
    perceivedRecovery,
    emotionalIntensity,
    notes,
    contextualFactors,
    physiologicalCorrelation,
    confidence,
    relatedMarkers,
    safetyCopy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectiveFeedbackEntriesTableData &&
          other.id == this.id &&
          other.generatedAt == this.generatedAt &&
          other.perceivedTimestamp == this.perceivedTimestamp &&
          other.perceivedStress == this.perceivedStress &&
          other.perceivedFatigue == this.perceivedFatigue &&
          other.perceivedControl == this.perceivedControl &&
          other.perceivedRecovery == this.perceivedRecovery &&
          other.emotionalIntensity == this.emotionalIntensity &&
          other.notes == this.notes &&
          other.contextualFactors == this.contextualFactors &&
          other.physiologicalCorrelation == this.physiologicalCorrelation &&
          other.confidence == this.confidence &&
          other.relatedMarkers == this.relatedMarkers &&
          other.safetyCopy == this.safetyCopy);
}

class SubjectiveFeedbackEntriesTableCompanion
    extends UpdateCompanion<SubjectiveFeedbackEntriesTableData> {
  final Value<String> id;
  final Value<DateTime> generatedAt;
  final Value<DateTime> perceivedTimestamp;
  final Value<int> perceivedStress;
  final Value<int> perceivedFatigue;
  final Value<int> perceivedControl;
  final Value<int> perceivedRecovery;
  final Value<int> emotionalIntensity;
  final Value<String> notes;
  final Value<String> contextualFactors;
  final Value<double> physiologicalCorrelation;
  final Value<double> confidence;
  final Value<String> relatedMarkers;
  final Value<String> safetyCopy;
  final Value<int> rowid;
  const SubjectiveFeedbackEntriesTableCompanion({
    this.id = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.perceivedTimestamp = const Value.absent(),
    this.perceivedStress = const Value.absent(),
    this.perceivedFatigue = const Value.absent(),
    this.perceivedControl = const Value.absent(),
    this.perceivedRecovery = const Value.absent(),
    this.emotionalIntensity = const Value.absent(),
    this.notes = const Value.absent(),
    this.contextualFactors = const Value.absent(),
    this.physiologicalCorrelation = const Value.absent(),
    this.confidence = const Value.absent(),
    this.relatedMarkers = const Value.absent(),
    this.safetyCopy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectiveFeedbackEntriesTableCompanion.insert({
    required String id,
    required DateTime generatedAt,
    required DateTime perceivedTimestamp,
    required int perceivedStress,
    required int perceivedFatigue,
    required int perceivedControl,
    required int perceivedRecovery,
    required int emotionalIntensity,
    required String notes,
    required String contextualFactors,
    required double physiologicalCorrelation,
    required double confidence,
    required String relatedMarkers,
    required String safetyCopy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       generatedAt = Value(generatedAt),
       perceivedTimestamp = Value(perceivedTimestamp),
       perceivedStress = Value(perceivedStress),
       perceivedFatigue = Value(perceivedFatigue),
       perceivedControl = Value(perceivedControl),
       perceivedRecovery = Value(perceivedRecovery),
       emotionalIntensity = Value(emotionalIntensity),
       notes = Value(notes),
       contextualFactors = Value(contextualFactors),
       physiologicalCorrelation = Value(physiologicalCorrelation),
       confidence = Value(confidence),
       relatedMarkers = Value(relatedMarkers),
       safetyCopy = Value(safetyCopy);
  static Insertable<SubjectiveFeedbackEntriesTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? generatedAt,
    Expression<DateTime>? perceivedTimestamp,
    Expression<int>? perceivedStress,
    Expression<int>? perceivedFatigue,
    Expression<int>? perceivedControl,
    Expression<int>? perceivedRecovery,
    Expression<int>? emotionalIntensity,
    Expression<String>? notes,
    Expression<String>? contextualFactors,
    Expression<double>? physiologicalCorrelation,
    Expression<double>? confidence,
    Expression<String>? relatedMarkers,
    Expression<String>? safetyCopy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (perceivedTimestamp != null) 'perceived_timestamp': perceivedTimestamp,
      if (perceivedStress != null) 'perceived_stress': perceivedStress,
      if (perceivedFatigue != null) 'perceived_fatigue': perceivedFatigue,
      if (perceivedControl != null) 'perceived_control': perceivedControl,
      if (perceivedRecovery != null) 'perceived_recovery': perceivedRecovery,
      if (emotionalIntensity != null) 'emotional_intensity': emotionalIntensity,
      if (notes != null) 'notes': notes,
      if (contextualFactors != null) 'contextual_factors': contextualFactors,
      if (physiologicalCorrelation != null)
        'physiological_correlation': physiologicalCorrelation,
      if (confidence != null) 'confidence': confidence,
      if (relatedMarkers != null) 'related_markers': relatedMarkers,
      if (safetyCopy != null) 'safety_copy': safetyCopy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectiveFeedbackEntriesTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? generatedAt,
    Value<DateTime>? perceivedTimestamp,
    Value<int>? perceivedStress,
    Value<int>? perceivedFatigue,
    Value<int>? perceivedControl,
    Value<int>? perceivedRecovery,
    Value<int>? emotionalIntensity,
    Value<String>? notes,
    Value<String>? contextualFactors,
    Value<double>? physiologicalCorrelation,
    Value<double>? confidence,
    Value<String>? relatedMarkers,
    Value<String>? safetyCopy,
    Value<int>? rowid,
  }) {
    return SubjectiveFeedbackEntriesTableCompanion(
      id: id ?? this.id,
      generatedAt: generatedAt ?? this.generatedAt,
      perceivedTimestamp: perceivedTimestamp ?? this.perceivedTimestamp,
      perceivedStress: perceivedStress ?? this.perceivedStress,
      perceivedFatigue: perceivedFatigue ?? this.perceivedFatigue,
      perceivedControl: perceivedControl ?? this.perceivedControl,
      perceivedRecovery: perceivedRecovery ?? this.perceivedRecovery,
      emotionalIntensity: emotionalIntensity ?? this.emotionalIntensity,
      notes: notes ?? this.notes,
      contextualFactors: contextualFactors ?? this.contextualFactors,
      physiologicalCorrelation:
          physiologicalCorrelation ?? this.physiologicalCorrelation,
      confidence: confidence ?? this.confidence,
      relatedMarkers: relatedMarkers ?? this.relatedMarkers,
      safetyCopy: safetyCopy ?? this.safetyCopy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (perceivedTimestamp.present) {
      map['perceived_timestamp'] = Variable<DateTime>(perceivedTimestamp.value);
    }
    if (perceivedStress.present) {
      map['perceived_stress'] = Variable<int>(perceivedStress.value);
    }
    if (perceivedFatigue.present) {
      map['perceived_fatigue'] = Variable<int>(perceivedFatigue.value);
    }
    if (perceivedControl.present) {
      map['perceived_control'] = Variable<int>(perceivedControl.value);
    }
    if (perceivedRecovery.present) {
      map['perceived_recovery'] = Variable<int>(perceivedRecovery.value);
    }
    if (emotionalIntensity.present) {
      map['emotional_intensity'] = Variable<int>(emotionalIntensity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (contextualFactors.present) {
      map['contextual_factors'] = Variable<String>(contextualFactors.value);
    }
    if (physiologicalCorrelation.present) {
      map['physiological_correlation'] = Variable<double>(
        physiologicalCorrelation.value,
      );
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (relatedMarkers.present) {
      map['related_markers'] = Variable<String>(relatedMarkers.value);
    }
    if (safetyCopy.present) {
      map['safety_copy'] = Variable<String>(safetyCopy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectiveFeedbackEntriesTableCompanion(')
          ..write('id: $id, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('perceivedTimestamp: $perceivedTimestamp, ')
          ..write('perceivedStress: $perceivedStress, ')
          ..write('perceivedFatigue: $perceivedFatigue, ')
          ..write('perceivedControl: $perceivedControl, ')
          ..write('perceivedRecovery: $perceivedRecovery, ')
          ..write('emotionalIntensity: $emotionalIntensity, ')
          ..write('notes: $notes, ')
          ..write('contextualFactors: $contextualFactors, ')
          ..write('physiologicalCorrelation: $physiologicalCorrelation, ')
          ..write('confidence: $confidence, ')
          ..write('relatedMarkers: $relatedMarkers, ')
          ..write('safetyCopy: $safetyCopy, ')
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
  late final $AutonomicRecoveryProfilesTableTable
  autonomicRecoveryProfilesTable = $AutonomicRecoveryProfilesTableTable(this);
  late final $ResearchDashboardSnapshotsTableTable
  researchDashboardSnapshotsTable = $ResearchDashboardSnapshotsTableTable(this);
  late final $EscalationForecastsTableTable escalationForecastsTable =
      $EscalationForecastsTableTable(this);
  late final $ContextualEventsTableTable contextualEventsTable =
      $ContextualEventsTableTable(this);
  late final $ContextualTriggerCorrelationsTableTable
  contextualTriggerCorrelationsTable = $ContextualTriggerCorrelationsTableTable(
    this,
  );
  late final $InterventionLearningProfilesTableTable
  interventionLearningProfilesTable = $InterventionLearningProfilesTableTable(
    this,
  );
  late final $ContextualInterventionRecommendationsTableTable
  contextualInterventionRecommendationsTable =
      $ContextualInterventionRecommendationsTableTable(this);
  late final $CohortAnalysisResultsTableTable cohortAnalysisResultsTable =
      $CohortAnalysisResultsTableTable(this);
  late final $PhysiologicalEvolutionProfilesTableTable
  physiologicalEvolutionProfilesTable =
      $PhysiologicalEvolutionProfilesTableTable(this);
  late final $RealtimePipelineSnapshotsTableTable
  realtimePipelineSnapshotsTable = $RealtimePipelineSnapshotsTableTable(this);
  late final $ReplayScenariosTableTable replayScenariosTable =
      $ReplayScenariosTableTable(this);
  late final $ReplayValidationResultsTableTable replayValidationResultsTable =
      $ReplayValidationResultsTableTable(this);
  late final $ExperimentalInsightsTableTable experimentalInsightsTable =
      $ExperimentalInsightsTableTable(this);
  late final $SubjectiveFeedbackEntriesTableTable
  subjectiveFeedbackEntriesTable = $SubjectiveFeedbackEntriesTableTable(this);
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
    autonomicRecoveryProfilesTable,
    researchDashboardSnapshotsTable,
    escalationForecastsTable,
    contextualEventsTable,
    contextualTriggerCorrelationsTable,
    interventionLearningProfilesTable,
    contextualInterventionRecommendationsTable,
    cohortAnalysisResultsTable,
    physiologicalEvolutionProfilesTable,
    realtimePipelineSnapshotsTable,
    replayScenariosTable,
    replayValidationResultsTable,
    experimentalInsightsTable,
    subjectiveFeedbackEntriesTable,
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
typedef $$AutonomicRecoveryProfilesTableTableCreateCompanionBuilder =
    AutonomicRecoveryProfilesTableCompanion Function({
      required String id,
      required String timelineId,
      required DateTime generatedAt,
      required String windowLabel,
      required int windowSeconds,
      required double recoveryRate,
      required double hrvRecoverySlope,
      required double heartRateNormalization,
      Value<int?> baselineReturnSeconds,
      required int resilienceScore,
      required int fatigueScore,
      required double stressCarryover,
      required String resilienceLevel,
      Value<int> rowid,
    });
typedef $$AutonomicRecoveryProfilesTableTableUpdateCompanionBuilder =
    AutonomicRecoveryProfilesTableCompanion Function({
      Value<String> id,
      Value<String> timelineId,
      Value<DateTime> generatedAt,
      Value<String> windowLabel,
      Value<int> windowSeconds,
      Value<double> recoveryRate,
      Value<double> hrvRecoverySlope,
      Value<double> heartRateNormalization,
      Value<int?> baselineReturnSeconds,
      Value<int> resilienceScore,
      Value<int> fatigueScore,
      Value<double> stressCarryover,
      Value<String> resilienceLevel,
      Value<int> rowid,
    });

class $$AutonomicRecoveryProfilesTableTableFilterComposer
    extends
        Composer<_$SignalFlowDatabase, $AutonomicRecoveryProfilesTableTable> {
  $$AutonomicRecoveryProfilesTableTableFilterComposer({
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

  ColumnFilters<double> get recoveryRate => $composableBuilder(
    column: $table.recoveryRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hrvRecoverySlope => $composableBuilder(
    column: $table.hrvRecoverySlope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heartRateNormalization => $composableBuilder(
    column: $table.heartRateNormalization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baselineReturnSeconds => $composableBuilder(
    column: $table.baselineReturnSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resilienceLevel => $composableBuilder(
    column: $table.resilienceLevel,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AutonomicRecoveryProfilesTableTableOrderingComposer
    extends
        Composer<_$SignalFlowDatabase, $AutonomicRecoveryProfilesTableTable> {
  $$AutonomicRecoveryProfilesTableTableOrderingComposer({
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

  ColumnOrderings<double> get recoveryRate => $composableBuilder(
    column: $table.recoveryRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hrvRecoverySlope => $composableBuilder(
    column: $table.hrvRecoverySlope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heartRateNormalization => $composableBuilder(
    column: $table.heartRateNormalization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baselineReturnSeconds => $composableBuilder(
    column: $table.baselineReturnSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resilienceLevel => $composableBuilder(
    column: $table.resilienceLevel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AutonomicRecoveryProfilesTableTableAnnotationComposer
    extends
        Composer<_$SignalFlowDatabase, $AutonomicRecoveryProfilesTableTable> {
  $$AutonomicRecoveryProfilesTableTableAnnotationComposer({
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

  GeneratedColumn<double> get recoveryRate => $composableBuilder(
    column: $table.recoveryRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get hrvRecoverySlope => $composableBuilder(
    column: $table.hrvRecoverySlope,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heartRateNormalization => $composableBuilder(
    column: $table.heartRateNormalization,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baselineReturnSeconds => $composableBuilder(
    column: $table.baselineReturnSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resilienceLevel => $composableBuilder(
    column: $table.resilienceLevel,
    builder: (column) => column,
  );
}

class $$AutonomicRecoveryProfilesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $AutonomicRecoveryProfilesTableTable,
          AutonomicRecoveryProfilesTableData,
          $$AutonomicRecoveryProfilesTableTableFilterComposer,
          $$AutonomicRecoveryProfilesTableTableOrderingComposer,
          $$AutonomicRecoveryProfilesTableTableAnnotationComposer,
          $$AutonomicRecoveryProfilesTableTableCreateCompanionBuilder,
          $$AutonomicRecoveryProfilesTableTableUpdateCompanionBuilder,
          (
            AutonomicRecoveryProfilesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $AutonomicRecoveryProfilesTableTable,
              AutonomicRecoveryProfilesTableData
            >,
          ),
          AutonomicRecoveryProfilesTableData,
          PrefetchHooks Function()
        > {
  $$AutonomicRecoveryProfilesTableTableTableManager(
    _$SignalFlowDatabase db,
    $AutonomicRecoveryProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AutonomicRecoveryProfilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AutonomicRecoveryProfilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AutonomicRecoveryProfilesTableTableAnnotationComposer(
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
                Value<double> recoveryRate = const Value.absent(),
                Value<double> hrvRecoverySlope = const Value.absent(),
                Value<double> heartRateNormalization = const Value.absent(),
                Value<int?> baselineReturnSeconds = const Value.absent(),
                Value<int> resilienceScore = const Value.absent(),
                Value<int> fatigueScore = const Value.absent(),
                Value<double> stressCarryover = const Value.absent(),
                Value<String> resilienceLevel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AutonomicRecoveryProfilesTableCompanion(
                id: id,
                timelineId: timelineId,
                generatedAt: generatedAt,
                windowLabel: windowLabel,
                windowSeconds: windowSeconds,
                recoveryRate: recoveryRate,
                hrvRecoverySlope: hrvRecoverySlope,
                heartRateNormalization: heartRateNormalization,
                baselineReturnSeconds: baselineReturnSeconds,
                resilienceScore: resilienceScore,
                fatigueScore: fatigueScore,
                stressCarryover: stressCarryover,
                resilienceLevel: resilienceLevel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String timelineId,
                required DateTime generatedAt,
                required String windowLabel,
                required int windowSeconds,
                required double recoveryRate,
                required double hrvRecoverySlope,
                required double heartRateNormalization,
                Value<int?> baselineReturnSeconds = const Value.absent(),
                required int resilienceScore,
                required int fatigueScore,
                required double stressCarryover,
                required String resilienceLevel,
                Value<int> rowid = const Value.absent(),
              }) => AutonomicRecoveryProfilesTableCompanion.insert(
                id: id,
                timelineId: timelineId,
                generatedAt: generatedAt,
                windowLabel: windowLabel,
                windowSeconds: windowSeconds,
                recoveryRate: recoveryRate,
                hrvRecoverySlope: hrvRecoverySlope,
                heartRateNormalization: heartRateNormalization,
                baselineReturnSeconds: baselineReturnSeconds,
                resilienceScore: resilienceScore,
                fatigueScore: fatigueScore,
                stressCarryover: stressCarryover,
                resilienceLevel: resilienceLevel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AutonomicRecoveryProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $AutonomicRecoveryProfilesTableTable,
      AutonomicRecoveryProfilesTableData,
      $$AutonomicRecoveryProfilesTableTableFilterComposer,
      $$AutonomicRecoveryProfilesTableTableOrderingComposer,
      $$AutonomicRecoveryProfilesTableTableAnnotationComposer,
      $$AutonomicRecoveryProfilesTableTableCreateCompanionBuilder,
      $$AutonomicRecoveryProfilesTableTableUpdateCompanionBuilder,
      (
        AutonomicRecoveryProfilesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $AutonomicRecoveryProfilesTableTable,
          AutonomicRecoveryProfilesTableData
        >,
      ),
      AutonomicRecoveryProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$ResearchDashboardSnapshotsTableTableCreateCompanionBuilder =
    ResearchDashboardSnapshotsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      required double averageConfidence,
      required int escalationCount,
      required int interventionCount,
      required double recoveryEfficiency,
      required int resilienceScore,
      required int fatigueScore,
      required double activationDensity,
      required double baselineStability,
      required double stressCarryover,
      required bool improvingTrend,
      required bool worseningTrend,
      required bool recoveryTrend,
      required bool confidenceTrend,
      required bool circadianStability,
      required double autonomicLoad,
      Value<int> rowid,
    });
typedef $$ResearchDashboardSnapshotsTableTableUpdateCompanionBuilder =
    ResearchDashboardSnapshotsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<double?> averageHeartRate,
      Value<double?> averageHrv,
      Value<double> averageConfidence,
      Value<int> escalationCount,
      Value<int> interventionCount,
      Value<double> recoveryEfficiency,
      Value<int> resilienceScore,
      Value<int> fatigueScore,
      Value<double> activationDensity,
      Value<double> baselineStability,
      Value<double> stressCarryover,
      Value<bool> improvingTrend,
      Value<bool> worseningTrend,
      Value<bool> recoveryTrend,
      Value<bool> confidenceTrend,
      Value<bool> circadianStability,
      Value<double> autonomicLoad,
      Value<int> rowid,
    });

class $$ResearchDashboardSnapshotsTableTableFilterComposer
    extends
        Composer<_$SignalFlowDatabase, $ResearchDashboardSnapshotsTableTable> {
  $$ResearchDashboardSnapshotsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
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

  ColumnFilters<double> get averageConfidence => $composableBuilder(
    column: $table.averageConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get escalationCount => $composableBuilder(
    column: $table.escalationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interventionCount => $composableBuilder(
    column: $table.interventionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryEfficiency => $composableBuilder(
    column: $table.recoveryEfficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baselineStability => $composableBuilder(
    column: $table.baselineStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get improvingTrend => $composableBuilder(
    column: $table.improvingTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get worseningTrend => $composableBuilder(
    column: $table.worseningTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confidenceTrend => $composableBuilder(
    column: $table.confidenceTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get circadianStability => $composableBuilder(
    column: $table.circadianStability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResearchDashboardSnapshotsTableTableOrderingComposer
    extends
        Composer<_$SignalFlowDatabase, $ResearchDashboardSnapshotsTableTable> {
  $$ResearchDashboardSnapshotsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
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

  ColumnOrderings<double> get averageConfidence => $composableBuilder(
    column: $table.averageConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get escalationCount => $composableBuilder(
    column: $table.escalationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interventionCount => $composableBuilder(
    column: $table.interventionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryEfficiency => $composableBuilder(
    column: $table.recoveryEfficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baselineStability => $composableBuilder(
    column: $table.baselineStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get improvingTrend => $composableBuilder(
    column: $table.improvingTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get worseningTrend => $composableBuilder(
    column: $table.worseningTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confidenceTrend => $composableBuilder(
    column: $table.confidenceTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get circadianStability => $composableBuilder(
    column: $table.circadianStability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResearchDashboardSnapshotsTableTableAnnotationComposer
    extends
        Composer<_$SignalFlowDatabase, $ResearchDashboardSnapshotsTableTable> {
  $$ResearchDashboardSnapshotsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
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

  GeneratedColumn<double> get averageConfidence => $composableBuilder(
    column: $table.averageConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get escalationCount => $composableBuilder(
    column: $table.escalationCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interventionCount => $composableBuilder(
    column: $table.interventionCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryEfficiency => $composableBuilder(
    column: $table.recoveryEfficiency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resilienceScore => $composableBuilder(
    column: $table.resilienceScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatigueScore => $composableBuilder(
    column: $table.fatigueScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get activationDensity => $composableBuilder(
    column: $table.activationDensity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get baselineStability => $composableBuilder(
    column: $table.baselineStability,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stressCarryover => $composableBuilder(
    column: $table.stressCarryover,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get improvingTrend => $composableBuilder(
    column: $table.improvingTrend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get worseningTrend => $composableBuilder(
    column: $table.worseningTrend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confidenceTrend => $composableBuilder(
    column: $table.confidenceTrend,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get circadianStability => $composableBuilder(
    column: $table.circadianStability,
    builder: (column) => column,
  );

  GeneratedColumn<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => column,
  );
}

class $$ResearchDashboardSnapshotsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ResearchDashboardSnapshotsTableTable,
          ResearchDashboardSnapshotsTableData,
          $$ResearchDashboardSnapshotsTableTableFilterComposer,
          $$ResearchDashboardSnapshotsTableTableOrderingComposer,
          $$ResearchDashboardSnapshotsTableTableAnnotationComposer,
          $$ResearchDashboardSnapshotsTableTableCreateCompanionBuilder,
          $$ResearchDashboardSnapshotsTableTableUpdateCompanionBuilder,
          (
            ResearchDashboardSnapshotsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ResearchDashboardSnapshotsTableTable,
              ResearchDashboardSnapshotsTableData
            >,
          ),
          ResearchDashboardSnapshotsTableData,
          PrefetchHooks Function()
        > {
  $$ResearchDashboardSnapshotsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ResearchDashboardSnapshotsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResearchDashboardSnapshotsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ResearchDashboardSnapshotsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ResearchDashboardSnapshotsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                Value<double> averageConfidence = const Value.absent(),
                Value<int> escalationCount = const Value.absent(),
                Value<int> interventionCount = const Value.absent(),
                Value<double> recoveryEfficiency = const Value.absent(),
                Value<int> resilienceScore = const Value.absent(),
                Value<int> fatigueScore = const Value.absent(),
                Value<double> activationDensity = const Value.absent(),
                Value<double> baselineStability = const Value.absent(),
                Value<double> stressCarryover = const Value.absent(),
                Value<bool> improvingTrend = const Value.absent(),
                Value<bool> worseningTrend = const Value.absent(),
                Value<bool> recoveryTrend = const Value.absent(),
                Value<bool> confidenceTrend = const Value.absent(),
                Value<bool> circadianStability = const Value.absent(),
                Value<double> autonomicLoad = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResearchDashboardSnapshotsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                averageConfidence: averageConfidence,
                escalationCount: escalationCount,
                interventionCount: interventionCount,
                recoveryEfficiency: recoveryEfficiency,
                resilienceScore: resilienceScore,
                fatigueScore: fatigueScore,
                activationDensity: activationDensity,
                baselineStability: baselineStability,
                stressCarryover: stressCarryover,
                improvingTrend: improvingTrend,
                worseningTrend: worseningTrend,
                recoveryTrend: recoveryTrend,
                confidenceTrend: confidenceTrend,
                circadianStability: circadianStability,
                autonomicLoad: autonomicLoad,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                Value<double?> averageHeartRate = const Value.absent(),
                Value<double?> averageHrv = const Value.absent(),
                required double averageConfidence,
                required int escalationCount,
                required int interventionCount,
                required double recoveryEfficiency,
                required int resilienceScore,
                required int fatigueScore,
                required double activationDensity,
                required double baselineStability,
                required double stressCarryover,
                required bool improvingTrend,
                required bool worseningTrend,
                required bool recoveryTrend,
                required bool confidenceTrend,
                required bool circadianStability,
                required double autonomicLoad,
                Value<int> rowid = const Value.absent(),
              }) => ResearchDashboardSnapshotsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                averageHeartRate: averageHeartRate,
                averageHrv: averageHrv,
                averageConfidence: averageConfidence,
                escalationCount: escalationCount,
                interventionCount: interventionCount,
                recoveryEfficiency: recoveryEfficiency,
                resilienceScore: resilienceScore,
                fatigueScore: fatigueScore,
                activationDensity: activationDensity,
                baselineStability: baselineStability,
                stressCarryover: stressCarryover,
                improvingTrend: improvingTrend,
                worseningTrend: worseningTrend,
                recoveryTrend: recoveryTrend,
                confidenceTrend: confidenceTrend,
                circadianStability: circadianStability,
                autonomicLoad: autonomicLoad,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResearchDashboardSnapshotsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ResearchDashboardSnapshotsTableTable,
      ResearchDashboardSnapshotsTableData,
      $$ResearchDashboardSnapshotsTableTableFilterComposer,
      $$ResearchDashboardSnapshotsTableTableOrderingComposer,
      $$ResearchDashboardSnapshotsTableTableAnnotationComposer,
      $$ResearchDashboardSnapshotsTableTableCreateCompanionBuilder,
      $$ResearchDashboardSnapshotsTableTableUpdateCompanionBuilder,
      (
        ResearchDashboardSnapshotsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ResearchDashboardSnapshotsTableTable,
          ResearchDashboardSnapshotsTableData
        >,
      ),
      ResearchDashboardSnapshotsTableData,
      PrefetchHooks Function()
    >;
typedef $$EscalationForecastsTableTableCreateCompanionBuilder =
    EscalationForecastsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required int forecastWindowSeconds,
      required String forecastWindowLabel,
      required double escalationProbability,
      required int forecastConfidence,
      required String forecastConfidenceLevel,
      required String escalationRiskLevel,
      required String contributingFactorsJson,
      required double recoveryProtection,
      required double autonomicLoad,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$EscalationForecastsTableTableUpdateCompanionBuilder =
    EscalationForecastsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<int> forecastWindowSeconds,
      Value<String> forecastWindowLabel,
      Value<double> escalationProbability,
      Value<int> forecastConfidence,
      Value<String> forecastConfidenceLevel,
      Value<String> escalationRiskLevel,
      Value<String> contributingFactorsJson,
      Value<double> recoveryProtection,
      Value<double> autonomicLoad,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$EscalationForecastsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $EscalationForecastsTableTable> {
  $$EscalationForecastsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get forecastWindowSeconds => $composableBuilder(
    column: $table.forecastWindowSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forecastWindowLabel => $composableBuilder(
    column: $table.forecastWindowLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get escalationProbability => $composableBuilder(
    column: $table.escalationProbability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get forecastConfidence => $composableBuilder(
    column: $table.forecastConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forecastConfidenceLevel => $composableBuilder(
    column: $table.forecastConfidenceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get escalationRiskLevel => $composableBuilder(
    column: $table.escalationRiskLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contributingFactorsJson => $composableBuilder(
    column: $table.contributingFactorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryProtection => $composableBuilder(
    column: $table.recoveryProtection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EscalationForecastsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $EscalationForecastsTableTable> {
  $$EscalationForecastsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get forecastWindowSeconds => $composableBuilder(
    column: $table.forecastWindowSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forecastWindowLabel => $composableBuilder(
    column: $table.forecastWindowLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get escalationProbability => $composableBuilder(
    column: $table.escalationProbability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get forecastConfidence => $composableBuilder(
    column: $table.forecastConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forecastConfidenceLevel => $composableBuilder(
    column: $table.forecastConfidenceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get escalationRiskLevel => $composableBuilder(
    column: $table.escalationRiskLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contributingFactorsJson => $composableBuilder(
    column: $table.contributingFactorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryProtection => $composableBuilder(
    column: $table.recoveryProtection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EscalationForecastsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $EscalationForecastsTableTable> {
  $$EscalationForecastsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get forecastWindowSeconds => $composableBuilder(
    column: $table.forecastWindowSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forecastWindowLabel => $composableBuilder(
    column: $table.forecastWindowLabel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get escalationProbability => $composableBuilder(
    column: $table.escalationProbability,
    builder: (column) => column,
  );

  GeneratedColumn<int> get forecastConfidence => $composableBuilder(
    column: $table.forecastConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forecastConfidenceLevel => $composableBuilder(
    column: $table.forecastConfidenceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get escalationRiskLevel => $composableBuilder(
    column: $table.escalationRiskLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contributingFactorsJson => $composableBuilder(
    column: $table.contributingFactorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryProtection => $composableBuilder(
    column: $table.recoveryProtection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get autonomicLoad => $composableBuilder(
    column: $table.autonomicLoad,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$EscalationForecastsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $EscalationForecastsTableTable,
          EscalationForecastsTableData,
          $$EscalationForecastsTableTableFilterComposer,
          $$EscalationForecastsTableTableOrderingComposer,
          $$EscalationForecastsTableTableAnnotationComposer,
          $$EscalationForecastsTableTableCreateCompanionBuilder,
          $$EscalationForecastsTableTableUpdateCompanionBuilder,
          (
            EscalationForecastsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $EscalationForecastsTableTable,
              EscalationForecastsTableData
            >,
          ),
          EscalationForecastsTableData,
          PrefetchHooks Function()
        > {
  $$EscalationForecastsTableTableTableManager(
    _$SignalFlowDatabase db,
    $EscalationForecastsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EscalationForecastsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$EscalationForecastsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EscalationForecastsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> forecastWindowSeconds = const Value.absent(),
                Value<String> forecastWindowLabel = const Value.absent(),
                Value<double> escalationProbability = const Value.absent(),
                Value<int> forecastConfidence = const Value.absent(),
                Value<String> forecastConfidenceLevel = const Value.absent(),
                Value<String> escalationRiskLevel = const Value.absent(),
                Value<String> contributingFactorsJson = const Value.absent(),
                Value<double> recoveryProtection = const Value.absent(),
                Value<double> autonomicLoad = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EscalationForecastsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                forecastWindowSeconds: forecastWindowSeconds,
                forecastWindowLabel: forecastWindowLabel,
                escalationProbability: escalationProbability,
                forecastConfidence: forecastConfidence,
                forecastConfidenceLevel: forecastConfidenceLevel,
                escalationRiskLevel: escalationRiskLevel,
                contributingFactorsJson: contributingFactorsJson,
                recoveryProtection: recoveryProtection,
                autonomicLoad: autonomicLoad,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required int forecastWindowSeconds,
                required String forecastWindowLabel,
                required double escalationProbability,
                required int forecastConfidence,
                required String forecastConfidenceLevel,
                required String escalationRiskLevel,
                required String contributingFactorsJson,
                required double recoveryProtection,
                required double autonomicLoad,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => EscalationForecastsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                forecastWindowSeconds: forecastWindowSeconds,
                forecastWindowLabel: forecastWindowLabel,
                escalationProbability: escalationProbability,
                forecastConfidence: forecastConfidence,
                forecastConfidenceLevel: forecastConfidenceLevel,
                escalationRiskLevel: escalationRiskLevel,
                contributingFactorsJson: contributingFactorsJson,
                recoveryProtection: recoveryProtection,
                autonomicLoad: autonomicLoad,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EscalationForecastsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $EscalationForecastsTableTable,
      EscalationForecastsTableData,
      $$EscalationForecastsTableTableFilterComposer,
      $$EscalationForecastsTableTableOrderingComposer,
      $$EscalationForecastsTableTableAnnotationComposer,
      $$EscalationForecastsTableTableCreateCompanionBuilder,
      $$EscalationForecastsTableTableUpdateCompanionBuilder,
      (
        EscalationForecastsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $EscalationForecastsTableTable,
          EscalationForecastsTableData
        >,
      ),
      EscalationForecastsTableData,
      PrefetchHooks Function()
    >;
typedef $$ContextualEventsTableTableCreateCompanionBuilder =
    ContextualEventsTableCompanion Function({
      required String id,
      required DateTime timestamp,
      required String category,
      required String label,
      required String description,
      required String intensity,
      required String source,
      Value<int> rowid,
    });
typedef $$ContextualEventsTableTableUpdateCompanionBuilder =
    ContextualEventsTableCompanion Function({
      Value<String> id,
      Value<DateTime> timestamp,
      Value<String> category,
      Value<String> label,
      Value<String> description,
      Value<String> intensity,
      Value<String> source,
      Value<int> rowid,
    });

class $$ContextualEventsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $ContextualEventsTableTable> {
  $$ContextualEventsTableTableFilterComposer({
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

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContextualEventsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $ContextualEventsTableTable> {
  $$ContextualEventsTableTableOrderingComposer({
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

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextualEventsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $ContextualEventsTableTable> {
  $$ContextualEventsTableTableAnnotationComposer({
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

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$ContextualEventsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ContextualEventsTableTable,
          ContextualEventsTableData,
          $$ContextualEventsTableTableFilterComposer,
          $$ContextualEventsTableTableOrderingComposer,
          $$ContextualEventsTableTableAnnotationComposer,
          $$ContextualEventsTableTableCreateCompanionBuilder,
          $$ContextualEventsTableTableUpdateCompanionBuilder,
          (
            ContextualEventsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ContextualEventsTableTable,
              ContextualEventsTableData
            >,
          ),
          ContextualEventsTableData,
          PrefetchHooks Function()
        > {
  $$ContextualEventsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ContextualEventsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextualEventsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContextualEventsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContextualEventsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> intensity = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextualEventsTableCompanion(
                id: id,
                timestamp: timestamp,
                category: category,
                label: label,
                description: description,
                intensity: intensity,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime timestamp,
                required String category,
                required String label,
                required String description,
                required String intensity,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => ContextualEventsTableCompanion.insert(
                id: id,
                timestamp: timestamp,
                category: category,
                label: label,
                description: description,
                intensity: intensity,
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

typedef $$ContextualEventsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ContextualEventsTableTable,
      ContextualEventsTableData,
      $$ContextualEventsTableTableFilterComposer,
      $$ContextualEventsTableTableOrderingComposer,
      $$ContextualEventsTableTableAnnotationComposer,
      $$ContextualEventsTableTableCreateCompanionBuilder,
      $$ContextualEventsTableTableUpdateCompanionBuilder,
      (
        ContextualEventsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ContextualEventsTableTable,
          ContextualEventsTableData
        >,
      ),
      ContextualEventsTableData,
      PrefetchHooks Function()
    >;
typedef $$ContextualTriggerCorrelationsTableTableCreateCompanionBuilder =
    ContextualTriggerCorrelationsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required String category,
      required int occurrenceCount,
      required double escalationCorrelation,
      required double recoveryImpact,
      required double confidence,
      Value<DateTime?> lastOccurrence,
      required String associatedMarkersJson,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$ContextualTriggerCorrelationsTableTableUpdateCompanionBuilder =
    ContextualTriggerCorrelationsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<String> category,
      Value<int> occurrenceCount,
      Value<double> escalationCorrelation,
      Value<double> recoveryImpact,
      Value<double> confidence,
      Value<DateTime?> lastOccurrence,
      Value<String> associatedMarkersJson,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$ContextualTriggerCorrelationsTableTableFilterComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualTriggerCorrelationsTableTable
        > {
  $$ContextualTriggerCorrelationsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get escalationCorrelation => $composableBuilder(
    column: $table.escalationCorrelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryImpact => $composableBuilder(
    column: $table.recoveryImpact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOccurrence => $composableBuilder(
    column: $table.lastOccurrence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get associatedMarkersJson => $composableBuilder(
    column: $table.associatedMarkersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContextualTriggerCorrelationsTableTableOrderingComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualTriggerCorrelationsTableTable
        > {
  $$ContextualTriggerCorrelationsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get escalationCorrelation => $composableBuilder(
    column: $table.escalationCorrelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryImpact => $composableBuilder(
    column: $table.recoveryImpact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOccurrence => $composableBuilder(
    column: $table.lastOccurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get associatedMarkersJson => $composableBuilder(
    column: $table.associatedMarkersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextualTriggerCorrelationsTableTableAnnotationComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualTriggerCorrelationsTableTable
        > {
  $$ContextualTriggerCorrelationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get occurrenceCount => $composableBuilder(
    column: $table.occurrenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get escalationCorrelation => $composableBuilder(
    column: $table.escalationCorrelation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryImpact => $composableBuilder(
    column: $table.recoveryImpact,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOccurrence => $composableBuilder(
    column: $table.lastOccurrence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get associatedMarkersJson => $composableBuilder(
    column: $table.associatedMarkersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$ContextualTriggerCorrelationsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ContextualTriggerCorrelationsTableTable,
          ContextualTriggerCorrelationsTableData,
          $$ContextualTriggerCorrelationsTableTableFilterComposer,
          $$ContextualTriggerCorrelationsTableTableOrderingComposer,
          $$ContextualTriggerCorrelationsTableTableAnnotationComposer,
          $$ContextualTriggerCorrelationsTableTableCreateCompanionBuilder,
          $$ContextualTriggerCorrelationsTableTableUpdateCompanionBuilder,
          (
            ContextualTriggerCorrelationsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ContextualTriggerCorrelationsTableTable,
              ContextualTriggerCorrelationsTableData
            >,
          ),
          ContextualTriggerCorrelationsTableData,
          PrefetchHooks Function()
        > {
  $$ContextualTriggerCorrelationsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ContextualTriggerCorrelationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextualTriggerCorrelationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContextualTriggerCorrelationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContextualTriggerCorrelationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> occurrenceCount = const Value.absent(),
                Value<double> escalationCorrelation = const Value.absent(),
                Value<double> recoveryImpact = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<DateTime?> lastOccurrence = const Value.absent(),
                Value<String> associatedMarkersJson = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextualTriggerCorrelationsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                category: category,
                occurrenceCount: occurrenceCount,
                escalationCorrelation: escalationCorrelation,
                recoveryImpact: recoveryImpact,
                confidence: confidence,
                lastOccurrence: lastOccurrence,
                associatedMarkersJson: associatedMarkersJson,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required String category,
                required int occurrenceCount,
                required double escalationCorrelation,
                required double recoveryImpact,
                required double confidence,
                Value<DateTime?> lastOccurrence = const Value.absent(),
                required String associatedMarkersJson,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => ContextualTriggerCorrelationsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                category: category,
                occurrenceCount: occurrenceCount,
                escalationCorrelation: escalationCorrelation,
                recoveryImpact: recoveryImpact,
                confidence: confidence,
                lastOccurrence: lastOccurrence,
                associatedMarkersJson: associatedMarkersJson,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContextualTriggerCorrelationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ContextualTriggerCorrelationsTableTable,
      ContextualTriggerCorrelationsTableData,
      $$ContextualTriggerCorrelationsTableTableFilterComposer,
      $$ContextualTriggerCorrelationsTableTableOrderingComposer,
      $$ContextualTriggerCorrelationsTableTableAnnotationComposer,
      $$ContextualTriggerCorrelationsTableTableCreateCompanionBuilder,
      $$ContextualTriggerCorrelationsTableTableUpdateCompanionBuilder,
      (
        ContextualTriggerCorrelationsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ContextualTriggerCorrelationsTableTable,
          ContextualTriggerCorrelationsTableData
        >,
      ),
      ContextualTriggerCorrelationsTableData,
      PrefetchHooks Function()
    >;
typedef $$InterventionLearningProfilesTableTableCreateCompanionBuilder =
    InterventionLearningProfilesTableCompanion Function({
      required String interventionType,
      required double successRate,
      required int averageRecoveryTimeSeconds,
      required double averageRecoveryImprovement,
      required String contextualPerformanceJson,
      required String circadianPerformanceJson,
      required double confidence,
      required int usageCount,
      required DateTime updatedAt,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$InterventionLearningProfilesTableTableUpdateCompanionBuilder =
    InterventionLearningProfilesTableCompanion Function({
      Value<String> interventionType,
      Value<double> successRate,
      Value<int> averageRecoveryTimeSeconds,
      Value<double> averageRecoveryImprovement,
      Value<String> contextualPerformanceJson,
      Value<String> circadianPerformanceJson,
      Value<double> confidence,
      Value<int> usageCount,
      Value<DateTime> updatedAt,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$InterventionLearningProfilesTableTableFilterComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $InterventionLearningProfilesTableTable
        > {
  $$InterventionLearningProfilesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get averageRecoveryTimeSeconds => $composableBuilder(
    column: $table.averageRecoveryTimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRecoveryImprovement => $composableBuilder(
    column: $table.averageRecoveryImprovement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextualPerformanceJson => $composableBuilder(
    column: $table.contextualPerformanceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circadianPerformanceJson => $composableBuilder(
    column: $table.circadianPerformanceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterventionLearningProfilesTableTableOrderingComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $InterventionLearningProfilesTableTable
        > {
  $$InterventionLearningProfilesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get averageRecoveryTimeSeconds => $composableBuilder(
    column: $table.averageRecoveryTimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRecoveryImprovement => $composableBuilder(
    column: $table.averageRecoveryImprovement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextualPerformanceJson => $composableBuilder(
    column: $table.contextualPerformanceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circadianPerformanceJson => $composableBuilder(
    column: $table.circadianPerformanceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterventionLearningProfilesTableTableAnnotationComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $InterventionLearningProfilesTableTable
        > {
  $$InterventionLearningProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get successRate => $composableBuilder(
    column: $table.successRate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get averageRecoveryTimeSeconds => $composableBuilder(
    column: $table.averageRecoveryTimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRecoveryImprovement => $composableBuilder(
    column: $table.averageRecoveryImprovement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextualPerformanceJson => $composableBuilder(
    column: $table.contextualPerformanceJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get circadianPerformanceJson => $composableBuilder(
    column: $table.circadianPerformanceJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageCount => $composableBuilder(
    column: $table.usageCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$InterventionLearningProfilesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $InterventionLearningProfilesTableTable,
          InterventionLearningProfilesTableData,
          $$InterventionLearningProfilesTableTableFilterComposer,
          $$InterventionLearningProfilesTableTableOrderingComposer,
          $$InterventionLearningProfilesTableTableAnnotationComposer,
          $$InterventionLearningProfilesTableTableCreateCompanionBuilder,
          $$InterventionLearningProfilesTableTableUpdateCompanionBuilder,
          (
            InterventionLearningProfilesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $InterventionLearningProfilesTableTable,
              InterventionLearningProfilesTableData
            >,
          ),
          InterventionLearningProfilesTableData,
          PrefetchHooks Function()
        > {
  $$InterventionLearningProfilesTableTableTableManager(
    _$SignalFlowDatabase db,
    $InterventionLearningProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterventionLearningProfilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InterventionLearningProfilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InterventionLearningProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> interventionType = const Value.absent(),
                Value<double> successRate = const Value.absent(),
                Value<int> averageRecoveryTimeSeconds = const Value.absent(),
                Value<double> averageRecoveryImprovement = const Value.absent(),
                Value<String> contextualPerformanceJson = const Value.absent(),
                Value<String> circadianPerformanceJson = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> usageCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionLearningProfilesTableCompanion(
                interventionType: interventionType,
                successRate: successRate,
                averageRecoveryTimeSeconds: averageRecoveryTimeSeconds,
                averageRecoveryImprovement: averageRecoveryImprovement,
                contextualPerformanceJson: contextualPerformanceJson,
                circadianPerformanceJson: circadianPerformanceJson,
                confidence: confidence,
                usageCount: usageCount,
                updatedAt: updatedAt,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String interventionType,
                required double successRate,
                required int averageRecoveryTimeSeconds,
                required double averageRecoveryImprovement,
                required String contextualPerformanceJson,
                required String circadianPerformanceJson,
                required double confidence,
                required int usageCount,
                required DateTime updatedAt,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => InterventionLearningProfilesTableCompanion.insert(
                interventionType: interventionType,
                successRate: successRate,
                averageRecoveryTimeSeconds: averageRecoveryTimeSeconds,
                averageRecoveryImprovement: averageRecoveryImprovement,
                contextualPerformanceJson: contextualPerformanceJson,
                circadianPerformanceJson: circadianPerformanceJson,
                confidence: confidence,
                usageCount: usageCount,
                updatedAt: updatedAt,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterventionLearningProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $InterventionLearningProfilesTableTable,
      InterventionLearningProfilesTableData,
      $$InterventionLearningProfilesTableTableFilterComposer,
      $$InterventionLearningProfilesTableTableOrderingComposer,
      $$InterventionLearningProfilesTableTableAnnotationComposer,
      $$InterventionLearningProfilesTableTableCreateCompanionBuilder,
      $$InterventionLearningProfilesTableTableUpdateCompanionBuilder,
      (
        InterventionLearningProfilesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $InterventionLearningProfilesTableTable,
          InterventionLearningProfilesTableData
        >,
      ),
      InterventionLearningProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$ContextualInterventionRecommendationsTableTableCreateCompanionBuilder =
    ContextualInterventionRecommendationsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required String interventionType,
      required double recommendationScore,
      required double expectedRecoveryBenefit,
      required double confidence,
      required String contextualFactorsJson,
      required String physiologicalFactorsJson,
      required String recoveryFactorsJson,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$ContextualInterventionRecommendationsTableTableUpdateCompanionBuilder =
    ContextualInterventionRecommendationsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<String> interventionType,
      Value<double> recommendationScore,
      Value<double> expectedRecoveryBenefit,
      Value<double> confidence,
      Value<String> contextualFactorsJson,
      Value<String> physiologicalFactorsJson,
      Value<String> recoveryFactorsJson,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$ContextualInterventionRecommendationsTableTableFilterComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualInterventionRecommendationsTableTable
        > {
  $$ContextualInterventionRecommendationsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recommendationScore => $composableBuilder(
    column: $table.recommendationScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get expectedRecoveryBenefit => $composableBuilder(
    column: $table.expectedRecoveryBenefit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextualFactorsJson => $composableBuilder(
    column: $table.contextualFactorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get physiologicalFactorsJson => $composableBuilder(
    column: $table.physiologicalFactorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryFactorsJson => $composableBuilder(
    column: $table.recoveryFactorsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContextualInterventionRecommendationsTableTableOrderingComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualInterventionRecommendationsTableTable
        > {
  $$ContextualInterventionRecommendationsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recommendationScore => $composableBuilder(
    column: $table.recommendationScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get expectedRecoveryBenefit => $composableBuilder(
    column: $table.expectedRecoveryBenefit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextualFactorsJson => $composableBuilder(
    column: $table.contextualFactorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get physiologicalFactorsJson => $composableBuilder(
    column: $table.physiologicalFactorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryFactorsJson => $composableBuilder(
    column: $table.recoveryFactorsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContextualInterventionRecommendationsTableTableAnnotationComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $ContextualInterventionRecommendationsTableTable
        > {
  $$ContextualInterventionRecommendationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get interventionType => $composableBuilder(
    column: $table.interventionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recommendationScore => $composableBuilder(
    column: $table.recommendationScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get expectedRecoveryBenefit => $composableBuilder(
    column: $table.expectedRecoveryBenefit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextualFactorsJson => $composableBuilder(
    column: $table.contextualFactorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get physiologicalFactorsJson => $composableBuilder(
    column: $table.physiologicalFactorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoveryFactorsJson => $composableBuilder(
    column: $table.recoveryFactorsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$ContextualInterventionRecommendationsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ContextualInterventionRecommendationsTableTable,
          ContextualInterventionRecommendationsTableData,
          $$ContextualInterventionRecommendationsTableTableFilterComposer,
          $$ContextualInterventionRecommendationsTableTableOrderingComposer,
          $$ContextualInterventionRecommendationsTableTableAnnotationComposer,
          $$ContextualInterventionRecommendationsTableTableCreateCompanionBuilder,
          $$ContextualInterventionRecommendationsTableTableUpdateCompanionBuilder,
          (
            ContextualInterventionRecommendationsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ContextualInterventionRecommendationsTableTable,
              ContextualInterventionRecommendationsTableData
            >,
          ),
          ContextualInterventionRecommendationsTableData,
          PrefetchHooks Function()
        > {
  $$ContextualInterventionRecommendationsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ContextualInterventionRecommendationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContextualInterventionRecommendationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ContextualInterventionRecommendationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ContextualInterventionRecommendationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> interventionType = const Value.absent(),
                Value<double> recommendationScore = const Value.absent(),
                Value<double> expectedRecoveryBenefit = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> contextualFactorsJson = const Value.absent(),
                Value<String> physiologicalFactorsJson = const Value.absent(),
                Value<String> recoveryFactorsJson = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContextualInterventionRecommendationsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                interventionType: interventionType,
                recommendationScore: recommendationScore,
                expectedRecoveryBenefit: expectedRecoveryBenefit,
                confidence: confidence,
                contextualFactorsJson: contextualFactorsJson,
                physiologicalFactorsJson: physiologicalFactorsJson,
                recoveryFactorsJson: recoveryFactorsJson,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required String interventionType,
                required double recommendationScore,
                required double expectedRecoveryBenefit,
                required double confidence,
                required String contextualFactorsJson,
                required String physiologicalFactorsJson,
                required String recoveryFactorsJson,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => ContextualInterventionRecommendationsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                interventionType: interventionType,
                recommendationScore: recommendationScore,
                expectedRecoveryBenefit: expectedRecoveryBenefit,
                confidence: confidence,
                contextualFactorsJson: contextualFactorsJson,
                physiologicalFactorsJson: physiologicalFactorsJson,
                recoveryFactorsJson: recoveryFactorsJson,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContextualInterventionRecommendationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ContextualInterventionRecommendationsTableTable,
      ContextualInterventionRecommendationsTableData,
      $$ContextualInterventionRecommendationsTableTableFilterComposer,
      $$ContextualInterventionRecommendationsTableTableOrderingComposer,
      $$ContextualInterventionRecommendationsTableTableAnnotationComposer,
      $$ContextualInterventionRecommendationsTableTableCreateCompanionBuilder,
      $$ContextualInterventionRecommendationsTableTableUpdateCompanionBuilder,
      (
        ContextualInterventionRecommendationsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ContextualInterventionRecommendationsTableTable,
          ContextualInterventionRecommendationsTableData
        >,
      ),
      ContextualInterventionRecommendationsTableData,
      PrefetchHooks Function()
    >;
typedef $$CohortAnalysisResultsTableTableCreateCompanionBuilder =
    CohortAnalysisResultsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required int comparedSessions,
      required double averageRecoveryEfficiency,
      required double averageEscalationProbability,
      required double averageResilience,
      required double stabilityScore,
      required double variabilityScore,
      required double contextualConsistency,
      required double longitudinalConfidence,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$CohortAnalysisResultsTableTableUpdateCompanionBuilder =
    CohortAnalysisResultsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<int> comparedSessions,
      Value<double> averageRecoveryEfficiency,
      Value<double> averageEscalationProbability,
      Value<double> averageResilience,
      Value<double> stabilityScore,
      Value<double> variabilityScore,
      Value<double> contextualConsistency,
      Value<double> longitudinalConfidence,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$CohortAnalysisResultsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $CohortAnalysisResultsTableTable> {
  $$CohortAnalysisResultsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get comparedSessions => $composableBuilder(
    column: $table.comparedSessions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageRecoveryEfficiency => $composableBuilder(
    column: $table.averageRecoveryEfficiency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageEscalationProbability => $composableBuilder(
    column: $table.averageEscalationProbability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageResilience => $composableBuilder(
    column: $table.averageResilience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stabilityScore => $composableBuilder(
    column: $table.stabilityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get variabilityScore => $composableBuilder(
    column: $table.variabilityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get contextualConsistency => $composableBuilder(
    column: $table.contextualConsistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitudinalConfidence => $composableBuilder(
    column: $table.longitudinalConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CohortAnalysisResultsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $CohortAnalysisResultsTableTable> {
  $$CohortAnalysisResultsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get comparedSessions => $composableBuilder(
    column: $table.comparedSessions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageRecoveryEfficiency => $composableBuilder(
    column: $table.averageRecoveryEfficiency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageEscalationProbability =>
      $composableBuilder(
        column: $table.averageEscalationProbability,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get averageResilience => $composableBuilder(
    column: $table.averageResilience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stabilityScore => $composableBuilder(
    column: $table.stabilityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get variabilityScore => $composableBuilder(
    column: $table.variabilityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get contextualConsistency => $composableBuilder(
    column: $table.contextualConsistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitudinalConfidence => $composableBuilder(
    column: $table.longitudinalConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CohortAnalysisResultsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $CohortAnalysisResultsTableTable> {
  $$CohortAnalysisResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get comparedSessions => $composableBuilder(
    column: $table.comparedSessions,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageRecoveryEfficiency => $composableBuilder(
    column: $table.averageRecoveryEfficiency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageEscalationProbability =>
      $composableBuilder(
        column: $table.averageEscalationProbability,
        builder: (column) => column,
      );

  GeneratedColumn<double> get averageResilience => $composableBuilder(
    column: $table.averageResilience,
    builder: (column) => column,
  );

  GeneratedColumn<double> get stabilityScore => $composableBuilder(
    column: $table.stabilityScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get variabilityScore => $composableBuilder(
    column: $table.variabilityScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get contextualConsistency => $composableBuilder(
    column: $table.contextualConsistency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get longitudinalConfidence => $composableBuilder(
    column: $table.longitudinalConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$CohortAnalysisResultsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $CohortAnalysisResultsTableTable,
          CohortAnalysisResultsTableData,
          $$CohortAnalysisResultsTableTableFilterComposer,
          $$CohortAnalysisResultsTableTableOrderingComposer,
          $$CohortAnalysisResultsTableTableAnnotationComposer,
          $$CohortAnalysisResultsTableTableCreateCompanionBuilder,
          $$CohortAnalysisResultsTableTableUpdateCompanionBuilder,
          (
            CohortAnalysisResultsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $CohortAnalysisResultsTableTable,
              CohortAnalysisResultsTableData
            >,
          ),
          CohortAnalysisResultsTableData,
          PrefetchHooks Function()
        > {
  $$CohortAnalysisResultsTableTableTableManager(
    _$SignalFlowDatabase db,
    $CohortAnalysisResultsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CohortAnalysisResultsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CohortAnalysisResultsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CohortAnalysisResultsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> comparedSessions = const Value.absent(),
                Value<double> averageRecoveryEfficiency = const Value.absent(),
                Value<double> averageEscalationProbability =
                    const Value.absent(),
                Value<double> averageResilience = const Value.absent(),
                Value<double> stabilityScore = const Value.absent(),
                Value<double> variabilityScore = const Value.absent(),
                Value<double> contextualConsistency = const Value.absent(),
                Value<double> longitudinalConfidence = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CohortAnalysisResultsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                comparedSessions: comparedSessions,
                averageRecoveryEfficiency: averageRecoveryEfficiency,
                averageEscalationProbability: averageEscalationProbability,
                averageResilience: averageResilience,
                stabilityScore: stabilityScore,
                variabilityScore: variabilityScore,
                contextualConsistency: contextualConsistency,
                longitudinalConfidence: longitudinalConfidence,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required int comparedSessions,
                required double averageRecoveryEfficiency,
                required double averageEscalationProbability,
                required double averageResilience,
                required double stabilityScore,
                required double variabilityScore,
                required double contextualConsistency,
                required double longitudinalConfidence,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => CohortAnalysisResultsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                comparedSessions: comparedSessions,
                averageRecoveryEfficiency: averageRecoveryEfficiency,
                averageEscalationProbability: averageEscalationProbability,
                averageResilience: averageResilience,
                stabilityScore: stabilityScore,
                variabilityScore: variabilityScore,
                contextualConsistency: contextualConsistency,
                longitudinalConfidence: longitudinalConfidence,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CohortAnalysisResultsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $CohortAnalysisResultsTableTable,
      CohortAnalysisResultsTableData,
      $$CohortAnalysisResultsTableTableFilterComposer,
      $$CohortAnalysisResultsTableTableOrderingComposer,
      $$CohortAnalysisResultsTableTableAnnotationComposer,
      $$CohortAnalysisResultsTableTableCreateCompanionBuilder,
      $$CohortAnalysisResultsTableTableUpdateCompanionBuilder,
      (
        CohortAnalysisResultsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $CohortAnalysisResultsTableTable,
          CohortAnalysisResultsTableData
        >,
      ),
      CohortAnalysisResultsTableData,
      PrefetchHooks Function()
    >;
typedef $$PhysiologicalEvolutionProfilesTableTableCreateCompanionBuilder =
    PhysiologicalEvolutionProfilesTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required String baselineTrend,
      required String recoveryTrend,
      required String resilienceTrend,
      required String escalationTrend,
      required String autonomicLoadTrend,
      required String circadianStabilityTrend,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$PhysiologicalEvolutionProfilesTableTableUpdateCompanionBuilder =
    PhysiologicalEvolutionProfilesTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<String> baselineTrend,
      Value<String> recoveryTrend,
      Value<String> resilienceTrend,
      Value<String> escalationTrend,
      Value<String> autonomicLoadTrend,
      Value<String> circadianStabilityTrend,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$PhysiologicalEvolutionProfilesTableTableFilterComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $PhysiologicalEvolutionProfilesTableTable
        > {
  $$PhysiologicalEvolutionProfilesTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baselineTrend => $composableBuilder(
    column: $table.baselineTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resilienceTrend => $composableBuilder(
    column: $table.resilienceTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get escalationTrend => $composableBuilder(
    column: $table.escalationTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autonomicLoadTrend => $composableBuilder(
    column: $table.autonomicLoadTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get circadianStabilityTrend => $composableBuilder(
    column: $table.circadianStabilityTrend,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhysiologicalEvolutionProfilesTableTableOrderingComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $PhysiologicalEvolutionProfilesTableTable
        > {
  $$PhysiologicalEvolutionProfilesTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baselineTrend => $composableBuilder(
    column: $table.baselineTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resilienceTrend => $composableBuilder(
    column: $table.resilienceTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get escalationTrend => $composableBuilder(
    column: $table.escalationTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autonomicLoadTrend => $composableBuilder(
    column: $table.autonomicLoadTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get circadianStabilityTrend => $composableBuilder(
    column: $table.circadianStabilityTrend,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhysiologicalEvolutionProfilesTableTableAnnotationComposer
    extends
        Composer<
          _$SignalFlowDatabase,
          $PhysiologicalEvolutionProfilesTableTable
        > {
  $$PhysiologicalEvolutionProfilesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get baselineTrend => $composableBuilder(
    column: $table.baselineTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recoveryTrend => $composableBuilder(
    column: $table.recoveryTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get resilienceTrend => $composableBuilder(
    column: $table.resilienceTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get escalationTrend => $composableBuilder(
    column: $table.escalationTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get autonomicLoadTrend => $composableBuilder(
    column: $table.autonomicLoadTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get circadianStabilityTrend => $composableBuilder(
    column: $table.circadianStabilityTrend,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$PhysiologicalEvolutionProfilesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $PhysiologicalEvolutionProfilesTableTable,
          PhysiologicalEvolutionProfilesTableData,
          $$PhysiologicalEvolutionProfilesTableTableFilterComposer,
          $$PhysiologicalEvolutionProfilesTableTableOrderingComposer,
          $$PhysiologicalEvolutionProfilesTableTableAnnotationComposer,
          $$PhysiologicalEvolutionProfilesTableTableCreateCompanionBuilder,
          $$PhysiologicalEvolutionProfilesTableTableUpdateCompanionBuilder,
          (
            PhysiologicalEvolutionProfilesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $PhysiologicalEvolutionProfilesTableTable,
              PhysiologicalEvolutionProfilesTableData
            >,
          ),
          PhysiologicalEvolutionProfilesTableData,
          PrefetchHooks Function()
        > {
  $$PhysiologicalEvolutionProfilesTableTableTableManager(
    _$SignalFlowDatabase db,
    $PhysiologicalEvolutionProfilesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhysiologicalEvolutionProfilesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PhysiologicalEvolutionProfilesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PhysiologicalEvolutionProfilesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> baselineTrend = const Value.absent(),
                Value<String> recoveryTrend = const Value.absent(),
                Value<String> resilienceTrend = const Value.absent(),
                Value<String> escalationTrend = const Value.absent(),
                Value<String> autonomicLoadTrend = const Value.absent(),
                Value<String> circadianStabilityTrend = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalEvolutionProfilesTableCompanion(
                id: id,
                generatedAt: generatedAt,
                baselineTrend: baselineTrend,
                recoveryTrend: recoveryTrend,
                resilienceTrend: resilienceTrend,
                escalationTrend: escalationTrend,
                autonomicLoadTrend: autonomicLoadTrend,
                circadianStabilityTrend: circadianStabilityTrend,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required String baselineTrend,
                required String recoveryTrend,
                required String resilienceTrend,
                required String escalationTrend,
                required String autonomicLoadTrend,
                required String circadianStabilityTrend,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => PhysiologicalEvolutionProfilesTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                baselineTrend: baselineTrend,
                recoveryTrend: recoveryTrend,
                resilienceTrend: resilienceTrend,
                escalationTrend: escalationTrend,
                autonomicLoadTrend: autonomicLoadTrend,
                circadianStabilityTrend: circadianStabilityTrend,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhysiologicalEvolutionProfilesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $PhysiologicalEvolutionProfilesTableTable,
      PhysiologicalEvolutionProfilesTableData,
      $$PhysiologicalEvolutionProfilesTableTableFilterComposer,
      $$PhysiologicalEvolutionProfilesTableTableOrderingComposer,
      $$PhysiologicalEvolutionProfilesTableTableAnnotationComposer,
      $$PhysiologicalEvolutionProfilesTableTableCreateCompanionBuilder,
      $$PhysiologicalEvolutionProfilesTableTableUpdateCompanionBuilder,
      (
        PhysiologicalEvolutionProfilesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $PhysiologicalEvolutionProfilesTableTable,
          PhysiologicalEvolutionProfilesTableData
        >,
      ),
      PhysiologicalEvolutionProfilesTableData,
      PrefetchHooks Function()
    >;
typedef $$RealtimePipelineSnapshotsTableTableCreateCompanionBuilder =
    RealtimePipelineSnapshotsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required int bufferSize,
      required double rollingHeartRate,
      required double rollingHrv,
      required double rollingConfidence,
      required double rollingEscalationDensity,
      required double latestEscalationProbability,
      required String streamingState,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$RealtimePipelineSnapshotsTableTableUpdateCompanionBuilder =
    RealtimePipelineSnapshotsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<int> bufferSize,
      Value<double> rollingHeartRate,
      Value<double> rollingHrv,
      Value<double> rollingConfidence,
      Value<double> rollingEscalationDensity,
      Value<double> latestEscalationProbability,
      Value<String> streamingState,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$RealtimePipelineSnapshotsTableTableFilterComposer
    extends
        Composer<_$SignalFlowDatabase, $RealtimePipelineSnapshotsTableTable> {
  $$RealtimePipelineSnapshotsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bufferSize => $composableBuilder(
    column: $table.bufferSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rollingHeartRate => $composableBuilder(
    column: $table.rollingHeartRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rollingHrv => $composableBuilder(
    column: $table.rollingHrv,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rollingConfidence => $composableBuilder(
    column: $table.rollingConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rollingEscalationDensity => $composableBuilder(
    column: $table.rollingEscalationDensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latestEscalationProbability => $composableBuilder(
    column: $table.latestEscalationProbability,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streamingState => $composableBuilder(
    column: $table.streamingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RealtimePipelineSnapshotsTableTableOrderingComposer
    extends
        Composer<_$SignalFlowDatabase, $RealtimePipelineSnapshotsTableTable> {
  $$RealtimePipelineSnapshotsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bufferSize => $composableBuilder(
    column: $table.bufferSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rollingHeartRate => $composableBuilder(
    column: $table.rollingHeartRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rollingHrv => $composableBuilder(
    column: $table.rollingHrv,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rollingConfidence => $composableBuilder(
    column: $table.rollingConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rollingEscalationDensity => $composableBuilder(
    column: $table.rollingEscalationDensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latestEscalationProbability => $composableBuilder(
    column: $table.latestEscalationProbability,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streamingState => $composableBuilder(
    column: $table.streamingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RealtimePipelineSnapshotsTableTableAnnotationComposer
    extends
        Composer<_$SignalFlowDatabase, $RealtimePipelineSnapshotsTableTable> {
  $$RealtimePipelineSnapshotsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bufferSize => $composableBuilder(
    column: $table.bufferSize,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rollingHeartRate => $composableBuilder(
    column: $table.rollingHeartRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rollingHrv => $composableBuilder(
    column: $table.rollingHrv,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rollingConfidence => $composableBuilder(
    column: $table.rollingConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rollingEscalationDensity => $composableBuilder(
    column: $table.rollingEscalationDensity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latestEscalationProbability => $composableBuilder(
    column: $table.latestEscalationProbability,
    builder: (column) => column,
  );

  GeneratedColumn<String> get streamingState => $composableBuilder(
    column: $table.streamingState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$RealtimePipelineSnapshotsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $RealtimePipelineSnapshotsTableTable,
          RealtimePipelineSnapshotsTableData,
          $$RealtimePipelineSnapshotsTableTableFilterComposer,
          $$RealtimePipelineSnapshotsTableTableOrderingComposer,
          $$RealtimePipelineSnapshotsTableTableAnnotationComposer,
          $$RealtimePipelineSnapshotsTableTableCreateCompanionBuilder,
          $$RealtimePipelineSnapshotsTableTableUpdateCompanionBuilder,
          (
            RealtimePipelineSnapshotsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $RealtimePipelineSnapshotsTableTable,
              RealtimePipelineSnapshotsTableData
            >,
          ),
          RealtimePipelineSnapshotsTableData,
          PrefetchHooks Function()
        > {
  $$RealtimePipelineSnapshotsTableTableTableManager(
    _$SignalFlowDatabase db,
    $RealtimePipelineSnapshotsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RealtimePipelineSnapshotsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RealtimePipelineSnapshotsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RealtimePipelineSnapshotsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> bufferSize = const Value.absent(),
                Value<double> rollingHeartRate = const Value.absent(),
                Value<double> rollingHrv = const Value.absent(),
                Value<double> rollingConfidence = const Value.absent(),
                Value<double> rollingEscalationDensity = const Value.absent(),
                Value<double> latestEscalationProbability =
                    const Value.absent(),
                Value<String> streamingState = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RealtimePipelineSnapshotsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                bufferSize: bufferSize,
                rollingHeartRate: rollingHeartRate,
                rollingHrv: rollingHrv,
                rollingConfidence: rollingConfidence,
                rollingEscalationDensity: rollingEscalationDensity,
                latestEscalationProbability: latestEscalationProbability,
                streamingState: streamingState,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required int bufferSize,
                required double rollingHeartRate,
                required double rollingHrv,
                required double rollingConfidence,
                required double rollingEscalationDensity,
                required double latestEscalationProbability,
                required String streamingState,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => RealtimePipelineSnapshotsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                bufferSize: bufferSize,
                rollingHeartRate: rollingHeartRate,
                rollingHrv: rollingHrv,
                rollingConfidence: rollingConfidence,
                rollingEscalationDensity: rollingEscalationDensity,
                latestEscalationProbability: latestEscalationProbability,
                streamingState: streamingState,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RealtimePipelineSnapshotsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $RealtimePipelineSnapshotsTableTable,
      RealtimePipelineSnapshotsTableData,
      $$RealtimePipelineSnapshotsTableTableFilterComposer,
      $$RealtimePipelineSnapshotsTableTableOrderingComposer,
      $$RealtimePipelineSnapshotsTableTableAnnotationComposer,
      $$RealtimePipelineSnapshotsTableTableCreateCompanionBuilder,
      $$RealtimePipelineSnapshotsTableTableUpdateCompanionBuilder,
      (
        RealtimePipelineSnapshotsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $RealtimePipelineSnapshotsTableTable,
          RealtimePipelineSnapshotsTableData
        >,
      ),
      RealtimePipelineSnapshotsTableData,
      PrefetchHooks Function()
    >;
typedef $$ReplayScenariosTableTableCreateCompanionBuilder =
    ReplayScenariosTableCompanion Function({
      required String id,
      required String title,
      required String description,
      required DateTime generatedAt,
      required int durationSeconds,
      required int sampleCount,
      required String scenarioType,
      required String expectedEscalationLevel,
      required String contextualFactors,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$ReplayScenariosTableTableUpdateCompanionBuilder =
    ReplayScenariosTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<DateTime> generatedAt,
      Value<int> durationSeconds,
      Value<int> sampleCount,
      Value<String> scenarioType,
      Value<String> expectedEscalationLevel,
      Value<String> contextualFactors,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$ReplayScenariosTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $ReplayScenariosTableTable> {
  $$ReplayScenariosTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedEscalationLevel => $composableBuilder(
    column: $table.expectedEscalationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReplayScenariosTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $ReplayScenariosTableTable> {
  $$ReplayScenariosTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedEscalationLevel => $composableBuilder(
    column: $table.expectedEscalationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReplayScenariosTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $ReplayScenariosTableTable> {
  $$ReplayScenariosTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sampleCount => $composableBuilder(
    column: $table.sampleCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scenarioType => $composableBuilder(
    column: $table.scenarioType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get expectedEscalationLevel => $composableBuilder(
    column: $table.expectedEscalationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$ReplayScenariosTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ReplayScenariosTableTable,
          ReplayScenariosTableData,
          $$ReplayScenariosTableTableFilterComposer,
          $$ReplayScenariosTableTableOrderingComposer,
          $$ReplayScenariosTableTableAnnotationComposer,
          $$ReplayScenariosTableTableCreateCompanionBuilder,
          $$ReplayScenariosTableTableUpdateCompanionBuilder,
          (
            ReplayScenariosTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ReplayScenariosTableTable,
              ReplayScenariosTableData
            >,
          ),
          ReplayScenariosTableData,
          PrefetchHooks Function()
        > {
  $$ReplayScenariosTableTableTableManager(
    _$SignalFlowDatabase db,
    $ReplayScenariosTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReplayScenariosTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReplayScenariosTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReplayScenariosTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> sampleCount = const Value.absent(),
                Value<String> scenarioType = const Value.absent(),
                Value<String> expectedEscalationLevel = const Value.absent(),
                Value<String> contextualFactors = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReplayScenariosTableCompanion(
                id: id,
                title: title,
                description: description,
                generatedAt: generatedAt,
                durationSeconds: durationSeconds,
                sampleCount: sampleCount,
                scenarioType: scenarioType,
                expectedEscalationLevel: expectedEscalationLevel,
                contextualFactors: contextualFactors,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required DateTime generatedAt,
                required int durationSeconds,
                required int sampleCount,
                required String scenarioType,
                required String expectedEscalationLevel,
                required String contextualFactors,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => ReplayScenariosTableCompanion.insert(
                id: id,
                title: title,
                description: description,
                generatedAt: generatedAt,
                durationSeconds: durationSeconds,
                sampleCount: sampleCount,
                scenarioType: scenarioType,
                expectedEscalationLevel: expectedEscalationLevel,
                contextualFactors: contextualFactors,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReplayScenariosTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ReplayScenariosTableTable,
      ReplayScenariosTableData,
      $$ReplayScenariosTableTableFilterComposer,
      $$ReplayScenariosTableTableOrderingComposer,
      $$ReplayScenariosTableTableAnnotationComposer,
      $$ReplayScenariosTableTableCreateCompanionBuilder,
      $$ReplayScenariosTableTableUpdateCompanionBuilder,
      (
        ReplayScenariosTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ReplayScenariosTableTable,
          ReplayScenariosTableData
        >,
      ),
      ReplayScenariosTableData,
      PrefetchHooks Function()
    >;
typedef $$ReplayValidationResultsTableTableCreateCompanionBuilder =
    ReplayValidationResultsTableCompanion Function({
      required String id,
      required String scenarioId,
      required DateTime generatedAt,
      required double replayConsistency,
      required double timelineConsistency,
      required double forecastConsistency,
      required double escalationDetectionScore,
      required double recoveryModelingScore,
      required String findings,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$ReplayValidationResultsTableTableUpdateCompanionBuilder =
    ReplayValidationResultsTableCompanion Function({
      Value<String> id,
      Value<String> scenarioId,
      Value<DateTime> generatedAt,
      Value<double> replayConsistency,
      Value<double> timelineConsistency,
      Value<double> forecastConsistency,
      Value<double> escalationDetectionScore,
      Value<double> recoveryModelingScore,
      Value<String> findings,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$ReplayValidationResultsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $ReplayValidationResultsTableTable> {
  $$ReplayValidationResultsTableTableFilterComposer({
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

  ColumnFilters<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get replayConsistency => $composableBuilder(
    column: $table.replayConsistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get timelineConsistency => $composableBuilder(
    column: $table.timelineConsistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get forecastConsistency => $composableBuilder(
    column: $table.forecastConsistency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get escalationDetectionScore => $composableBuilder(
    column: $table.escalationDetectionScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get recoveryModelingScore => $composableBuilder(
    column: $table.recoveryModelingScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get findings => $composableBuilder(
    column: $table.findings,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReplayValidationResultsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $ReplayValidationResultsTableTable> {
  $$ReplayValidationResultsTableTableOrderingComposer({
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

  ColumnOrderings<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get replayConsistency => $composableBuilder(
    column: $table.replayConsistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get timelineConsistency => $composableBuilder(
    column: $table.timelineConsistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get forecastConsistency => $composableBuilder(
    column: $table.forecastConsistency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get escalationDetectionScore => $composableBuilder(
    column: $table.escalationDetectionScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get recoveryModelingScore => $composableBuilder(
    column: $table.recoveryModelingScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get findings => $composableBuilder(
    column: $table.findings,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReplayValidationResultsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $ReplayValidationResultsTableTable> {
  $$ReplayValidationResultsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scenarioId => $composableBuilder(
    column: $table.scenarioId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get replayConsistency => $composableBuilder(
    column: $table.replayConsistency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get timelineConsistency => $composableBuilder(
    column: $table.timelineConsistency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get forecastConsistency => $composableBuilder(
    column: $table.forecastConsistency,
    builder: (column) => column,
  );

  GeneratedColumn<double> get escalationDetectionScore => $composableBuilder(
    column: $table.escalationDetectionScore,
    builder: (column) => column,
  );

  GeneratedColumn<double> get recoveryModelingScore => $composableBuilder(
    column: $table.recoveryModelingScore,
    builder: (column) => column,
  );

  GeneratedColumn<String> get findings =>
      $composableBuilder(column: $table.findings, builder: (column) => column);

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$ReplayValidationResultsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ReplayValidationResultsTableTable,
          ReplayValidationResultsTableData,
          $$ReplayValidationResultsTableTableFilterComposer,
          $$ReplayValidationResultsTableTableOrderingComposer,
          $$ReplayValidationResultsTableTableAnnotationComposer,
          $$ReplayValidationResultsTableTableCreateCompanionBuilder,
          $$ReplayValidationResultsTableTableUpdateCompanionBuilder,
          (
            ReplayValidationResultsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ReplayValidationResultsTableTable,
              ReplayValidationResultsTableData
            >,
          ),
          ReplayValidationResultsTableData,
          PrefetchHooks Function()
        > {
  $$ReplayValidationResultsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ReplayValidationResultsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReplayValidationResultsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReplayValidationResultsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReplayValidationResultsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scenarioId = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<double> replayConsistency = const Value.absent(),
                Value<double> timelineConsistency = const Value.absent(),
                Value<double> forecastConsistency = const Value.absent(),
                Value<double> escalationDetectionScore = const Value.absent(),
                Value<double> recoveryModelingScore = const Value.absent(),
                Value<String> findings = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReplayValidationResultsTableCompanion(
                id: id,
                scenarioId: scenarioId,
                generatedAt: generatedAt,
                replayConsistency: replayConsistency,
                timelineConsistency: timelineConsistency,
                forecastConsistency: forecastConsistency,
                escalationDetectionScore: escalationDetectionScore,
                recoveryModelingScore: recoveryModelingScore,
                findings: findings,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scenarioId,
                required DateTime generatedAt,
                required double replayConsistency,
                required double timelineConsistency,
                required double forecastConsistency,
                required double escalationDetectionScore,
                required double recoveryModelingScore,
                required String findings,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => ReplayValidationResultsTableCompanion.insert(
                id: id,
                scenarioId: scenarioId,
                generatedAt: generatedAt,
                replayConsistency: replayConsistency,
                timelineConsistency: timelineConsistency,
                forecastConsistency: forecastConsistency,
                escalationDetectionScore: escalationDetectionScore,
                recoveryModelingScore: recoveryModelingScore,
                findings: findings,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReplayValidationResultsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ReplayValidationResultsTableTable,
      ReplayValidationResultsTableData,
      $$ReplayValidationResultsTableTableFilterComposer,
      $$ReplayValidationResultsTableTableOrderingComposer,
      $$ReplayValidationResultsTableTableAnnotationComposer,
      $$ReplayValidationResultsTableTableCreateCompanionBuilder,
      $$ReplayValidationResultsTableTableUpdateCompanionBuilder,
      (
        ReplayValidationResultsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ReplayValidationResultsTableTable,
          ReplayValidationResultsTableData
        >,
      ),
      ReplayValidationResultsTableData,
      PrefetchHooks Function()
    >;
typedef $$ExperimentalInsightsTableTableCreateCompanionBuilder =
    ExperimentalInsightsTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required String title,
      required String summary,
      required double confidence,
      required String insightType,
      required String contributingFactors,
      required String relatedMarkers,
      required String relatedForecasts,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$ExperimentalInsightsTableTableUpdateCompanionBuilder =
    ExperimentalInsightsTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<String> title,
      Value<String> summary,
      Value<double> confidence,
      Value<String> insightType,
      Value<String> contributingFactors,
      Value<String> relatedMarkers,
      Value<String> relatedForecasts,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$ExperimentalInsightsTableTableFilterComposer
    extends Composer<_$SignalFlowDatabase, $ExperimentalInsightsTableTable> {
  $$ExperimentalInsightsTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contributingFactors => $composableBuilder(
    column: $table.contributingFactors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedForecasts => $composableBuilder(
    column: $table.relatedForecasts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExperimentalInsightsTableTableOrderingComposer
    extends Composer<_$SignalFlowDatabase, $ExperimentalInsightsTableTable> {
  $$ExperimentalInsightsTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contributingFactors => $composableBuilder(
    column: $table.contributingFactors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedForecasts => $composableBuilder(
    column: $table.relatedForecasts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExperimentalInsightsTableTableAnnotationComposer
    extends Composer<_$SignalFlowDatabase, $ExperimentalInsightsTableTable> {
  $$ExperimentalInsightsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get insightType => $composableBuilder(
    column: $table.insightType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contributingFactors => $composableBuilder(
    column: $table.contributingFactors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedForecasts => $composableBuilder(
    column: $table.relatedForecasts,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$ExperimentalInsightsTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $ExperimentalInsightsTableTable,
          ExperimentalInsightsTableData,
          $$ExperimentalInsightsTableTableFilterComposer,
          $$ExperimentalInsightsTableTableOrderingComposer,
          $$ExperimentalInsightsTableTableAnnotationComposer,
          $$ExperimentalInsightsTableTableCreateCompanionBuilder,
          $$ExperimentalInsightsTableTableUpdateCompanionBuilder,
          (
            ExperimentalInsightsTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $ExperimentalInsightsTableTable,
              ExperimentalInsightsTableData
            >,
          ),
          ExperimentalInsightsTableData,
          PrefetchHooks Function()
        > {
  $$ExperimentalInsightsTableTableTableManager(
    _$SignalFlowDatabase db,
    $ExperimentalInsightsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExperimentalInsightsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ExperimentalInsightsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ExperimentalInsightsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> insightType = const Value.absent(),
                Value<String> contributingFactors = const Value.absent(),
                Value<String> relatedMarkers = const Value.absent(),
                Value<String> relatedForecasts = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExperimentalInsightsTableCompanion(
                id: id,
                generatedAt: generatedAt,
                title: title,
                summary: summary,
                confidence: confidence,
                insightType: insightType,
                contributingFactors: contributingFactors,
                relatedMarkers: relatedMarkers,
                relatedForecasts: relatedForecasts,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required String title,
                required String summary,
                required double confidence,
                required String insightType,
                required String contributingFactors,
                required String relatedMarkers,
                required String relatedForecasts,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => ExperimentalInsightsTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                title: title,
                summary: summary,
                confidence: confidence,
                insightType: insightType,
                contributingFactors: contributingFactors,
                relatedMarkers: relatedMarkers,
                relatedForecasts: relatedForecasts,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExperimentalInsightsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $ExperimentalInsightsTableTable,
      ExperimentalInsightsTableData,
      $$ExperimentalInsightsTableTableFilterComposer,
      $$ExperimentalInsightsTableTableOrderingComposer,
      $$ExperimentalInsightsTableTableAnnotationComposer,
      $$ExperimentalInsightsTableTableCreateCompanionBuilder,
      $$ExperimentalInsightsTableTableUpdateCompanionBuilder,
      (
        ExperimentalInsightsTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $ExperimentalInsightsTableTable,
          ExperimentalInsightsTableData
        >,
      ),
      ExperimentalInsightsTableData,
      PrefetchHooks Function()
    >;
typedef $$SubjectiveFeedbackEntriesTableTableCreateCompanionBuilder =
    SubjectiveFeedbackEntriesTableCompanion Function({
      required String id,
      required DateTime generatedAt,
      required DateTime perceivedTimestamp,
      required int perceivedStress,
      required int perceivedFatigue,
      required int perceivedControl,
      required int perceivedRecovery,
      required int emotionalIntensity,
      required String notes,
      required String contextualFactors,
      required double physiologicalCorrelation,
      required double confidence,
      required String relatedMarkers,
      required String safetyCopy,
      Value<int> rowid,
    });
typedef $$SubjectiveFeedbackEntriesTableTableUpdateCompanionBuilder =
    SubjectiveFeedbackEntriesTableCompanion Function({
      Value<String> id,
      Value<DateTime> generatedAt,
      Value<DateTime> perceivedTimestamp,
      Value<int> perceivedStress,
      Value<int> perceivedFatigue,
      Value<int> perceivedControl,
      Value<int> perceivedRecovery,
      Value<int> emotionalIntensity,
      Value<String> notes,
      Value<String> contextualFactors,
      Value<double> physiologicalCorrelation,
      Value<double> confidence,
      Value<String> relatedMarkers,
      Value<String> safetyCopy,
      Value<int> rowid,
    });

class $$SubjectiveFeedbackEntriesTableTableFilterComposer
    extends
        Composer<_$SignalFlowDatabase, $SubjectiveFeedbackEntriesTableTable> {
  $$SubjectiveFeedbackEntriesTableTableFilterComposer({
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

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get perceivedTimestamp => $composableBuilder(
    column: $table.perceivedTimestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedStress => $composableBuilder(
    column: $table.perceivedStress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedControl => $composableBuilder(
    column: $table.perceivedControl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get perceivedRecovery => $composableBuilder(
    column: $table.perceivedRecovery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emotionalIntensity => $composableBuilder(
    column: $table.emotionalIntensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get physiologicalCorrelation => $composableBuilder(
    column: $table.physiologicalCorrelation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectiveFeedbackEntriesTableTableOrderingComposer
    extends
        Composer<_$SignalFlowDatabase, $SubjectiveFeedbackEntriesTableTable> {
  $$SubjectiveFeedbackEntriesTableTableOrderingComposer({
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

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get perceivedTimestamp => $composableBuilder(
    column: $table.perceivedTimestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedStress => $composableBuilder(
    column: $table.perceivedStress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedControl => $composableBuilder(
    column: $table.perceivedControl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get perceivedRecovery => $composableBuilder(
    column: $table.perceivedRecovery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emotionalIntensity => $composableBuilder(
    column: $table.emotionalIntensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get physiologicalCorrelation => $composableBuilder(
    column: $table.physiologicalCorrelation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectiveFeedbackEntriesTableTableAnnotationComposer
    extends
        Composer<_$SignalFlowDatabase, $SubjectiveFeedbackEntriesTableTable> {
  $$SubjectiveFeedbackEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
    column: $table.generatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get perceivedTimestamp => $composableBuilder(
    column: $table.perceivedTimestamp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get perceivedStress => $composableBuilder(
    column: $table.perceivedStress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get perceivedFatigue => $composableBuilder(
    column: $table.perceivedFatigue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get perceivedControl => $composableBuilder(
    column: $table.perceivedControl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get perceivedRecovery => $composableBuilder(
    column: $table.perceivedRecovery,
    builder: (column) => column,
  );

  GeneratedColumn<int> get emotionalIntensity => $composableBuilder(
    column: $table.emotionalIntensity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get contextualFactors => $composableBuilder(
    column: $table.contextualFactors,
    builder: (column) => column,
  );

  GeneratedColumn<double> get physiologicalCorrelation => $composableBuilder(
    column: $table.physiologicalCorrelation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedMarkers => $composableBuilder(
    column: $table.relatedMarkers,
    builder: (column) => column,
  );

  GeneratedColumn<String> get safetyCopy => $composableBuilder(
    column: $table.safetyCopy,
    builder: (column) => column,
  );
}

class $$SubjectiveFeedbackEntriesTableTableTableManager
    extends
        RootTableManager<
          _$SignalFlowDatabase,
          $SubjectiveFeedbackEntriesTableTable,
          SubjectiveFeedbackEntriesTableData,
          $$SubjectiveFeedbackEntriesTableTableFilterComposer,
          $$SubjectiveFeedbackEntriesTableTableOrderingComposer,
          $$SubjectiveFeedbackEntriesTableTableAnnotationComposer,
          $$SubjectiveFeedbackEntriesTableTableCreateCompanionBuilder,
          $$SubjectiveFeedbackEntriesTableTableUpdateCompanionBuilder,
          (
            SubjectiveFeedbackEntriesTableData,
            BaseReferences<
              _$SignalFlowDatabase,
              $SubjectiveFeedbackEntriesTableTable,
              SubjectiveFeedbackEntriesTableData
            >,
          ),
          SubjectiveFeedbackEntriesTableData,
          PrefetchHooks Function()
        > {
  $$SubjectiveFeedbackEntriesTableTableTableManager(
    _$SignalFlowDatabase db,
    $SubjectiveFeedbackEntriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectiveFeedbackEntriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SubjectiveFeedbackEntriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SubjectiveFeedbackEntriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> generatedAt = const Value.absent(),
                Value<DateTime> perceivedTimestamp = const Value.absent(),
                Value<int> perceivedStress = const Value.absent(),
                Value<int> perceivedFatigue = const Value.absent(),
                Value<int> perceivedControl = const Value.absent(),
                Value<int> perceivedRecovery = const Value.absent(),
                Value<int> emotionalIntensity = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String> contextualFactors = const Value.absent(),
                Value<double> physiologicalCorrelation = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> relatedMarkers = const Value.absent(),
                Value<String> safetyCopy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectiveFeedbackEntriesTableCompanion(
                id: id,
                generatedAt: generatedAt,
                perceivedTimestamp: perceivedTimestamp,
                perceivedStress: perceivedStress,
                perceivedFatigue: perceivedFatigue,
                perceivedControl: perceivedControl,
                perceivedRecovery: perceivedRecovery,
                emotionalIntensity: emotionalIntensity,
                notes: notes,
                contextualFactors: contextualFactors,
                physiologicalCorrelation: physiologicalCorrelation,
                confidence: confidence,
                relatedMarkers: relatedMarkers,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime generatedAt,
                required DateTime perceivedTimestamp,
                required int perceivedStress,
                required int perceivedFatigue,
                required int perceivedControl,
                required int perceivedRecovery,
                required int emotionalIntensity,
                required String notes,
                required String contextualFactors,
                required double physiologicalCorrelation,
                required double confidence,
                required String relatedMarkers,
                required String safetyCopy,
                Value<int> rowid = const Value.absent(),
              }) => SubjectiveFeedbackEntriesTableCompanion.insert(
                id: id,
                generatedAt: generatedAt,
                perceivedTimestamp: perceivedTimestamp,
                perceivedStress: perceivedStress,
                perceivedFatigue: perceivedFatigue,
                perceivedControl: perceivedControl,
                perceivedRecovery: perceivedRecovery,
                emotionalIntensity: emotionalIntensity,
                notes: notes,
                contextualFactors: contextualFactors,
                physiologicalCorrelation: physiologicalCorrelation,
                confidence: confidence,
                relatedMarkers: relatedMarkers,
                safetyCopy: safetyCopy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectiveFeedbackEntriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$SignalFlowDatabase,
      $SubjectiveFeedbackEntriesTableTable,
      SubjectiveFeedbackEntriesTableData,
      $$SubjectiveFeedbackEntriesTableTableFilterComposer,
      $$SubjectiveFeedbackEntriesTableTableOrderingComposer,
      $$SubjectiveFeedbackEntriesTableTableAnnotationComposer,
      $$SubjectiveFeedbackEntriesTableTableCreateCompanionBuilder,
      $$SubjectiveFeedbackEntriesTableTableUpdateCompanionBuilder,
      (
        SubjectiveFeedbackEntriesTableData,
        BaseReferences<
          _$SignalFlowDatabase,
          $SubjectiveFeedbackEntriesTableTable,
          SubjectiveFeedbackEntriesTableData
        >,
      ),
      SubjectiveFeedbackEntriesTableData,
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
  $$AutonomicRecoveryProfilesTableTableTableManager
  get autonomicRecoveryProfilesTable =>
      $$AutonomicRecoveryProfilesTableTableTableManager(
        _db,
        _db.autonomicRecoveryProfilesTable,
      );
  $$ResearchDashboardSnapshotsTableTableTableManager
  get researchDashboardSnapshotsTable =>
      $$ResearchDashboardSnapshotsTableTableTableManager(
        _db,
        _db.researchDashboardSnapshotsTable,
      );
  $$EscalationForecastsTableTableTableManager get escalationForecastsTable =>
      $$EscalationForecastsTableTableTableManager(
        _db,
        _db.escalationForecastsTable,
      );
  $$ContextualEventsTableTableTableManager get contextualEventsTable =>
      $$ContextualEventsTableTableTableManager(_db, _db.contextualEventsTable);
  $$ContextualTriggerCorrelationsTableTableTableManager
  get contextualTriggerCorrelationsTable =>
      $$ContextualTriggerCorrelationsTableTableTableManager(
        _db,
        _db.contextualTriggerCorrelationsTable,
      );
  $$InterventionLearningProfilesTableTableTableManager
  get interventionLearningProfilesTable =>
      $$InterventionLearningProfilesTableTableTableManager(
        _db,
        _db.interventionLearningProfilesTable,
      );
  $$ContextualInterventionRecommendationsTableTableTableManager
  get contextualInterventionRecommendationsTable =>
      $$ContextualInterventionRecommendationsTableTableTableManager(
        _db,
        _db.contextualInterventionRecommendationsTable,
      );
  $$CohortAnalysisResultsTableTableTableManager
  get cohortAnalysisResultsTable =>
      $$CohortAnalysisResultsTableTableTableManager(
        _db,
        _db.cohortAnalysisResultsTable,
      );
  $$PhysiologicalEvolutionProfilesTableTableTableManager
  get physiologicalEvolutionProfilesTable =>
      $$PhysiologicalEvolutionProfilesTableTableTableManager(
        _db,
        _db.physiologicalEvolutionProfilesTable,
      );
  $$RealtimePipelineSnapshotsTableTableTableManager
  get realtimePipelineSnapshotsTable =>
      $$RealtimePipelineSnapshotsTableTableTableManager(
        _db,
        _db.realtimePipelineSnapshotsTable,
      );
  $$ReplayScenariosTableTableTableManager get replayScenariosTable =>
      $$ReplayScenariosTableTableTableManager(_db, _db.replayScenariosTable);
  $$ReplayValidationResultsTableTableTableManager
  get replayValidationResultsTable =>
      $$ReplayValidationResultsTableTableTableManager(
        _db,
        _db.replayValidationResultsTable,
      );
  $$ExperimentalInsightsTableTableTableManager get experimentalInsightsTable =>
      $$ExperimentalInsightsTableTableTableManager(
        _db,
        _db.experimentalInsightsTable,
      );
  $$SubjectiveFeedbackEntriesTableTableTableManager
  get subjectiveFeedbackEntriesTable =>
      $$SubjectiveFeedbackEntriesTableTableTableManager(
        _db,
        _db.subjectiveFeedbackEntriesTable,
      );
}
