// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'produit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProduitAdapter extends TypeAdapter<Produit> {
  @override
  final int typeId = 0;

  @override
  Produit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Produit(
      id: fields[0] as String,
      codeProduit: fields[1] as String,
      categorie: fields[2] as String,
      prixUnitaire: fields[3] as double,
      stock: fields[4] as int,
      imagePath: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Produit obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.codeProduit)
      ..writeByte(2)
      ..write(obj.categorie)
      ..writeByte(3)
      ..write(obj.prixUnitaire)
      ..writeByte(4)
      ..write(obj.stock)
      ..writeByte(5)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProduitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
