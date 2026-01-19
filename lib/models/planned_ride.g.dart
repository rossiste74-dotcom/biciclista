// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_ride.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPlannedRideCollection on Isar {
  IsarCollection<PlannedRide> get plannedRides => this.collection();
}

const PlannedRideSchema = CollectionSchema(
  name: r'PlannedRide',
  id: 5531456562814518774,
  properties: {
    r'aiAnalysis': PropertySchema(
      id: 0,
      name: r'aiAnalysis',
      type: IsarType.string,
    ),
    r'avgCadence': PropertySchema(
      id: 1,
      name: r'avgCadence',
      type: IsarType.double,
    ),
    r'avgHeartRate': PropertySchema(
      id: 2,
      name: r'avgHeartRate',
      type: IsarType.double,
    ),
    r'avgPower': PropertySchema(
      id: 3,
      name: r'avgPower',
      type: IsarType.double,
    ),
    r'avgSpeed': PropertySchema(
      id: 4,
      name: r'avgSpeed',
      type: IsarType.double,
    ),
    r'bicycleId': PropertySchema(
      id: 5,
      name: r'bicycleId',
      type: IsarType.long,
    ),
    r'calories': PropertySchema(
      id: 6,
      name: r'calories',
      type: IsarType.long,
    ),
    r'createdAt': PropertySchema(
      id: 7,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'displayName': PropertySchema(
      id: 8,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'distance': PropertySchema(
      id: 9,
      name: r'distance',
      type: IsarType.double,
    ),
    r'effectiveDistance': PropertySchema(
      id: 10,
      name: r'effectiveDistance',
      type: IsarType.double,
    ),
    r'effectiveElevation': PropertySchema(
      id: 11,
      name: r'effectiveElevation',
      type: IsarType.double,
    ),
    r'effectiveGpxPath': PropertySchema(
      id: 12,
      name: r'effectiveGpxPath',
      type: IsarType.string,
    ),
    r'elevation': PropertySchema(
      id: 13,
      name: r'elevation',
      type: IsarType.double,
    ),
    r'forecastWeather': PropertySchema(
      id: 14,
      name: r'forecastWeather',
      type: IsarType.string,
    ),
    r'gpxFilePath': PropertySchema(
      id: 15,
      name: r'gpxFilePath',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 16,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'isGroupRide': PropertySchema(
      id: 17,
      name: r'isGroupRide',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 18,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 19,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'maxHeartRate': PropertySchema(
      id: 20,
      name: r'maxHeartRate',
      type: IsarType.double,
    ),
    r'maxPower': PropertySchema(
      id: 21,
      name: r'maxPower',
      type: IsarType.double,
    ),
    r'movingTime': PropertySchema(
      id: 22,
      name: r'movingTime',
      type: IsarType.long,
    ),
    r'notes': PropertySchema(
      id: 23,
      name: r'notes',
      type: IsarType.string,
    ),
    r'rideDate': PropertySchema(
      id: 24,
      name: r'rideDate',
      type: IsarType.dateTime,
    ),
    r'rideName': PropertySchema(
      id: 25,
      name: r'rideName',
      type: IsarType.string,
    ),
    r'supabaseEventId': PropertySchema(
      id: 26,
      name: r'supabaseEventId',
      type: IsarType.string,
    ),
    r'trackId': PropertySchema(
      id: 27,
      name: r'trackId',
      type: IsarType.long,
    )
  },
  estimateSize: _plannedRideEstimateSize,
  serialize: _plannedRideSerialize,
  deserialize: _plannedRideDeserialize,
  deserializeProp: _plannedRideDeserializeProp,
  idName: r'id',
  indexes: {
    r'rideDate': IndexSchema(
      id: 4856470415229834843,
      name: r'rideDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'rideDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isGroupRide': IndexSchema(
      id: -2935029703562824705,
      name: r'isGroupRide',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isGroupRide',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isCompleted': IndexSchema(
      id: -7936144632215868537,
      name: r'isCompleted',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isCompleted',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'track': LinkSchema(
      id: 6415461671034924028,
      name: r'track',
      target: r'Track',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _plannedRideGetId,
  getLinks: _plannedRideGetLinks,
  attach: _plannedRideAttach,
  version: '3.1.0+1',
);

int _plannedRideEstimateSize(
  PlannedRide object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiAnalysis;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.effectiveGpxPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.forecastWeather;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gpxFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.rideName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.supabaseEventId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _plannedRideSerialize(
  PlannedRide object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiAnalysis);
  writer.writeDouble(offsets[1], object.avgCadence);
  writer.writeDouble(offsets[2], object.avgHeartRate);
  writer.writeDouble(offsets[3], object.avgPower);
  writer.writeDouble(offsets[4], object.avgSpeed);
  writer.writeLong(offsets[5], object.bicycleId);
  writer.writeLong(offsets[6], object.calories);
  writer.writeDateTime(offsets[7], object.createdAt);
  writer.writeString(offsets[8], object.displayName);
  writer.writeDouble(offsets[9], object.distance);
  writer.writeDouble(offsets[10], object.effectiveDistance);
  writer.writeDouble(offsets[11], object.effectiveElevation);
  writer.writeString(offsets[12], object.effectiveGpxPath);
  writer.writeDouble(offsets[13], object.elevation);
  writer.writeString(offsets[14], object.forecastWeather);
  writer.writeString(offsets[15], object.gpxFilePath);
  writer.writeBool(offsets[16], object.isCompleted);
  writer.writeBool(offsets[17], object.isGroupRide);
  writer.writeDouble(offsets[18], object.latitude);
  writer.writeDouble(offsets[19], object.longitude);
  writer.writeDouble(offsets[20], object.maxHeartRate);
  writer.writeDouble(offsets[21], object.maxPower);
  writer.writeLong(offsets[22], object.movingTime);
  writer.writeString(offsets[23], object.notes);
  writer.writeDateTime(offsets[24], object.rideDate);
  writer.writeString(offsets[25], object.rideName);
  writer.writeString(offsets[26], object.supabaseEventId);
  writer.writeLong(offsets[27], object.trackId);
}

PlannedRide _plannedRideDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedRide();
  object.aiAnalysis = reader.readStringOrNull(offsets[0]);
  object.avgCadence = reader.readDoubleOrNull(offsets[1]);
  object.avgHeartRate = reader.readDoubleOrNull(offsets[2]);
  object.avgPower = reader.readDoubleOrNull(offsets[3]);
  object.avgSpeed = reader.readDoubleOrNull(offsets[4]);
  object.bicycleId = reader.readLongOrNull(offsets[5]);
  object.calories = reader.readLongOrNull(offsets[6]);
  object.createdAt = reader.readDateTime(offsets[7]);
  object.distance = reader.readDouble(offsets[9]);
  object.elevation = reader.readDouble(offsets[13]);
  object.forecastWeather = reader.readStringOrNull(offsets[14]);
  object.gpxFilePath = reader.readStringOrNull(offsets[15]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[16]);
  object.isGroupRide = reader.readBool(offsets[17]);
  object.latitude = reader.readDoubleOrNull(offsets[18]);
  object.longitude = reader.readDoubleOrNull(offsets[19]);
  object.maxHeartRate = reader.readDoubleOrNull(offsets[20]);
  object.maxPower = reader.readDoubleOrNull(offsets[21]);
  object.movingTime = reader.readLongOrNull(offsets[22]);
  object.notes = reader.readStringOrNull(offsets[23]);
  object.rideDate = reader.readDateTime(offsets[24]);
  object.rideName = reader.readStringOrNull(offsets[25]);
  object.supabaseEventId = reader.readStringOrNull(offsets[26]);
  object.trackId = reader.readLongOrNull(offsets[27]);
  return object;
}

P _plannedRideDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset)) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    case 13:
      return (reader.readDouble(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readBool(offset)) as P;
    case 17:
      return (reader.readBool(offset)) as P;
    case 18:
      return (reader.readDoubleOrNull(offset)) as P;
    case 19:
      return (reader.readDoubleOrNull(offset)) as P;
    case 20:
      return (reader.readDoubleOrNull(offset)) as P;
    case 21:
      return (reader.readDoubleOrNull(offset)) as P;
    case 22:
      return (reader.readLongOrNull(offset)) as P;
    case 23:
      return (reader.readStringOrNull(offset)) as P;
    case 24:
      return (reader.readDateTime(offset)) as P;
    case 25:
      return (reader.readStringOrNull(offset)) as P;
    case 26:
      return (reader.readStringOrNull(offset)) as P;
    case 27:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _plannedRideGetId(PlannedRide object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plannedRideGetLinks(PlannedRide object) {
  return [object.track];
}

void _plannedRideAttach(
    IsarCollection<dynamic> col, Id id, PlannedRide object) {
  object.id = id;
  object.track.attach(col, col.isar.collection<Track>(), r'track', id);
}

extension PlannedRideQueryWhereSort
    on QueryBuilder<PlannedRide, PlannedRide, QWhere> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhere> anyRideDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'rideDate'),
      );
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhere> anyIsGroupRide() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isGroupRide'),
      );
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhere> anyIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isCompleted'),
      );
    });
  }
}

extension PlannedRideQueryWhere
    on QueryBuilder<PlannedRide, PlannedRide, QWhereClause> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> rideDateEqualTo(
      DateTime rideDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'rideDate',
        value: [rideDate],
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> rideDateNotEqualTo(
      DateTime rideDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rideDate',
              lower: [],
              upper: [rideDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rideDate',
              lower: [rideDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rideDate',
              lower: [rideDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'rideDate',
              lower: [],
              upper: [rideDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> rideDateGreaterThan(
    DateTime rideDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'rideDate',
        lower: [rideDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> rideDateLessThan(
    DateTime rideDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'rideDate',
        lower: [],
        upper: [rideDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> rideDateBetween(
    DateTime lowerRideDate,
    DateTime upperRideDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'rideDate',
        lower: [lowerRideDate],
        includeLower: includeLower,
        upper: [upperRideDate],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> isGroupRideEqualTo(
      bool isGroupRide) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isGroupRide',
        value: [isGroupRide],
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause>
      isGroupRideNotEqualTo(bool isGroupRide) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGroupRide',
              lower: [],
              upper: [isGroupRide],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGroupRide',
              lower: [isGroupRide],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGroupRide',
              lower: [isGroupRide],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isGroupRide',
              lower: [],
              upper: [isGroupRide],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause> isCompletedEqualTo(
      bool isCompleted) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isCompleted',
        value: [isCompleted],
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterWhereClause>
      isCompletedNotEqualTo(bool isCompleted) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCompleted',
              lower: [],
              upper: [isCompleted],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCompleted',
              lower: [isCompleted],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCompleted',
              lower: [isCompleted],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isCompleted',
              lower: [],
              upper: [isCompleted],
              includeUpper: false,
            ));
      }
    });
  }
}

extension PlannedRideQueryFilter
    on QueryBuilder<PlannedRide, PlannedRide, QFilterCondition> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiAnalysis',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiAnalysis',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiAnalysis',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiAnalysis',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiAnalysis',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiAnalysis',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      aiAnalysisIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiAnalysis',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgCadence',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgCadence',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgCadence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgCadence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgCadence',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgCadenceBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgCadence',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgHeartRate',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgHeartRate',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgHeartRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgHeartRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgPowerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgPower',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgPowerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgPower',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> avgPowerEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgPowerGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgPowerLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> avgPowerBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgPower',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgSpeedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'avgSpeed',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgSpeedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'avgSpeed',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> avgSpeedEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgSpeedGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      avgSpeedLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgSpeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> avgSpeedBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgSpeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bicycleId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bicycleId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bicycleId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bicycleId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bicycleId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      bicycleIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bicycleId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      caloriesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'calories',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      caloriesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'calories',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> caloriesEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      caloriesGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      caloriesLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'calories',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> caloriesBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'calories',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> distanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      distanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      distanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'distance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> distanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'distance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveDistanceEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveDistanceGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveDistanceLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveDistance',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveDistanceBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveDistance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveElevationEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveElevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveElevationGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveElevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveElevationLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveElevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveElevationBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveElevation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'effectiveGpxPath',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'effectiveGpxPath',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveGpxPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'effectiveGpxPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'effectiveGpxPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveGpxPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      effectiveGpxPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'effectiveGpxPath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      elevationEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'elevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      elevationGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'elevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      elevationLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'elevation',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      elevationBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'elevation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'forecastWeather',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'forecastWeather',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'forecastWeather',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'forecastWeather',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'forecastWeather',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'forecastWeather',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      forecastWeatherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'forecastWeather',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gpxFilePath',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gpxFilePath',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gpxFilePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gpxFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpxFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      gpxFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gpxFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      isCompletedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      isGroupRideEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isGroupRide',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      latitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      latitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'latitude',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> latitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      latitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      latitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'latitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> latitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'latitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'longitude',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'longitude',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      longitudeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'longitude',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxHeartRate',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxHeartRate',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxHeartRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxHeartRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxHeartRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxPowerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'maxPower',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxPowerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'maxPower',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> maxPowerEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxPowerGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      maxPowerLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxPower',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> maxPowerBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxPower',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'movingTime',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'movingTime',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'movingTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      movingTimeBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'movingTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> rideDateEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rideDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rideDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rideDate',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> rideDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rideDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'rideName',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'rideName',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> rideNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> rideNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rideName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rideName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> rideNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rideName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rideName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      rideNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rideName',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseEventId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseEventId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supabaseEventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseEventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      supabaseEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      trackIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'trackId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      trackIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'trackId',
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> trackIdEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition>
      trackIdGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> trackIdLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackId',
        value: value,
      ));
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> trackIdBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PlannedRideQueryObject
    on QueryBuilder<PlannedRide, PlannedRide, QFilterCondition> {}

extension PlannedRideQueryLinks
    on QueryBuilder<PlannedRide, PlannedRide, QFilterCondition> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> track(
      FilterQuery<Track> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'track');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterFilterCondition> trackIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'track', 0, true, 0, true);
    });
  }
}

extension PlannedRideQuerySortBy
    on QueryBuilder<PlannedRide, PlannedRide, QSortBy> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgCadence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCadence', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgCadenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCadence', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByAvgHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgPower', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgPower', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgSpeed', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByAvgSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgSpeed', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByBicycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicycleId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByBicycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicycleId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDistance', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDistance', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveElevation', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveElevation', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveGpxPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveGpxPath', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByEffectiveGpxPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveGpxPath', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByForecastWeather() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forecastWeather', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByForecastWeatherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forecastWeather', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByGpxFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByGpxFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByIsGroupRide() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroupRide', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByIsGroupRideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroupRide', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortByMaxHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByMaxPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPower', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByMaxPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPower', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByRideDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideDate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByRideDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideDate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByRideName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideName', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByRideNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideName', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortBySupabaseEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseEventId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      sortBySupabaseEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseEventId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> sortByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension PlannedRideQuerySortThenBy
    on QueryBuilder<PlannedRide, PlannedRide, QSortThenBy> {
  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAiAnalysis() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAiAnalysisDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiAnalysis', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgCadence() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCadence', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgCadenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgCadence', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByAvgHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgPower', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgPower', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgSpeed', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByAvgSpeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgSpeed', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByBicycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicycleId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByBicycleIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bicycleId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByCaloriesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'calories', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDistance', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveDistance', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveElevation', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveElevation', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveGpxPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveGpxPath', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByEffectiveGpxPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveGpxPath', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByForecastWeather() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forecastWeather', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByForecastWeatherDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'forecastWeather', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByGpxFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByGpxFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByIsGroupRide() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroupRide', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByIsGroupRideDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isGroupRide', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByLatitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'latitude', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByLongitudeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'longitude', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenByMaxHeartRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxHeartRate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByMaxPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPower', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByMaxPowerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxPower', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByMovingTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'movingTime', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByRideDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideDate', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByRideDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideDate', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByRideName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideName', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByRideNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rideName', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenBySupabaseEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseEventId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy>
      thenBySupabaseEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseEventId', Sort.desc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.asc);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QAfterSortBy> thenByTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'trackId', Sort.desc);
    });
  }
}

extension PlannedRideQueryWhereDistinct
    on QueryBuilder<PlannedRide, PlannedRide, QDistinct> {
  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByAiAnalysis(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiAnalysis', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByAvgCadence() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgCadence');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByAvgHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgHeartRate');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByAvgPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgPower');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByAvgSpeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgSpeed');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByBicycleId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bicycleId');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByCalories() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'calories');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct>
      distinctByEffectiveDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveDistance');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct>
      distinctByEffectiveElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveElevation');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByEffectiveGpxPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveGpxPath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elevation');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByForecastWeather(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'forecastWeather',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByGpxFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gpxFilePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByIsGroupRide() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isGroupRide');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByLatitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'latitude');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByLongitude() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'longitude');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByMaxHeartRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxHeartRate');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByMaxPower() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxPower');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByMovingTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'movingTime');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByRideDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rideDate');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByRideName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rideName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctBySupabaseEventId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseEventId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackId');
    });
  }
}

extension PlannedRideQueryProperty
    on QueryBuilder<PlannedRide, PlannedRide, QQueryProperty> {
  QueryBuilder<PlannedRide, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations> aiAnalysisProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiAnalysis');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> avgCadenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgCadence');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> avgHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgHeartRate');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> avgPowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgPower');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> avgSpeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgSpeed');
    });
  }

  QueryBuilder<PlannedRide, int?, QQueryOperations> bicycleIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bicycleId');
    });
  }

  QueryBuilder<PlannedRide, int?, QQueryOperations> caloriesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'calories');
    });
  }

  QueryBuilder<PlannedRide, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PlannedRide, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<PlannedRide, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<PlannedRide, double, QQueryOperations>
      effectiveDistanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveDistance');
    });
  }

  QueryBuilder<PlannedRide, double, QQueryOperations>
      effectiveElevationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveElevation');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations>
      effectiveGpxPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveGpxPath');
    });
  }

  QueryBuilder<PlannedRide, double, QQueryOperations> elevationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elevation');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations>
      forecastWeatherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'forecastWeather');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations> gpxFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gpxFilePath');
    });
  }

  QueryBuilder<PlannedRide, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<PlannedRide, bool, QQueryOperations> isGroupRideProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isGroupRide');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> latitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'latitude');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> longitudeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'longitude');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> maxHeartRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxHeartRate');
    });
  }

  QueryBuilder<PlannedRide, double?, QQueryOperations> maxPowerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxPower');
    });
  }

  QueryBuilder<PlannedRide, int?, QQueryOperations> movingTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'movingTime');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<PlannedRide, DateTime, QQueryOperations> rideDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rideDate');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations> rideNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rideName');
    });
  }

  QueryBuilder<PlannedRide, String?, QQueryOperations>
      supabaseEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseEventId');
    });
  }

  QueryBuilder<PlannedRide, int?, QQueryOperations> trackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackId');
    });
  }
}
