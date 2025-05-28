// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 3;

  @override
  Transaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Transaction(
      id: fields[0] as String,
      type: fields[1] as String,
      clientId: fields[2] as String?,
      date: fields[3] as DateTime,
      isCredit: fields[4] as bool,
      produits: (fields[5] as List).cast<TransactionItem>(),
      note: fields[6] as String?,
      total: fields[7] as double,
      fournisseur: fields[8] as String?,
      clientNom: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.clientId)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.isCredit)
      ..writeByte(5)
      ..write(obj.produits)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.total)
      ..writeByte(8)
      ..write(obj.fournisseur)
      ..writeByte(9)
      ..write(obj.clientNom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
