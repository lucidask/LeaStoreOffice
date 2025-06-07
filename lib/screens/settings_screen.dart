import 'package:flutter/material.dart';
import 'package:lea_store_office/screens/restore_backup_screen.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/auto_backup_service.dart';
import '../services/google_drive_service.dart';
import '../services/json_export_service.dart';
import '../utils/duration_parser.dart';
import '../utils/google_drive_backup_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String themeMode = 'Système';
  double tauxChange = 125.0;
  bool includeLogo = true;
  String thankYouText = 'Merci pour votre achat !';
  String? signaturePath;
  bool lockHome = false;
  String? backupPath;

  @override
  void initState() {
    super.initState();
    _attemptSilentSignIn();
  }

  void _attemptSilentSignIn() async {
    await GoogleDriveService.trySilentSignIn();
    setState(() {}); // Rafraîchit l'écran pour que le bouton logout apparaisse si connecté
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Apparence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            title: const Text('Thème'),
            trailing: DropdownButton<String>(
              value: themeMode,
              items: const [
                DropdownMenuItem(value: 'Clair', child: Text('Clair')),
                DropdownMenuItem(value: 'Sombre', child: Text('Sombre')),
                DropdownMenuItem(value: 'Système', child: Text('Système')),
              ],
              onChanged: (value) {
                setState(() {
                  themeMode = value!;
                });
              },
            ),
          ),
          const Divider(),

          const Text('Taux de Change', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            title: const Text('1 USD ='),
            subtitle: Text('$tauxChange HTG'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final controller = TextEditingController(text: tauxChange.toString());
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Modifier Taux de Change'),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(suffixText: 'HTG'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tauxChange = double.tryParse(controller.text) ?? tauxChange;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Valider'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          const Text('Sécurité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            title: const Text('Mot de passe pour accéder à l\'accueil'),
            value: Provider.of<SettingsProvider>(context).lockHome,
            onChanged: (val) {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              if (val) {
                _showPasswordDialog(context, settings);
              } else {
                settings.toggleLock(false);
              }
            },
          ),
          ListTile(
            title: const Text('Modifier le mot de passe'),
            trailing: const Icon(Icons.lock),
            onTap: () {
              final settings = Provider.of<SettingsProvider>(context, listen: false);
              _showPasswordDialog(context, settings, isModification: true);
            },
          ),

          const Divider(),
          const Text('Sauvegarde et Restauration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🟦 Colonne Sauvegarde
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.backup),
                      label: const Text('Backup local'),
                      onPressed: () async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          final filePath = await JsonExportService.exportDataToJson();
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Fichier exporté dans:\n$filePath'),
                              duration: const Duration(seconds: 6),
                            ),
                          );
                        } catch (e) {
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text('Erreur lors de l\'export : $e')),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Backup Drive'),
                      onPressed: () async {
                        final scaffold = ScaffoldMessenger.of(context);
                        try {
                          await GoogleDriveBackupHelper.uploadBackup();
                          scaffold.showSnackBar(
                            const SnackBar(content: Text('✅ Sauvegarde envoyée sur Google Drive')),
                          );
                          setState(() {}); // 🔄 rafraîchir pour bouton logout
                        } catch (e) {
                          scaffold.showSnackBar(
                            SnackBar(content: Text('❌ Erreur : $e')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 🟩 Colonne Restauration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.restore),
                      label: const Text('Restaurer local'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RestoreBackupScreen(source: 'local'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Restaurer Drive'),
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RestoreBackupScreen(source: 'drive'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (GoogleDriveService.isSignedIn)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter de Google Drive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  await GoogleDriveService.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Déconnecté de Google Drive')),
                  );
                  setState(() {}); // 🔄 Refresh UI
                },
              ),
            ),


          const Text('Sauvegarde automatique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Sauvegarde automatique Local'),
              value: settings.autoBackupEnabled,
              onChanged: (val) {
                settings.setAutoBackupEnabled(val);
                final duration = DurationParser.parse(settings.backupIntervalRaw);
                if (val) {
                  AutoBackupService.startWithDuration(context, duration);
                } else {
                  AutoBackupService.stop();
                }
              },
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Sauvegarde automatique Drive'),
              value: settings.autoDriveBackupEnabled,
              onChanged: (val) {
                settings.setAutoDriveBackupEnabled(val);
              },
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => ListTile(
              title: const Text('Intervalle de sauvegarde automatique'),
              subtitle: Text(settings.backupIntervalRaw),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final controller = TextEditingController(text: settings.backupIntervalRaw);
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Définir l\'intervalle (ex : 5h10m30s)'),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Exemple : 6h ou 1h30m ou 10m45s',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            final input = controller.text.trim();
                            try {
                              final duration = DurationParser.parse(input);
                              if (duration.inSeconds >= 60) {
                                settings.setBackupIntervalRaw(input);
                                if (settings.autoBackupEnabled) {
                                  AutoBackupService.startWithDuration(context, duration);
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ Intervalle enregistré')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('⛔ Minimum : 1 minute')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('❌ Format invalide')),
                              );
                            }
                            Navigator.pop(context);
                          },
                          child: const Text('Valider'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(),
          const Text('Réinitialisation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ListTile(
            title: const Text('Réinitialiser l\'inventaire'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              // Confirmation à ajouter plus tard
            },
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, SettingsProvider settings, {bool isModification = false}) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isModification ? 'Modifier le mot de passe' : 'Définir le mot de passe'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Mot de passe',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                settings.setPassword(controller.text);
                if (!isModification) {
                  settings.toggleLock(true);
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }


}
