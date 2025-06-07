import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

class GoogleDriveService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [drive.DriveApi.driveFileScope],
  );

  static drive.DriveApi? _driveApi;
  static bool get isSignedIn => _googleSignIn.currentUser != null;


  static Future<drive.DriveApi> _getDriveApi() async {
    if (_driveApi != null) return _driveApi!;
    final account = await _googleSignIn.signIn();
    if (account == null) throw Exception('Google sign-in failed');

    final authHeaders = await account.authHeaders;
    final authenticatedClient = GoogleAuthClient(authHeaders);
    _driveApi = drive.DriveApi(authenticatedClient);
    return _driveApi!;
  }

  static Future<void> uploadFileToDrive(File file) async {
    final driveApi = await _getDriveApi();
    final rootFolderName = "Lea Store Office Backup";
    final backupFileName = file.path.split('/').last;
    final subFolderName = backupFileName.replaceAll(".json", "");

    // Dossier racine
    final rootFolderList = await driveApi.files.list(
      q: "mimeType='application/vnd.google-apps.folder' and name='$rootFolderName' and trashed=false",
    );

    String rootFolderId;
    if (rootFolderList.files != null && rootFolderList.files!.isNotEmpty) {
      rootFolderId = rootFolderList.files!.first.id!;
    } else {
      final folder = drive.File()
        ..name = rootFolderName
        ..mimeType = 'application/vnd.google-apps.folder';
      final created = await driveApi.files.create(folder);
      rootFolderId = created.id!;
    }

    // Sous-dossier pour ce backup
    final subFolder = drive.File()
      ..name = subFolderName
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [rootFolderId];

    final createdSubFolder = await driveApi.files.create(subFolder);
    final subFolderId = createdSubFolder.id!;

    // Envoi du fichier dans le sous-dossier
    final driveFile = drive.File()
      ..name = backupFileName
      ..parents = [subFolderId];

    final media = drive.Media(file.openRead(), await file.length());
    await driveApi.files.create(driveFile, uploadMedia: media);
  }

  static Future<List<drive.File>> listBackupFiles() async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return [];

    // Trouver le dossier principal
    final rootFolderList = await driveApi.files.list(
      q: "name = 'Lea Store Office Backup' and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      $fields: "files(id)",
    );
    if (rootFolderList.files == null || rootFolderList.files!.isEmpty) return [];

    final rootFolderId = rootFolderList.files!.first.id!;

    // Trouver tous les sous-dossiers (chaque sous-dossier = un backup)
    final subFoldersList = await driveApi.files.list(
      q: "'$rootFolderId' in parents and mimeType = 'application/vnd.google-apps.folder' and trashed = false",
      $fields: "files(id, name, createdTime)",
    );

    final List<drive.File> backupFiles = [];

    for (var folder in subFoldersList.files ?? []) {
      final filesInFolder = await driveApi.files.list(
        q: "'${folder.id}' in parents and name contains '.json' and trashed = false",
        $fields: "files(id, name, createdTime)",
      );

      if (filesInFolder.files != null && filesInFolder.files!.isNotEmpty) {
        backupFiles.add(filesInFolder.files!.first);
      }
    }

    // Trier par date de création (du plus récent au plus ancien)
    backupFiles.sort((a, b) {
      final aDate = a.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.createdTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });

    return backupFiles;
  }

  static Future<File?> downloadFileById(String fileId, String fileName) async {
    final driveApi = await _getDriveApi();
    final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia) as drive.Media;

    final bytes = await media.stream.fold<List<int>>([], (b, d) => b..addAll(d));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);
    return file;
  }


  static Future<void> deleteFileById(String fileId) async {
    final driveApi = await _getDriveApi();
    if (driveApi == null) return;

    // ✅ Correction ici : cast explicite avec `as drive.File`
    final file = await driveApi.files.get(fileId, $fields: 'parents') as drive.File;
    final parents = file.parents;

    // 🗑️ Supprimer le fichier
    await driveApi.files.delete(fileId);
    // 🔍 Supprimer le dossier parent s’il est vide
    if (parents != null && parents.isNotEmpty) {
      final parentId = parents.first;

      final remainingFiles = await driveApi.files.list(
        q: "'$parentId' in parents and trashed = false",
        $fields: "files(id)",
      );

      if (remainingFiles.files == null || remainingFiles.files!.isEmpty) {
        await driveApi.files.delete(parentId);
      }
    }
  }

  static Future<void> logout() async {
    await _googleSignIn.signOut();
    _driveApi = null;
  }

  static Future<void> trySilentSignIn() async {
    final account = await _googleSignIn.signInSilently();
    if (account != null) {
      final authHeaders = await account.authHeaders;
      final authenticatedClient = GoogleAuthClient(authHeaders);
      _driveApi = drive.DriveApi(authenticatedClient);
    }
  }


}
