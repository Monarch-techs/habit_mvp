// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HabitImpl _$$HabitImplFromJson(Map<String, dynamic> json) => _$HabitImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp),
      userId: json['userId'] as String,
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => const TimestampConverter().fromJson(e as Timestamp))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HabitImplToJson(_$HabitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'iconName': instance.iconName,
      'colorHex': instance.colorHex,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'userId': instance.userId,
      'completedDates': instance.completedDates
          .map(const TimestampConverter().toJson)
          .toList(),
    };
