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
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'distance': PropertySchema(
      id: 1,
      name: r'distance',
      type: IsarType.double,
    ),
    r'elevation': PropertySchema(
      id: 2,
      name: r'elevation',
      type: IsarType.double,
    ),
    r'forecastWeather': PropertySchema(
      id: 3,
      name: r'forecastWeather',
      type: IsarType.string,
    ),
    r'gpxFilePath': PropertySchema(
      id: 4,
      name: r'gpxFilePath',
      type: IsarType.string,
    ),
    r'isCompleted': PropertySchema(
      id: 5,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'latitude': PropertySchema(
      id: 6,
      name: r'latitude',
      type: IsarType.double,
    ),
    r'longitude': PropertySchema(
      id: 7,
      name: r'longitude',
      type: IsarType.double,
    ),
    r'notes': PropertySchema(
      id: 8,
      name: r'notes',
      type: IsarType.string,
    ),
    r'rideDate': PropertySchema(
      id: 9,
      name: r'rideDate',
      type: IsarType.dateTime,
    ),
    r'rideName': PropertySchema(
      id: 10,
      name: r'rideName',
      type: IsarType.string,
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
  links: {},
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
  return bytesCount;
}

void _plannedRideSerialize(
  PlannedRide object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDouble(offsets[1], object.distance);
  writer.writeDouble(offsets[2], object.elevation);
  writer.writeString(offsets[3], object.forecastWeather);
  writer.writeString(offsets[4], object.gpxFilePath);
  writer.writeBool(offsets[5], object.isCompleted);
  writer.writeDouble(offsets[6], object.latitude);
  writer.writeDouble(offsets[7], object.longitude);
  writer.writeString(offsets[8], object.notes);
  writer.writeDateTime(offsets[9], object.rideDate);
  writer.writeString(offsets[10], object.rideName);
}

PlannedRide _plannedRideDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PlannedRide();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.distance = reader.readDouble(offsets[1]);
  object.elevation = reader.readDouble(offsets[2]);
  object.forecastWeather = reader.readStringOrNull(offsets[3]);
  object.gpxFilePath = reader.readStringOrNull(offsets[4]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[5]);
  object.latitude = reader.readDoubleOrNull(offsets[6]);
  object.longitude = reader.readDoubleOrNull(offsets[7]);
  object.notes = reader.readStringOrNull(offsets[8]);
  object.rideDate = reader.readDateTime(offsets[9]);
  object.rideName = reader.readStringOrNull(offsets[10]);
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
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _plannedRideGetId(PlannedRide object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _plannedRideGetLinks(PlannedRide object) {
  return [];
}

void _plannedRideAttach(
    IsarCollection<dynamic> col, Id id, PlannedRide object) {
  object.id = id;
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
}

extension PlannedRideQueryObject
    on QueryBuilder<PlannedRide, PlannedRide, QFilterCondition> {}

extension PlannedRideQueryLinks
    on QueryBuilder<PlannedRide, PlannedRide, QFilterCondition> {}

extension PlannedRideQuerySortBy
    on QueryBuilder<PlannedRide, PlannedRide, QSortBy> {
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
}

extension PlannedRideQuerySortThenBy
    on QueryBuilder<PlannedRide, PlannedRide, QSortThenBy> {
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
}

extension PlannedRideQueryWhereDistinct
    on QueryBuilder<PlannedRide, PlannedRide, QDistinct> {
  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<PlannedRide, PlannedRide, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
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
}

extension PlannedRideQueryProperty
    on QueryBuilder<PlannedRide, PlannedRide, QQueryProperty> {
  QueryBuilder<PlannedRide, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PlannedRide, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<PlannedRide, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
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
}
