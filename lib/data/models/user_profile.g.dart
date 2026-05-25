// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUserProfileCollection on Isar {
  IsarCollection<UserProfile> get userProfiles => this.collection();
}

const UserProfileSchema = CollectionSchema(
  name: r'UserProfile',
  id: 4738427352541298891,
  properties: {
    r'activityLevel': PropertySchema(
      id: 0,
      name: r'activityLevel',
      type: IsarType.string,
    ),
    r'aiProviders': PropertySchema(
      id: 1,
      name: r'aiProviders',
      type: IsarType.objectList,
      target: r'AIProvider',
    ),
    r'aiRoutingMode': PropertySchema(
      id: 2,
      name: r'aiRoutingMode',
      type: IsarType.string,
    ),
    r'breakfastTime': PropertySchema(
      id: 3,
      name: r'breakfastTime',
      type: IsarType.long,
    ),
    r'carbsGoal': PropertySchema(
      id: 4,
      name: r'carbsGoal',
      type: IsarType.double,
    ),
    r'carbsPercentage': PropertySchema(
      id: 5,
      name: r'carbsPercentage',
      type: IsarType.double,
    ),
    r'dietPreference': PropertySchema(
      id: 6,
      name: r'dietPreference',
      type: IsarType.string,
    ),
    r'dietType': PropertySchema(
      id: 7,
      name: r'dietType',
      type: IsarType.string,
    ),
    r'dinnerTime': PropertySchema(
      id: 8,
      name: r'dinnerTime',
      type: IsarType.long,
    ),
    r'dob': PropertySchema(
      id: 9,
      name: r'dob',
      type: IsarType.dateTime,
    ),
    r'fatGoal': PropertySchema(
      id: 10,
      name: r'fatGoal',
      type: IsarType.double,
    ),
    r'fatPercentage': PropertySchema(
      id: 11,
      name: r'fatPercentage',
      type: IsarType.double,
    ),
    r'fiberGoal': PropertySchema(
      id: 12,
      name: r'fiberGoal',
      type: IsarType.double,
    ),
    r'geminiApiKey': PropertySchema(
      id: 13,
      name: r'geminiApiKey',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 14,
      name: r'gender',
      type: IsarType.string,
    ),
    r'goalType': PropertySchema(
      id: 15,
      name: r'goalType',
      type: IsarType.string,
    ),
    r'height': PropertySchema(
      id: 16,
      name: r'height',
      type: IsarType.double,
    ),
    r'isMetric': PropertySchema(
      id: 17,
      name: r'isMetric',
      type: IsarType.bool,
    ),
    r'lunchTime': PropertySchema(
      id: 18,
      name: r'lunchTime',
      type: IsarType.long,
    ),
    r'maxRollover': PropertySchema(
      id: 19,
      name: r'maxRollover',
      type: IsarType.long,
    ),
    r'notificationsEnabled': PropertySchema(
      id: 20,
      name: r'notificationsEnabled',
      type: IsarType.bool,
    ),
    r'proteinGoal': PropertySchema(
      id: 21,
      name: r'proteinGoal',
      type: IsarType.double,
    ),
    r'proteinPercentage': PropertySchema(
      id: 22,
      name: r'proteinPercentage',
      type: IsarType.double,
    ),
    r'rolloverEnabled': PropertySchema(
      id: 23,
      name: r'rolloverEnabled',
      type: IsarType.bool,
    ),
    r'sodiumGoal': PropertySchema(
      id: 24,
      name: r'sodiumGoal',
      type: IsarType.double,
    ),
    r'successTolerance': PropertySchema(
      id: 25,
      name: r'successTolerance',
      type: IsarType.long,
    ),
    r'sugarGoal': PropertySchema(
      id: 26,
      name: r'sugarGoal',
      type: IsarType.double,
    ),
    r'targetWeight': PropertySchema(
      id: 27,
      name: r'targetWeight',
      type: IsarType.double,
    ),
    r'tdeeGoal': PropertySchema(
      id: 28,
      name: r'tdeeGoal',
      type: IsarType.long,
    ),
    r'themeMode': PropertySchema(
      id: 29,
      name: r'themeMode',
      type: IsarType.string,
    ),
    r'utcOffset': PropertySchema(
      id: 30,
      name: r'utcOffset',
      type: IsarType.long,
    ),
    r'weeklyGoals': PropertySchema(
      id: 31,
      name: r'weeklyGoals',
      type: IsarType.objectList,
      target: r'MacroGoal',
    ),
    r'weight': PropertySchema(
      id: 32,
      name: r'weight',
      type: IsarType.double,
    ),
    r'weightLossRate': PropertySchema(
      id: 33,
      name: r'weightLossRate',
      type: IsarType.double,
    )
  },
  estimateSize: _userProfileEstimateSize,
  serialize: _userProfileSerialize,
  deserialize: _userProfileDeserialize,
  deserializeProp: _userProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {
    r'AIProvider': AIProviderSchema,
    r'MacroGoal': MacroGoalSchema
  },
  getId: _userProfileGetId,
  getLinks: _userProfileGetLinks,
  attach: _userProfileAttach,
  version: '3.1.0+1',
);

int _userProfileEstimateSize(
  UserProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.activityLevel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.aiProviders;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[AIProvider]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              AIProviderSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  {
    final value = object.aiRoutingMode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dietPreference;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dietType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.geminiApiKey;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.goalType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.themeMode.length * 3;
  {
    final list = object.weeklyGoals;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        final offsets = allOffsets[MacroGoal]!;
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount +=
              MacroGoalSchema.estimateSize(value, offsets, allOffsets);
        }
      }
    }
  }
  return bytesCount;
}

void _userProfileSerialize(
  UserProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.activityLevel);
  writer.writeObjectList<AIProvider>(
    offsets[1],
    allOffsets,
    AIProviderSchema.serialize,
    object.aiProviders,
  );
  writer.writeString(offsets[2], object.aiRoutingMode);
  writer.writeLong(offsets[3], object.breakfastTime);
  writer.writeDouble(offsets[4], object.carbsGoal);
  writer.writeDouble(offsets[5], object.carbsPercentage);
  writer.writeString(offsets[6], object.dietPreference);
  writer.writeString(offsets[7], object.dietType);
  writer.writeLong(offsets[8], object.dinnerTime);
  writer.writeDateTime(offsets[9], object.dob);
  writer.writeDouble(offsets[10], object.fatGoal);
  writer.writeDouble(offsets[11], object.fatPercentage);
  writer.writeDouble(offsets[12], object.fiberGoal);
  writer.writeString(offsets[13], object.geminiApiKey);
  writer.writeString(offsets[14], object.gender);
  writer.writeString(offsets[15], object.goalType);
  writer.writeDouble(offsets[16], object.height);
  writer.writeBool(offsets[17], object.isMetric);
  writer.writeLong(offsets[18], object.lunchTime);
  writer.writeLong(offsets[19], object.maxRollover);
  writer.writeBool(offsets[20], object.notificationsEnabled);
  writer.writeDouble(offsets[21], object.proteinGoal);
  writer.writeDouble(offsets[22], object.proteinPercentage);
  writer.writeBool(offsets[23], object.rolloverEnabled);
  writer.writeDouble(offsets[24], object.sodiumGoal);
  writer.writeLong(offsets[25], object.successTolerance);
  writer.writeDouble(offsets[26], object.sugarGoal);
  writer.writeDouble(offsets[27], object.targetWeight);
  writer.writeLong(offsets[28], object.tdeeGoal);
  writer.writeString(offsets[29], object.themeMode);
  writer.writeLong(offsets[30], object.utcOffset);
  writer.writeObjectList<MacroGoal>(
    offsets[31],
    allOffsets,
    MacroGoalSchema.serialize,
    object.weeklyGoals,
  );
  writer.writeDouble(offsets[32], object.weight);
  writer.writeDouble(offsets[33], object.weightLossRate);
}

UserProfile _userProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UserProfile();
  object.activityLevel = reader.readStringOrNull(offsets[0]);
  object.aiProviders = reader.readObjectList<AIProvider>(
    offsets[1],
    AIProviderSchema.deserialize,
    allOffsets,
    AIProvider(),
  );
  object.aiRoutingMode = reader.readStringOrNull(offsets[2]);
  object.breakfastTime = reader.readLong(offsets[3]);
  object.carbsGoal = reader.readDoubleOrNull(offsets[4]);
  object.carbsPercentage = reader.readDouble(offsets[5]);
  object.dietPreference = reader.readStringOrNull(offsets[6]);
  object.dietType = reader.readStringOrNull(offsets[7]);
  object.dinnerTime = reader.readLong(offsets[8]);
  object.dob = reader.readDateTimeOrNull(offsets[9]);
  object.fatGoal = reader.readDoubleOrNull(offsets[10]);
  object.fatPercentage = reader.readDouble(offsets[11]);
  object.fiberGoal = reader.readDoubleOrNull(offsets[12]);
  object.geminiApiKey = reader.readStringOrNull(offsets[13]);
  object.gender = reader.readStringOrNull(offsets[14]);
  object.goalType = reader.readStringOrNull(offsets[15]);
  object.height = reader.readDoubleOrNull(offsets[16]);
  object.id = id;
  object.isMetric = reader.readBoolOrNull(offsets[17]);
  object.lunchTime = reader.readLong(offsets[18]);
  object.maxRollover = reader.readLong(offsets[19]);
  object.notificationsEnabled = reader.readBool(offsets[20]);
  object.proteinGoal = reader.readDoubleOrNull(offsets[21]);
  object.proteinPercentage = reader.readDouble(offsets[22]);
  object.rolloverEnabled = reader.readBool(offsets[23]);
  object.sodiumGoal = reader.readDoubleOrNull(offsets[24]);
  object.successTolerance = reader.readLong(offsets[25]);
  object.sugarGoal = reader.readDoubleOrNull(offsets[26]);
  object.targetWeight = reader.readDoubleOrNull(offsets[27]);
  object.tdeeGoal = reader.readLongOrNull(offsets[28]);
  object.themeMode = reader.readString(offsets[29]);
  object.utcOffset = reader.readLong(offsets[30]);
  object.weeklyGoals = reader.readObjectList<MacroGoal>(
    offsets[31],
    MacroGoalSchema.deserialize,
    allOffsets,
    MacroGoal(),
  );
  object.weight = reader.readDoubleOrNull(offsets[32]);
  object.weightLossRate = reader.readDoubleOrNull(offsets[33]);
  return object;
}

P _userProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readObjectList<AIProvider>(
        offset,
        AIProviderSchema.deserialize,
        allOffsets,
        AIProvider(),
      )) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 10:
      return (reader.readDoubleOrNull(offset)) as P;
    case 11:
      return (reader.readDouble(offset)) as P;
    case 12:
      return (reader.readDoubleOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    case 16:
      return (reader.readDoubleOrNull(offset)) as P;
    case 17:
      return (reader.readBoolOrNull(offset)) as P;
    case 18:
      return (reader.readLong(offset)) as P;
    case 19:
      return (reader.readLong(offset)) as P;
    case 20:
      return (reader.readBool(offset)) as P;
    case 21:
      return (reader.readDoubleOrNull(offset)) as P;
    case 22:
      return (reader.readDouble(offset)) as P;
    case 23:
      return (reader.readBool(offset)) as P;
    case 24:
      return (reader.readDoubleOrNull(offset)) as P;
    case 25:
      return (reader.readLong(offset)) as P;
    case 26:
      return (reader.readDoubleOrNull(offset)) as P;
    case 27:
      return (reader.readDoubleOrNull(offset)) as P;
    case 28:
      return (reader.readLongOrNull(offset)) as P;
    case 29:
      return (reader.readString(offset)) as P;
    case 30:
      return (reader.readLong(offset)) as P;
    case 31:
      return (reader.readObjectList<MacroGoal>(
        offset,
        MacroGoalSchema.deserialize,
        allOffsets,
        MacroGoal(),
      )) as P;
    case 32:
      return (reader.readDoubleOrNull(offset)) as P;
    case 33:
      return (reader.readDoubleOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _userProfileGetId(UserProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _userProfileGetLinks(UserProfile object) {
  return [];
}

void _userProfileAttach(
    IsarCollection<dynamic> col, Id id, UserProfile object) {
  object.id = id;
}

extension UserProfileQueryWhereSort
    on QueryBuilder<UserProfile, UserProfile, QWhere> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension UserProfileQueryWhere
    on QueryBuilder<UserProfile, UserProfile, QWhereClause> {
  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterWhereClause> idBetween(
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
}

extension UserProfileQueryFilter
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {
  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'activityLevel',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'activityLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'activityLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'activityLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      activityLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'activityLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiProviders',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiProviders',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aiProviders',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiRoutingMode',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiRoutingMode',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiRoutingMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiRoutingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiRoutingMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiRoutingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiRoutingModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiRoutingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      breakfastTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakfastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      breakfastTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakfastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      breakfastTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakfastTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      breakfastTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakfastTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'carbsGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'carbsGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'carbsPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'carbsPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'carbsPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      carbsPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'carbsPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dietPreference',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dietPreference',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietPreference',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dietPreference',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dietPreference',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietPreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietPreferenceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dietPreference',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dietType',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dietType',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dietTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dietTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dietType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dietType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dietTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dietType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dietType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dietTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dietType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dinnerTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dinnerTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dinnerTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dinnerTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dinnerTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dinnerTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      dinnerTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dinnerTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dob',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dob',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dob',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> dobBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dob',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fatGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fatGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> fatGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fatPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fatPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fatPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiberGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiberGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fiberGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fiberGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fiberGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      fiberGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fiberGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'geminiApiKey',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'geminiApiKey',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'geminiApiKey',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'geminiApiKey',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'geminiApiKey',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'geminiApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      geminiApiKeyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'geminiApiKey',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> genderMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'goalType',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'goalType',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> goalTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> goalTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'goalType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'goalType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> goalTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'goalType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'goalType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      goalTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'goalType',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      heightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> heightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> idBetween(
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

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      isMetricIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'isMetric',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      isMetricIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'isMetric',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> isMetricEqualTo(
      bool? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isMetric',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      lunchTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lunchTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      lunchTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lunchTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      lunchTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lunchTime',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      lunchTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lunchTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      maxRolloverEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxRollover',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      maxRolloverGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxRollover',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      maxRolloverLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxRollover',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      maxRolloverBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxRollover',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      notificationsEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notificationsEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proteinGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proteinGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proteinPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proteinPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proteinPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      proteinPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proteinPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      rolloverEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rolloverEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sodiumGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sodiumGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sodiumGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sodiumGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sodiumGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sodiumGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sodiumGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      successToleranceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'successTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      successToleranceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'successTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      successToleranceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'successTolerance',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      successToleranceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'successTolerance',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sugarGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sugarGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sugarGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sugarGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sugarGoal',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      sugarGoalBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sugarGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'targetWeight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'targetWeight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'targetWeight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      targetWeightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'targetWeight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      tdeeGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tdeeGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      tdeeGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tdeeGoal',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> tdeeGoalEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tdeeGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      tdeeGoalGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tdeeGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      tdeeGoalLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tdeeGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> tdeeGoalBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tdeeGoal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'themeMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'themeMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'themeMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      themeModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'themeMode',
        value: '',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      utcOffsetEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'utcOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      utcOffsetGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'utcOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      utcOffsetLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'utcOffset',
        value: value,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      utcOffsetBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'utcOffset',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weeklyGoals',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weeklyGoals',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'weeklyGoals',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weight',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weight',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition> weightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weight',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'weightLossRate',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'weightLossRate',
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weightLossRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weightLossRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weightLossRate',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weightLossRateBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weightLossRate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension UserProfileQueryObject
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {
  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      aiProvidersElement(FilterQuery<AIProvider> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'aiProviders');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterFilterCondition>
      weeklyGoalsElement(FilterQuery<MacroGoal> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'weeklyGoals');
    });
  }
}

extension UserProfileQueryLinks
    on QueryBuilder<UserProfile, UserProfile, QFilterCondition> {}

extension UserProfileQuerySortBy
    on QueryBuilder<UserProfile, UserProfile, QSortBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByAiRoutingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRoutingMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByAiRoutingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRoutingMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByBreakfastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByBreakfastTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCarbsGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCarbsGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByCarbsPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByCarbsPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDietPreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByDietPreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDietType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietType', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDietTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietType', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDinnerTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDinnerTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByDobDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFatGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByFatPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFiberGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByFiberGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGeminiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiApiKey', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByGeminiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiApiKey', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGoalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByGoalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByIsMetricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByLunchTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByLunchTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByMaxRollover() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRollover', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByMaxRolloverDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRollover', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByProteinPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByProteinPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByRolloverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByRolloverEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortBySodiumGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortBySodiumGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortBySuccessTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successTolerance', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortBySuccessToleranceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successTolerance', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortBySugarGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortBySugarGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByTdeeGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdeeGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByTdeeGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdeeGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByUtcOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'utcOffset', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByUtcOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'utcOffset', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> sortByWeightLossRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightLossRate', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      sortByWeightLossRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightLossRate', Sort.desc);
    });
  }
}

extension UserProfileQuerySortThenBy
    on QueryBuilder<UserProfile, UserProfile, QSortThenBy> {
  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByActivityLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByActivityLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activityLevel', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByAiRoutingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRoutingMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByAiRoutingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiRoutingMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByBreakfastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByBreakfastTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakfastTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCarbsGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCarbsGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByCarbsPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByCarbsPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'carbsPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDietPreference() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByDietPreferenceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietPreference', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDietType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietType', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDietTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dietType', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDinnerTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDinnerTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dinnerTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByDobDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dob', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFatGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByFatPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fatPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFiberGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByFiberGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fiberGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGeminiApiKey() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiApiKey', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByGeminiApiKeyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'geminiApiKey', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGoalType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByGoalTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'goalType', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByHeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'height', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByIsMetricDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMetric', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByLunchTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchTime', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByLunchTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lunchTime', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByMaxRollover() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRollover', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByMaxRolloverDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxRollover', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByNotificationsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notificationsEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByProteinGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByProteinPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPercentage', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByProteinPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proteinPercentage', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByRolloverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverEnabled', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByRolloverEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolloverEnabled', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenBySodiumGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenBySodiumGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sodiumGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenBySuccessTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successTolerance', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenBySuccessToleranceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'successTolerance', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenBySugarGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenBySugarGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sugarGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByTargetWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetWeight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByTdeeGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdeeGoal', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByTdeeGoalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tdeeGoal', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByThemeMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByThemeModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'themeMode', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByUtcOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'utcOffset', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByUtcOffsetDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'utcOffset', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weight', Sort.desc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy> thenByWeightLossRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightLossRate', Sort.asc);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QAfterSortBy>
      thenByWeightLossRateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weightLossRate', Sort.desc);
    });
  }
}

extension UserProfileQueryWhereDistinct
    on QueryBuilder<UserProfile, UserProfile, QDistinct> {
  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByActivityLevel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activityLevel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByAiRoutingMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiRoutingMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByBreakfastTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakfastTime');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByCarbsGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByCarbsPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'carbsPercentage');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDietPreference(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dietPreference',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDietType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dietType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDinnerTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dinnerTime');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByDob() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dob');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByFatGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByFatPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fatPercentage');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByFiberGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fiberGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByGeminiApiKey(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'geminiApiKey', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByGender(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByGoalType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'goalType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByHeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'height');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByIsMetric() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMetric');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByLunchTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lunchTime');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByMaxRollover() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxRollover');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByNotificationsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByProteinGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByProteinPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proteinPercentage');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctByRolloverEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rolloverEnabled');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctBySodiumGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sodiumGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct>
      distinctBySuccessTolerance() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'successTolerance');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctBySugarGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sugarGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByTargetWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetWeight');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByTdeeGoal() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tdeeGoal');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByThemeMode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'themeMode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByUtcOffset() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'utcOffset');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByWeight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weight');
    });
  }

  QueryBuilder<UserProfile, UserProfile, QDistinct> distinctByWeightLossRate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weightLossRate');
    });
  }
}

extension UserProfileQueryProperty
    on QueryBuilder<UserProfile, UserProfile, QQueryProperty> {
  QueryBuilder<UserProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> activityLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activityLevel');
    });
  }

  QueryBuilder<UserProfile, List<AIProvider>?, QQueryOperations>
      aiProvidersProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiProviders');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> aiRoutingModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiRoutingMode');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> breakfastTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakfastTime');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> carbsGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsGoal');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations>
      carbsPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'carbsPercentage');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations>
      dietPreferenceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dietPreference');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> dietTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dietType');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> dinnerTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dinnerTime');
    });
  }

  QueryBuilder<UserProfile, DateTime?, QQueryOperations> dobProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dob');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> fatGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatGoal');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations> fatPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fatPercentage');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> fiberGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fiberGoal');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> geminiApiKeyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'geminiApiKey');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<UserProfile, String?, QQueryOperations> goalTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'goalType');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> heightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'height');
    });
  }

  QueryBuilder<UserProfile, bool?, QQueryOperations> isMetricProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMetric');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> lunchTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lunchTime');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> maxRolloverProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxRollover');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations>
      notificationsEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notificationsEnabled');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> proteinGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinGoal');
    });
  }

  QueryBuilder<UserProfile, double, QQueryOperations>
      proteinPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proteinPercentage');
    });
  }

  QueryBuilder<UserProfile, bool, QQueryOperations> rolloverEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolloverEnabled');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> sodiumGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sodiumGoal');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> successToleranceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'successTolerance');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> sugarGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sugarGoal');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> targetWeightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetWeight');
    });
  }

  QueryBuilder<UserProfile, int?, QQueryOperations> tdeeGoalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tdeeGoal');
    });
  }

  QueryBuilder<UserProfile, String, QQueryOperations> themeModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'themeMode');
    });
  }

  QueryBuilder<UserProfile, int, QQueryOperations> utcOffsetProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'utcOffset');
    });
  }

  QueryBuilder<UserProfile, List<MacroGoal>?, QQueryOperations>
      weeklyGoalsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weeklyGoals');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations> weightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weight');
    });
  }

  QueryBuilder<UserProfile, double?, QQueryOperations>
      weightLossRateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weightLossRate');
    });
  }
}
