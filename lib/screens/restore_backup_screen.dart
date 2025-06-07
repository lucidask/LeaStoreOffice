import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import '../services/json_import_service.dart';
import '../services/google_drive_service.dart';
import '../utils/app_data_reloader.dart';

class RestoreBackupScreen extends StatefulWidget {
  final String source; // 'local' ou 'drive'
  const RestoreBackupScreen({super.key, required this.source});

  @override
  State<RestoreBackupScreen> createState() => _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends State<RestoreBackupScreen> {
  List<File> localBackups = [];
  List<drive.File> driveBackups = [];
  bool isLoading = true;
  bool selectionMode = false;
  Set<String> selectedPaths = {}; // for local
  Set<String> selectedDriveIds = {}; // for drive

  @override
  void initState() {
    super.initState();
    widget.source == 'local' ? _loadLocalBackups() : _loadDriveBackups();
  }

  Future<void> _loadLocalBackups() async {
    final dir = await getExternalStorageDirectory();
    final backupDir = Directory('${dir!.path}/backup');

    if (await backupDir.exists()) {
      final now = DateTime.now();
      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      for (var file in files) {
        final modified = file.lastModifiedSync();
        if (now.difference(modified).inDays > 30) await file.delete();
      }

      final validFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
        localBackups = validFiles;
        isLoading = false;
      });
    }
  }

  Future<void> _loadDriveBackups() async {
    final files = await GoogleDriveService.listBackupFiles();
    setState(() {
      driveBackups = files;
      isLoading = false;
    });
  }

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
          TextButton(onPressed: () => Navigator.pop(context, 'merge'), child: const Text('Fusionner')),
          TextButton(onPressed: () => Navigator.pop(context, 'replace'), child: const Text('Remplacer')),
          TextButton(onPressed: () => Navigator.pop(context, 'erase'), child: const Text('Écraser tout')),
        ],
      ),
    );
  }

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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLocal = widget.source == 'local';
    final selectedCount = isLocal ? selectedPaths.length : selectedDriveIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode
            ? '$selectedCount sélectionné(s)'
            : 'Restaurer depuis ${isLocal ? 'Local' : 'Google Drive'}'),
        actions: [
          IconButton(
            icon: Icon(selectionMode ? Icons.close : Icons.delete),
            onPressed: () {
              setState(() {
                selectionMode = !selectionMode;
                if (!selectionMode) {
                  selectedPaths.clear();
                  selectedDriveIds.clear();
                }
              });
            },
          ),
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectAll,
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildListView(),
      floatingActionButton: selectionMode && selectedCount > 0
          ? FloatingActionButton.extended(
        onPressed: _confirmDeleteSelection,
        icon: const Icon(Icons.delete),
        label: const Text("Supprimer sélection"),
        backgroundColor: Colors.red,
      )
          : null,
    );
  }
}
