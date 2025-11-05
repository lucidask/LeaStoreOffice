import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive/hive.dart';
import 'package:lea_store_office/screens/restore_backup_screen.dart';
import 'package:lea_store_office/utils/app_data_reloader.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/client.dart';
import '../models/depot.dart';
import '../models/produit.dart';
import '../models/transaction.dart';
import '../models/transaction_supprimee.dart';
import '../models/versement.dart';
import '../providers/client_provider.dart';
import '../providers/product_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/background/background_service_initializer.dart';
import '../services/google_drive_service.dart';
import '../services/json_export_service.dart';
import '../utils/duration_parser.dart';
import '../utils/google_drive_backup_helper.dart';
import '../utils/loading_helper.dart';
import 'package:lea_store_office/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  String themeMode = 'Système';
  bool lockHome = false;
  String? backupPath;

  @override
  void initState() {
    super.initState();
    _attemptSilentSignIn();
  }

  void _attemptSilentSignIn() async {
    await GoogleDriveService.trySilentSignIn();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    double tauxChange = settings.tauxChange;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Apparence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),

    DropdownButtonFormField<ThemeMode>(
      decoration: InputDecoration(
        labelText: 'Thème de l’application',
        labelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[800] : Colors.white, // ✅ fond adapté
        border: const OutlineInputBorder(),
      ),
      dropdownColor: isDark ? Colors.grey[900] : Colors.white, // ✅ menu adapté
      value: currentMode,
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black87, // ✅ texte visible
        fontWeight: FontWeight.w500,
      ),
      items: const [
        DropdownMenuItem(
          value: ThemeMode.light,
          child: Text('Clair'),
        ),
        DropdownMenuItem(
          value: ThemeMode.dark,
          child: Text('Sombre'),
        ),
        DropdownMenuItem(
          value: ThemeMode.system,
          child: Text('Système'),
        ),
      ],
      onChanged: (mode) {
        if (mode != null) {
          themeProvider.setThemeMode(mode);
        }
      },
    ),
   const SizedBox(height: 24),
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
                          final parsed = double.tryParse(controller.text);
                          if (parsed != null) {
                            settings.setTauxChange(parsed);
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
                      onPressed: () {
                        final currentContext = context;

                        executeWithLoading(currentContext, () async {
                          final filePath = await JsonExportService.exportDataToJson();

                          if (!currentContext.mounted) return;

                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            SnackBar(
                              content: Text('Fichier exporté dans:\n$filePath'),
                              duration: const Duration(seconds: 6),
                            ),
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Backup Drive'),
                      onPressed: () {
                        final currentContext = context;

                        executeWithLoading(currentContext, () async {
                          await GoogleDriveBackupHelper.uploadBackup();

                          if (!currentContext.mounted) return;

                          ScaffoldMessenger.of(currentContext).showSnackBar(
                            const SnackBar(content: Text('✅ Sauvegarde envoyée sur Google Drive')),
                          );

                          setState(() {});
                        });
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
                  final currentContext = context;

                  await GoogleDriveService.logout();

                  if (!currentContext.mounted) return;

                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text('Déconnecté de Google Drive')),
                  );

                  setState(() {}); // 🔄 Refresh UI
                },
              ),
            ),

          const Text('Sauvegarde automatique', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Local'),
              value: settings.autoBackupEnabled,
              onChanged: (val) async {
                settings.setAutoBackupEnabled(val);
                final driveEnabled = settings.autoDriveBackupEnabled;
                if (val || driveEnabled) {
                  FlutterBackgroundService().invoke('startService');
                } else {
                  FlutterBackgroundService().invoke('stopService');
                }
              },
            ),
          ),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) => SwitchListTile(
              title: const Text('Google Drive'),
              value: settings.autoDriveBackupEnabled,
              onChanged: (val) async {
                settings.setAutoDriveBackupEnabled(val);
                final localEnabled = settings.autoBackupEnabled;
                if (val || localEnabled) {
                  FlutterBackgroundService().invoke('startService');
                } else {
                  FlutterBackgroundService().invoke('stopService');
                }
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
                  final currentContext = context;
                  final controller = TextEditingController(text: settings.backupIntervalRaw);

                  await showDialog(
                    context: currentContext,
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
                          onPressed: () => Navigator.pop(currentContext),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final input = controller.text.trim();
                            try {
                              final duration = DurationParser.parse(input);
                              if (duration.inSeconds >= 60) {
                                final prefs = await SharedPreferences.getInstance();
                                await prefs.setString('backup_interval', input);

                                settings.setBackupIntervalRaw(input);

                                if (settings.autoBackupEnabled) {
                                  await BackgroundServiceInitializer.initializeWith(
                                    duration,
                                    driveEnabled: settings.autoDriveBackupEnabled,
                                  );
                                }

                                if (!currentContext.mounted) return;
                                ScaffoldMessenger.of(currentContext).showSnackBar(
                                  const SnackBar(content: Text('✅ Intervalle enregistré')),
                                );
                              } else {
                                if (!currentContext.mounted) return;
                                ScaffoldMessenger.of(currentContext).showSnackBar(
                                  const SnackBar(content: Text('⛔ Minimum : 1 minute')),
                                );
                              }
                            } catch (e) {
                              if (!currentContext.mounted) return;
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                const SnackBar(content: Text('❌ Format invalide')),
                              );
                            }

                            if (currentContext.mounted) {
                              Navigator.pop(currentContext);
                            }
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
            title: const Text('Réinitialiser'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              final currentContext = context;

              showDialog(
                context: currentContext,
                builder: (_) => SimpleDialog(
                  title: const Text('Réinitialiser...'),
                  children: [
                    _buildResetOption(currentContext, 'Transactions', () async {
                      await Hive.box<Transaction>('transactions').clear();
                      if (!currentContext.mounted) return;
                      Provider.of<TransactionProvider>(currentContext, listen: false).loadTransactions();
                      showRestartReminder(currentContext);
                    }),
                    _buildResetOption(currentContext, 'Clients', () async {
                      final clientBox = Hive.box<Client>('clients');
                      final clientsAGarder = clientBox.values
                          .where((c) => c.nom.toLowerCase() == 'anonyme')
                          .toList();
                      try {
                        await clientBox.clear();
                        for (var client in clientsAGarder) {
                          await clientBox.put(client.id, client);
                        }
                      } catch (e) {
                        debugPrint('Erreur clientBox.clear/put: $e');
                      }

                      if (!currentContext.mounted) return;
                      Provider.of<ClientProvider>(currentContext, listen: false).loadClients();
                      showRestartReminder(currentContext);
                    }),
                    _buildResetOption(currentContext, 'Produits', () async {
                      await Hive.box<Produit>('produits').clear();
                      if (!currentContext.mounted) return;
                      Provider.of<ProductProvider>(currentContext, listen: false).loadProduits();
                      showRestartReminder(currentContext);
                    }),
                    _buildResetOption(currentContext, 'Inventaire uniquement', () async {
                      final box = Hive.box<Produit>('produits');
                      try {
                        for (var produit in box.values) {
                          produit.stock = 0;
                          await produit.save();
                        }
                      } catch (e) {
                        debugPrint('Erreur lors du reset inventaire: $e');
                      }

                      if (!currentContext.mounted) return;
                      Provider.of<ProductProvider>(currentContext, listen: false).loadProduits();
                      showRestartReminder(currentContext);
                    }),
                    _buildResetOption(currentContext, 'TOUT réinitialiser', () async {
                      await Hive.box<Transaction>('transactions').clear();
                      await Hive.box<Versement>('versements').clear();
                      await Hive.box<Depot>('depots').clear();
                      await Hive.box<TransactionSupprimee>('transactionsSupprimees').clear();
                      await Hive.box('settings').clear();

                      final clientBox = Hive.box<Client>('clients');
                      final clientsAGarder = clientBox.values
                          .where((c) => c.nom.toLowerCase() == 'anonyme')
                          .toList();
                      try {
                        await clientBox.clear();
                        for (var client in clientsAGarder) {
                          await clientBox.put(client.id, client);
                        }

                        await Hive.box<Produit>('produits').clear();
                      } catch (e) {
                        debugPrint('Erreur réinitialisation totale: $e');
                      }

                      if (!currentContext.mounted) return;
                      AppDataReloader.refreshAll(currentContext);

                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        if (!currentContext.mounted) return;
                        showRestartReminder(currentContext);
                      });
                    }),
                  ],
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, SettingsProvider settings, {bool isModification = false}) {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isModification ? 'Modifier le mot de passe' : 'Définir le mot de passe'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != controller.text) return 'Les mots de passe ne correspondent pas';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
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

  Widget _buildResetOption(
      BuildContext context,
      String label,
      Future<void> Function() onConfirm,
      ) {
    return SimpleDialogOption(
      child: Text(label),
      onPressed: () {
        Navigator.of(context).pop(); // Ferme SimpleDialog avant

        final currentContext = context;

        Future.delayed(Duration.zero, () {
          if (!currentContext.mounted) return;

          showDialog(
            context: currentContext,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Confirmer ?'),
              content: Text(
                'Tu es sûr(e) de vouloir réinitialiser "$label" ? Cette action est irréversible.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Ferme la confirmation

                    // Montre le loading
                    showDialog(
                      context: dialogContext,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );

                    await onConfirm();

                    if (!dialogContext.mounted) return;

                    // Ferme le loader
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void showRestartReminder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Relancez l\'app svp!'),
        duration: Duration(seconds: 4),
      ),
    );
  }


}
