// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BoxesTable extends Boxes with TableInfo<$BoxesTable, Boxe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoxesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
      'number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _localMeta = const VerificationMeta('local');
  @override
  late final GeneratedColumn<String> local = GeneratedColumn<String>(
      'local', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, number, local, name, notes, photoPath, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'boxes';
  @override
  VerificationContext validateIntegrity(Insertable<Boxe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('number')) {
      context.handle(_numberMeta,
          number.isAcceptableOrUnknown(data['number']!, _numberMeta));
    }
    if (data.containsKey('local')) {
      context.handle(
          _localMeta, local.isAcceptableOrUnknown(data['local']!, _localMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Boxe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Boxe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      number: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}number'])!,
      local: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BoxesTable createAlias(String alias) {
    return $BoxesTable(attachedDatabase, alias);
  }
}

class Boxe extends DataClass implements Insertable<Boxe> {
  final String id;
  final int number;
  final String local;
  final String name;
  final String? notes;
  final String? photoPath;
  final int createdAt;
  const Boxe(
      {required this.id,
      required this.number,
      required this.local,
      required this.name,
      this.notes,
      this.photoPath,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['number'] = Variable<int>(number);
    map['local'] = Variable<String>(local);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BoxesCompanion toCompanion(bool nullToAbsent) {
    return BoxesCompanion(
      id: Value(id),
      number: Value(number),
      local: Value(local),
      name: Value(name),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      createdAt: Value(createdAt),
    );
  }

  factory Boxe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Boxe(
      id: serializer.fromJson<String>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      local: serializer.fromJson<String>(json['local']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'number': serializer.toJson<int>(number),
      'local': serializer.toJson<String>(local),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Boxe copyWith(
          {String? id,
          int? number,
          String? local,
          String? name,
          Value<String?> notes = const Value.absent(),
          Value<String?> photoPath = const Value.absent(),
          int? createdAt}) =>
      Boxe(
        id: id ?? this.id,
        number: number ?? this.number,
        local: local ?? this.local,
        name: name ?? this.name,
        notes: notes.present ? notes.value : this.notes,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
        createdAt: createdAt ?? this.createdAt,
      );
  Boxe copyWithCompanion(BoxesCompanion data) {
    return Boxe(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      local: data.local.present ? data.local.value : this.local,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Boxe(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('local: $local, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, number, local, name, notes, photoPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Boxe &&
          other.id == this.id &&
          other.number == this.number &&
          other.local == this.local &&
          other.name == this.name &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.createdAt == this.createdAt);
}

class BoxesCompanion extends UpdateCompanion<Boxe> {
  final Value<String> id;
  final Value<int> number;
  final Value<String> local;
  final Value<String> name;
  final Value<String?> notes;
  final Value<String?> photoPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const BoxesCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.local = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoxesCompanion.insert({
    required String id,
    this.number = const Value.absent(),
    this.local = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt);
  static Insertable<Boxe> custom({
    Expression<String>? id,
    Expression<int>? number,
    Expression<String>? local,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (local != null) 'local': local,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoxesCompanion copyWith(
      {Value<String>? id,
      Value<int>? number,
      Value<String>? local,
      Value<String>? name,
      Value<String?>? notes,
      Value<String?>? photoPath,
      Value<int>? createdAt,
      Value<int>? rowid}) {
    return BoxesCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      local: local ?? this.local,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
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
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (local.present) {
      map['local'] = Variable<String>(local.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoxesCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('local: $local, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToysTable extends Toys with TableInfo<$ToysTable, Toy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('outros'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _boxIdMeta = const VerificationMeta('boxId');
  @override
  late final GeneratedColumn<String> boxId = GeneratedColumn<String>(
      'box_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES boxes (id)'));
  static const VerificationMeta _locationTextMeta =
      const VerificationMeta('locationText');
  @override
  late final GeneratedColumn<String> locationText = GeneratedColumn<String>(
      'location_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _photoPathMeta =
      const VerificationMeta('photoPath');
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
      'photo_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, categoryId, name, boxId, locationText, createdAt, photoPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'toys';
  @override
  VerificationContext validateIntegrity(Insertable<Toy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('box_id')) {
      context.handle(
          _boxIdMeta, boxId.isAcceptableOrUnknown(data['box_id']!, _boxIdMeta));
    }
    if (data.containsKey('location_text')) {
      context.handle(
          _locationTextMeta,
          locationText.isAcceptableOrUnknown(
              data['location_text']!, _locationTextMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(_photoPathMeta,
          photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Toy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Toy(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      boxId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}box_id']),
      locationText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location_text']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      photoPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_path']),
    );
  }

  @override
  $ToysTable createAlias(String alias) {
    return $ToysTable(attachedDatabase, alias);
  }
}

class Toy extends DataClass implements Insertable<Toy> {
  final String id;
  final String categoryId;
  final String name;
  final String? boxId;
  final String? locationText;
  final int createdAt;
  final String? photoPath;
  const Toy(
      {required this.id,
      required this.categoryId,
      required this.name,
      this.boxId,
      this.locationText,
      required this.createdAt,
      this.photoPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || boxId != null) {
      map['box_id'] = Variable<String>(boxId);
    }
    if (!nullToAbsent || locationText != null) {
      map['location_text'] = Variable<String>(locationText);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    return map;
  }

  ToysCompanion toCompanion(bool nullToAbsent) {
    return ToysCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      name: Value(name),
      boxId:
          boxId == null && nullToAbsent ? const Value.absent() : Value(boxId),
      locationText: locationText == null && nullToAbsent
          ? const Value.absent()
          : Value(locationText),
      createdAt: Value(createdAt),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
    );
  }

  factory Toy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Toy(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      name: serializer.fromJson<String>(json['name']),
      boxId: serializer.fromJson<String?>(json['boxId']),
      locationText: serializer.fromJson<String?>(json['locationText']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'name': serializer.toJson<String>(name),
      'boxId': serializer.toJson<String?>(boxId),
      'locationText': serializer.toJson<String?>(locationText),
      'createdAt': serializer.toJson<int>(createdAt),
      'photoPath': serializer.toJson<String?>(photoPath),
    };
  }

  Toy copyWith(
          {String? id,
          String? categoryId,
          String? name,
          Value<String?> boxId = const Value.absent(),
          Value<String?> locationText = const Value.absent(),
          int? createdAt,
          Value<String?> photoPath = const Value.absent()}) =>
      Toy(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        name: name ?? this.name,
        boxId: boxId.present ? boxId.value : this.boxId,
        locationText:
            locationText.present ? locationText.value : this.locationText,
        createdAt: createdAt ?? this.createdAt,
        photoPath: photoPath.present ? photoPath.value : this.photoPath,
      );
  Toy copyWithCompanion(ToysCompanion data) {
    return Toy(
      id: data.id.present ? data.id.value : this.id,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      name: data.name.present ? data.name.value : this.name,
      boxId: data.boxId.present ? data.boxId.value : this.boxId,
      locationText: data.locationText.present
          ? data.locationText.value
          : this.locationText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Toy(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('boxId: $boxId, ')
          ..write('locationText: $locationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('photoPath: $photoPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, categoryId, name, boxId, locationText, createdAt, photoPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Toy &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.name == this.name &&
          other.boxId == this.boxId &&
          other.locationText == this.locationText &&
          other.createdAt == this.createdAt &&
          other.photoPath == this.photoPath);
}

class ToysCompanion extends UpdateCompanion<Toy> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<String> name;
  final Value<String?> boxId;
  final Value<String?> locationText;
  final Value<int> createdAt;
  final Value<String?> photoPath;
  final Value<int> rowid;
  const ToysCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.name = const Value.absent(),
    this.boxId = const Value.absent(),
    this.locationText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ToysCompanion.insert({
    required String id,
    this.categoryId = const Value.absent(),
    required String name,
    this.boxId = const Value.absent(),
    this.locationText = const Value.absent(),
    required int createdAt,
    this.photoPath = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Toy> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<String>? name,
    Expression<String>? boxId,
    Expression<String>? locationText,
    Expression<int>? createdAt,
    Expression<String>? photoPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (name != null) 'name': name,
      if (boxId != null) 'box_id': boxId,
      if (locationText != null) 'location_text': locationText,
      if (createdAt != null) 'created_at': createdAt,
      if (photoPath != null) 'photo_path': photoPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ToysCompanion copyWith(
      {Value<String>? id,
      Value<String>? categoryId,
      Value<String>? name,
      Value<String?>? boxId,
      Value<String?>? locationText,
      Value<int>? createdAt,
      Value<String?>? photoPath,
      Value<int>? rowid}) {
    return ToysCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      boxId: boxId ?? this.boxId,
      locationText: locationText ?? this.locationText,
      createdAt: createdAt ?? this.createdAt,
      photoPath: photoPath ?? this.photoPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (boxId.present) {
      map['box_id'] = Variable<String>(boxId.value);
    }
    if (locationText.present) {
      map['location_text'] = Variable<String>(locationText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToysCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('name: $name, ')
          ..write('boxId: $boxId, ')
          ..write('locationText: $locationText, ')
          ..write('createdAt: $createdAt, ')
          ..write('photoPath: $photoPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryDefinitionsTable extends CategoryDefinitions
    with TableInfo<$CategoryDefinitionsTable, CategoryDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _examplesMeta =
      const VerificationMeta('examples');
  @override
  late final GeneratedColumn<String> examples = GeneratedColumn<String>(
      'examples', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _developmentAspectMeta =
      const VerificationMeta('developmentAspect');
  @override
  late final GeneratedColumn<String> developmentAspect =
      GeneratedColumn<String>('development_aspect', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(999));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        examples,
        developmentAspect,
        sortOrder,
        isDefault,
        isActive
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_definitions';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryDefinition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('examples')) {
      context.handle(_examplesMeta,
          examples.isAcceptableOrUnknown(data['examples']!, _examplesMeta));
    }
    if (data.containsKey('development_aspect')) {
      context.handle(
          _developmentAspectMeta,
          developmentAspect.isAcceptableOrUnknown(
              data['development_aspect']!, _developmentAspectMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryDefinition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      examples: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}examples']),
      developmentAspect: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}development_aspect']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $CategoryDefinitionsTable createAlias(String alias) {
    return $CategoryDefinitionsTable(attachedDatabase, alias);
  }
}

class CategoryDefinition extends DataClass
    implements Insertable<CategoryDefinition> {
  final String id;
  final String name;
  final String? description;
  final String? examples;
  final String? developmentAspect;
  final int sortOrder;
  final bool isDefault;
  final bool isActive;
  const CategoryDefinition(
      {required this.id,
      required this.name,
      this.description,
      this.examples,
      this.developmentAspect,
      required this.sortOrder,
      required this.isDefault,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || examples != null) {
      map['examples'] = Variable<String>(examples);
    }
    if (!nullToAbsent || developmentAspect != null) {
      map['development_aspect'] = Variable<String>(developmentAspect);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CategoryDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return CategoryDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      examples: examples == null && nullToAbsent
          ? const Value.absent()
          : Value(examples),
      developmentAspect: developmentAspect == null && nullToAbsent
          ? const Value.absent()
          : Value(developmentAspect),
      sortOrder: Value(sortOrder),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
    );
  }

  factory CategoryDefinition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryDefinition(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      examples: serializer.fromJson<String?>(json['examples']),
      developmentAspect:
          serializer.fromJson<String?>(json['developmentAspect']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'examples': serializer.toJson<String?>(examples),
      'developmentAspect': serializer.toJson<String?>(developmentAspect),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CategoryDefinition copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          Value<String?> examples = const Value.absent(),
          Value<String?> developmentAspect = const Value.absent(),
          int? sortOrder,
          bool? isDefault,
          bool? isActive}) =>
      CategoryDefinition(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        examples: examples.present ? examples.value : this.examples,
        developmentAspect: developmentAspect.present
            ? developmentAspect.value
            : this.developmentAspect,
        sortOrder: sortOrder ?? this.sortOrder,
        isDefault: isDefault ?? this.isDefault,
        isActive: isActive ?? this.isActive,
      );
  CategoryDefinition copyWithCompanion(CategoryDefinitionsCompanion data) {
    return CategoryDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      examples: data.examples.present ? data.examples.value : this.examples,
      developmentAspect: data.developmentAspect.present
          ? data.developmentAspect.value
          : this.developmentAspect,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryDefinition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('developmentAspect: $developmentAspect, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, examples,
      developmentAspect, sortOrder, isDefault, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryDefinition &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.examples == this.examples &&
          other.developmentAspect == this.developmentAspect &&
          other.sortOrder == this.sortOrder &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive);
}

class CategoryDefinitionsCompanion extends UpdateCompanion<CategoryDefinition> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> examples;
  final Value<String?> developmentAspect;
  final Value<int> sortOrder;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<int> rowid;
  const CategoryDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.developmentAspect = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.examples = const Value.absent(),
    this.developmentAspect = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CategoryDefinition> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? examples,
    Expression<String>? developmentAspect,
    Expression<int>? sortOrder,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (examples != null) 'examples': examples,
      if (developmentAspect != null) 'development_aspect': developmentAspect,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryDefinitionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String?>? examples,
      Value<String?>? developmentAspect,
      Value<int>? sortOrder,
      Value<bool>? isDefault,
      Value<bool>? isActive,
      Value<int>? rowid}) {
    return CategoryDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      examples: examples ?? this.examples,
      developmentAspect: developmentAspect ?? this.developmentAspect,
      sortOrder: sortOrder ?? this.sortOrder,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(examples.value);
    }
    if (developmentAspect.present) {
      map['development_aspect'] = Variable<String>(developmentAspect.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('examples: $examples, ')
          ..write('developmentAspect: $developmentAspect, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoryCountersTable extends CategoryCounters
    with TableInfo<$CategoryCountersTable, CategoryCounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES category_definitions (id)'));
  static const VerificationMeta _nextNumberMeta =
      const VerificationMeta('nextNumber');
  @override
  late final GeneratedColumn<int> nextNumber = GeneratedColumn<int>(
      'next_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [categoryId, nextNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_counters';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryCounter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('next_number')) {
      context.handle(
          _nextNumberMeta,
          nextNumber.isAcceptableOrUnknown(
              data['next_number']!, _nextNumberMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  CategoryCounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryCounter(
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      nextNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_number'])!,
    );
  }

  @override
  $CategoryCountersTable createAlias(String alias) {
    return $CategoryCountersTable(attachedDatabase, alias);
  }
}

class CategoryCounter extends DataClass implements Insertable<CategoryCounter> {
  final String categoryId;
  final int nextNumber;
  const CategoryCounter({required this.categoryId, required this.nextNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['next_number'] = Variable<int>(nextNumber);
    return map;
  }

  CategoryCountersCompanion toCompanion(bool nullToAbsent) {
    return CategoryCountersCompanion(
      categoryId: Value(categoryId),
      nextNumber: Value(nextNumber),
    );
  }

  factory CategoryCounter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryCounter(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      nextNumber: serializer.fromJson<int>(json['nextNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'nextNumber': serializer.toJson<int>(nextNumber),
    };
  }

  CategoryCounter copyWith({String? categoryId, int? nextNumber}) =>
      CategoryCounter(
        categoryId: categoryId ?? this.categoryId,
        nextNumber: nextNumber ?? this.nextNumber,
      );
  CategoryCounter copyWithCompanion(CategoryCountersCompanion data) {
    return CategoryCounter(
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      nextNumber:
          data.nextNumber.present ? data.nextNumber.value : this.nextNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCounter(')
          ..write('categoryId: $categoryId, ')
          ..write('nextNumber: $nextNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, nextNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryCounter &&
          other.categoryId == this.categoryId &&
          other.nextNumber == this.nextNumber);
}

class CategoryCountersCompanion extends UpdateCompanion<CategoryCounter> {
  final Value<String> categoryId;
  final Value<int> nextNumber;
  final Value<int> rowid;
  const CategoryCountersCompanion({
    this.categoryId = const Value.absent(),
    this.nextNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoryCountersCompanion.insert({
    required String categoryId,
    this.nextNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId);
  static Insertable<CategoryCounter> custom({
    Expression<String>? categoryId,
    Expression<int>? nextNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (nextNumber != null) 'next_number': nextNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoryCountersCompanion copyWith(
      {Value<String>? categoryId, Value<int>? nextNumber, Value<int>? rowid}) {
    return CategoryCountersCompanion(
      categoryId: categoryId ?? this.categoryId,
      nextNumber: nextNumber ?? this.nextNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (nextNumber.present) {
      map['next_number'] = Variable<int>(nextNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryCountersCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('nextNumber: $nextNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundCategorySettingsTable extends RoundCategorySettings
    with TableInfo<$RoundCategorySettingsTable, RoundCategorySetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundCategorySettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES category_definitions (id)'));
  static const VerificationMeta _isIncludedMeta =
      const VerificationMeta('isIncluded');
  @override
  late final GeneratedColumn<bool> isIncluded = GeneratedColumn<bool>(
      'is_included', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_included" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _quotaMeta = const VerificationMeta('quota');
  @override
  late final GeneratedColumn<int> quota = GeneratedColumn<int>(
      'quota', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [categoryId, isIncluded, quota];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_category_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<RoundCategorySetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_included')) {
      context.handle(
          _isIncludedMeta,
          isIncluded.isAcceptableOrUnknown(
              data['is_included']!, _isIncludedMeta));
    }
    if (data.containsKey('quota')) {
      context.handle(
          _quotaMeta, quota.isAcceptableOrUnknown(data['quota']!, _quotaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {categoryId};
  @override
  RoundCategorySetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundCategorySetting(
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      isIncluded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_included'])!,
      quota: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quota'])!,
    );
  }

  @override
  $RoundCategorySettingsTable createAlias(String alias) {
    return $RoundCategorySettingsTable(attachedDatabase, alias);
  }
}

class RoundCategorySetting extends DataClass
    implements Insertable<RoundCategorySetting> {
  final String categoryId;
  final bool isIncluded;
  final int quota;
  const RoundCategorySetting(
      {required this.categoryId,
      required this.isIncluded,
      required this.quota});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['category_id'] = Variable<String>(categoryId);
    map['is_included'] = Variable<bool>(isIncluded);
    map['quota'] = Variable<int>(quota);
    return map;
  }

  RoundCategorySettingsCompanion toCompanion(bool nullToAbsent) {
    return RoundCategorySettingsCompanion(
      categoryId: Value(categoryId),
      isIncluded: Value(isIncluded),
      quota: Value(quota),
    );
  }

  factory RoundCategorySetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundCategorySetting(
      categoryId: serializer.fromJson<String>(json['categoryId']),
      isIncluded: serializer.fromJson<bool>(json['isIncluded']),
      quota: serializer.fromJson<int>(json['quota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'categoryId': serializer.toJson<String>(categoryId),
      'isIncluded': serializer.toJson<bool>(isIncluded),
      'quota': serializer.toJson<int>(quota),
    };
  }

  RoundCategorySetting copyWith(
          {String? categoryId, bool? isIncluded, int? quota}) =>
      RoundCategorySetting(
        categoryId: categoryId ?? this.categoryId,
        isIncluded: isIncluded ?? this.isIncluded,
        quota: quota ?? this.quota,
      );
  RoundCategorySetting copyWithCompanion(RoundCategorySettingsCompanion data) {
    return RoundCategorySetting(
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      isIncluded:
          data.isIncluded.present ? data.isIncluded.value : this.isIncluded,
      quota: data.quota.present ? data.quota.value : this.quota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundCategorySetting(')
          ..write('categoryId: $categoryId, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('quota: $quota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(categoryId, isIncluded, quota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundCategorySetting &&
          other.categoryId == this.categoryId &&
          other.isIncluded == this.isIncluded &&
          other.quota == this.quota);
}

class RoundCategorySettingsCompanion
    extends UpdateCompanion<RoundCategorySetting> {
  final Value<String> categoryId;
  final Value<bool> isIncluded;
  final Value<int> quota;
  final Value<int> rowid;
  const RoundCategorySettingsCompanion({
    this.categoryId = const Value.absent(),
    this.isIncluded = const Value.absent(),
    this.quota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundCategorySettingsCompanion.insert({
    required String categoryId,
    this.isIncluded = const Value.absent(),
    this.quota = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : categoryId = Value(categoryId);
  static Insertable<RoundCategorySetting> custom({
    Expression<String>? categoryId,
    Expression<bool>? isIncluded,
    Expression<int>? quota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (categoryId != null) 'category_id': categoryId,
      if (isIncluded != null) 'is_included': isIncluded,
      if (quota != null) 'quota': quota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundCategorySettingsCompanion copyWith(
      {Value<String>? categoryId,
      Value<bool>? isIncluded,
      Value<int>? quota,
      Value<int>? rowid}) {
    return RoundCategorySettingsCompanion(
      categoryId: categoryId ?? this.categoryId,
      isIncluded: isIncluded ?? this.isIncluded,
      quota: quota ?? this.quota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isIncluded.present) {
      map['is_included'] = Variable<bool>(isIncluded.value);
    }
    if (quota.present) {
      map['quota'] = Variable<int>(quota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundCategorySettingsCompanion(')
          ..write('categoryId: $categoryId, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('quota: $quota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundUiSettingsTable extends RoundUiSettings
    with TableInfo<$RoundUiSettingsTable, RoundUiSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundUiSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _perCategoryLimitMeta =
      const VerificationMeta('perCategoryLimit');
  @override
  late final GeneratedColumn<int> perCategoryLimit = GeneratedColumn<int>(
      'per_category_limit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(12));
  static const VerificationMeta _hapticEnabledMeta =
      const VerificationMeta('hapticEnabled');
  @override
  late final GeneratedColumn<bool> hapticEnabled = GeneratedColumn<bool>(
      'haptic_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("haptic_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _soundEnabledMeta =
      const VerificationMeta('soundEnabled');
  @override
  late final GeneratedColumn<bool> soundEnabled = GeneratedColumn<bool>(
      'sound_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("sound_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _darkModeEnabledMeta =
      const VerificationMeta('darkModeEnabled');
  @override
  late final GeneratedColumn<bool> darkModeEnabled = GeneratedColumn<bool>(
      'dark_mode_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("dark_mode_enabled" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _childAgeRangeMeta =
      const VerificationMeta('childAgeRange');
  @override
  late final GeneratedColumn<String> childAgeRange = GeneratedColumn<String>(
      'child_age_range', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        perCategoryLimit,
        hapticEnabled,
        soundEnabled,
        darkModeEnabled,
        childAgeRange
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_ui_settings';
  @override
  VerificationContext validateIntegrity(Insertable<RoundUiSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('per_category_limit')) {
      context.handle(
          _perCategoryLimitMeta,
          perCategoryLimit.isAcceptableOrUnknown(
              data['per_category_limit']!, _perCategoryLimitMeta));
    }
    if (data.containsKey('haptic_enabled')) {
      context.handle(
          _hapticEnabledMeta,
          hapticEnabled.isAcceptableOrUnknown(
              data['haptic_enabled']!, _hapticEnabledMeta));
    }
    if (data.containsKey('sound_enabled')) {
      context.handle(
          _soundEnabledMeta,
          soundEnabled.isAcceptableOrUnknown(
              data['sound_enabled']!, _soundEnabledMeta));
    }
    if (data.containsKey('dark_mode_enabled')) {
      context.handle(
          _darkModeEnabledMeta,
          darkModeEnabled.isAcceptableOrUnknown(
              data['dark_mode_enabled']!, _darkModeEnabledMeta));
    }
    if (data.containsKey('child_age_range')) {
      context.handle(
          _childAgeRangeMeta,
          childAgeRange.isAcceptableOrUnknown(
              data['child_age_range']!, _childAgeRangeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RoundUiSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundUiSetting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      perCategoryLimit: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}per_category_limit'])!,
      hapticEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}haptic_enabled'])!,
      soundEnabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sound_enabled'])!,
      darkModeEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}dark_mode_enabled'])!,
      childAgeRange: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}child_age_range']),
    );
  }

  @override
  $RoundUiSettingsTable createAlias(String alias) {
    return $RoundUiSettingsTable(attachedDatabase, alias);
  }
}

class RoundUiSetting extends DataClass implements Insertable<RoundUiSetting> {
  final int id;
  final int perCategoryLimit;
  final bool hapticEnabled;
  final bool soundEnabled;
  final bool darkModeEnabled;
  final String? childAgeRange;
  const RoundUiSetting(
      {required this.id,
      required this.perCategoryLimit,
      required this.hapticEnabled,
      required this.soundEnabled,
      required this.darkModeEnabled,
      this.childAgeRange});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['per_category_limit'] = Variable<int>(perCategoryLimit);
    map['haptic_enabled'] = Variable<bool>(hapticEnabled);
    map['sound_enabled'] = Variable<bool>(soundEnabled);
    map['dark_mode_enabled'] = Variable<bool>(darkModeEnabled);
    if (!nullToAbsent || childAgeRange != null) {
      map['child_age_range'] = Variable<String>(childAgeRange);
    }
    return map;
  }

  RoundUiSettingsCompanion toCompanion(bool nullToAbsent) {
    return RoundUiSettingsCompanion(
      id: Value(id),
      perCategoryLimit: Value(perCategoryLimit),
      hapticEnabled: Value(hapticEnabled),
      soundEnabled: Value(soundEnabled),
      darkModeEnabled: Value(darkModeEnabled),
      childAgeRange: childAgeRange == null && nullToAbsent
          ? const Value.absent()
          : Value(childAgeRange),
    );
  }

  factory RoundUiSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundUiSetting(
      id: serializer.fromJson<int>(json['id']),
      perCategoryLimit: serializer.fromJson<int>(json['perCategoryLimit']),
      hapticEnabled: serializer.fromJson<bool>(json['hapticEnabled']),
      soundEnabled: serializer.fromJson<bool>(json['soundEnabled']),
      darkModeEnabled: serializer.fromJson<bool>(json['darkModeEnabled']),
      childAgeRange: serializer.fromJson<String?>(json['childAgeRange']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'perCategoryLimit': serializer.toJson<int>(perCategoryLimit),
      'hapticEnabled': serializer.toJson<bool>(hapticEnabled),
      'soundEnabled': serializer.toJson<bool>(soundEnabled),
      'darkModeEnabled': serializer.toJson<bool>(darkModeEnabled),
      'childAgeRange': serializer.toJson<String?>(childAgeRange),
    };
  }

  RoundUiSetting copyWith(
          {int? id,
          int? perCategoryLimit,
          bool? hapticEnabled,
          bool? soundEnabled,
          bool? darkModeEnabled,
          Value<String?> childAgeRange = const Value.absent()}) =>
      RoundUiSetting(
        id: id ?? this.id,
        perCategoryLimit: perCategoryLimit ?? this.perCategoryLimit,
        hapticEnabled: hapticEnabled ?? this.hapticEnabled,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
        childAgeRange:
            childAgeRange.present ? childAgeRange.value : this.childAgeRange,
      );
  RoundUiSetting copyWithCompanion(RoundUiSettingsCompanion data) {
    return RoundUiSetting(
      id: data.id.present ? data.id.value : this.id,
      perCategoryLimit: data.perCategoryLimit.present
          ? data.perCategoryLimit.value
          : this.perCategoryLimit,
      hapticEnabled: data.hapticEnabled.present
          ? data.hapticEnabled.value
          : this.hapticEnabled,
      soundEnabled: data.soundEnabled.present
          ? data.soundEnabled.value
          : this.soundEnabled,
      darkModeEnabled: data.darkModeEnabled.present
          ? data.darkModeEnabled.value
          : this.darkModeEnabled,
      childAgeRange: data.childAgeRange.present
          ? data.childAgeRange.value
          : this.childAgeRange,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundUiSetting(')
          ..write('id: $id, ')
          ..write('perCategoryLimit: $perCategoryLimit, ')
          ..write('hapticEnabled: $hapticEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('darkModeEnabled: $darkModeEnabled, ')
          ..write('childAgeRange: $childAgeRange')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, perCategoryLimit, hapticEnabled,
      soundEnabled, darkModeEnabled, childAgeRange);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundUiSetting &&
          other.id == this.id &&
          other.perCategoryLimit == this.perCategoryLimit &&
          other.hapticEnabled == this.hapticEnabled &&
          other.soundEnabled == this.soundEnabled &&
          other.darkModeEnabled == this.darkModeEnabled &&
          other.childAgeRange == this.childAgeRange);
}

class RoundUiSettingsCompanion extends UpdateCompanion<RoundUiSetting> {
  final Value<int> id;
  final Value<int> perCategoryLimit;
  final Value<bool> hapticEnabled;
  final Value<bool> soundEnabled;
  final Value<bool> darkModeEnabled;
  final Value<String?> childAgeRange;
  const RoundUiSettingsCompanion({
    this.id = const Value.absent(),
    this.perCategoryLimit = const Value.absent(),
    this.hapticEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.darkModeEnabled = const Value.absent(),
    this.childAgeRange = const Value.absent(),
  });
  RoundUiSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.perCategoryLimit = const Value.absent(),
    this.hapticEnabled = const Value.absent(),
    this.soundEnabled = const Value.absent(),
    this.darkModeEnabled = const Value.absent(),
    this.childAgeRange = const Value.absent(),
  });
  static Insertable<RoundUiSetting> custom({
    Expression<int>? id,
    Expression<int>? perCategoryLimit,
    Expression<bool>? hapticEnabled,
    Expression<bool>? soundEnabled,
    Expression<bool>? darkModeEnabled,
    Expression<String>? childAgeRange,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (perCategoryLimit != null) 'per_category_limit': perCategoryLimit,
      if (hapticEnabled != null) 'haptic_enabled': hapticEnabled,
      if (soundEnabled != null) 'sound_enabled': soundEnabled,
      if (darkModeEnabled != null) 'dark_mode_enabled': darkModeEnabled,
      if (childAgeRange != null) 'child_age_range': childAgeRange,
    });
  }

  RoundUiSettingsCompanion copyWith(
      {Value<int>? id,
      Value<int>? perCategoryLimit,
      Value<bool>? hapticEnabled,
      Value<bool>? soundEnabled,
      Value<bool>? darkModeEnabled,
      Value<String?>? childAgeRange}) {
    return RoundUiSettingsCompanion(
      id: id ?? this.id,
      perCategoryLimit: perCategoryLimit ?? this.perCategoryLimit,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      childAgeRange: childAgeRange ?? this.childAgeRange,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (perCategoryLimit.present) {
      map['per_category_limit'] = Variable<int>(perCategoryLimit.value);
    }
    if (hapticEnabled.present) {
      map['haptic_enabled'] = Variable<bool>(hapticEnabled.value);
    }
    if (soundEnabled.present) {
      map['sound_enabled'] = Variable<bool>(soundEnabled.value);
    }
    if (darkModeEnabled.present) {
      map['dark_mode_enabled'] = Variable<bool>(darkModeEnabled.value);
    }
    if (childAgeRange.present) {
      map['child_age_range'] = Variable<String>(childAgeRange.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundUiSettingsCompanion(')
          ..write('id: $id, ')
          ..write('perCategoryLimit: $perCategoryLimit, ')
          ..write('hapticEnabled: $hapticEnabled, ')
          ..write('soundEnabled: $soundEnabled, ')
          ..write('darkModeEnabled: $darkModeEnabled, ')
          ..write('childAgeRange: $childAgeRange')
          ..write(')'))
        .toString();
  }
}

class $WeeklyPlanningSettingsTable extends WeeklyPlanningSettings
    with TableInfo<$WeeklyPlanningSettingsTable, WeeklyPlanningSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyPlanningSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _useDefaultMeta =
      const VerificationMeta('useDefault');
  @override
  late final GeneratedColumn<bool> useDefault = GeneratedColumn<bool>(
      'use_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("use_default" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _customSizeMeta =
      const VerificationMeta('customSize');
  @override
  late final GeneratedColumn<int> customSize = GeneratedColumn<int>(
      'custom_size', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [weekday, useDefault, customSize];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_planning_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<WeeklyPlanningSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    }
    if (data.containsKey('use_default')) {
      context.handle(
          _useDefaultMeta,
          useDefault.isAcceptableOrUnknown(
              data['use_default']!, _useDefaultMeta));
    }
    if (data.containsKey('custom_size')) {
      context.handle(
          _customSizeMeta,
          customSize.isAcceptableOrUnknown(
              data['custom_size']!, _customSizeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday};
  @override
  WeeklyPlanningSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyPlanningSetting(
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      useDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}use_default'])!,
      customSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}custom_size']),
    );
  }

  @override
  $WeeklyPlanningSettingsTable createAlias(String alias) {
    return $WeeklyPlanningSettingsTable(attachedDatabase, alias);
  }
}

class WeeklyPlanningSetting extends DataClass
    implements Insertable<WeeklyPlanningSetting> {
  final int weekday;
  final bool useDefault;
  final int? customSize;
  const WeeklyPlanningSetting(
      {required this.weekday, required this.useDefault, this.customSize});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['use_default'] = Variable<bool>(useDefault);
    if (!nullToAbsent || customSize != null) {
      map['custom_size'] = Variable<int>(customSize);
    }
    return map;
  }

  WeeklyPlanningSettingsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyPlanningSettingsCompanion(
      weekday: Value(weekday),
      useDefault: Value(useDefault),
      customSize: customSize == null && nullToAbsent
          ? const Value.absent()
          : Value(customSize),
    );
  }

  factory WeeklyPlanningSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyPlanningSetting(
      weekday: serializer.fromJson<int>(json['weekday']),
      useDefault: serializer.fromJson<bool>(json['useDefault']),
      customSize: serializer.fromJson<int?>(json['customSize']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'useDefault': serializer.toJson<bool>(useDefault),
      'customSize': serializer.toJson<int?>(customSize),
    };
  }

  WeeklyPlanningSetting copyWith(
          {int? weekday,
          bool? useDefault,
          Value<int?> customSize = const Value.absent()}) =>
      WeeklyPlanningSetting(
        weekday: weekday ?? this.weekday,
        useDefault: useDefault ?? this.useDefault,
        customSize: customSize.present ? customSize.value : this.customSize,
      );
  WeeklyPlanningSetting copyWithCompanion(
      WeeklyPlanningSettingsCompanion data) {
    return WeeklyPlanningSetting(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      useDefault:
          data.useDefault.present ? data.useDefault.value : this.useDefault,
      customSize:
          data.customSize.present ? data.customSize.value : this.customSize,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlanningSetting(')
          ..write('weekday: $weekday, ')
          ..write('useDefault: $useDefault, ')
          ..write('customSize: $customSize')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, useDefault, customSize);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyPlanningSetting &&
          other.weekday == this.weekday &&
          other.useDefault == this.useDefault &&
          other.customSize == this.customSize);
}

class WeeklyPlanningSettingsCompanion
    extends UpdateCompanion<WeeklyPlanningSetting> {
  final Value<int> weekday;
  final Value<bool> useDefault;
  final Value<int?> customSize;
  const WeeklyPlanningSettingsCompanion({
    this.weekday = const Value.absent(),
    this.useDefault = const Value.absent(),
    this.customSize = const Value.absent(),
  });
  WeeklyPlanningSettingsCompanion.insert({
    this.weekday = const Value.absent(),
    this.useDefault = const Value.absent(),
    this.customSize = const Value.absent(),
  });
  static Insertable<WeeklyPlanningSetting> custom({
    Expression<int>? weekday,
    Expression<bool>? useDefault,
    Expression<int>? customSize,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (useDefault != null) 'use_default': useDefault,
      if (customSize != null) 'custom_size': customSize,
    });
  }

  WeeklyPlanningSettingsCompanion copyWith(
      {Value<int>? weekday, Value<bool>? useDefault, Value<int?>? customSize}) {
    return WeeklyPlanningSettingsCompanion(
      weekday: weekday ?? this.weekday,
      useDefault: useDefault ?? this.useDefault,
      customSize: customSize ?? this.customSize,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (useDefault.present) {
      map['use_default'] = Variable<bool>(useDefault.value);
    }
    if (customSize.present) {
      map['custom_size'] = Variable<int>(customSize.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlanningSettingsCompanion(')
          ..write('weekday: $weekday, ')
          ..write('useDefault: $useDefault, ')
          ..write('customSize: $customSize')
          ..write(')'))
        .toString();
  }
}

class $WeeklyPlanningCategorySettingsTable
    extends WeeklyPlanningCategorySettings
    with
        TableInfo<$WeeklyPlanningCategorySettingsTable,
            WeeklyPlanningCategorySetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklyPlanningCategorySettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _weekdayMeta =
      const VerificationMeta('weekday');
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
      'weekday', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES category_definitions (id)'));
  static const VerificationMeta _isIncludedMeta =
      const VerificationMeta('isIncluded');
  @override
  late final GeneratedColumn<bool> isIncluded = GeneratedColumn<bool>(
      'is_included', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_included" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _quotaMeta = const VerificationMeta('quota');
  @override
  late final GeneratedColumn<int> quota = GeneratedColumn<int>(
      'quota', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns =>
      [weekday, categoryId, isIncluded, quota];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_planning_category_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<WeeklyPlanningCategorySetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('weekday')) {
      context.handle(_weekdayMeta,
          weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta));
    } else if (isInserting) {
      context.missing(_weekdayMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_included')) {
      context.handle(
          _isIncludedMeta,
          isIncluded.isAcceptableOrUnknown(
              data['is_included']!, _isIncludedMeta));
    }
    if (data.containsKey('quota')) {
      context.handle(
          _quotaMeta, quota.isAcceptableOrUnknown(data['quota']!, _quotaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekday, categoryId};
  @override
  WeeklyPlanningCategorySetting map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyPlanningCategorySetting(
      weekday: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}weekday'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      isIncluded: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_included'])!,
      quota: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quota'])!,
    );
  }

  @override
  $WeeklyPlanningCategorySettingsTable createAlias(String alias) {
    return $WeeklyPlanningCategorySettingsTable(attachedDatabase, alias);
  }
}

class WeeklyPlanningCategorySetting extends DataClass
    implements Insertable<WeeklyPlanningCategorySetting> {
  final int weekday;
  final String categoryId;
  final bool isIncluded;
  final int quota;
  const WeeklyPlanningCategorySetting(
      {required this.weekday,
      required this.categoryId,
      required this.isIncluded,
      required this.quota});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['weekday'] = Variable<int>(weekday);
    map['category_id'] = Variable<String>(categoryId);
    map['is_included'] = Variable<bool>(isIncluded);
    map['quota'] = Variable<int>(quota);
    return map;
  }

  WeeklyPlanningCategorySettingsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyPlanningCategorySettingsCompanion(
      weekday: Value(weekday),
      categoryId: Value(categoryId),
      isIncluded: Value(isIncluded),
      quota: Value(quota),
    );
  }

  factory WeeklyPlanningCategorySetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyPlanningCategorySetting(
      weekday: serializer.fromJson<int>(json['weekday']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      isIncluded: serializer.fromJson<bool>(json['isIncluded']),
      quota: serializer.fromJson<int>(json['quota']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekday': serializer.toJson<int>(weekday),
      'categoryId': serializer.toJson<String>(categoryId),
      'isIncluded': serializer.toJson<bool>(isIncluded),
      'quota': serializer.toJson<int>(quota),
    };
  }

  WeeklyPlanningCategorySetting copyWith(
          {int? weekday, String? categoryId, bool? isIncluded, int? quota}) =>
      WeeklyPlanningCategorySetting(
        weekday: weekday ?? this.weekday,
        categoryId: categoryId ?? this.categoryId,
        isIncluded: isIncluded ?? this.isIncluded,
        quota: quota ?? this.quota,
      );
  WeeklyPlanningCategorySetting copyWithCompanion(
      WeeklyPlanningCategorySettingsCompanion data) {
    return WeeklyPlanningCategorySetting(
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      isIncluded:
          data.isIncluded.present ? data.isIncluded.value : this.isIncluded,
      quota: data.quota.present ? data.quota.value : this.quota,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlanningCategorySetting(')
          ..write('weekday: $weekday, ')
          ..write('categoryId: $categoryId, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('quota: $quota')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekday, categoryId, isIncluded, quota);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyPlanningCategorySetting &&
          other.weekday == this.weekday &&
          other.categoryId == this.categoryId &&
          other.isIncluded == this.isIncluded &&
          other.quota == this.quota);
}

class WeeklyPlanningCategorySettingsCompanion
    extends UpdateCompanion<WeeklyPlanningCategorySetting> {
  final Value<int> weekday;
  final Value<String> categoryId;
  final Value<bool> isIncluded;
  final Value<int> quota;
  final Value<int> rowid;
  const WeeklyPlanningCategorySettingsCompanion({
    this.weekday = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isIncluded = const Value.absent(),
    this.quota = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeeklyPlanningCategorySettingsCompanion.insert({
    required int weekday,
    required String categoryId,
    this.isIncluded = const Value.absent(),
    this.quota = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : weekday = Value(weekday),
        categoryId = Value(categoryId);
  static Insertable<WeeklyPlanningCategorySetting> custom({
    Expression<int>? weekday,
    Expression<String>? categoryId,
    Expression<bool>? isIncluded,
    Expression<int>? quota,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekday != null) 'weekday': weekday,
      if (categoryId != null) 'category_id': categoryId,
      if (isIncluded != null) 'is_included': isIncluded,
      if (quota != null) 'quota': quota,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeeklyPlanningCategorySettingsCompanion copyWith(
      {Value<int>? weekday,
      Value<String>? categoryId,
      Value<bool>? isIncluded,
      Value<int>? quota,
      Value<int>? rowid}) {
    return WeeklyPlanningCategorySettingsCompanion(
      weekday: weekday ?? this.weekday,
      categoryId: categoryId ?? this.categoryId,
      isIncluded: isIncluded ?? this.isIncluded,
      quota: quota ?? this.quota,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isIncluded.present) {
      map['is_included'] = Variable<bool>(isIncluded.value);
    }
    if (quota.present) {
      map['quota'] = Variable<int>(quota.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyPlanningCategorySettingsCompanion(')
          ..write('weekday: $weekday, ')
          ..write('categoryId: $categoryId, ')
          ..write('isIncluded: $isIncluded, ')
          ..write('quota: $quota, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ToyAutoNameCountersTable extends ToyAutoNameCounters
    with TableInfo<$ToyAutoNameCountersTable, ToyAutoNameCounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ToyAutoNameCountersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boxIndexMeta =
      const VerificationMeta('boxIndex');
  @override
  late final GeneratedColumn<int> boxIndex = GeneratedColumn<int>(
      'box_index', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nextNumberMeta =
      const VerificationMeta('nextNumber');
  @override
  late final GeneratedColumn<int> nextNumber = GeneratedColumn<int>(
      'next_number', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  @override
  List<GeneratedColumn> get $columns => [boxIndex, nextNumber];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'toy_auto_name_counters';
  @override
  VerificationContext validateIntegrity(Insertable<ToyAutoNameCounter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('box_index')) {
      context.handle(_boxIndexMeta,
          boxIndex.isAcceptableOrUnknown(data['box_index']!, _boxIndexMeta));
    }
    if (data.containsKey('next_number')) {
      context.handle(
          _nextNumberMeta,
          nextNumber.isAcceptableOrUnknown(
              data['next_number']!, _nextNumberMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {boxIndex};
  @override
  ToyAutoNameCounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ToyAutoNameCounter(
      boxIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}box_index'])!,
      nextNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}next_number'])!,
    );
  }

  @override
  $ToyAutoNameCountersTable createAlias(String alias) {
    return $ToyAutoNameCountersTable(attachedDatabase, alias);
  }
}

class ToyAutoNameCounter extends DataClass
    implements Insertable<ToyAutoNameCounter> {
  final int boxIndex;
  final int nextNumber;
  const ToyAutoNameCounter({required this.boxIndex, required this.nextNumber});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['box_index'] = Variable<int>(boxIndex);
    map['next_number'] = Variable<int>(nextNumber);
    return map;
  }

  ToyAutoNameCountersCompanion toCompanion(bool nullToAbsent) {
    return ToyAutoNameCountersCompanion(
      boxIndex: Value(boxIndex),
      nextNumber: Value(nextNumber),
    );
  }

  factory ToyAutoNameCounter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ToyAutoNameCounter(
      boxIndex: serializer.fromJson<int>(json['boxIndex']),
      nextNumber: serializer.fromJson<int>(json['nextNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'boxIndex': serializer.toJson<int>(boxIndex),
      'nextNumber': serializer.toJson<int>(nextNumber),
    };
  }

  ToyAutoNameCounter copyWith({int? boxIndex, int? nextNumber}) =>
      ToyAutoNameCounter(
        boxIndex: boxIndex ?? this.boxIndex,
        nextNumber: nextNumber ?? this.nextNumber,
      );
  ToyAutoNameCounter copyWithCompanion(ToyAutoNameCountersCompanion data) {
    return ToyAutoNameCounter(
      boxIndex: data.boxIndex.present ? data.boxIndex.value : this.boxIndex,
      nextNumber:
          data.nextNumber.present ? data.nextNumber.value : this.nextNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ToyAutoNameCounter(')
          ..write('boxIndex: $boxIndex, ')
          ..write('nextNumber: $nextNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(boxIndex, nextNumber);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ToyAutoNameCounter &&
          other.boxIndex == this.boxIndex &&
          other.nextNumber == this.nextNumber);
}

class ToyAutoNameCountersCompanion extends UpdateCompanion<ToyAutoNameCounter> {
  final Value<int> boxIndex;
  final Value<int> nextNumber;
  const ToyAutoNameCountersCompanion({
    this.boxIndex = const Value.absent(),
    this.nextNumber = const Value.absent(),
  });
  ToyAutoNameCountersCompanion.insert({
    this.boxIndex = const Value.absent(),
    this.nextNumber = const Value.absent(),
  });
  static Insertable<ToyAutoNameCounter> custom({
    Expression<int>? boxIndex,
    Expression<int>? nextNumber,
  }) {
    return RawValuesInsertable({
      if (boxIndex != null) 'box_index': boxIndex,
      if (nextNumber != null) 'next_number': nextNumber,
    });
  }

  ToyAutoNameCountersCompanion copyWith(
      {Value<int>? boxIndex, Value<int>? nextNumber}) {
    return ToyAutoNameCountersCompanion(
      boxIndex: boxIndex ?? this.boxIndex,
      nextNumber: nextNumber ?? this.nextNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (boxIndex.present) {
      map['box_index'] = Variable<int>(boxIndex.value);
    }
    if (nextNumber.present) {
      map['next_number'] = Variable<int>(nextNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ToyAutoNameCountersCompanion(')
          ..write('boxIndex: $boxIndex, ')
          ..write('nextNumber: $nextNumber')
          ..write(')'))
        .toString();
  }
}

class $LocationDefinitionsTable extends LocationDefinitions
    with TableInfo<$LocationDefinitionsTable, LocationDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'location_definitions';
  @override
  VerificationContext validateIntegrity(Insertable<LocationDefinition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationDefinition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $LocationDefinitionsTable createAlias(String alias) {
    return $LocationDefinitionsTable(attachedDatabase, alias);
  }
}

class LocationDefinition extends DataClass
    implements Insertable<LocationDefinition> {
  final String id;
  final String name;
  const LocationDefinition({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  LocationDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return LocationDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory LocationDefinition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationDefinition(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  LocationDefinition copyWith({String? id, String? name}) => LocationDefinition(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  LocationDefinition copyWithCompanion(LocationDefinitionsCompanion data) {
    return LocationDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationDefinition(')
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
      (other is LocationDefinition &&
          other.id == this.id &&
          other.name == this.name);
}

class LocationDefinitionsCompanion extends UpdateCompanion<LocationDefinition> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const LocationDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationDefinitionsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<LocationDefinition> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationDefinitionsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return LocationDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundsTable extends Rounds with TableInfo<$RoundsTable, Round> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<int> startAt = GeneratedColumn<int>(
      'start_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<int> endAt = GeneratedColumn<int>(
      'end_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, startAt, endAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rounds';
  @override
  VerificationContext validateIntegrity(Insertable<Round> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Round map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Round(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}end_at']),
    );
  }

  @override
  $RoundsTable createAlias(String alias) {
    return $RoundsTable(attachedDatabase, alias);
  }
}

class Round extends DataClass implements Insertable<Round> {
  final String id;
  final int startAt;
  final int? endAt;
  const Round({required this.id, required this.startAt, this.endAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['start_at'] = Variable<int>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<int>(endAt);
    }
    return map;
  }

  RoundsCompanion toCompanion(bool nullToAbsent) {
    return RoundsCompanion(
      id: Value(id),
      startAt: Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
    );
  }

  factory Round.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Round(
      id: serializer.fromJson<String>(json['id']),
      startAt: serializer.fromJson<int>(json['startAt']),
      endAt: serializer.fromJson<int?>(json['endAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'startAt': serializer.toJson<int>(startAt),
      'endAt': serializer.toJson<int?>(endAt),
    };
  }

  Round copyWith(
          {String? id,
          int? startAt,
          Value<int?> endAt = const Value.absent()}) =>
      Round(
        id: id ?? this.id,
        startAt: startAt ?? this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
      );
  Round copyWithCompanion(RoundsCompanion data) {
    return Round(
      id: data.id.present ? data.id.value : this.id,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Round(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, startAt, endAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Round &&
          other.id == this.id &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt);
}

class RoundsCompanion extends UpdateCompanion<Round> {
  final Value<String> id;
  final Value<int> startAt;
  final Value<int?> endAt;
  final Value<int> rowid;
  const RoundsCompanion({
    this.id = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundsCompanion.insert({
    required String id,
    required int startAt,
    this.endAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startAt = Value(startAt);
  static Insertable<Round> custom({
    Expression<String>? id,
    Expression<int>? startAt,
    Expression<int>? endAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundsCompanion copyWith(
      {Value<String>? id,
      Value<int>? startAt,
      Value<int?>? endAt,
      Value<int>? rowid}) {
    return RoundsCompanion(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<int>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<int>(endAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundsCompanion(')
          ..write('id: $id, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundToysTable extends RoundToys
    with TableInfo<$RoundToysTable, RoundToy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundToysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _roundIdMeta =
      const VerificationMeta('roundId');
  @override
  late final GeneratedColumn<String> roundId = GeneratedColumn<String>(
      'round_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES rounds (id)'));
  static const VerificationMeta _toyIdMeta = const VerificationMeta('toyId');
  @override
  late final GeneratedColumn<String> toyId = GeneratedColumn<String>(
      'toy_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES toys (id)'));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [roundId, toyId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_toys';
  @override
  VerificationContext validateIntegrity(Insertable<RoundToy> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('round_id')) {
      context.handle(_roundIdMeta,
          roundId.isAcceptableOrUnknown(data['round_id']!, _roundIdMeta));
    } else if (isInserting) {
      context.missing(_roundIdMeta);
    }
    if (data.containsKey('toy_id')) {
      context.handle(
          _toyIdMeta, toyId.isAcceptableOrUnknown(data['toy_id']!, _toyIdMeta));
    } else if (isInserting) {
      context.missing(_toyIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {roundId, toyId};
  @override
  RoundToy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundToy(
      roundId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}round_id'])!,
      toyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toy_id'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $RoundToysTable createAlias(String alias) {
    return $RoundToysTable(attachedDatabase, alias);
  }
}

class RoundToy extends DataClass implements Insertable<RoundToy> {
  final String roundId;
  final String toyId;
  final int position;
  const RoundToy(
      {required this.roundId, required this.toyId, required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['round_id'] = Variable<String>(roundId);
    map['toy_id'] = Variable<String>(toyId);
    map['position'] = Variable<int>(position);
    return map;
  }

  RoundToysCompanion toCompanion(bool nullToAbsent) {
    return RoundToysCompanion(
      roundId: Value(roundId),
      toyId: Value(toyId),
      position: Value(position),
    );
  }

  factory RoundToy.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundToy(
      roundId: serializer.fromJson<String>(json['roundId']),
      toyId: serializer.fromJson<String>(json['toyId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'roundId': serializer.toJson<String>(roundId),
      'toyId': serializer.toJson<String>(toyId),
      'position': serializer.toJson<int>(position),
    };
  }

  RoundToy copyWith({String? roundId, String? toyId, int? position}) =>
      RoundToy(
        roundId: roundId ?? this.roundId,
        toyId: toyId ?? this.toyId,
        position: position ?? this.position,
      );
  RoundToy copyWithCompanion(RoundToysCompanion data) {
    return RoundToy(
      roundId: data.roundId.present ? data.roundId.value : this.roundId,
      toyId: data.toyId.present ? data.toyId.value : this.toyId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundToy(')
          ..write('roundId: $roundId, ')
          ..write('toyId: $toyId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(roundId, toyId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundToy &&
          other.roundId == this.roundId &&
          other.toyId == this.toyId &&
          other.position == this.position);
}

class RoundToysCompanion extends UpdateCompanion<RoundToy> {
  final Value<String> roundId;
  final Value<String> toyId;
  final Value<int> position;
  final Value<int> rowid;
  const RoundToysCompanion({
    this.roundId = const Value.absent(),
    this.toyId = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundToysCompanion.insert({
    required String roundId,
    required String toyId,
    required int position,
    this.rowid = const Value.absent(),
  })  : roundId = Value(roundId),
        toyId = Value(toyId),
        position = Value(position);
  static Insertable<RoundToy> custom({
    Expression<String>? roundId,
    Expression<String>? toyId,
    Expression<int>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (roundId != null) 'round_id': roundId,
      if (toyId != null) 'toy_id': toyId,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundToysCompanion copyWith(
      {Value<String>? roundId,
      Value<String>? toyId,
      Value<int>? position,
      Value<int>? rowid}) {
    return RoundToysCompanion(
      roundId: roundId ?? this.roundId,
      toyId: toyId ?? this.toyId,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (roundId.present) {
      map['round_id'] = Variable<String>(roundId.value);
    }
    if (toyId.present) {
      map['toy_id'] = Variable<String>(toyId.value);
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
    return (StringBuffer('RoundToysCompanion(')
          ..write('roundId: $roundId, ')
          ..write('toyId: $toyId, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoundToyChecklistItemsTable extends RoundToyChecklistItems
    with TableInfo<$RoundToyChecklistItemsTable, RoundToyChecklistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoundToyChecklistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta =
      const VerificationMeta('dateKey');
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
      'date_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toyIdMeta = const VerificationMeta('toyId');
  @override
  late final GeneratedColumn<String> toyId = GeneratedColumn<String>(
      'toy_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES toys (id) ON DELETE CASCADE'));
  static const VerificationMeta _collectedMeta =
      const VerificationMeta('collected');
  @override
  late final GeneratedColumn<bool> collected = GeneratedColumn<bool>(
      'collected', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("collected" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [dateKey, toyId, collected, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'round_toy_checklist_items';
  @override
  VerificationContext validateIntegrity(
      Insertable<RoundToyChecklistItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(_dateKeyMeta,
          dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta));
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('toy_id')) {
      context.handle(
          _toyIdMeta, toyId.isAcceptableOrUnknown(data['toy_id']!, _toyIdMeta));
    } else if (isInserting) {
      context.missing(_toyIdMeta);
    }
    if (data.containsKey('collected')) {
      context.handle(_collectedMeta,
          collected.isAcceptableOrUnknown(data['collected']!, _collectedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey, toyId};
  @override
  RoundToyChecklistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RoundToyChecklistItem(
      dateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_key'])!,
      toyId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}toy_id'])!,
      collected: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}collected'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $RoundToyChecklistItemsTable createAlias(String alias) {
    return $RoundToyChecklistItemsTable(attachedDatabase, alias);
  }
}

class RoundToyChecklistItem extends DataClass
    implements Insertable<RoundToyChecklistItem> {
  final String dateKey;
  final String toyId;
  final bool collected;
  final int updatedAt;
  const RoundToyChecklistItem(
      {required this.dateKey,
      required this.toyId,
      required this.collected,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['toy_id'] = Variable<String>(toyId);
    map['collected'] = Variable<bool>(collected);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  RoundToyChecklistItemsCompanion toCompanion(bool nullToAbsent) {
    return RoundToyChecklistItemsCompanion(
      dateKey: Value(dateKey),
      toyId: Value(toyId),
      collected: Value(collected),
      updatedAt: Value(updatedAt),
    );
  }

  factory RoundToyChecklistItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RoundToyChecklistItem(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      toyId: serializer.fromJson<String>(json['toyId']),
      collected: serializer.fromJson<bool>(json['collected']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'toyId': serializer.toJson<String>(toyId),
      'collected': serializer.toJson<bool>(collected),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  RoundToyChecklistItem copyWith(
          {String? dateKey, String? toyId, bool? collected, int? updatedAt}) =>
      RoundToyChecklistItem(
        dateKey: dateKey ?? this.dateKey,
        toyId: toyId ?? this.toyId,
        collected: collected ?? this.collected,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RoundToyChecklistItem copyWithCompanion(
      RoundToyChecklistItemsCompanion data) {
    return RoundToyChecklistItem(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      toyId: data.toyId.present ? data.toyId.value : this.toyId,
      collected: data.collected.present ? data.collected.value : this.collected,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RoundToyChecklistItem(')
          ..write('dateKey: $dateKey, ')
          ..write('toyId: $toyId, ')
          ..write('collected: $collected, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dateKey, toyId, collected, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RoundToyChecklistItem &&
          other.dateKey == this.dateKey &&
          other.toyId == this.toyId &&
          other.collected == this.collected &&
          other.updatedAt == this.updatedAt);
}

class RoundToyChecklistItemsCompanion
    extends UpdateCompanion<RoundToyChecklistItem> {
  final Value<String> dateKey;
  final Value<String> toyId;
  final Value<bool> collected;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const RoundToyChecklistItemsCompanion({
    this.dateKey = const Value.absent(),
    this.toyId = const Value.absent(),
    this.collected = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoundToyChecklistItemsCompanion.insert({
    required String dateKey,
    required String toyId,
    this.collected = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : dateKey = Value(dateKey),
        toyId = Value(toyId),
        updatedAt = Value(updatedAt);
  static Insertable<RoundToyChecklistItem> custom({
    Expression<String>? dateKey,
    Expression<String>? toyId,
    Expression<bool>? collected,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (toyId != null) 'toy_id': toyId,
      if (collected != null) 'collected': collected,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoundToyChecklistItemsCompanion copyWith(
      {Value<String>? dateKey,
      Value<String>? toyId,
      Value<bool>? collected,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return RoundToyChecklistItemsCompanion(
      dateKey: dateKey ?? this.dateKey,
      toyId: toyId ?? this.toyId,
      collected: collected ?? this.collected,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (toyId.present) {
      map['toy_id'] = Variable<String>(toyId.value);
    }
    if (collected.present) {
      map['collected'] = Variable<bool>(collected.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoundToyChecklistItemsCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('toyId: $toyId, ')
          ..write('collected: $collected, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistoryEventsTable extends HistoryEvents
    with TableInfo<$HistoryEventsTable, HistoryEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistoryEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _eventTypeMeta =
      const VerificationMeta('eventType');
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
      'event_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, eventType, createdAt, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_events';
  @override
  VerificationContext validateIntegrity(Insertable<HistoryEvent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(_eventTypeMeta,
          eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta));
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistoryEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistoryEvent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      eventType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}event_type'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
    );
  }

  @override
  $HistoryEventsTable createAlias(String alias) {
    return $HistoryEventsTable(attachedDatabase, alias);
  }
}

class HistoryEvent extends DataClass implements Insertable<HistoryEvent> {
  final int id;
  final String eventType;
  final int createdAt;
  final String payload;
  const HistoryEvent(
      {required this.id,
      required this.eventType,
      required this.createdAt,
      required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_type'] = Variable<String>(eventType);
    map['created_at'] = Variable<int>(createdAt);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  HistoryEventsCompanion toCompanion(bool nullToAbsent) {
    return HistoryEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      createdAt: Value(createdAt),
      payload: Value(payload),
    );
  }

  factory HistoryEvent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistoryEvent(
      id: serializer.fromJson<int>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(eventType),
      'createdAt': serializer.toJson<int>(createdAt),
      'payload': serializer.toJson<String>(payload),
    };
  }

  HistoryEvent copyWith(
          {int? id, String? eventType, int? createdAt, String? payload}) =>
      HistoryEvent(
        id: id ?? this.id,
        eventType: eventType ?? this.eventType,
        createdAt: createdAt ?? this.createdAt,
        payload: payload ?? this.payload,
      );
  HistoryEvent copyWithCompanion(HistoryEventsCompanion data) {
    return HistoryEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, eventType, createdAt, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistoryEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.createdAt == this.createdAt &&
          other.payload == this.payload);
}

class HistoryEventsCompanion extends UpdateCompanion<HistoryEvent> {
  final Value<int> id;
  final Value<String> eventType;
  final Value<int> createdAt;
  final Value<String> payload;
  const HistoryEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.payload = const Value.absent(),
  });
  HistoryEventsCompanion.insert({
    this.id = const Value.absent(),
    required String eventType,
    required int createdAt,
    required String payload,
  })  : eventType = Value(eventType),
        createdAt = Value(createdAt),
        payload = Value(payload);
  static Insertable<HistoryEvent> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<int>? createdAt,
    Expression<String>? payload,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (createdAt != null) 'created_at': createdAt,
      if (payload != null) 'payload': payload,
    });
  }

  HistoryEventsCompanion copyWith(
      {Value<int>? id,
      Value<String>? eventType,
      Value<int>? createdAt,
      Value<String>? payload}) {
    return HistoryEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      createdAt: createdAt ?? this.createdAt,
      payload: payload ?? this.payload,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistoryEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('createdAt: $createdAt, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BoxesTable boxes = $BoxesTable(this);
  late final $ToysTable toys = $ToysTable(this);
  late final $CategoryDefinitionsTable categoryDefinitions =
      $CategoryDefinitionsTable(this);
  late final $CategoryCountersTable categoryCounters =
      $CategoryCountersTable(this);
  late final $RoundCategorySettingsTable roundCategorySettings =
      $RoundCategorySettingsTable(this);
  late final $RoundUiSettingsTable roundUiSettings =
      $RoundUiSettingsTable(this);
  late final $WeeklyPlanningSettingsTable weeklyPlanningSettings =
      $WeeklyPlanningSettingsTable(this);
  late final $WeeklyPlanningCategorySettingsTable
      weeklyPlanningCategorySettings =
      $WeeklyPlanningCategorySettingsTable(this);
  late final $ToyAutoNameCountersTable toyAutoNameCounters =
      $ToyAutoNameCountersTable(this);
  late final $LocationDefinitionsTable locationDefinitions =
      $LocationDefinitionsTable(this);
  late final $RoundsTable rounds = $RoundsTable(this);
  late final $RoundToysTable roundToys = $RoundToysTable(this);
  late final $RoundToyChecklistItemsTable roundToyChecklistItems =
      $RoundToyChecklistItemsTable(this);
  late final $HistoryEventsTable historyEvents = $HistoryEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        boxes,
        toys,
        categoryDefinitions,
        categoryCounters,
        roundCategorySettings,
        roundUiSettings,
        weeklyPlanningSettings,
        weeklyPlanningCategorySettings,
        toyAutoNameCounters,
        locationDefinitions,
        rounds,
        roundToys,
        roundToyChecklistItems,
        historyEvents
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('toys',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('round_toy_checklist_items', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$BoxesTableCreateCompanionBuilder = BoxesCompanion Function({
  required String id,
  Value<int> number,
  Value<String> local,
  Value<String> name,
  Value<String?> notes,
  Value<String?> photoPath,
  required int createdAt,
  Value<int> rowid,
});
typedef $$BoxesTableUpdateCompanionBuilder = BoxesCompanion Function({
  Value<String> id,
  Value<int> number,
  Value<String> local,
  Value<String> name,
  Value<String?> notes,
  Value<String?> photoPath,
  Value<int> createdAt,
  Value<int> rowid,
});

final class $$BoxesTableReferences
    extends BaseReferences<_$AppDatabase, $BoxesTable, Boxe> {
  $$BoxesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ToysTable, List<Toy>> _toysRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.toys,
          aliasName: $_aliasNameGenerator(db.boxes.id, db.toys.boxId));

  $$ToysTableProcessedTableManager get toysRefs {
    final manager = $$ToysTableTableManager($_db, $_db.toys)
        .filter((f) => f.boxId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_toysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$BoxesTableFilterComposer extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get local => $composableBuilder(
      column: $table.local, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> toysRefs(
      Expression<bool> Function($$ToysTableFilterComposer f) f) {
    final $$ToysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.boxId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableFilterComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BoxesTableOrderingComposer
    extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get number => $composableBuilder(
      column: $table.number, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get local => $composableBuilder(
      column: $table.local, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BoxesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BoxesTable> {
  $$BoxesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumn<String> get local =>
      $composableBuilder(column: $table.local, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> toysRefs<T extends Object>(
      Expression<T> Function($$ToysTableAnnotationComposer a) f) {
    final $$ToysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.boxId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableAnnotationComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$BoxesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BoxesTable,
    Boxe,
    $$BoxesTableFilterComposer,
    $$BoxesTableOrderingComposer,
    $$BoxesTableAnnotationComposer,
    $$BoxesTableCreateCompanionBuilder,
    $$BoxesTableUpdateCompanionBuilder,
    (Boxe, $$BoxesTableReferences),
    Boxe,
    PrefetchHooks Function({bool toysRefs})> {
  $$BoxesTableTableManager(_$AppDatabase db, $BoxesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BoxesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BoxesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BoxesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> number = const Value.absent(),
            Value<String> local = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BoxesCompanion(
            id: id,
            number: number,
            local: local,
            name: name,
            notes: notes,
            photoPath: photoPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int> number = const Value.absent(),
            Value<String> local = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            required int createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              BoxesCompanion.insert(
            id: id,
            number: number,
            local: local,
            name: name,
            notes: notes,
            photoPath: photoPath,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BoxesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({toysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (toysRefs) db.toys],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (toysRefs)
                    await $_getPrefetchedData<Boxe, $BoxesTable, Toy>(
                        currentTable: table,
                        referencedTable:
                            $$BoxesTableReferences._toysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$BoxesTableReferences(db, table, p0).toysRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.boxId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$BoxesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BoxesTable,
    Boxe,
    $$BoxesTableFilterComposer,
    $$BoxesTableOrderingComposer,
    $$BoxesTableAnnotationComposer,
    $$BoxesTableCreateCompanionBuilder,
    $$BoxesTableUpdateCompanionBuilder,
    (Boxe, $$BoxesTableReferences),
    Boxe,
    PrefetchHooks Function({bool toysRefs})>;
typedef $$ToysTableCreateCompanionBuilder = ToysCompanion Function({
  required String id,
  Value<String> categoryId,
  required String name,
  Value<String?> boxId,
  Value<String?> locationText,
  required int createdAt,
  Value<String?> photoPath,
  Value<int> rowid,
});
typedef $$ToysTableUpdateCompanionBuilder = ToysCompanion Function({
  Value<String> id,
  Value<String> categoryId,
  Value<String> name,
  Value<String?> boxId,
  Value<String?> locationText,
  Value<int> createdAt,
  Value<String?> photoPath,
  Value<int> rowid,
});

final class $$ToysTableReferences
    extends BaseReferences<_$AppDatabase, $ToysTable, Toy> {
  $$ToysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BoxesTable _boxIdTable(_$AppDatabase db) =>
      db.boxes.createAlias($_aliasNameGenerator(db.toys.boxId, db.boxes.id));

  $$BoxesTableProcessedTableManager? get boxId {
    final $_column = $_itemColumn<String>('box_id');
    if ($_column == null) return null;
    final manager = $$BoxesTableTableManager($_db, $_db.boxes)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_boxIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$RoundToysTable, List<RoundToy>>
      _roundToysRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.roundToys,
              aliasName: $_aliasNameGenerator(db.toys.id, db.roundToys.toyId));

  $$RoundToysTableProcessedTableManager get roundToysRefs {
    final manager = $$RoundToysTableTableManager($_db, $_db.roundToys)
        .filter((f) => f.toyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundToysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoundToyChecklistItemsTable,
      List<RoundToyChecklistItem>> _roundToyChecklistItemsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roundToyChecklistItems,
          aliasName: $_aliasNameGenerator(
              db.toys.id, db.roundToyChecklistItems.toyId));

  $$RoundToyChecklistItemsTableProcessedTableManager
      get roundToyChecklistItemsRefs {
    final manager = $$RoundToyChecklistItemsTableTableManager(
            $_db, $_db.roundToyChecklistItems)
        .filter((f) => f.toyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_roundToyChecklistItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ToysTableFilterComposer extends Composer<_$AppDatabase, $ToysTable> {
  $$ToysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locationText => $composableBuilder(
      column: $table.locationText, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnFilters(column));

  $$BoxesTableFilterComposer get boxId {
    final $$BoxesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.boxId,
        referencedTable: $db.boxes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BoxesTableFilterComposer(
              $db: $db,
              $table: $db.boxes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> roundToysRefs(
      Expression<bool> Function($$RoundToysTableFilterComposer f) f) {
    final $$RoundToysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roundToys,
        getReferencedColumn: (t) => t.toyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundToysTableFilterComposer(
              $db: $db,
              $table: $db.roundToys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roundToyChecklistItemsRefs(
      Expression<bool> Function($$RoundToyChecklistItemsTableFilterComposer f)
          f) {
    final $$RoundToyChecklistItemsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.roundToyChecklistItems,
            getReferencedColumn: (t) => t.toyId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoundToyChecklistItemsTableFilterComposer(
                  $db: $db,
                  $table: $db.roundToyChecklistItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ToysTableOrderingComposer extends Composer<_$AppDatabase, $ToysTable> {
  $$ToysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locationText => $composableBuilder(
      column: $table.locationText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoPath => $composableBuilder(
      column: $table.photoPath, builder: (column) => ColumnOrderings(column));

  $$BoxesTableOrderingComposer get boxId {
    final $$BoxesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.boxId,
        referencedTable: $db.boxes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BoxesTableOrderingComposer(
              $db: $db,
              $table: $db.boxes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ToysTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToysTable> {
  $$ToysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
      column: $table.categoryId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get locationText => $composableBuilder(
      column: $table.locationText, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  $$BoxesTableAnnotationComposer get boxId {
    final $$BoxesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.boxId,
        referencedTable: $db.boxes,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BoxesTableAnnotationComposer(
              $db: $db,
              $table: $db.boxes,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> roundToysRefs<T extends Object>(
      Expression<T> Function($$RoundToysTableAnnotationComposer a) f) {
    final $$RoundToysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roundToys,
        getReferencedColumn: (t) => t.toyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundToysTableAnnotationComposer(
              $db: $db,
              $table: $db.roundToys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roundToyChecklistItemsRefs<T extends Object>(
      Expression<T> Function($$RoundToyChecklistItemsTableAnnotationComposer a)
          f) {
    final $$RoundToyChecklistItemsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.roundToyChecklistItems,
            getReferencedColumn: (t) => t.toyId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoundToyChecklistItemsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roundToyChecklistItems,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ToysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ToysTable,
    Toy,
    $$ToysTableFilterComposer,
    $$ToysTableOrderingComposer,
    $$ToysTableAnnotationComposer,
    $$ToysTableCreateCompanionBuilder,
    $$ToysTableUpdateCompanionBuilder,
    (Toy, $$ToysTableReferences),
    Toy,
    PrefetchHooks Function(
        {bool boxId, bool roundToysRefs, bool roundToyChecklistItemsRefs})> {
  $$ToysTableTableManager(_$AppDatabase db, $ToysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> boxId = const Value.absent(),
            Value<String?> locationText = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToysCompanion(
            id: id,
            categoryId: categoryId,
            name: name,
            boxId: boxId,
            locationText: locationText,
            createdAt: createdAt,
            photoPath: photoPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> categoryId = const Value.absent(),
            required String name,
            Value<String?> boxId = const Value.absent(),
            Value<String?> locationText = const Value.absent(),
            required int createdAt,
            Value<String?> photoPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ToysCompanion.insert(
            id: id,
            categoryId: categoryId,
            name: name,
            boxId: boxId,
            locationText: locationText,
            createdAt: createdAt,
            photoPath: photoPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ToysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {boxId = false,
              roundToysRefs = false,
              roundToyChecklistItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (roundToysRefs) db.roundToys,
                if (roundToyChecklistItemsRefs) db.roundToyChecklistItems
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (boxId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.boxId,
                    referencedTable: $$ToysTableReferences._boxIdTable(db),
                    referencedColumn: $$ToysTableReferences._boxIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roundToysRefs)
                    await $_getPrefetchedData<Toy, $ToysTable, RoundToy>(
                        currentTable: table,
                        referencedTable:
                            $$ToysTableReferences._roundToysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ToysTableReferences(db, table, p0).roundToysRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.toyId == item.id),
                        typedResults: items),
                  if (roundToyChecklistItemsRefs)
                    await $_getPrefetchedData<Toy, $ToysTable,
                            RoundToyChecklistItem>(
                        currentTable: table,
                        referencedTable: $$ToysTableReferences
                            ._roundToyChecklistItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ToysTableReferences(db, table, p0)
                                .roundToyChecklistItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.toyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ToysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ToysTable,
    Toy,
    $$ToysTableFilterComposer,
    $$ToysTableOrderingComposer,
    $$ToysTableAnnotationComposer,
    $$ToysTableCreateCompanionBuilder,
    $$ToysTableUpdateCompanionBuilder,
    (Toy, $$ToysTableReferences),
    Toy,
    PrefetchHooks Function(
        {bool boxId, bool roundToysRefs, bool roundToyChecklistItemsRefs})>;
typedef $$CategoryDefinitionsTableCreateCompanionBuilder
    = CategoryDefinitionsCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  Value<String?> examples,
  Value<String?> developmentAspect,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<int> rowid,
});
typedef $$CategoryDefinitionsTableUpdateCompanionBuilder
    = CategoryDefinitionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String?> examples,
  Value<String?> developmentAspect,
  Value<int> sortOrder,
  Value<bool> isDefault,
  Value<bool> isActive,
  Value<int> rowid,
});

final class $$CategoryDefinitionsTableReferences extends BaseReferences<
    _$AppDatabase, $CategoryDefinitionsTable, CategoryDefinition> {
  $$CategoryDefinitionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CategoryCountersTable, List<CategoryCounter>>
      _categoryCountersRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.categoryCounters,
              aliasName: $_aliasNameGenerator(
                  db.categoryDefinitions.id, db.categoryCounters.categoryId));

  $$CategoryCountersTableProcessedTableManager get categoryCountersRefs {
    final manager = $$CategoryCountersTableTableManager(
            $_db, $_db.categoryCounters)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_categoryCountersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RoundCategorySettingsTable,
      List<RoundCategorySetting>> _roundCategorySettingsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.roundCategorySettings,
          aliasName: $_aliasNameGenerator(
              db.categoryDefinitions.id, db.roundCategorySettings.categoryId));

  $$RoundCategorySettingsTableProcessedTableManager
      get roundCategorySettingsRefs {
    final manager = $$RoundCategorySettingsTableTableManager(
            $_db, $_db.roundCategorySettings)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_roundCategorySettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$WeeklyPlanningCategorySettingsTable,
          List<WeeklyPlanningCategorySetting>>
      _weeklyPlanningCategorySettingsRefsTable(
              _$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.weeklyPlanningCategorySettings,
              aliasName: $_aliasNameGenerator(db.categoryDefinitions.id,
                  db.weeklyPlanningCategorySettings.categoryId));

  $$WeeklyPlanningCategorySettingsTableProcessedTableManager
      get weeklyPlanningCategorySettingsRefs {
    final manager = $$WeeklyPlanningCategorySettingsTableTableManager(
            $_db, $_db.weeklyPlanningCategorySettings)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_weeklyPlanningCategorySettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoryDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryDefinitionsTable> {
  $$CategoryDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get examples => $composableBuilder(
      column: $table.examples, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get developmentAspect => $composableBuilder(
      column: $table.developmentAspect,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  Expression<bool> categoryCountersRefs(
      Expression<bool> Function($$CategoryCountersTableFilterComposer f) f) {
    final $$CategoryCountersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryCounters,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryCountersTableFilterComposer(
              $db: $db,
              $table: $db.categoryCounters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> roundCategorySettingsRefs(
      Expression<bool> Function($$RoundCategorySettingsTableFilterComposer f)
          f) {
    final $$RoundCategorySettingsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.roundCategorySettings,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoundCategorySettingsTableFilterComposer(
                  $db: $db,
                  $table: $db.roundCategorySettings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> weeklyPlanningCategorySettingsRefs(
      Expression<bool> Function(
              $$WeeklyPlanningCategorySettingsTableFilterComposer f)
          f) {
    final $$WeeklyPlanningCategorySettingsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.weeklyPlanningCategorySettings,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WeeklyPlanningCategorySettingsTableFilterComposer(
                  $db: $db,
                  $table: $db.weeklyPlanningCategorySettings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoryDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryDefinitionsTable> {
  $$CategoryDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get examples => $composableBuilder(
      column: $table.examples, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get developmentAspect => $composableBuilder(
      column: $table.developmentAspect,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$CategoryDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryDefinitionsTable> {
  $$CategoryDefinitionsTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);

  GeneratedColumn<String> get developmentAspect => $composableBuilder(
      column: $table.developmentAspect, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> categoryCountersRefs<T extends Object>(
      Expression<T> Function($$CategoryCountersTableAnnotationComposer a) f) {
    final $$CategoryCountersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.categoryCounters,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryCountersTableAnnotationComposer(
              $db: $db,
              $table: $db.categoryCounters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> roundCategorySettingsRefs<T extends Object>(
      Expression<T> Function($$RoundCategorySettingsTableAnnotationComposer a)
          f) {
    final $$RoundCategorySettingsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.roundCategorySettings,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RoundCategorySettingsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.roundCategorySettings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> weeklyPlanningCategorySettingsRefs<T extends Object>(
      Expression<T> Function(
              $$WeeklyPlanningCategorySettingsTableAnnotationComposer a)
          f) {
    final $$WeeklyPlanningCategorySettingsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.weeklyPlanningCategorySettings,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$WeeklyPlanningCategorySettingsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.weeklyPlanningCategorySettings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoryDefinitionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryDefinitionsTable,
    CategoryDefinition,
    $$CategoryDefinitionsTableFilterComposer,
    $$CategoryDefinitionsTableOrderingComposer,
    $$CategoryDefinitionsTableAnnotationComposer,
    $$CategoryDefinitionsTableCreateCompanionBuilder,
    $$CategoryDefinitionsTableUpdateCompanionBuilder,
    (CategoryDefinition, $$CategoryDefinitionsTableReferences),
    CategoryDefinition,
    PrefetchHooks Function(
        {bool categoryCountersRefs,
        bool roundCategorySettingsRefs,
        bool weeklyPlanningCategorySettingsRefs})> {
  $$CategoryDefinitionsTableTableManager(
      _$AppDatabase db, $CategoryDefinitionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryDefinitionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryDefinitionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String?> examples = const Value.absent(),
            Value<String?> developmentAspect = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryDefinitionsCompanion(
            id: id,
            name: name,
            description: description,
            examples: examples,
            developmentAspect: developmentAspect,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isActive: isActive,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            Value<String?> examples = const Value.absent(),
            Value<String?> developmentAspect = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryDefinitionsCompanion.insert(
            id: id,
            name: name,
            description: description,
            examples: examples,
            developmentAspect: developmentAspect,
            sortOrder: sortOrder,
            isDefault: isDefault,
            isActive: isActive,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryDefinitionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {categoryCountersRefs = false,
              roundCategorySettingsRefs = false,
              weeklyPlanningCategorySettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (categoryCountersRefs) db.categoryCounters,
                if (roundCategorySettingsRefs) db.roundCategorySettings,
                if (weeklyPlanningCategorySettingsRefs)
                  db.weeklyPlanningCategorySettings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (categoryCountersRefs)
                    await $_getPrefetchedData<CategoryDefinition,
                            $CategoryDefinitionsTable, CategoryCounter>(
                        currentTable: table,
                        referencedTable: $$CategoryDefinitionsTableReferences
                            ._categoryCountersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryDefinitionsTableReferences(db, table, p0)
                                .categoryCountersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (roundCategorySettingsRefs)
                    await $_getPrefetchedData<CategoryDefinition,
                            $CategoryDefinitionsTable, RoundCategorySetting>(
                        currentTable: table,
                        referencedTable: $$CategoryDefinitionsTableReferences
                            ._roundCategorySettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryDefinitionsTableReferences(db, table, p0)
                                .roundCategorySettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (weeklyPlanningCategorySettingsRefs)
                    await $_getPrefetchedData<
                            CategoryDefinition,
                            $CategoryDefinitionsTable,
                            WeeklyPlanningCategorySetting>(
                        currentTable: table,
                        referencedTable: $$CategoryDefinitionsTableReferences
                            ._weeklyPlanningCategorySettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoryDefinitionsTableReferences(db, table, p0)
                                .weeklyPlanningCategorySettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoryDefinitionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryDefinitionsTable,
    CategoryDefinition,
    $$CategoryDefinitionsTableFilterComposer,
    $$CategoryDefinitionsTableOrderingComposer,
    $$CategoryDefinitionsTableAnnotationComposer,
    $$CategoryDefinitionsTableCreateCompanionBuilder,
    $$CategoryDefinitionsTableUpdateCompanionBuilder,
    (CategoryDefinition, $$CategoryDefinitionsTableReferences),
    CategoryDefinition,
    PrefetchHooks Function(
        {bool categoryCountersRefs,
        bool roundCategorySettingsRefs,
        bool weeklyPlanningCategorySettingsRefs})>;
typedef $$CategoryCountersTableCreateCompanionBuilder
    = CategoryCountersCompanion Function({
  required String categoryId,
  Value<int> nextNumber,
  Value<int> rowid,
});
typedef $$CategoryCountersTableUpdateCompanionBuilder
    = CategoryCountersCompanion Function({
  Value<String> categoryId,
  Value<int> nextNumber,
  Value<int> rowid,
});

final class $$CategoryCountersTableReferences extends BaseReferences<
    _$AppDatabase, $CategoryCountersTable, CategoryCounter> {
  $$CategoryCountersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoryDefinitionsTable _categoryIdTable(_$AppDatabase db) =>
      db.categoryDefinitions.createAlias($_aliasNameGenerator(
          db.categoryCounters.categoryId, db.categoryDefinitions.id));

  $$CategoryDefinitionsTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager =
        $$CategoryDefinitionsTableTableManager($_db, $_db.categoryDefinitions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CategoryCountersTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryCountersTable> {
  $$CategoryCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnFilters(column));

  $$CategoryDefinitionsTableFilterComposer get categoryId {
    final $$CategoryDefinitionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryDefinitions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryDefinitionsTableFilterComposer(
              $db: $db,
              $table: $db.categoryDefinitions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CategoryCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryCountersTable> {
  $$CategoryCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnOrderings(column));

  $$CategoryDefinitionsTableOrderingComposer get categoryId {
    final $$CategoryDefinitionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CategoryCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryCountersTable> {
  $$CategoryCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => column);

  $$CategoryDefinitionsTableAnnotationComposer get categoryId {
    final $$CategoryDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$CategoryCountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoryCountersTable,
    CategoryCounter,
    $$CategoryCountersTableFilterComposer,
    $$CategoryCountersTableOrderingComposer,
    $$CategoryCountersTableAnnotationComposer,
    $$CategoryCountersTableCreateCompanionBuilder,
    $$CategoryCountersTableUpdateCompanionBuilder,
    (CategoryCounter, $$CategoryCountersTableReferences),
    CategoryCounter,
    PrefetchHooks Function({bool categoryId})> {
  $$CategoryCountersTableTableManager(
      _$AppDatabase db, $CategoryCountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryCountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryCountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> categoryId = const Value.absent(),
            Value<int> nextNumber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryCountersCompanion(
            categoryId: categoryId,
            nextNumber: nextNumber,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String categoryId,
            Value<int> nextNumber = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoryCountersCompanion.insert(
            categoryId: categoryId,
            nextNumber: nextNumber,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoryCountersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$CategoryCountersTableReferences._categoryIdTable(db),
                    referencedColumn: $$CategoryCountersTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CategoryCountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoryCountersTable,
    CategoryCounter,
    $$CategoryCountersTableFilterComposer,
    $$CategoryCountersTableOrderingComposer,
    $$CategoryCountersTableAnnotationComposer,
    $$CategoryCountersTableCreateCompanionBuilder,
    $$CategoryCountersTableUpdateCompanionBuilder,
    (CategoryCounter, $$CategoryCountersTableReferences),
    CategoryCounter,
    PrefetchHooks Function({bool categoryId})>;
typedef $$RoundCategorySettingsTableCreateCompanionBuilder
    = RoundCategorySettingsCompanion Function({
  required String categoryId,
  Value<bool> isIncluded,
  Value<int> quota,
  Value<int> rowid,
});
typedef $$RoundCategorySettingsTableUpdateCompanionBuilder
    = RoundCategorySettingsCompanion Function({
  Value<String> categoryId,
  Value<bool> isIncluded,
  Value<int> quota,
  Value<int> rowid,
});

final class $$RoundCategorySettingsTableReferences extends BaseReferences<
    _$AppDatabase, $RoundCategorySettingsTable, RoundCategorySetting> {
  $$RoundCategorySettingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoryDefinitionsTable _categoryIdTable(_$AppDatabase db) =>
      db.categoryDefinitions.createAlias($_aliasNameGenerator(
          db.roundCategorySettings.categoryId, db.categoryDefinitions.id));

  $$CategoryDefinitionsTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager =
        $$CategoryDefinitionsTableTableManager($_db, $_db.categoryDefinitions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoundCategorySettingsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundCategorySettingsTable> {
  $$RoundCategorySettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quota => $composableBuilder(
      column: $table.quota, builder: (column) => ColumnFilters(column));

  $$CategoryDefinitionsTableFilterComposer get categoryId {
    final $$CategoryDefinitionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryDefinitions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryDefinitionsTableFilterComposer(
              $db: $db,
              $table: $db.categoryDefinitions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundCategorySettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundCategorySettingsTable> {
  $$RoundCategorySettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quota => $composableBuilder(
      column: $table.quota, builder: (column) => ColumnOrderings(column));

  $$CategoryDefinitionsTableOrderingComposer get categoryId {
    final $$CategoryDefinitionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$RoundCategorySettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundCategorySettingsTable> {
  $$RoundCategorySettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => column);

  GeneratedColumn<int> get quota =>
      $composableBuilder(column: $table.quota, builder: (column) => column);

  $$CategoryDefinitionsTableAnnotationComposer get categoryId {
    final $$CategoryDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$RoundCategorySettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundCategorySettingsTable,
    RoundCategorySetting,
    $$RoundCategorySettingsTableFilterComposer,
    $$RoundCategorySettingsTableOrderingComposer,
    $$RoundCategorySettingsTableAnnotationComposer,
    $$RoundCategorySettingsTableCreateCompanionBuilder,
    $$RoundCategorySettingsTableUpdateCompanionBuilder,
    (RoundCategorySetting, $$RoundCategorySettingsTableReferences),
    RoundCategorySetting,
    PrefetchHooks Function({bool categoryId})> {
  $$RoundCategorySettingsTableTableManager(
      _$AppDatabase db, $RoundCategorySettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundCategorySettingsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundCategorySettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundCategorySettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> categoryId = const Value.absent(),
            Value<bool> isIncluded = const Value.absent(),
            Value<int> quota = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundCategorySettingsCompanion(
            categoryId: categoryId,
            isIncluded: isIncluded,
            quota: quota,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String categoryId,
            Value<bool> isIncluded = const Value.absent(),
            Value<int> quota = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundCategorySettingsCompanion.insert(
            categoryId: categoryId,
            isIncluded: isIncluded,
            quota: quota,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoundCategorySettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable: $$RoundCategorySettingsTableReferences
                        ._categoryIdTable(db),
                    referencedColumn: $$RoundCategorySettingsTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoundCategorySettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RoundCategorySettingsTable,
        RoundCategorySetting,
        $$RoundCategorySettingsTableFilterComposer,
        $$RoundCategorySettingsTableOrderingComposer,
        $$RoundCategorySettingsTableAnnotationComposer,
        $$RoundCategorySettingsTableCreateCompanionBuilder,
        $$RoundCategorySettingsTableUpdateCompanionBuilder,
        (RoundCategorySetting, $$RoundCategorySettingsTableReferences),
        RoundCategorySetting,
        PrefetchHooks Function({bool categoryId})>;
typedef $$RoundUiSettingsTableCreateCompanionBuilder = RoundUiSettingsCompanion
    Function({
  Value<int> id,
  Value<int> perCategoryLimit,
  Value<bool> hapticEnabled,
  Value<bool> soundEnabled,
  Value<bool> darkModeEnabled,
  Value<String?> childAgeRange,
});
typedef $$RoundUiSettingsTableUpdateCompanionBuilder = RoundUiSettingsCompanion
    Function({
  Value<int> id,
  Value<int> perCategoryLimit,
  Value<bool> hapticEnabled,
  Value<bool> soundEnabled,
  Value<bool> darkModeEnabled,
  Value<String?> childAgeRange,
});

class $$RoundUiSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundUiSettingsTable> {
  $$RoundUiSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get perCategoryLimit => $composableBuilder(
      column: $table.perCategoryLimit,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hapticEnabled => $composableBuilder(
      column: $table.hapticEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get darkModeEnabled => $composableBuilder(
      column: $table.darkModeEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get childAgeRange => $composableBuilder(
      column: $table.childAgeRange, builder: (column) => ColumnFilters(column));
}

class $$RoundUiSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundUiSettingsTable> {
  $$RoundUiSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get perCategoryLimit => $composableBuilder(
      column: $table.perCategoryLimit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hapticEnabled => $composableBuilder(
      column: $table.hapticEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get darkModeEnabled => $composableBuilder(
      column: $table.darkModeEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get childAgeRange => $composableBuilder(
      column: $table.childAgeRange,
      builder: (column) => ColumnOrderings(column));
}

class $$RoundUiSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundUiSettingsTable> {
  $$RoundUiSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get perCategoryLimit => $composableBuilder(
      column: $table.perCategoryLimit, builder: (column) => column);

  GeneratedColumn<bool> get hapticEnabled => $composableBuilder(
      column: $table.hapticEnabled, builder: (column) => column);

  GeneratedColumn<bool> get soundEnabled => $composableBuilder(
      column: $table.soundEnabled, builder: (column) => column);

  GeneratedColumn<bool> get darkModeEnabled => $composableBuilder(
      column: $table.darkModeEnabled, builder: (column) => column);

  GeneratedColumn<String> get childAgeRange => $composableBuilder(
      column: $table.childAgeRange, builder: (column) => column);
}

class $$RoundUiSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundUiSettingsTable,
    RoundUiSetting,
    $$RoundUiSettingsTableFilterComposer,
    $$RoundUiSettingsTableOrderingComposer,
    $$RoundUiSettingsTableAnnotationComposer,
    $$RoundUiSettingsTableCreateCompanionBuilder,
    $$RoundUiSettingsTableUpdateCompanionBuilder,
    (
      RoundUiSetting,
      BaseReferences<_$AppDatabase, $RoundUiSettingsTable, RoundUiSetting>
    ),
    RoundUiSetting,
    PrefetchHooks Function()> {
  $$RoundUiSettingsTableTableManager(
      _$AppDatabase db, $RoundUiSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundUiSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundUiSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundUiSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> perCategoryLimit = const Value.absent(),
            Value<bool> hapticEnabled = const Value.absent(),
            Value<bool> soundEnabled = const Value.absent(),
            Value<bool> darkModeEnabled = const Value.absent(),
            Value<String?> childAgeRange = const Value.absent(),
          }) =>
              RoundUiSettingsCompanion(
            id: id,
            perCategoryLimit: perCategoryLimit,
            hapticEnabled: hapticEnabled,
            soundEnabled: soundEnabled,
            darkModeEnabled: darkModeEnabled,
            childAgeRange: childAgeRange,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> perCategoryLimit = const Value.absent(),
            Value<bool> hapticEnabled = const Value.absent(),
            Value<bool> soundEnabled = const Value.absent(),
            Value<bool> darkModeEnabled = const Value.absent(),
            Value<String?> childAgeRange = const Value.absent(),
          }) =>
              RoundUiSettingsCompanion.insert(
            id: id,
            perCategoryLimit: perCategoryLimit,
            hapticEnabled: hapticEnabled,
            soundEnabled: soundEnabled,
            darkModeEnabled: darkModeEnabled,
            childAgeRange: childAgeRange,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RoundUiSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoundUiSettingsTable,
    RoundUiSetting,
    $$RoundUiSettingsTableFilterComposer,
    $$RoundUiSettingsTableOrderingComposer,
    $$RoundUiSettingsTableAnnotationComposer,
    $$RoundUiSettingsTableCreateCompanionBuilder,
    $$RoundUiSettingsTableUpdateCompanionBuilder,
    (
      RoundUiSetting,
      BaseReferences<_$AppDatabase, $RoundUiSettingsTable, RoundUiSetting>
    ),
    RoundUiSetting,
    PrefetchHooks Function()>;
typedef $$WeeklyPlanningSettingsTableCreateCompanionBuilder
    = WeeklyPlanningSettingsCompanion Function({
  Value<int> weekday,
  Value<bool> useDefault,
  Value<int?> customSize,
});
typedef $$WeeklyPlanningSettingsTableUpdateCompanionBuilder
    = WeeklyPlanningSettingsCompanion Function({
  Value<int> weekday,
  Value<bool> useDefault,
  Value<int?> customSize,
});

class $$WeeklyPlanningSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningSettingsTable> {
  $$WeeklyPlanningSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get useDefault => $composableBuilder(
      column: $table.useDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customSize => $composableBuilder(
      column: $table.customSize, builder: (column) => ColumnFilters(column));
}

class $$WeeklyPlanningSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningSettingsTable> {
  $$WeeklyPlanningSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get useDefault => $composableBuilder(
      column: $table.useDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customSize => $composableBuilder(
      column: $table.customSize, builder: (column) => ColumnOrderings(column));
}

class $$WeeklyPlanningSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningSettingsTable> {
  $$WeeklyPlanningSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<bool> get useDefault => $composableBuilder(
      column: $table.useDefault, builder: (column) => column);

  GeneratedColumn<int> get customSize => $composableBuilder(
      column: $table.customSize, builder: (column) => column);
}

class $$WeeklyPlanningSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeeklyPlanningSettingsTable,
    WeeklyPlanningSetting,
    $$WeeklyPlanningSettingsTableFilterComposer,
    $$WeeklyPlanningSettingsTableOrderingComposer,
    $$WeeklyPlanningSettingsTableAnnotationComposer,
    $$WeeklyPlanningSettingsTableCreateCompanionBuilder,
    $$WeeklyPlanningSettingsTableUpdateCompanionBuilder,
    (
      WeeklyPlanningSetting,
      BaseReferences<_$AppDatabase, $WeeklyPlanningSettingsTable,
          WeeklyPlanningSetting>
    ),
    WeeklyPlanningSetting,
    PrefetchHooks Function()> {
  $$WeeklyPlanningSettingsTableTableManager(
      _$AppDatabase db, $WeeklyPlanningSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyPlanningSettingsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyPlanningSettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyPlanningSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> weekday = const Value.absent(),
            Value<bool> useDefault = const Value.absent(),
            Value<int?> customSize = const Value.absent(),
          }) =>
              WeeklyPlanningSettingsCompanion(
            weekday: weekday,
            useDefault: useDefault,
            customSize: customSize,
          ),
          createCompanionCallback: ({
            Value<int> weekday = const Value.absent(),
            Value<bool> useDefault = const Value.absent(),
            Value<int?> customSize = const Value.absent(),
          }) =>
              WeeklyPlanningSettingsCompanion.insert(
            weekday: weekday,
            useDefault: useDefault,
            customSize: customSize,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeeklyPlanningSettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $WeeklyPlanningSettingsTable,
        WeeklyPlanningSetting,
        $$WeeklyPlanningSettingsTableFilterComposer,
        $$WeeklyPlanningSettingsTableOrderingComposer,
        $$WeeklyPlanningSettingsTableAnnotationComposer,
        $$WeeklyPlanningSettingsTableCreateCompanionBuilder,
        $$WeeklyPlanningSettingsTableUpdateCompanionBuilder,
        (
          WeeklyPlanningSetting,
          BaseReferences<_$AppDatabase, $WeeklyPlanningSettingsTable,
              WeeklyPlanningSetting>
        ),
        WeeklyPlanningSetting,
        PrefetchHooks Function()>;
typedef $$WeeklyPlanningCategorySettingsTableCreateCompanionBuilder
    = WeeklyPlanningCategorySettingsCompanion Function({
  required int weekday,
  required String categoryId,
  Value<bool> isIncluded,
  Value<int> quota,
  Value<int> rowid,
});
typedef $$WeeklyPlanningCategorySettingsTableUpdateCompanionBuilder
    = WeeklyPlanningCategorySettingsCompanion Function({
  Value<int> weekday,
  Value<String> categoryId,
  Value<bool> isIncluded,
  Value<int> quota,
  Value<int> rowid,
});

final class $$WeeklyPlanningCategorySettingsTableReferences
    extends BaseReferences<_$AppDatabase, $WeeklyPlanningCategorySettingsTable,
        WeeklyPlanningCategorySetting> {
  $$WeeklyPlanningCategorySettingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoryDefinitionsTable _categoryIdTable(_$AppDatabase db) =>
      db.categoryDefinitions.createAlias($_aliasNameGenerator(
          db.weeklyPlanningCategorySettings.categoryId,
          db.categoryDefinitions.id));

  $$CategoryDefinitionsTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager =
        $$CategoryDefinitionsTableTableManager($_db, $_db.categoryDefinitions)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$WeeklyPlanningCategorySettingsTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningCategorySettingsTable> {
  $$WeeklyPlanningCategorySettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quota => $composableBuilder(
      column: $table.quota, builder: (column) => ColumnFilters(column));

  $$CategoryDefinitionsTableFilterComposer get categoryId {
    final $$CategoryDefinitionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categoryDefinitions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoryDefinitionsTableFilterComposer(
              $db: $db,
              $table: $db.categoryDefinitions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$WeeklyPlanningCategorySettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningCategorySettingsTable> {
  $$WeeklyPlanningCategorySettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekday => $composableBuilder(
      column: $table.weekday, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quota => $composableBuilder(
      column: $table.quota, builder: (column) => ColumnOrderings(column));

  $$CategoryDefinitionsTableOrderingComposer get categoryId {
    final $$CategoryDefinitionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WeeklyPlanningCategorySettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklyPlanningCategorySettingsTable> {
  $$WeeklyPlanningCategorySettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<bool> get isIncluded => $composableBuilder(
      column: $table.isIncluded, builder: (column) => column);

  GeneratedColumn<int> get quota =>
      $composableBuilder(column: $table.quota, builder: (column) => column);

  $$CategoryDefinitionsTableAnnotationComposer get categoryId {
    final $$CategoryDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.categoryId,
            referencedTable: $db.categoryDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CategoryDefinitionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.categoryDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$WeeklyPlanningCategorySettingsTableTableManager
    extends RootTableManager<
        _$AppDatabase,
        $WeeklyPlanningCategorySettingsTable,
        WeeklyPlanningCategorySetting,
        $$WeeklyPlanningCategorySettingsTableFilterComposer,
        $$WeeklyPlanningCategorySettingsTableOrderingComposer,
        $$WeeklyPlanningCategorySettingsTableAnnotationComposer,
        $$WeeklyPlanningCategorySettingsTableCreateCompanionBuilder,
        $$WeeklyPlanningCategorySettingsTableUpdateCompanionBuilder,
        (
          WeeklyPlanningCategorySetting,
          $$WeeklyPlanningCategorySettingsTableReferences
        ),
        WeeklyPlanningCategorySetting,
        PrefetchHooks Function({bool categoryId})> {
  $$WeeklyPlanningCategorySettingsTableTableManager(
      _$AppDatabase db, $WeeklyPlanningCategorySettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklyPlanningCategorySettingsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklyPlanningCategorySettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklyPlanningCategorySettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> weekday = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<bool> isIncluded = const Value.absent(),
            Value<int> quota = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeeklyPlanningCategorySettingsCompanion(
            weekday: weekday,
            categoryId: categoryId,
            isIncluded: isIncluded,
            quota: quota,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int weekday,
            required String categoryId,
            Value<bool> isIncluded = const Value.absent(),
            Value<int> quota = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeeklyPlanningCategorySettingsCompanion.insert(
            weekday: weekday,
            categoryId: categoryId,
            isIncluded: isIncluded,
            quota: quota,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$WeeklyPlanningCategorySettingsTableReferences(
                        db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$WeeklyPlanningCategorySettingsTableReferences
                            ._categoryIdTable(db),
                    referencedColumn:
                        $$WeeklyPlanningCategorySettingsTableReferences
                            ._categoryIdTable(db)
                            .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$WeeklyPlanningCategorySettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $WeeklyPlanningCategorySettingsTable,
        WeeklyPlanningCategorySetting,
        $$WeeklyPlanningCategorySettingsTableFilterComposer,
        $$WeeklyPlanningCategorySettingsTableOrderingComposer,
        $$WeeklyPlanningCategorySettingsTableAnnotationComposer,
        $$WeeklyPlanningCategorySettingsTableCreateCompanionBuilder,
        $$WeeklyPlanningCategorySettingsTableUpdateCompanionBuilder,
        (
          WeeklyPlanningCategorySetting,
          $$WeeklyPlanningCategorySettingsTableReferences
        ),
        WeeklyPlanningCategorySetting,
        PrefetchHooks Function({bool categoryId})>;
typedef $$ToyAutoNameCountersTableCreateCompanionBuilder
    = ToyAutoNameCountersCompanion Function({
  Value<int> boxIndex,
  Value<int> nextNumber,
});
typedef $$ToyAutoNameCountersTableUpdateCompanionBuilder
    = ToyAutoNameCountersCompanion Function({
  Value<int> boxIndex,
  Value<int> nextNumber,
});

class $$ToyAutoNameCountersTableFilterComposer
    extends Composer<_$AppDatabase, $ToyAutoNameCountersTable> {
  $$ToyAutoNameCountersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get boxIndex => $composableBuilder(
      column: $table.boxIndex, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnFilters(column));
}

class $$ToyAutoNameCountersTableOrderingComposer
    extends Composer<_$AppDatabase, $ToyAutoNameCountersTable> {
  $$ToyAutoNameCountersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get boxIndex => $composableBuilder(
      column: $table.boxIndex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => ColumnOrderings(column));
}

class $$ToyAutoNameCountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ToyAutoNameCountersTable> {
  $$ToyAutoNameCountersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get boxIndex =>
      $composableBuilder(column: $table.boxIndex, builder: (column) => column);

  GeneratedColumn<int> get nextNumber => $composableBuilder(
      column: $table.nextNumber, builder: (column) => column);
}

class $$ToyAutoNameCountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ToyAutoNameCountersTable,
    ToyAutoNameCounter,
    $$ToyAutoNameCountersTableFilterComposer,
    $$ToyAutoNameCountersTableOrderingComposer,
    $$ToyAutoNameCountersTableAnnotationComposer,
    $$ToyAutoNameCountersTableCreateCompanionBuilder,
    $$ToyAutoNameCountersTableUpdateCompanionBuilder,
    (
      ToyAutoNameCounter,
      BaseReferences<_$AppDatabase, $ToyAutoNameCountersTable,
          ToyAutoNameCounter>
    ),
    ToyAutoNameCounter,
    PrefetchHooks Function()> {
  $$ToyAutoNameCountersTableTableManager(
      _$AppDatabase db, $ToyAutoNameCountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ToyAutoNameCountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ToyAutoNameCountersTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ToyAutoNameCountersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> boxIndex = const Value.absent(),
            Value<int> nextNumber = const Value.absent(),
          }) =>
              ToyAutoNameCountersCompanion(
            boxIndex: boxIndex,
            nextNumber: nextNumber,
          ),
          createCompanionCallback: ({
            Value<int> boxIndex = const Value.absent(),
            Value<int> nextNumber = const Value.absent(),
          }) =>
              ToyAutoNameCountersCompanion.insert(
            boxIndex: boxIndex,
            nextNumber: nextNumber,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ToyAutoNameCountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ToyAutoNameCountersTable,
    ToyAutoNameCounter,
    $$ToyAutoNameCountersTableFilterComposer,
    $$ToyAutoNameCountersTableOrderingComposer,
    $$ToyAutoNameCountersTableAnnotationComposer,
    $$ToyAutoNameCountersTableCreateCompanionBuilder,
    $$ToyAutoNameCountersTableUpdateCompanionBuilder,
    (
      ToyAutoNameCounter,
      BaseReferences<_$AppDatabase, $ToyAutoNameCountersTable,
          ToyAutoNameCounter>
    ),
    ToyAutoNameCounter,
    PrefetchHooks Function()>;
typedef $$LocationDefinitionsTableCreateCompanionBuilder
    = LocationDefinitionsCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$LocationDefinitionsTableUpdateCompanionBuilder
    = LocationDefinitionsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$LocationDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationDefinitionsTable> {
  $$LocationDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$LocationDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationDefinitionsTable> {
  $$LocationDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$LocationDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationDefinitionsTable> {
  $$LocationDefinitionsTableAnnotationComposer({
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
}

class $$LocationDefinitionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocationDefinitionsTable,
    LocationDefinition,
    $$LocationDefinitionsTableFilterComposer,
    $$LocationDefinitionsTableOrderingComposer,
    $$LocationDefinitionsTableAnnotationComposer,
    $$LocationDefinitionsTableCreateCompanionBuilder,
    $$LocationDefinitionsTableUpdateCompanionBuilder,
    (
      LocationDefinition,
      BaseReferences<_$AppDatabase, $LocationDefinitionsTable,
          LocationDefinition>
    ),
    LocationDefinition,
    PrefetchHooks Function()> {
  $$LocationDefinitionsTableTableManager(
      _$AppDatabase db, $LocationDefinitionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationDefinitionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationDefinitionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationDefinitionsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocationDefinitionsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocationDefinitionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocationDefinitionsTable,
    LocationDefinition,
    $$LocationDefinitionsTableFilterComposer,
    $$LocationDefinitionsTableOrderingComposer,
    $$LocationDefinitionsTableAnnotationComposer,
    $$LocationDefinitionsTableCreateCompanionBuilder,
    $$LocationDefinitionsTableUpdateCompanionBuilder,
    (
      LocationDefinition,
      BaseReferences<_$AppDatabase, $LocationDefinitionsTable,
          LocationDefinition>
    ),
    LocationDefinition,
    PrefetchHooks Function()>;
typedef $$RoundsTableCreateCompanionBuilder = RoundsCompanion Function({
  required String id,
  required int startAt,
  Value<int?> endAt,
  Value<int> rowid,
});
typedef $$RoundsTableUpdateCompanionBuilder = RoundsCompanion Function({
  Value<String> id,
  Value<int> startAt,
  Value<int?> endAt,
  Value<int> rowid,
});

final class $$RoundsTableReferences
    extends BaseReferences<_$AppDatabase, $RoundsTable, Round> {
  $$RoundsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RoundToysTable, List<RoundToy>>
      _roundToysRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.roundToys,
          aliasName: $_aliasNameGenerator(db.rounds.id, db.roundToys.roundId));

  $$RoundToysTableProcessedTableManager get roundToysRefs {
    final manager = $$RoundToysTableTableManager($_db, $_db.roundToys)
        .filter((f) => f.roundId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_roundToysRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RoundsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  Expression<bool> roundToysRefs(
      Expression<bool> Function($$RoundToysTableFilterComposer f) f) {
    final $$RoundToysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roundToys,
        getReferencedColumn: (t) => t.roundId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundToysTableFilterComposer(
              $db: $db,
              $table: $db.roundToys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));
}

class $$RoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundsTable> {
  $$RoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<int> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  Expression<T> roundToysRefs<T extends Object>(
      Expression<T> Function($$RoundToysTableAnnotationComposer a) f) {
    final $$RoundToysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.roundToys,
        getReferencedColumn: (t) => t.roundId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundToysTableAnnotationComposer(
              $db: $db,
              $table: $db.roundToys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RoundsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundsTable,
    Round,
    $$RoundsTableFilterComposer,
    $$RoundsTableOrderingComposer,
    $$RoundsTableAnnotationComposer,
    $$RoundsTableCreateCompanionBuilder,
    $$RoundsTableUpdateCompanionBuilder,
    (Round, $$RoundsTableReferences),
    Round,
    PrefetchHooks Function({bool roundToysRefs})> {
  $$RoundsTableTableManager(_$AppDatabase db, $RoundsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> startAt = const Value.absent(),
            Value<int?> endAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundsCompanion(
            id: id,
            startAt: startAt,
            endAt: endAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int startAt,
            Value<int?> endAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundsCompanion.insert(
            id: id,
            startAt: startAt,
            endAt: endAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$RoundsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({roundToysRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (roundToysRefs) db.roundToys],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (roundToysRefs)
                    await $_getPrefetchedData<Round, $RoundsTable, RoundToy>(
                        currentTable: table,
                        referencedTable:
                            $$RoundsTableReferences._roundToysRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RoundsTableReferences(db, table, p0)
                                .roundToysRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.roundId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RoundsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoundsTable,
    Round,
    $$RoundsTableFilterComposer,
    $$RoundsTableOrderingComposer,
    $$RoundsTableAnnotationComposer,
    $$RoundsTableCreateCompanionBuilder,
    $$RoundsTableUpdateCompanionBuilder,
    (Round, $$RoundsTableReferences),
    Round,
    PrefetchHooks Function({bool roundToysRefs})>;
typedef $$RoundToysTableCreateCompanionBuilder = RoundToysCompanion Function({
  required String roundId,
  required String toyId,
  required int position,
  Value<int> rowid,
});
typedef $$RoundToysTableUpdateCompanionBuilder = RoundToysCompanion Function({
  Value<String> roundId,
  Value<String> toyId,
  Value<int> position,
  Value<int> rowid,
});

final class $$RoundToysTableReferences
    extends BaseReferences<_$AppDatabase, $RoundToysTable, RoundToy> {
  $$RoundToysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoundsTable _roundIdTable(_$AppDatabase db) => db.rounds
      .createAlias($_aliasNameGenerator(db.roundToys.roundId, db.rounds.id));

  $$RoundsTableProcessedTableManager get roundId {
    final $_column = $_itemColumn<String>('round_id')!;

    final manager = $$RoundsTableTableManager($_db, $_db.rounds)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roundIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ToysTable _toyIdTable(_$AppDatabase db) =>
      db.toys.createAlias($_aliasNameGenerator(db.roundToys.toyId, db.toys.id));

  $$ToysTableProcessedTableManager get toyId {
    final $_column = $_itemColumn<String>('toy_id')!;

    final manager = $$ToysTableTableManager($_db, $_db.toys)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoundToysTableFilterComposer
    extends Composer<_$AppDatabase, $RoundToysTable> {
  $$RoundToysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  $$RoundsTableFilterComposer get roundId {
    final $$RoundsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roundId,
        referencedTable: $db.rounds,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundsTableFilterComposer(
              $db: $db,
              $table: $db.rounds,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ToysTableFilterComposer get toyId {
    final $$ToysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableFilterComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToysTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundToysTable> {
  $$RoundToysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  $$RoundsTableOrderingComposer get roundId {
    final $$RoundsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roundId,
        referencedTable: $db.rounds,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundsTableOrderingComposer(
              $db: $db,
              $table: $db.rounds,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ToysTableOrderingComposer get toyId {
    final $$ToysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableOrderingComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToysTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundToysTable> {
  $$RoundToysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$RoundsTableAnnotationComposer get roundId {
    final $$RoundsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.roundId,
        referencedTable: $db.rounds,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RoundsTableAnnotationComposer(
              $db: $db,
              $table: $db.rounds,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ToysTableAnnotationComposer get toyId {
    final $$ToysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableAnnotationComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundToysTable,
    RoundToy,
    $$RoundToysTableFilterComposer,
    $$RoundToysTableOrderingComposer,
    $$RoundToysTableAnnotationComposer,
    $$RoundToysTableCreateCompanionBuilder,
    $$RoundToysTableUpdateCompanionBuilder,
    (RoundToy, $$RoundToysTableReferences),
    RoundToy,
    PrefetchHooks Function({bool roundId, bool toyId})> {
  $$RoundToysTableTableManager(_$AppDatabase db, $RoundToysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundToysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundToysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundToysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> roundId = const Value.absent(),
            Value<String> toyId = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundToysCompanion(
            roundId: roundId,
            toyId: toyId,
            position: position,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String roundId,
            required String toyId,
            required int position,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundToysCompanion.insert(
            roundId: roundId,
            toyId: toyId,
            position: position,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoundToysTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({roundId = false, toyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (roundId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.roundId,
                    referencedTable:
                        $$RoundToysTableReferences._roundIdTable(db),
                    referencedColumn:
                        $$RoundToysTableReferences._roundIdTable(db).id,
                  ) as T;
                }
                if (toyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toyId,
                    referencedTable: $$RoundToysTableReferences._toyIdTable(db),
                    referencedColumn:
                        $$RoundToysTableReferences._toyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoundToysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RoundToysTable,
    RoundToy,
    $$RoundToysTableFilterComposer,
    $$RoundToysTableOrderingComposer,
    $$RoundToysTableAnnotationComposer,
    $$RoundToysTableCreateCompanionBuilder,
    $$RoundToysTableUpdateCompanionBuilder,
    (RoundToy, $$RoundToysTableReferences),
    RoundToy,
    PrefetchHooks Function({bool roundId, bool toyId})>;
typedef $$RoundToyChecklistItemsTableCreateCompanionBuilder
    = RoundToyChecklistItemsCompanion Function({
  required String dateKey,
  required String toyId,
  Value<bool> collected,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$RoundToyChecklistItemsTableUpdateCompanionBuilder
    = RoundToyChecklistItemsCompanion Function({
  Value<String> dateKey,
  Value<String> toyId,
  Value<bool> collected,
  Value<int> updatedAt,
  Value<int> rowid,
});

final class $$RoundToyChecklistItemsTableReferences extends BaseReferences<
    _$AppDatabase, $RoundToyChecklistItemsTable, RoundToyChecklistItem> {
  $$RoundToyChecklistItemsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ToysTable _toyIdTable(_$AppDatabase db) => db.toys.createAlias(
      $_aliasNameGenerator(db.roundToyChecklistItems.toyId, db.toys.id));

  $$ToysTableProcessedTableManager get toyId {
    final $_column = $_itemColumn<String>('toy_id')!;

    final manager = $$ToysTableTableManager($_db, $_db.toys)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RoundToyChecklistItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RoundToyChecklistItemsTable> {
  $$RoundToyChecklistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
      column: $table.dateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get collected => $composableBuilder(
      column: $table.collected, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$ToysTableFilterComposer get toyId {
    final $$ToysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableFilterComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToyChecklistItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RoundToyChecklistItemsTable> {
  $$RoundToyChecklistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
      column: $table.dateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get collected => $composableBuilder(
      column: $table.collected, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$ToysTableOrderingComposer get toyId {
    final $$ToysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableOrderingComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToyChecklistItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoundToyChecklistItemsTable> {
  $$RoundToyChecklistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<bool> get collected =>
      $composableBuilder(column: $table.collected, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$ToysTableAnnotationComposer get toyId {
    final $$ToysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.toyId,
        referencedTable: $db.toys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ToysTableAnnotationComposer(
              $db: $db,
              $table: $db.toys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RoundToyChecklistItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RoundToyChecklistItemsTable,
    RoundToyChecklistItem,
    $$RoundToyChecklistItemsTableFilterComposer,
    $$RoundToyChecklistItemsTableOrderingComposer,
    $$RoundToyChecklistItemsTableAnnotationComposer,
    $$RoundToyChecklistItemsTableCreateCompanionBuilder,
    $$RoundToyChecklistItemsTableUpdateCompanionBuilder,
    (RoundToyChecklistItem, $$RoundToyChecklistItemsTableReferences),
    RoundToyChecklistItem,
    PrefetchHooks Function({bool toyId})> {
  $$RoundToyChecklistItemsTableTableManager(
      _$AppDatabase db, $RoundToyChecklistItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoundToyChecklistItemsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$RoundToyChecklistItemsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoundToyChecklistItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateKey = const Value.absent(),
            Value<String> toyId = const Value.absent(),
            Value<bool> collected = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundToyChecklistItemsCompanion(
            dateKey: dateKey,
            toyId: toyId,
            collected: collected,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateKey,
            required String toyId,
            Value<bool> collected = const Value.absent(),
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              RoundToyChecklistItemsCompanion.insert(
            dateKey: dateKey,
            toyId: toyId,
            collected: collected,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RoundToyChecklistItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({toyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (toyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.toyId,
                    referencedTable:
                        $$RoundToyChecklistItemsTableReferences._toyIdTable(db),
                    referencedColumn: $$RoundToyChecklistItemsTableReferences
                        ._toyIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RoundToyChecklistItemsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $RoundToyChecklistItemsTable,
        RoundToyChecklistItem,
        $$RoundToyChecklistItemsTableFilterComposer,
        $$RoundToyChecklistItemsTableOrderingComposer,
        $$RoundToyChecklistItemsTableAnnotationComposer,
        $$RoundToyChecklistItemsTableCreateCompanionBuilder,
        $$RoundToyChecklistItemsTableUpdateCompanionBuilder,
        (RoundToyChecklistItem, $$RoundToyChecklistItemsTableReferences),
        RoundToyChecklistItem,
        PrefetchHooks Function({bool toyId})>;
typedef $$HistoryEventsTableCreateCompanionBuilder = HistoryEventsCompanion
    Function({
  Value<int> id,
  required String eventType,
  required int createdAt,
  required String payload,
});
typedef $$HistoryEventsTableUpdateCompanionBuilder = HistoryEventsCompanion
    Function({
  Value<int> id,
  Value<String> eventType,
  Value<int> createdAt,
  Value<String> payload,
});

class $$HistoryEventsTableFilterComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));
}

class $$HistoryEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get eventType => $composableBuilder(
      column: $table.eventType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));
}

class $$HistoryEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HistoryEventsTable> {
  $$HistoryEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$HistoryEventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HistoryEventsTable,
    HistoryEvent,
    $$HistoryEventsTableFilterComposer,
    $$HistoryEventsTableOrderingComposer,
    $$HistoryEventsTableAnnotationComposer,
    $$HistoryEventsTableCreateCompanionBuilder,
    $$HistoryEventsTableUpdateCompanionBuilder,
    (
      HistoryEvent,
      BaseReferences<_$AppDatabase, $HistoryEventsTable, HistoryEvent>
    ),
    HistoryEvent,
    PrefetchHooks Function()> {
  $$HistoryEventsTableTableManager(_$AppDatabase db, $HistoryEventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HistoryEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HistoryEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HistoryEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> eventType = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<String> payload = const Value.absent(),
          }) =>
              HistoryEventsCompanion(
            id: id,
            eventType: eventType,
            createdAt: createdAt,
            payload: payload,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String eventType,
            required int createdAt,
            required String payload,
          }) =>
              HistoryEventsCompanion.insert(
            id: id,
            eventType: eventType,
            createdAt: createdAt,
            payload: payload,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HistoryEventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HistoryEventsTable,
    HistoryEvent,
    $$HistoryEventsTableFilterComposer,
    $$HistoryEventsTableOrderingComposer,
    $$HistoryEventsTableAnnotationComposer,
    $$HistoryEventsTableCreateCompanionBuilder,
    $$HistoryEventsTableUpdateCompanionBuilder,
    (
      HistoryEvent,
      BaseReferences<_$AppDatabase, $HistoryEventsTable, HistoryEvent>
    ),
    HistoryEvent,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BoxesTableTableManager get boxes =>
      $$BoxesTableTableManager(_db, _db.boxes);
  $$ToysTableTableManager get toys => $$ToysTableTableManager(_db, _db.toys);
  $$CategoryDefinitionsTableTableManager get categoryDefinitions =>
      $$CategoryDefinitionsTableTableManager(_db, _db.categoryDefinitions);
  $$CategoryCountersTableTableManager get categoryCounters =>
      $$CategoryCountersTableTableManager(_db, _db.categoryCounters);
  $$RoundCategorySettingsTableTableManager get roundCategorySettings =>
      $$RoundCategorySettingsTableTableManager(_db, _db.roundCategorySettings);
  $$RoundUiSettingsTableTableManager get roundUiSettings =>
      $$RoundUiSettingsTableTableManager(_db, _db.roundUiSettings);
  $$WeeklyPlanningSettingsTableTableManager get weeklyPlanningSettings =>
      $$WeeklyPlanningSettingsTableTableManager(
          _db, _db.weeklyPlanningSettings);
  $$WeeklyPlanningCategorySettingsTableTableManager
      get weeklyPlanningCategorySettings =>
          $$WeeklyPlanningCategorySettingsTableTableManager(
              _db, _db.weeklyPlanningCategorySettings);
  $$ToyAutoNameCountersTableTableManager get toyAutoNameCounters =>
      $$ToyAutoNameCountersTableTableManager(_db, _db.toyAutoNameCounters);
  $$LocationDefinitionsTableTableManager get locationDefinitions =>
      $$LocationDefinitionsTableTableManager(_db, _db.locationDefinitions);
  $$RoundsTableTableManager get rounds =>
      $$RoundsTableTableManager(_db, _db.rounds);
  $$RoundToysTableTableManager get roundToys =>
      $$RoundToysTableTableManager(_db, _db.roundToys);
  $$RoundToyChecklistItemsTableTableManager get roundToyChecklistItems =>
      $$RoundToyChecklistItemsTableTableManager(
          _db, _db.roundToyChecklistItems);
  $$HistoryEventsTableTableManager get historyEvents =>
      $$HistoryEventsTableTableManager(_db, _db.historyEvents);
}
