import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/json_import_service.dart';
import '../utils/app_data_reloader.dart';

class RestoreBackupScreen extends StatefulWidget {
  const RestoreBackupScreen({super.key});

  @override
  State<RestoreBackupScreen> createState() => _RestoreBackupScreenState();
}

class _RestoreBackupScreenState extends State<RestoreBackupScreen> {
  List<File> backupFiles = [];
  bool selectionMode = false;
  Set<String> selectedFilePaths = {};

  @override
  void initState() {
    super.initState();
    _loadBackupFiles();
  }

  Future<void> _loadBackupFiles() async {
    final dir = await getExternalStorageDirectory();
    final backupDir = Directory('${dir!.path}/backup');

    if (await backupDir.exists()) {
      final now = DateTime.now();

      final files = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      // 🔥 Supprimer ceux qui datent de plus de 30 jours
      for (var file in files) {
        final lastModified = file.lastModifiedSync();
        if (now.difference(lastModified).inDays > 30) {
          await file.delete();
        }
      }

      // 🔁 Recharger la liste après suppression
      final validFiles = backupDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      setState(() {
        backupFiles = validFiles;
      });
    }
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
        ],
      ),
    );
  }

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
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectionMode
            ? '${selectedFilePaths.length} sélectionné(s)'
            : 'Restaurer une sauvegarde'),
        actions: [
          IconButton(
            icon: Icon(selectionMode ? Icons.close : Icons.delete),
            onPressed: () {
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
            },
          ),
          if (selectionMode)
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _toggleSelectAll,
            ),
        ],
      ),
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
        backgroundColor: Colors.red,
      )
          : null,
    );
  }

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
}
