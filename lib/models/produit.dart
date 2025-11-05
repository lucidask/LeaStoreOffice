import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'produit.g.dart'; // Nécessaire pour Hive

@HiveType(typeId: 0)
class Produit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String codeProduit;

  @HiveField(2)
  String categorie;

  @HiveField(3)
  double prixUnitaire;

  @HiveField(4)
  int stock;

  @HiveField(5)
  String? imagePath;

  Produit({
    required this.id,
    required this.codeProduit,
    required this.categorie,
    required this.prixUnitaire,
    this.stock = 0,
    this.imagePath,
  });

  /// ✅ Méthode de sérialisation (pour export)
  Map<String, dynamic> toJson() {
    String? base64Image;
    if (imagePath != null && File(imagePath!).existsSync()) {
      final bytes = File(imagePath!).readAsBytesSync();
      base64Image = base64Encode(bytes);
    }

    return {
      'id': id,
      'codeProduit': codeProduit,
      'categorie': categorie,
      'prixUnitaire': prixUnitaire,
      'stock': stock,
      'imageBase64': base64Image,
    };
  }

  /// ✅ Méthode de désérialisation (pour import avec image)
  factory Produit.fromJson(Map<String, dynamic> json) {
    String? restoredImagePath;

    if (json['imageBase64'] != null) {
      final bytes = base64Decode(json['imageBase64']);
      final imageFile = File('${_imageDirectory.path}/produit_${json['id']}.png');
      imageFile.writeAsBytesSync(bytes);
      restoredImagePath = imageFile.path;
    }

    return Produit(
      id: json['id'],
      codeProduit: json['codeProduit'],
      categorie: json['categorie'],
      prixUnitaire: (json['prixUnitaire'] as num).toDouble(),
      stock: json['stock'] ?? 0,
      imagePath: restoredImagePath,
    );
  }

  /// ✅ Initialiser le répertoire d’image (à appeler une seule fois avant import)
  static late Directory _imageDirectory;

  static Future<void> initImageDirectory() async {
    final baseDir = await getExternalStorageDirectory();
    _imageDirectory = Directory('${baseDir!.path}/images/produits');
    if (!await _imageDirectory.exists()) {
      await _imageDirectory.create(recursive: true);
    }
  }
}
