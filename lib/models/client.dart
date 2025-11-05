import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

part 'client.g.dart';

@HiveType(typeId: 1)
class Client extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nom;

  @HiveField(2)
  String? telephone;

  @HiveField(3)
  String? imagePath;

  @HiveField(4)
  double solde;

  @HiveField(5)
  double? depot;

  Client({
    required this.id,
    required this.nom,
    this.telephone,
    this.imagePath,
    required this.solde,
    this.depot,
  });

  /// ✅ Export JSON avec image encodée
  Map<String, dynamic> toJson() {
    String? base64Image;
    if (imagePath != null && File(imagePath!).existsSync()) {
      final bytes = File(imagePath!).readAsBytesSync();
      base64Image = base64Encode(bytes);
    }

    return {
      'id': id,
      'nom': nom,
      'telephone': telephone,
      'solde': solde,
      'depot': depot,
      'imageBase64': base64Image,
    };
  }

  /// ✅ Import JSON avec restauration de l’image
  factory Client.fromJson(Map<String, dynamic> json) {
    String? restoredPath;

    if (json['imageBase64'] != null) {
      final bytes = base64Decode(json['imageBase64']);
      final file = File('${_imageDir.path}/client_${json['id']}.png');
      file.writeAsBytesSync(bytes);
      restoredPath = file.path;
    }

    return Client(
      id: json['id'],
      nom: json['nom'],
      telephone: json['telephone'],
      solde: (json['solde'] as num).toDouble(),
      depot: (json['depot'] as num?)?.toDouble(),
      imagePath: restoredPath,
    );
  }

  /// ✅ Initialiser le répertoire d'image
  static late Directory _imageDir;

  static Future<void> initImageDirectory() async {
    final base = await getExternalStorageDirectory();
    _imageDir = Directory('${base!.path}/images/clients');
    if (!await _imageDir.exists()) {
      await _imageDir.create(recursive: true);
    }
  }
}
