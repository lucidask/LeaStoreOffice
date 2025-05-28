import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/produit.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Produit produit;

  const EditProductScreen({super.key, required this.produit});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _categorieController;
  late TextEditingController _prixController;
  late TextEditingController _stockController;
  File? _imageFile;
  String? _selectedCategory;
  final _newCategoryController = TextEditingController();
  bool _isNewCategory = false;


  @override
  void initState() {
    super.initState();
    _categorieController = TextEditingController(text: widget.produit.categorie);
    _prixController = TextEditingController(text: widget.produit.prixUnitaire.toString());
    _stockController = TextEditingController(text: widget.produit.stock.toString());
    _selectedCategory = widget.produit.categorie;

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
      final categorie = _isNewCategory ? _newCategoryController.text : _selectedCategory;

      if (categorie == null || categorie.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir ou saisir une catégorie.')),
        );
        return;
      }

      Provider.of<ProductProvider>(context, listen: false).modifierProduit(
        widget.produit.id,
        widget.produit.codeProduit, // ✅ Le code produit ne change pas
        categorie,
        double.parse(_prixController.text),
        _imageFile?.path ?? widget.produit.imagePath,
      );

      Navigator.pop(context);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le Produit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text('Code produit : ${widget.produit.codeProduit}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Consumer<ProductProvider>(
                  builder: (context, productProvider, _) {
                    final categories = productProvider.getCategories();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _isNewCategory ? 'Nouvelle Catégorie' : 'Catégorie existante',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isNewCategory = !_isNewCategory;
                                });
                              },
                              child: Text(_isNewCategory ? 'Choisir' : 'Créer'),
                            ),
                          ],
                        ),
                        _isNewCategory
                            ? TextFormField(
                          controller: _newCategoryController,
                          decoration: const InputDecoration(labelText: 'Nouvelle Catégorie'),
                          validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                        )
                            : DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(labelText: 'Catégorie'),
                          items: categories
                              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
                        ),
                      ],
                    );
                  },
                ),
                TextFormField(
                  controller: _prixController,
                  decoration: const InputDecoration(labelText: 'Prix'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                ),
                Text('Stock actuel : ${widget.produit.stock}'),
                const SizedBox(height: 10),
                _imageFile == null
                    ? (widget.produit.imagePath != null
                    ? Image.file(File(widget.produit.imagePath!), height: 100)
                    : const Text('Pas d\'image'))
                    : Image.file(_imageFile!, height: 100),
                TextButton(onPressed: _pickImage, child: const Text('Changer l\'image')),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Sauvegarder les modifications'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
