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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    baselineProfilesTable,
    crisisRiskEventsTable,
    interventionHistoryTable,
    researchConsentTable,
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
}
