import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
<<<<<<< HEAD
import 'package:googleapis/drive/v3.dart' as drive;
import '../services/json_import_service.dart';
import '../services/google_drive_service.dart';
import '../utils/app_data_reloader.dart';

class RestoreBackupScreen extends StatefulWidget {
  final String source; // 'local' ou 'drive'
  const RestoreBackupScreen({super.key, required this.source});
=======
import '../services/json_import_service.dart';
import '../utils/app_data_reloader.dart';

class RestoreBackupScreen extends StatefulWidget {
  const RestoreBackupScreen({super.key});
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a

  @override
  State<RestoreBackupScreen> createState() => _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends State<RestoreBackupScreen> {
<<<<<<< HEAD
  List<File> localBackups = [];
  List<drive.File> driveBackups = [];
  bool isLoading = true;
  bool selectionMode = false;
  Set<String> selectedPaths = {}; // for local
  Set<String> selectedDriveIds = {}; // for drive
=======
  List<File> backupFiles = [];
  bool selectionMode = false;
  Set<String> selectedFilePaths = {};
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    widget.source == 'local' ? _loadLocalBackups() : _loadDriveBackups();
  }

  Future<void> _loadLocalBackups() async {
=======
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
    final dir = await getExternalStorageDirectory();
    final backupDir = Directory('${dir!.path}/backup');

    if (await backupDir.exists()) {
      final now = DateTime.now();
<<<<<<< HEAD
=======

>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

<<<<<<< HEAD
      for (var file in files) {
        final modified = file.lastModifiedSync();
        if (now.difference(modified).inDays > 30) await file.delete();
      }

=======
      // 🔥 Supprimer ceux qui datent de plus de 30 jours
      for (var file in files) {
        final lastModified = file.lastModifiedSync();
        if (now.difference(lastModified).inDays > 30) {
          await file.delete();
        }
      }

      // 🔁 Recharger la liste après suppression
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
      final validFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
<<<<<<< HEAD
        localBackups = validFiles;
        isLoading = false;
=======
        backupFiles = validFiles;
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
      });
    }
  }

<<<<<<< HEAD
  Future<void> _loadDriveBackups() async {
    final files = await GoogleDriveService.listBackupFiles();
    setState(() {
      driveBackups = files;
      isLoading = false;
    });
  }
=======
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a

  Future<String?> _askRestoreMode(BuildContext context) async {
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Restaurer les données'),
        content: const Text(
          'Comment souhaites-tu restaurer les données ?\n\n'
              '• Écraser : Supprime tout ce qui existe\n'
              '• Remplacer : Remplace les éléments avec le même ID\n'
              '• Fusionner : Additionne les stocks et garde les champs locaux',
        ),
        actions: [
<<<<<<< HEAD
          TextButton(onPressed: () => Navigator.pop(context, 'merge'), child: const Text('Fusionner')),
          TextButton(onPressed: () => Navigator.pop(context, 'replace'), child: const Text('Remplacer')),
          TextButton(onPressed: () => Navigator.pop(context, 'erase'), child: const Text('Écraser tout')),
=======
          TextButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: const Text('Fusionner'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            child: const Text('Remplacer'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'erase'),
            child: const Text('Écraser tout'),
          ),
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
        ],
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _restoreLocal(File file) async {
    final mode = await _askRestoreMode(context);
    if (mode == null) return;

    try {
      await JsonImportService.importFromFile(file, mode: mode);
      AppDataReloader.refreshAll(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Données restaurées.')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Erreur : $e')));
    }
  }

  Future<void> _restoreDrive(drive.File file) async {
    final mode = await _askRestoreMode(context);
    if (mode == null) return;

    try {
      final downloaded = await GoogleDriveService.downloadFileById(file.id!, file.name!);
      if (downloaded != null) {
        await JsonImportService.importFromFile(downloaded, mode: mode);
        AppDataReloader.refreshAll(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Données restaurées.')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ Téléchargement échoué.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Erreur : $e')));
    }
  }

  void _toggleSelection(String path) {
    setState(() {
      if (selectedPaths.contains(path)) {
        selectedPaths.remove(path);
        if (selectedPaths.isEmpty) selectionMode = false;
      } else {
        selectedPaths.add(path);
      }
    });
  }

  void _toggleDriveSelection(String id) {
    setState(() {
      if (selectedDriveIds.contains(id)) {
        selectedDriveIds.remove(id);
        if (selectedDriveIds.isEmpty) selectionMode = false;
      } else {
        selectedDriveIds.add(id);
      }
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (widget.source == 'local') {
        if (selectedPaths.length == localBackups.length) {
          selectedPaths.clear();
        } else {
          selectedPaths = localBackups.map((f) => f.path).toSet();
        }
      } else {
        if (selectedDriveIds.length == driveBackups.length) {
          selectedDriveIds.clear();
        } else {
          selectedDriveIds = driveBackups.map((f) => f.id!).toSet();
        }
      }
    });
  }

  void _confirmDeleteSelection() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmer suppression'),
        content: Text('Supprimer ${widget.source == 'local' ? selectedPaths.length : selectedDriveIds.length} sauvegarde(s) ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.source == 'local') {
        for (final path in selectedPaths) {
          final f = File(path);
          if (await f.exists()) await f.delete();
        }
        selectedPaths.clear();
        await _loadLocalBackups();
      } else {
        for (final id in selectedDriveIds) {
          await GoogleDriveService.deleteFileById(id);
        }
        selectedDriveIds.clear();
        await _loadDriveBackups();
      }
      setState(() => selectionMode = false);
    }
  }

  Widget _buildListView() {
    if (widget.source == 'local') {
      return localBackups.isEmpty
          ? const Center(child: Text('Aucune sauvegarde trouvée.'))
          : ListView.builder(
        itemCount: localBackups.length,
        itemBuilder: (context, index) {
          final file = localBackups[index];
          final name = file.path.split('/').last;
          final selected = selectedPaths.contains(file.path);

          return ListTile(
            title: Text(name),
            trailing: selectionMode
                ? Checkbox(
              value: selected,
              onChanged: (_) => _toggleSelection(file.path),
            )
                : const Icon(Icons.restore),
            selected: selected,
            selectedTileColor: Colors.red.shade100,
            onLongPress: () {
              setState(() {
                selectionMode = true;
                selectedPaths.add(file.path);
              });
            },
            onTap: () {
              if (selectionMode) {
                _toggleSelection(file.path);
              } else {
                _restoreLocal(file);
              }
            },
          );
        },
      );
    } else {
      return driveBackups.isEmpty
          ? const Center(child: Text('Aucun backup Drive trouvé.'))
          : ListView.builder(
        itemCount: driveBackups.length,
        itemBuilder: (context, index) {
          final file = driveBackups[index];
          final selected = selectedDriveIds.contains(file.id);
          return ListTile(
            title: Text(file.name ?? 'Nom inconnu'),
            subtitle: Text(file.createdTime?.toLocal().toString() ?? ''),
            trailing: selectionMode
                ? Checkbox(
              value: selected,
              onChanged: (_) => _toggleDriveSelection(file.id!),
            )
                : const Icon(Icons.restore),
            selected: selected,
            selectedTileColor: Colors.red.shade100,
            onLongPress: () {
              setState(() {
                selectionMode = true;
                selectedDriveIds.add(file.id!);
              });
            },
            onTap: () {
              if (selectionMode) {
                _toggleDriveSelection(file.id!);
              } else {
                _restoreDrive(file);
              }
            },
          );
        },
=======
  Future<void> _restore(File file) async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final mode = await _askRestoreMode(context);
      if (mode == null) return;

      await JsonImportService.importFromFile(file, mode: mode);
      AppDataReloader.refreshAll(context);

      scaffold.showSnackBar(
        const SnackBar(content: Text('✅ Données restaurées avec succès')),
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(content: Text('❌ Erreur lors de la restauration : $e')),
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
      );
    }
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    final isLocal = widget.source == 'local';
    final selectedCount = isLocal ? selectedPaths.length : selectedDriveIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode
            ? '$selectedCount sélectionné(s)'
            : 'Restaurer depuis ${isLocal ? 'Local' : 'Google Drive'}'),
=======
    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode
            ? '${selectedFilePaths.length} sélectionné(s)'
            : 'Restaurer une sauvegarde'),
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
        actions: [
          IconButton(
            icon: Icon(selectionMode ? Icons.close : Icons.delete),
            onPressed: () {
<<<<<<< HEAD
              setState(() {
                selectionMode = !selectionMode;
                if (!selectionMode) {
                  selectedPaths.clear();
                  selectedDriveIds.clear();
                }
              });
=======
              if (selectionMode) {
                setState(() {
                  selectionMode = false;
                  selectedFilePaths.clear();
                });
              } else {
                setState(() {
                  selectionMode = true;
                });
              }
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
            },
          ),
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectAll,
            ),
        ],
      ),
<<<<<<< HEAD
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildListView(),
      floatingActionButton: selectionMode && selectedCount > 0
          ? FloatingActionButton.extended(
        onPressed: _confirmDeleteSelection,
        icon: const Icon(Icons.delete),
        label: const Text("Supprimer sélection"),
=======
      body: backupFiles.isEmpty
          ? const Center(child: Text('Aucune sauvegarde trouvée.'))
          : ListView.builder(
        itemCount: backupFiles.length,
        itemBuilder: (context, index) {
          final file = backupFiles[index];
          final name = file.path.split('/').last;
          final selected = selectedFilePaths.contains(file.path);

          return ListTile(
            title: Text(name),
            trailing: selectionMode
                ? Checkbox(
              value: selected,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    selectedFilePaths.add(file.path);
                  } else {
                    selectedFilePaths.remove(file.path);
                    if (selectedFilePaths.isEmpty) {
                      selectionMode = false;
                    }
                  }
                });
              },
            )
                : const Icon(Icons.restore),
            selected: selected,
            selectedTileColor: Colors.red.shade100,
            onLongPress: () {
              setState(() {
                selectionMode = true;
                selectedFilePaths.add(file.path);
              });
            },
            onTap: () {
              if (selectionMode) {
                setState(() {
                  if (selected) {
                    selectedFilePaths.remove(file.path);
                    if (selectedFilePaths.isEmpty) selectionMode = false;
                  } else {
                    selectedFilePaths.add(file.path);
                  }
                });
              } else {
                _restore(file);
              }
            },
          );
        },
      ),
      floatingActionButton: selectionMode && selectedFilePaths.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _confirmerSuppression,
        icon: const Icon(Icons.delete),
        label: const Text('Supprimer sélection'),
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
        backgroundColor: Colors.red,
      )
          : null,
    );
  }
<<<<<<< HEAD
=======

  void _toggleSelectAll() {
    setState(() {
      if (selectedFilePaths.length == backupFiles.length) {
        selectedFilePaths.clear();
      } else {
        selectedFilePaths = backupFiles.map((f) => f.path).toSet();
      }
    });
  }

  void _confirmerSuppression() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Supprimer ${selectedFilePaths.length} sauvegarde(s) ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Supprimer')),
        ],
      ),
    );

    if (confirm == true) {
      for (var path in selectedFilePaths) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      selectedFilePaths.clear();
      selectionMode = false;
      await _loadBackupFiles();
      setState(() {});
    }
  }
>>>>>>> 2283ded628918f9e765790a9a7c2222455f4434a
}
