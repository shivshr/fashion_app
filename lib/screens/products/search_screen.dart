import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:fashion_app/providers/product_provider.dart';
import 'package:fashion_app/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  static const _categories = ['All', 'men', 'women', 'kids', 'ethnic'];
  String _selectedCat = 'All';
  RangeValues _priceRange = const RangeValues(0, 10000);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search products, categories...',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
            filled: false,
          ),
          onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((cat) {
                final isSelected = _selectedCat == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
  label: Text(
    cat == 'All' ? 'All' : cat.toUpperCase(),
    style: TextStyle(
      color: isSelected
          ? Colors.white
          : const Color(0xFF0F6C5C),
      fontWeight: FontWeight.w600,
    ),
  ),
  selected: isSelected,

  // light green for unselected
  backgroundColor: const Color(0xFFE6F7ED),

  // darker green when selected
  selectedColor: const Color(0xFF0F6C5C),

  checkmarkColor: Colors.white,

  side: const BorderSide(
    color: Color(0xFF0F6C5C),
    width: 1,
  ),

  onSelected: (_) {
    setState(() => _selectedCat = cat);
    ref.read(searchCategoryProvider.notifier).state =
        cat == 'All' ? null : cat;
  },
)
                );
              }).toList(),
            ),
          ),
          // Price range
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Price: ₹${_priceRange.start.toInt()} - ₹${_priceRange.end.toInt()}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                Expanded(
                  child: RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    activeColor: AppColors.primary,
                    onChanged: (v) {
                      setState(() => _priceRange = v);
                      ref.read(searchMinPriceProvider.notifier).state = v.start;
                      ref.read(searchMaxPriceProvider.notifier).state = v.end;
                    },
                  ),
                ),
              ],
            ),
          ),
          // Results
          Expanded(
            child: results.when(
              data: (products) {
                if (ref.read(searchQueryProvider).isEmpty && ref.read(searchCategoryProvider) == null) {
                  return const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_outlined, size: 64, color: AppColors.textHint),
                        SizedBox(height: 12),
                        Text('Search for products', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }
                if (products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => ProductCard(product: products[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
