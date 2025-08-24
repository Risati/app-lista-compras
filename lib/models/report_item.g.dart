// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReportItemAdapter extends TypeAdapter<ReportItem> {
  @override
  final int typeId = 10;

  @override
  ReportItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReportItem(
      name: fields[0] as String,
      quantity: fields[1] as int,
      unitPrice: fields[2] as double,
      subtotal: fields[3] as double,
      category: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ReportItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitPrice)
      ..writeByte(3)
      ..write(obj.subtotal)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReportItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
