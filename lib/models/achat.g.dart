// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achat.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchatAdapter extends TypeAdapter<Achat> {
  @override
  final int typeId = 7;

  @override
  Achat read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achat(
      id: fields[0] as String,
      produitId: fields[1] as String,
      prixAchat: fields[2] as double,
      quantite: fields[3] as int,
      date: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Achat obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.produitId)
      ..writeByte(2)
      ..write(obj.prixAchat)
      ..writeByte(3)
      ..write(obj.quantite)
      ..writeByte(4)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchatAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
