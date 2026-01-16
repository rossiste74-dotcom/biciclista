// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_snapshot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetHealthSnapshotCollection on Isar {
  IsarCollection<HealthSnapshot> get healthSnapshots => this.collection();
}

const HealthSnapshotSchema = CollectionSchema(
  name: r'HealthSnapshot',
  id: 6696792979165729457,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'dailyWeight': PropertySchema(
      id: 1,
      name: r'dailyWeight',
      type: IsarType.double,
    ),
    r'date': PropertySchema(
      id: 2,
      name: r'date',
      type: IsarType.dateTime,
    ),
    r'hrv': PropertySchema(
      id: 3,
      name: r'hrv',
      type: IsarType.long,
    ),
    r'sleepHours': PropertySchema(
      id: 4,
      name: r'sleepHours',
      type: IsarType.double,
    )
  },
  estimateSize: _healthSnapshotEstimateSize,
  serialize: _healthSnapshotSerialize,
  deserialize: _healthSnapshotDeserialize,
  deserializeProp: _healthSnapshotDeserializeProp,
  idName: r'id',
  indexes: {
    r'date': IndexSchema(
      id: -7552997827385218417,
      name: r'date',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'date',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _healthSnapshotGetId,
  getLinks: _healthSnapshotGetLinks,
  attach: _healthSnapshotAttach,
  version: '3.1.0+1',
);

int _healthSnapshotEstimateSize(
  HealthSnapshot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _healthSnapshotSerialize(
  HealthSnapshot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeDouble(offsets[1], object.dailyWeight);
  writer.writeDateTime(offsets[2], object.date);
  writer.writeLong(offsets[3], object.hrv);
  writer.writeDouble(offsets[4], object.sleepHours);
}

HealthSnapshot _healthSnapshotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = HealthSnapshot();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.dailyWeight = reader.readDouble(offsets[1]);
  object.date = reader.readDateTime(offsets[2]);
  object.hrv = reader.readLong(offsets[3]);
  object.id = id;
  object.sleepHours = reader.readDouble(offsets[4]);
  return object;
}

P _healthSnapshotDeserializeProp<P>(
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
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _healthSnapshotGetId(HealthSnapshot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _healthSnapshotGetLinks(HealthSnapshot object) {
  return [];
}

void _healthSnapshotAttach(
    IsarCollection<dynamic> col, Id id, HealthSnapshot object) {
  object.id = id;
}

extension HealthSnapshotQueryWhereSort
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QWhere> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhere> anyDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'date'),
      );
    });
  }
}

extension HealthSnapshotQueryWhere
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QWhereClause> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> idBetween(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> dateEqualTo(
      DateTime date) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'date',
        value: [date],
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause>
      dateNotEqualTo(DateTime date) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [date],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'date',
              lower: [],
              upper: [date],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause>
      dateGreaterThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [date],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> dateLessThan(
    DateTime date, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [],
        upper: [date],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterWhereClause> dateBetween(
    DateTime lowerDate,
    DateTime upperDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'date',
        lower: [lowerDate],
        includeLower: includeLower,
        upper: [upperDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension HealthSnapshotQueryFilter
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dailyWeightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dailyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dailyWeightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dailyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dailyWeightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dailyWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dailyWeightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dailyWeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'date',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'date',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      hrvEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hrv',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      hrvGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'hrv',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      hrvLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'hrv',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      hrvBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'hrv',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition> idBetween(
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

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      sleepHoursEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      sleepHoursGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      sleepHoursLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sleepHours',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterFilterCondition>
      sleepHoursBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sleepHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension HealthSnapshotQueryObject
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {}

extension HealthSnapshotQueryLinks
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QFilterCondition> {}

extension HealthSnapshotQuerySortBy
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QSortBy> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      sortByDailyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyWeight', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      sortByDailyWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyWeight', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByHrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrv', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> sortByHrvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrv', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      sortBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      sortBySleepHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.desc);
    });
  }
}

extension HealthSnapshotQuerySortThenBy
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QSortThenBy> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      thenByDailyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyWeight', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      thenByDailyWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dailyWeight', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByHrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrv', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByHrvDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hrv', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      thenBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.asc);
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QAfterSortBy>
      thenBySleepHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sleepHours', Sort.desc);
    });
  }
}

extension HealthSnapshotQueryWhereDistinct
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct> {
  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
      distinctByDailyWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dailyWeight');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct> distinctByHrv() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hrv');
    });
  }

  QueryBuilder<HealthSnapshot, HealthSnapshot, QDistinct>
      distinctBySleepHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sleepHours');
    });
  }
}

extension HealthSnapshotQueryProperty
    on QueryBuilder<HealthSnapshot, HealthSnapshot, QQueryProperty> {
  QueryBuilder<HealthSnapshot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<HealthSnapshot, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<HealthSnapshot, double, QQueryOperations> dailyWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dailyWeight');
    });
  }

  QueryBuilder<HealthSnapshot, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<HealthSnapshot, int, QQueryOperations> hrvProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hrv');
    });
  }

  QueryBuilder<HealthSnapshot, double, QQueryOperations> sleepHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sleepHours');
    });
  }
}
