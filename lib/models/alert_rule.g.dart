// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_rule.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetAlertRuleCollection on Isar {
  IsarCollection<AlertRule> get alertRules => this.collection();
}

const AlertRuleSchema = CollectionSchema(
  name: r'AlertRule',
  id: 2173485486139534631,
  properties: {
    r'actionIndex': PropertySchema(
      id: 0,
      name: r'actionIndex',
      type: IsarType.long,
    ),
    r'defaultVoiceMessage': PropertySchema(
      id: 1,
      name: r'defaultVoiceMessage',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 2,
      name: r'description',
      type: IsarType.string,
    ),
    r'displayOrder': PropertySchema(
      id: 3,
      name: r'displayOrder',
      type: IsarType.long,
    ),
    r'effectiveVoiceMessage': PropertySchema(
      id: 4,
      name: r'effectiveVoiceMessage',
      type: IsarType.string,
    ),
    r'eventName': PropertySchema(
      id: 5,
      name: r'eventName',
      type: IsarType.string,
    ),
    r'eventTypeIndex': PropertySchema(
      id: 6,
      name: r'eventTypeIndex',
      type: IsarType.long,
    ),
    r'isEnabled': PropertySchema(
      id: 7,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'triggerValue': PropertySchema(
      id: 8,
      name: r'triggerValue',
      type: IsarType.double,
    ),
    r'voiceMessage': PropertySchema(
      id: 9,
      name: r'voiceMessage',
      type: IsarType.string,
    )
  },
  estimateSize: _alertRuleEstimateSize,
  serialize: _alertRuleSerialize,
  deserialize: _alertRuleDeserialize,
  deserializeProp: _alertRuleDeserializeProp,
  idName: r'id',
  indexes: {
    r'eventTypeIndex': IndexSchema(
      id: -7616421477009545983,
      name: r'eventTypeIndex',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'eventTypeIndex',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _alertRuleGetId,
  getLinks: _alertRuleGetLinks,
  attach: _alertRuleAttach,
  version: '3.1.0+1',
);

int _alertRuleEstimateSize(
  AlertRule object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.defaultVoiceMessage.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.effectiveVoiceMessage.length * 3;
  bytesCount += 3 + object.eventName.length * 3;
  {
    final value = object.voiceMessage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _alertRuleSerialize(
  AlertRule object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.actionIndex);
  writer.writeString(offsets[1], object.defaultVoiceMessage);
  writer.writeString(offsets[2], object.description);
  writer.writeLong(offsets[3], object.displayOrder);
  writer.writeString(offsets[4], object.effectiveVoiceMessage);
  writer.writeString(offsets[5], object.eventName);
  writer.writeLong(offsets[6], object.eventTypeIndex);
  writer.writeBool(offsets[7], object.isEnabled);
  writer.writeDouble(offsets[8], object.triggerValue);
  writer.writeString(offsets[9], object.voiceMessage);
}

AlertRule _alertRuleDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = AlertRule();
  object.actionIndex = reader.readLong(offsets[0]);
  object.displayOrder = reader.readLong(offsets[3]);
  object.eventTypeIndex = reader.readLong(offsets[6]);
  object.id = id;
  object.isEnabled = reader.readBool(offsets[7]);
  object.triggerValue = reader.readDoubleOrNull(offsets[8]);
  object.voiceMessage = reader.readStringOrNull(offsets[9]);
  return object;
}

P _alertRuleDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readLong(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _alertRuleGetId(AlertRule object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _alertRuleGetLinks(AlertRule object) {
  return [];
}

void _alertRuleAttach(IsarCollection<dynamic> col, Id id, AlertRule object) {
  object.id = id;
}

extension AlertRuleQueryWhereSort
    on QueryBuilder<AlertRule, AlertRule, QWhere> {
  QueryBuilder<AlertRule, AlertRule, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhere> anyEventTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'eventTypeIndex'),
      );
    });
  }
}

extension AlertRuleQueryWhere
    on QueryBuilder<AlertRule, AlertRule, QWhereClause> {
  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> idBetween(
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

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> eventTypeIndexEqualTo(
      int eventTypeIndex) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'eventTypeIndex',
        value: [eventTypeIndex],
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause>
      eventTypeIndexNotEqualTo(int eventTypeIndex) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventTypeIndex',
              lower: [],
              upper: [eventTypeIndex],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventTypeIndex',
              lower: [eventTypeIndex],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventTypeIndex',
              lower: [eventTypeIndex],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'eventTypeIndex',
              lower: [],
              upper: [eventTypeIndex],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause>
      eventTypeIndexGreaterThan(
    int eventTypeIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'eventTypeIndex',
        lower: [eventTypeIndex],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> eventTypeIndexLessThan(
    int eventTypeIndex, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'eventTypeIndex',
        lower: [],
        upper: [eventTypeIndex],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterWhereClause> eventTypeIndexBetween(
    int lowerEventTypeIndex,
    int upperEventTypeIndex, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'eventTypeIndex',
        lower: [lowerEventTypeIndex],
        includeLower: includeLower,
        upper: [upperEventTypeIndex],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension AlertRuleQueryFilter
    on QueryBuilder<AlertRule, AlertRule, QFilterCondition> {
  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> actionIndexEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'actionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      actionIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'actionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> actionIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'actionIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> actionIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'actionIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'defaultVoiceMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'defaultVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'defaultVoiceMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'defaultVoiceMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      defaultVoiceMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'defaultVoiceMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionEqualTo(
    String value, {
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionLessThan(
    String value, {
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionBetween(
    String lower,
    String upper, {
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      descriptionStartsWith(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionEndsWith(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionContains(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> descriptionMatches(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> displayOrderEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      displayOrderGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      displayOrderLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayOrder',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> displayOrderBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayOrder',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'effectiveVoiceMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'effectiveVoiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'effectiveVoiceMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'effectiveVoiceMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      effectiveVoiceMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'effectiveVoiceMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'eventName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'eventName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> eventNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventName',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'eventName',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventTypeIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'eventTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventTypeIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'eventTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventTypeIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'eventTypeIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      eventTypeIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'eventTypeIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> idBetween(
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

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> isEnabledEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      triggerValueIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'triggerValue',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      triggerValueIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'triggerValue',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> triggerValueEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'triggerValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      triggerValueGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'triggerValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      triggerValueLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'triggerValue',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> triggerValueBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'triggerValue',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'voiceMessage',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'voiceMessage',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> voiceMessageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> voiceMessageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voiceMessage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'voiceMessage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition> voiceMessageMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'voiceMessage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voiceMessage',
        value: '',
      ));
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterFilterCondition>
      voiceMessageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'voiceMessage',
        value: '',
      ));
    });
  }
}

extension AlertRuleQueryObject
    on QueryBuilder<AlertRule, AlertRule, QFilterCondition> {}

extension AlertRuleQueryLinks
    on QueryBuilder<AlertRule, AlertRule, QFilterCondition> {}

extension AlertRuleQuerySortBy on QueryBuilder<AlertRule, AlertRule, QSortBy> {
  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByActionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionIndex', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByActionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionIndex', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByDefaultVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultVoiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      sortByDefaultVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultVoiceMessage', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByDisplayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      sortByEffectiveVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveVoiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      sortByEffectiveVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveVoiceMessage', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByEventTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByEventTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByTriggerValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByTriggerValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> sortByVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceMessage', Sort.desc);
    });
  }
}

extension AlertRuleQuerySortThenBy
    on QueryBuilder<AlertRule, AlertRule, QSortThenBy> {
  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByActionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionIndex', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByActionIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'actionIndex', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByDefaultVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultVoiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      thenByDefaultVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'defaultVoiceMessage', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByDisplayOrderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayOrder', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      thenByEffectiveVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveVoiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy>
      thenByEffectiveVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'effectiveVoiceMessage', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByEventName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByEventNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventName', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByEventTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeIndex', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByEventTypeIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'eventTypeIndex', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByTriggerValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByTriggerValueDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'triggerValue', Sort.desc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByVoiceMessage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceMessage', Sort.asc);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QAfterSortBy> thenByVoiceMessageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voiceMessage', Sort.desc);
    });
  }
}

extension AlertRuleQueryWhereDistinct
    on QueryBuilder<AlertRule, AlertRule, QDistinct> {
  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByActionIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'actionIndex');
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByDefaultVoiceMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'defaultVoiceMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByDisplayOrder() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayOrder');
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByEffectiveVoiceMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'effectiveVoiceMessage',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByEventName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByEventTypeIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'eventTypeIndex');
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByTriggerValue() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'triggerValue');
    });
  }

  QueryBuilder<AlertRule, AlertRule, QDistinct> distinctByVoiceMessage(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voiceMessage', caseSensitive: caseSensitive);
    });
  }
}

extension AlertRuleQueryProperty
    on QueryBuilder<AlertRule, AlertRule, QQueryProperty> {
  QueryBuilder<AlertRule, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<AlertRule, int, QQueryOperations> actionIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'actionIndex');
    });
  }

  QueryBuilder<AlertRule, String, QQueryOperations>
      defaultVoiceMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'defaultVoiceMessage');
    });
  }

  QueryBuilder<AlertRule, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<AlertRule, int, QQueryOperations> displayOrderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayOrder');
    });
  }

  QueryBuilder<AlertRule, String, QQueryOperations>
      effectiveVoiceMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'effectiveVoiceMessage');
    });
  }

  QueryBuilder<AlertRule, String, QQueryOperations> eventNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventName');
    });
  }

  QueryBuilder<AlertRule, int, QQueryOperations> eventTypeIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'eventTypeIndex');
    });
  }

  QueryBuilder<AlertRule, bool, QQueryOperations> isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<AlertRule, double?, QQueryOperations> triggerValueProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'triggerValue');
    });
  }

  QueryBuilder<AlertRule, String?, QQueryOperations> voiceMessageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voiceMessage');
    });
  }
}
