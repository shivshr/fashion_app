import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/core/utils/validators.dart';
import 'package:fashion_app/models/product_model.dart';
import 'package:fashion_app/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final dynamic product;
  const AddProductScreen({this.product, super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _comparePriceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  String _category = 'men';
  String _subCategory = 'topwear';
  final List<String> _selectedSizes = [];
  final List<String> _imageUrls = [];
  bool _isFeatured = false;
  bool _isActive = true;
  bool _saving = false;

  bool get _isEditing => widget.product != null;
  ProductModel? get _product => widget.product as ProductModel?;

  final _categories = ['men', 'women', 'kids', 'ethnic'];
  final _subCategories = ['topwear', 'bottomwear', 'footwear', 'accessories', 'ethnic', 'sports'];
  final _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL', 'Free Size'];

  @override
  void initState() {
    super.initState();
    if (_isEditing && _product != null) {
      _nameCtrl.text = _product!.name;
      _descCtrl.text = _product!.description;
      _priceCtrl.text = _product!.price.toString();
      _comparePriceCtrl.text = _product!.comparePrice?.toString() ?? '';
      _stockCtrl.text = _product!.stock.toString();
      _tagsCtrl.text = _product!.tags.join(', ');
      _category = _product!.category;
      _subCategory = _product!.subCategory.isNotEmpty ? _product!.subCategory : 'topwear';
      _selectedSizes.addAll(_product!.sizes);
      _imageUrls.addAll(_product!.imageUrls);
      _isFeatured = _product!.isFeatured;
      _isActive = _product!.isActive;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _comparePriceCtrl.dispose();
    _stockCtrl.dispose();
    _tagsCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _addImageUrl() {
    final url = _imageUrlCtrl.text.trim();
    if (url.isEmpty) return;
    if (!url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid image URL starting with http'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() {
      _imageUrls.add(url);
      _imageUrlCtrl.clear();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one product image URL'), backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _saving = true);

    try {
      final productId = _isEditing ? _product!.productId : const Uuid().v4();
      final stock = int.parse(_stockCtrl.text);
      final tags = _tagsCtrl.text
          .split(',')
          .map((t) => t.trim().toLowerCase())
          .where((t) => t.isNotEmpty)
          .toList();
      tags.addAll(_nameCtrl.text.toLowerCase().split(' '));

      final product = ProductModel(
        productId: productId,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        comparePrice: _comparePriceCtrl.text.isNotEmpty ? double.tryParse(_comparePriceCtrl.text) : null,
        category: _category,
        subCategory: _subCategory,
        tags: tags.toSet().toList(),
        imageUrls: _imageUrls,
        sizes: _selectedSizes,
        stock: stock,
        inStock: stock > 0,
        stockStatus: ProductModel.deriveStockStatus(stock),
        isFeatured: _isFeatured,
        isActive: _isActive,
      );

      final service = ProductService();
      if (_isEditing) {
        await service.updateProduct(productId, product.toMap());
      } else {
        await service.addProduct(product);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Product updated!' : 'Product added!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image URLs Section ──────────────────────────────────
              const Text('Product Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text(
                'Paste image URLs from Google Images or any website',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),

              // URL input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageUrlCtrl,
                      decoration: InputDecoration(
                        hintText: 'https://example.com/image.jpg',
                        labelText: 'Image URL',
                        prefixIcon: const Icon(Icons.link),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (_) => _addImageUrl(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addImageUrl,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Image previews
              if (_imageUrls.isNotEmpty) ...[
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _imageUrls.length,
                    itemBuilder: (context, index) => Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                            image: DecorationImage(
                              image: NetworkImage(_imageUrls[index]),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              _imageUrls[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(Icons.broken_image, color: AppColors.textHint),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 10,
                          child: GestureDetector(
                            onTap: () => setState(() => _imageUrls.removeAt(index)),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: AppColors.error,
                              child: Icon(Icons.close, size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text('${_imageUrls.length} image(s) added', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],

              const SizedBox(height: 16),

              // ── How to get image URLs hint ──────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.tips_and_updates, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('How to get image URLs:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary)),
                    ]),
                    SizedBox(height: 6),
                    Text('1. Go to Google Images', style: TextStyle(fontSize: 12)),
                    Text('2. Right-click any image → "Copy image address"', style: TextStyle(fontSize: 12)),
                    Text('3. Paste the URL above and tap +', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Product Details ─────────────────────────────────────
              TextFormField(
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, 'Product name'),
                decoration: const InputDecoration(labelText: 'Product Name *'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                validator: (v) => Validators.required(v, 'Description'),
                decoration: const InputDecoration(labelText: 'Description *'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      validator: Validators.price,
                      decoration: const InputDecoration(labelText: 'Price (₹) *', prefixText: '₹'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _comparePriceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'MRP (₹)', prefixText: '₹'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockCtrl,
                keyboardType: TextInputType.number,
                validator: Validators.stock,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  helperText: 'Set 0 to mark Out of Stock',
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c.toUpperCase()))).toList(),
                      onChanged: (v) => setState(() => _category = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _subCategory,
                      decoration: const InputDecoration(labelText: 'Sub-Category'),
                      items: _subCategories.map((c) => DropdownMenuItem(value: c, child: Text(c.capitalize))).toList(),
                      onChanged: (v) => setState(() => _subCategory = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Sizes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _sizes.map((s) {
                  final sel = _selectedSizes.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: sel,
                    selectedColor: AppColors.primaryLight.withValues(alpha: 0.25),
                    onSelected: (v) => setState(() => v ? _selectedSizes.add(s) : _selectedSizes.remove(s)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tagsCtrl,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  hintText: 'cotton, casual, summer...',
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Featured Product'),
                value: _isFeatured,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isFeatured = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active (Visible to customers)'),
                value: _isActive,
                activeColor: AppColors.primary,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isEditing ? 'Update Product' : 'Add Product'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

extension on String {
  String get capitalize => isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}


