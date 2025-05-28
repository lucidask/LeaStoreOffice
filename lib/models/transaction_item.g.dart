// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionItemAdapter extends TypeAdapter<TransactionItem> {
  @override
  final int typeId = 2;

  @override
  TransactionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionItem(
      produitId: fields[0] as String,
      produitNom: fields[1] as String,
      produitImagePath: fields[2] as String?,
      quantite: fields[3] as int,
      prixUnitaire: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.produitId)
      ..writeByte(1)
      ..write(obj.produitNom)
      ..writeByte(2)
      ..write(obj.produitImagePath)
      ..writeByte(3)
      ..write(obj.quantite)
      ..writeByte(4)
      ..write(obj.prixUnitaire);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
