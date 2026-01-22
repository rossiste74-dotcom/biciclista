// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTrackCollection on Isar {
  IsarCollection<Track> get tracks => this.collection();
}

const TrackSchema = CollectionSchema(
  name: r'Track',
  id: 6244076704169336260,
  properties: {
    r'asphaltPercent': PropertySchema(
      id: 0,
      name: r'asphaltPercent',
      type: IsarType.double,
    ),
    r'communityTrackId': PropertySchema(
      id: 1,
      name: r'communityTrackId',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'description': PropertySchema(
      id: 3,
      name: r'description',
      type: IsarType.string,
    ),
    r'difficultyLevel': PropertySchema(
      id: 4,
      name: r'difficultyLevel',
      type: IsarType.long,
    ),
    r'displayName': PropertySchema(
      id: 5,
      name: r'displayName',
      type: IsarType.string,
    ),
    r'distance': PropertySchema(
      id: 6,
      name: r'distance',
      type: IsarType.double,
    ),
    r'duration': PropertySchema(
      id: 7,
      name: r'duration',
      type: IsarType.long,
    ),
    r'elevation': PropertySchema(
      id: 8,
      name: r'elevation',
      type: IsarType.double,
    ),
    r'gpxFilePath': PropertySchema(
      id: 9,
      name: r'gpxFilePath',
      type: IsarType.string,
    ),
    r'gpxUrl': PropertySchema(
      id: 10,
      name: r'gpxUrl',
      type: IsarType.string,
    ),
    r'gravelPercent': PropertySchema(
      id: 11,
      name: r'gravelPercent',
      type: IsarType.double,
    ),
    r'lastSyncedAt': PropertySchema(
      id: 12,
      name: r'lastSyncedAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 13,
      name: r'name',
      type: IsarType.string,
    ),
    r'pathPercent': PropertySchema(
      id: 14,
      name: r'pathPercent',
      type: IsarType.double,
    ),
    r'region': PropertySchema(
      id: 15,
      name: r'region',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 16,
      name: r'source',
      type: IsarType.string,
    ),
    r'supabaseId': PropertySchema(
      id: 17,
      name: r'supabaseId',
      type: IsarType.string,
    ),
    r'terrainIcon': PropertySchema(
      id: 18,
      name: r'terrainIcon',
      type: IsarType.string,
    ),
    r'terrainLabel': PropertySchema(
      id: 19,
      name: r'terrainLabel',
      type: IsarType.string,
    ),
    r'terrainType': PropertySchema(
      id: 20,
      name: r'terrainType',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 21,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _trackEstimateSize,
  serialize: _trackSerialize,
  deserialize: _trackDeserialize,
  deserializeProp: _trackDeserializeProp,
  idName: r'id',
  indexes: {
    r'terrainType': IndexSchema(
      id: -7586036175502631394,
      name: r'terrainType',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'terrainType',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'supabaseId': IndexSchema(
      id: 2753382765909358918,
      name: r'supabaseId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'supabaseId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _trackGetId,
  getLinks: _trackGetLinks,
  attach: _trackAttach,
  version: '3.1.0+1',
);

int _trackEstimateSize(
  Track object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.communityTrackId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.displayName.length * 3;
  {
    final value = object.gpxFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gpxUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  {
    final value = object.region;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  {
    final value = object.supabaseId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.terrainIcon.length * 3;
  bytesCount += 3 + object.terrainLabel.length * 3;
  bytesCount += 3 + object.terrainType.length * 3;
  return bytesCount;
}

void _trackSerialize(
  Track object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.asphaltPercent);
  writer.writeString(offsets[1], object.communityTrackId);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.description);
  writer.writeLong(offsets[4], object.difficultyLevel);
  writer.writeString(offsets[5], object.displayName);
  writer.writeDouble(offsets[6], object.distance);
  writer.writeLong(offsets[7], object.duration);
  writer.writeDouble(offsets[8], object.elevation);
  writer.writeString(offsets[9], object.gpxFilePath);
  writer.writeString(offsets[10], object.gpxUrl);
  writer.writeDouble(offsets[11], object.gravelPercent);
  writer.writeDateTime(offsets[12], object.lastSyncedAt);
  writer.writeString(offsets[13], object.name);
  writer.writeDouble(offsets[14], object.pathPercent);
  writer.writeString(offsets[15], object.region);
  writer.writeString(offsets[16], object.source);
  writer.writeString(offsets[17], object.supabaseId);
  writer.writeString(offsets[18], object.terrainIcon);
  writer.writeString(offsets[19], object.terrainLabel);
  writer.writeString(offsets[20], object.terrainType);
  writer.writeDateTime(offsets[21], object.updatedAt);
}

Track _trackDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Track();
  object.asphaltPercent = reader.readDoubleOrNull(offsets[0]);
  object.communityTrackId = reader.readStringOrNull(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.description = reader.readStringOrNull(offsets[3]);
  object.difficultyLevel = reader.readLongOrNull(offsets[4]);
  object.distance = reader.readDouble(offsets[6]);
  object.duration = reader.readLongOrNull(offsets[7]);
  object.elevation = reader.readDouble(offsets[8]);
  object.gpxFilePath = reader.readStringOrNull(offsets[9]);
  object.gpxUrl = reader.readStringOrNull(offsets[10]);
  object.gravelPercent = reader.readDoubleOrNull(offsets[11]);
  object.id = id;
  object.lastSyncedAt = reader.readDateTimeOrNull(offsets[12]);
  object.name = reader.readString(offsets[13]);
  object.pathPercent = reader.readDoubleOrNull(offsets[14]);
  object.region = reader.readStringOrNull(offsets[15]);
  object.source = reader.readString(offsets[16]);
  object.supabaseId = reader.readStringOrNull(offsets[17]);
  object.terrainType = reader.readString(offsets[20]);
  object.updatedAt = reader.readDateTime(offsets[21]);
  return object;
}

P _trackDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLongOrNull(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLongOrNull(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readDoubleOrNull(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDoubleOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readString(offset)) as P;
    case 17:
      return (reader.readStringOrNull(offset)) as P;
    case 18:
      return (reader.readString(offset)) as P;
    case 19:
      return (reader.readString(offset)) as P;
    case 20:
      return (reader.readString(offset)) as P;
    case 21:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _trackGetId(Track object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _trackGetLinks(Track object) {
  return [];
}

void _trackAttach(IsarCollection<dynamic> col, Id id, Track object) {
  object.id = id;
}

extension TrackQueryWhereSort on QueryBuilder<Track, Track, QWhere> {
  QueryBuilder<Track, Track, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TrackQueryWhere on QueryBuilder<Track, Track, QWhereClause> {
  QueryBuilder<Track, Track, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Track, Track, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> idBetween(
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

  QueryBuilder<Track, Track, QAfterWhereClause> terrainTypeEqualTo(
      String terrainType) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'terrainType',
        value: [terrainType],
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> terrainTypeNotEqualTo(
      String terrainType) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'terrainType',
              lower: [],
              upper: [terrainType],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'terrainType',
              lower: [terrainType],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'terrainType',
              lower: [terrainType],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'terrainType',
              lower: [],
              upper: [terrainType],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [null],
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'supabaseId',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> supabaseIdEqualTo(
      String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'supabaseId',
        value: [supabaseId],
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterWhereClause> supabaseIdNotEqualTo(
      String? supabaseId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [supabaseId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'supabaseId',
              lower: [],
              upper: [supabaseId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension TrackQueryFilter on QueryBuilder<Track, Track, QFilterCondition> {
  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'asphaltPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'asphaltPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'asphaltPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'asphaltPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'asphaltPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> asphaltPercentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'asphaltPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'communityTrackId',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition>
      communityTrackIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'communityTrackId',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'communityTrackId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'communityTrackId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'communityTrackId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> communityTrackIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'communityTrackId',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition>
      communityTrackIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'communityTrackId',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> createdAtGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'difficultyLevel',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'difficultyLevel',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'difficultyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'difficultyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'difficultyLevel',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> difficultyLevelBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'difficultyLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameEqualTo(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameStartsWith(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameEndsWith(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> displayNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayName',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> distanceEqualTo(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> distanceGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> distanceLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> distanceBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> durationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> durationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'duration',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> durationEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> durationGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> durationLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> durationBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> elevationEqualTo(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> elevationGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> elevationLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> elevationBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gpxFilePath',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gpxFilePath',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathEqualTo(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathStartsWith(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathEndsWith(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gpxFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gpxFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpxFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gpxFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gpxUrl',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gpxUrl',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gpxUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gpxUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gpxUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gpxUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gpxUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gpxUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gravelPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gravelPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gravelPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gravelPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gravelPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> gravelPercentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gravelPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncedAt',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> lastSyncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pathPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pathPercent',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pathPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pathPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pathPercent',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> pathPercentBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pathPercent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'region',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'region',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'region',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'region',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'region',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> regionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'region',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'supabaseId',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'supabaseId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'supabaseId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'supabaseId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> supabaseIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'supabaseId',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'terrainIcon',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'terrainIcon',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'terrainIcon',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainIcon',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainIconIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'terrainIcon',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'terrainLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'terrainLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'terrainLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'terrainLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'terrainType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'terrainType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'terrainType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'terrainType',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> terrainTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'terrainType',
        value: '',
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Track, Track, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension TrackQueryObject on QueryBuilder<Track, Track, QFilterCondition> {}

extension TrackQueryLinks on QueryBuilder<Track, Track, QFilterCondition> {}

extension TrackQuerySortBy on QueryBuilder<Track, Track, QSortBy> {
  QueryBuilder<Track, Track, QAfterSortBy> sortByAsphaltPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asphaltPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByAsphaltPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asphaltPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByCommunityTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'communityTrackId', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByCommunityTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'communityTrackId', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDifficultyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyLevel', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDifficultyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyLevel', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGpxFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGpxFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGpxUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxUrl', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGpxUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxUrl', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGravelPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gravelPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByGravelPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gravelPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByPathPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByPathPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainIcon', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainIcon', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainLabel', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainLabel', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByTerrainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TrackQuerySortThenBy on QueryBuilder<Track, Track, QSortThenBy> {
  QueryBuilder<Track, Track, QAfterSortBy> thenByAsphaltPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asphaltPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByAsphaltPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'asphaltPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByCommunityTrackId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'communityTrackId', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByCommunityTrackIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'communityTrackId', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDifficultyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyLevel', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDifficultyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'difficultyLevel', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDisplayName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDisplayNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayName', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDistanceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'distance', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByElevationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'elevation', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGpxFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGpxFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxFilePath', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGpxUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxUrl', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGpxUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gpxUrl', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGravelPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gravelPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByGravelPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gravelPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByLastSyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncedAt', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByPathPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathPercent', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByPathPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pathPercent', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByRegion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByRegionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'region', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenBySupabaseId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenBySupabaseIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'supabaseId', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainIcon() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainIcon', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainIconDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainIcon', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainLabel', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainLabel', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByTerrainTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'terrainType', Sort.desc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Track, Track, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension TrackQueryWhereDistinct on QueryBuilder<Track, Track, QDistinct> {
  QueryBuilder<Track, Track, QDistinct> distinctByAsphaltPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'asphaltPercent');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByCommunityTrackId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'communityTrackId',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByDifficultyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'difficultyLevel');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByDisplayName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByDistance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'distance');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByElevation() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'elevation');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByGpxFilePath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gpxFilePath', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByGpxUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gpxUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByGravelPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gravelPercent');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByLastSyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncedAt');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByPathPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pathPercent');
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByRegion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'region', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctBySupabaseId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'supabaseId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByTerrainIcon(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'terrainIcon', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByTerrainLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'terrainLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByTerrainType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'terrainType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Track, Track, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension TrackQueryProperty on QueryBuilder<Track, Track, QQueryProperty> {
  QueryBuilder<Track, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Track, double?, QQueryOperations> asphaltPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'asphaltPercent');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> communityTrackIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'communityTrackId');
    });
  }

  QueryBuilder<Track, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Track, int?, QQueryOperations> difficultyLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'difficultyLevel');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> displayNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayName');
    });
  }

  QueryBuilder<Track, double, QQueryOperations> distanceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'distance');
    });
  }

  QueryBuilder<Track, int?, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<Track, double, QQueryOperations> elevationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'elevation');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> gpxFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gpxFilePath');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> gpxUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gpxUrl');
    });
  }

  QueryBuilder<Track, double?, QQueryOperations> gravelPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gravelPercent');
    });
  }

  QueryBuilder<Track, DateTime?, QQueryOperations> lastSyncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncedAt');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Track, double?, QQueryOperations> pathPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pathPercent');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> regionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'region');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<Track, String?, QQueryOperations> supabaseIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'supabaseId');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> terrainIconProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'terrainIcon');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> terrainLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'terrainLabel');
    });
  }

  QueryBuilder<Track, String, QQueryOperations> terrainTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'terrainType');
    });
  }

  QueryBuilder<Track, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
