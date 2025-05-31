// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'versement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VersementAdapter extends TypeAdapter<Versement> {
  @override
  final int typeId = 5;

  @override
  Versement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Versement(
      id: fields[0] as String,
      clientId: fields[1] as String,
      montant: fields[2] as double,
      date: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Versement obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.clientId)
      ..writeByte(2)
      ..write(obj.montant)
      ..writeByte(3)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VersementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
