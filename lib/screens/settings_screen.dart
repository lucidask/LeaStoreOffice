import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';

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

          const Text('PDF et Impression', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SwitchListTile(
            title: const Text('Inclure logo dans PDF'),
            value: includeLogo,
            onChanged: (val) => setState(() => includeLogo = val),
          ),
          ListTile(
            title: const Text('Texte de remerciement'),
            subtitle: Text(thankYouText),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final controller = TextEditingController(text: thankYouText);
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Modifier texte de remerciement'),
                    content: TextField(
                      controller: controller,
                      maxLines: 2,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            thankYouText = controller.text;
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
          ListTile(
            title: const Text('Ajouter signature/cachet dans PDF'),
            subtitle: Text(signaturePath ?? 'Aucun fichier sélectionné'),
            trailing: IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    signaturePath = result.files.single.path;
                  });
                }
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
          ListTile(
            title: const Text('Sauvegarder les données'),
            trailing: Icon(Icons.backup),
            onTap: () {
              // Action à ajouter plus tard
            },
          ),
          ListTile(
            title: const Text('Restaurer depuis un fichier'),
            trailing: const Icon(Icons.restore),
            onTap: () {
              // Action à ajouter plus tard
            },
          ),
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
