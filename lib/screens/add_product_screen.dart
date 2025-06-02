import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'product_list_screen.dart'; // Importé pour la navigation

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prixController = TextEditingController();
  final _newCategoryController = TextEditingController();
  bool _isNewCategory = false;
  String? _selectedCategory;
  File? _imageFile;

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final categorie = _isNewCategory ? _newCategoryController.text : _selectedCategory;
      if (categorie == null || categorie.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez choisir ou saisir une catégorie.')),
        );
        return;
      }

      final prix = double.tryParse(_prixController.text) ?? 0;

      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.ajouterProduit(categorie, prix, 0, _imageFile?.path);

      setState(() {
        _selectedCategory = null;
        _isNewCategory = false;
        _newCategoryController.clear();
        _prixController.clear();
        _imageFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produit ajouté avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un Produit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Formulaire
            Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                              const SizedBox(height: 10),
                              _isNewCategory
                                  ? TextFormField(
                                controller: _newCategoryController,
                                decoration: const InputDecoration(
                                  labelText: 'Nouvelle Catégorie',
                                  prefixIcon: Icon(Icons.category),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                              )
                                  : DropdownSearch<String>(
                                items: categories.toList(),
                                selectedItem: _selectedCategory,
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedCategory = value;
                                    });
                                  }
                                },
                                validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
                                dropdownDecoratorProps: const DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                    labelText: 'Catégorie',
                                    prefixIcon: Icon(Icons.category_outlined),
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                ),
                                popupProps: const PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      labelText: 'Rechercher...',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  constraints: BoxConstraints(maxHeight: 300),
                                ),
                                dropdownButtonProps: const DropdownButtonProps(
                                  icon: Icon(Icons.arrow_drop_down),
                                ),
                              )

                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _prixController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Prix unitaire (HTG)',
                          prefixIcon: Icon(Icons.attach_money),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Champ obligatoire' : null,
                      ),
                      const SizedBox(height: 16),
                      _imageFile == null
                          ? ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_a_photo),
                        label: const Text('Choisir une image (optionnel)'),
                      )
                          : Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(_imageFile!, height: 150, fit: BoxFit.cover),
                          ),
                          TextButton(
                            onPressed: () => setState(() => _imageFile = null),
                            child: const Text('Supprimer l\'image'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _saveProduct,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Enregistrer le produit'),
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
            const Text('Derniers produits ajoutés', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Consumer<ProductProvider>(
              builder: (context, productProvider, _) {
                final produits = productProvider.produits.reversed.take(5).toList();
                if (produits.isEmpty) {
                  return const Center(child: Text('Aucun produit enregistré.'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: produits.length,
                  itemBuilder: (context, index) {
                    final p = produits[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                        child: ListTile(
                          leading: p.imagePath != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(File(p.imagePath!), width: 50, height: 50, fit: BoxFit.cover),
                          )
                              : const Icon(Icons.shopping_bag_outlined, size: 40, color: Colors.grey),
                          title: Text(p.codeProduit),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${p.prixUnitaire} HTG | Stock : ${p.stock}'),
                              Text('Catégorie : ${p.categorie}'),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductListScreen(highlightProductId: p.id),
                              ),
                            );
                          },
                        ),
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
