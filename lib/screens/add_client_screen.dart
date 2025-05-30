import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import 'client_list_screen.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  File? _imageFile;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _saveClient() {
    if (_formKey.currentState!.validate()) {
      final nom = _nomController.text.trim();
      final telephone = _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim();
      final imagePath = _imageFile?.path;

      final newClient = Provider.of<ClientProvider>(context, listen: false)
          .ajouterClient(nom, telephone, imagePath);

      setState(() {
        _nomController.clear();
        _telephoneController.clear();
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Client ajouté avec succès !')),
      );

      // Redirection vers ClientListScreen avec le client ajouté en surbrillance
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientListScreen(highlightedClientId: newClient.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clients = Provider.of<ClientProvider>(context).clients.reversed.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Client')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom du client',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telephoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Téléphone (optionnel)',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _imageFile == null
                          ? ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Choisir une photo (optionnel)'),
                      )
                          : Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _imageFile = null),
                            child: const Text('Supprimer la photo'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _saveClient,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Enregistrer le client'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text('Derniers clients ajoutés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            clients.isEmpty
                ? const Center(child: Text('Aucun client enregistré.'))
                : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clients.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final c = clients[index];
                return ListTile(
                  leading: c.imagePath != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(File(c.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                  )
                      : const Icon(Icons.account_circle_outlined, size: 40, color: Colors.grey),
                  title: Text(c.nom),
                  subtitle: Text(c.telephone ?? 'Pas de téléphone'),
                  trailing: Text('${c.solde.toStringAsFixed(2)} HTG', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ClientListScreen(highlightedClientId: c.id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}