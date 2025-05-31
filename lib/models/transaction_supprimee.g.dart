// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_supprimee.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionSupprimeeAdapter extends TypeAdapter<TransactionSupprimee> {
  @override
  final int typeId = 4;

  @override
  TransactionSupprimee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionSupprimee(
      id: fields[0] as String,
      dateSuppression: fields[1] as DateTime,
      transactionOriginale: fields[2] as Transaction,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionSupprimee obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateSuppression)
      ..writeByte(2)
      ..write(obj.transactionOriginale);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionSupprimeeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
