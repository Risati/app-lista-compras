// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportSnapshotAdapter extends TypeAdapter<ReportSnapshot> {
  @override
  final int typeId = 11;

  @override
  ReportSnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportSnapshot(
      id: fields[0] as String,
      listId: fields[1] as String,
      date: fields[2] as DateTime,
      marketName: fields[3] as String?,
      total: fields[4] as double,
      budget: fields[5] as double?,
      items: (fields[6] as List).cast<ReportItem>(),
      note: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportSnapshot obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.listId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.marketName)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.budget)
      ..writeByte(6)
      ..write(obj.items)
      ..writeByte(7)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportSnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
