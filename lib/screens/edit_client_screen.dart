import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/client.dart';
import '../providers/client_provider.dart';

class EditClientScreen extends StatefulWidget {
  final Client client;

  const EditClientScreen({super.key, required this.client});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _telephoneController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.client.nom);
    _telephoneController = TextEditingController(text: widget.client.telephone ?? '');
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      final nom = _nomController.text.trim();
      final telephone = _telephoneController.text.trim().isEmpty ? null : _telephoneController.text.trim();
      final imagePath = _imageFile?.path ?? widget.client.imagePath;

      Provider.of<ClientProvider>(context, listen: false).modifierClient(
        widget.client.id,
        nom,
        telephone,
        imagePath,
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir le nom du client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le Client')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nomController,
                  decoration: const InputDecoration(labelText: 'Nom du client'),
                  validator: (value) => value!.isEmpty ? 'Champ obligatoire' : null,
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone (optionnel)'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),
                _imageFile != null
                    ? Column(
                  children: [
                    Image.file(_imageFile!, height: 150),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                      child: const Text('Supprimer la photo'),
                    ),
                  ],
                )
                    : widget.client.imagePath != null
                    ? Column(
                  children: [
                    Image.file(File(widget.client.imagePath!), height: 150),
                    TextButton(
                      onPressed: _pickImage,
                      child: const Text('Changer la photo'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                          widget.client.imagePath = null; // Efface l'image
                        });
                      },
                      child: const Text('Supprimer la photo'),
                    ),
                  ],
                )
                    : ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Choisir une photo (optionnel)'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Enregistrer les modifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
