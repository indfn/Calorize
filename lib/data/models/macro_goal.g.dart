// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_goal.dart';

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const MacroGoalSchema = Schema(
  name: r'MacroGoal',
  id: 676971607062092717,
  properties: {
    r'carbsGoal': PropertySchema(
      id: 0,
      name: r'carbsGoal',
      type: IsarType.double,
    ),
    r'carbsPercentage': PropertySchema(
      id: 1,
      name: r'carbsPercentage',
      type: IsarType.double,
    ),
    r'dayOfWeek': PropertySchema(
      id: 2,
      name: r'dayOfWeek',
      type: IsarType.long,
    ),
    r'fatGoal': PropertySchema(
      id: 3,
      name: r'fatGoal',
      type: IsarType.double,
    ),
    r'fatPercentage': PropertySchema(
      id: 4,
      name: r'fatPercentage',
      type: IsarType.double,
    ),
    r'fiberGoal': PropertySchema(
      id: 5,
      name: r'fiberGoal',
      type: IsarType.double,
    ),
    r'proteinGoal': PropertySchema(
      id: 6,
      name: r'proteinGoal',
      type: IsarType.double,
    ),
    r'proteinPercentage': PropertySchema(
      id: 7,
      name: r'proteinPercentage',
      type: IsarType.double,
    ),
    r'sodiumGoal': PropertySchema(
      id: 8,
      name: r'sodiumGoal',
      type: IsarType.double,
    ),
    r'sugarGoal': PropertySchema(
      id: 9,
      name: r'sugarGoal',
      type: IsarType.double,
    ),
    r'tdeeGoal': PropertySchema(
      id: 10,
      name: r'tdeeGoal',
      type: IsarType.long,
    )
  },
  estimateSize: _macroGoalEstimateSize,
  serialize: _macroGoalSerialize,
  deserialize: _macroGoalDeserialize,
  deserializeProp: _macroGoalDeserializeProp,
);

int _macroGoalEstimateSize(
  MacroGoal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _macroGoalSerialize(
  MacroGoal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.carbsGoal);
  writer.writeDouble(offsets[1], object.carbsPercentage);
  writer.writeLong(offsets[2], object.dayOfWeek);
  writer.writeDouble(offsets[3], object.fatGoal);
  writer.writeDouble(offsets[4], object.fatPercentage);
  writer.writeDouble(offsets[5], object.fiberGoal);
  writer.writeDouble(offsets[6], object.proteinGoal);
  writer.writeDouble(offsets[7], object.proteinPercentage);
  writer.writeDouble(offsets[8], object.sodiumGoal);
  writer.writeDouble(offsets[9], object.sugarGoal);
  writer.writeLong(offsets[10], object.tdeeGoal);
}

MacroGoal _macroGoalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MacroGoal();
  object.carbsGoal = reader.readDoubleOrNull(offsets[0]);
  object.carbsPercentage = reader.readDoubleOrNull(offsets[1]);
  object.dayOfWeek = reader.readLongOrNull(offsets[2]);
  object.fatGoal = reader.readDoubleOrNull(offsets[3]);
  object.fatPercentage = reader.readDoubleOrNull(offsets[4]);
  object.fiberGoal = reader.readDoubleOrNull(offsets[5]);
  object.proteinGoal = reader.readDoubleOrNull(offsets[6]);
  object.proteinPercentage = reader.readDoubleOrNull(offsets[7]);
  object.sodiumGoal = reader.readDoubleOrNull(offsets[8]);
  object.sugarGoal = reader.readDoubleOrNull(offsets[9]);
  object.tdeeGoal = reader.readLongOrNull(offsets[10]);
  return object;
}

P _macroGoalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDoubleOrNull(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (reader.readDoubleOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (reader.readDoubleOrNull(offset)) as P;
    case 8:
      return (reader.readDoubleOrNull(offset)) as P;
    case 9:
      return (reader.readDoubleOrNull(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

extension MacroGoalQueryFilter
    on QueryBuilder<MacroGoal, MacroGoal, QFilterCondition> {
  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> carbsGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'carbsGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'carbsGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> carbsGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> carbsGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> carbsGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'carbsPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'carbsPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageEqualTo(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageGreaterThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageLessThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      carbsPercentageBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> dayOfWeekIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dayOfWeek',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      dayOfWeekIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dayOfWeek',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> dayOfWeekEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      dayOfWeekGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> dayOfWeekLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dayOfWeek',
        value: value,
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> dayOfWeekBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dayOfWeek',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fatGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fatGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalGreaterThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fatGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fatPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fatPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageEqualTo(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageGreaterThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageLessThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fatPercentageBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fiberGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fiberGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      fiberGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fiberGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fiberGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fiberGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> fiberGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proteinGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proteinGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> proteinGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> proteinGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> proteinGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'proteinPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'proteinPercentage',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageEqualTo(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageGreaterThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageLessThan(
    double? value, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      proteinPercentageBetween(
    double? lower,
    double? upper, {
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sodiumGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sodiumGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      sodiumGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sodiumGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sodiumGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sodiumGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sodiumGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sugarGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sugarGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      sugarGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sugarGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sugarGoalEqualTo(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sugarGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> sugarGoalBetween(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> tdeeGoalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'tdeeGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition>
      tdeeGoalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'tdeeGoal',
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> tdeeGoalEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tdeeGoal',
        value: value,
      ));
    });
  }

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> tdeeGoalGreaterThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> tdeeGoalLessThan(
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

  QueryBuilder<MacroGoal, MacroGoal, QAfterFilterCondition> tdeeGoalBetween(
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
}

extension MacroGoalQueryObject
    on QueryBuilder<MacroGoal, MacroGoal, QFilterCondition> {}
