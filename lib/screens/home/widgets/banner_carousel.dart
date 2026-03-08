import 'package:carousel_slider/carousel_slider.dart';
import 'package:fashion_app/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'title': "Men's Special\nCollection",
      'subtitle': 'Men Special Collection',
      'discount': '10% OFF',
      'gradient': [Color(0xFF1A1A2E), Color(0xFF16213E)],
    },
    {
      'title': "Women's\nTrending",
      'subtitle': 'New Arrivals',
      'discount': '15% OFF',
      'gradient': [Color(0xFF6B2737), Color(0xFF9B4DCA)],
    },
    {
      'title': "Kids Festive\nCollection",
      'subtitle': 'Cute Styles',
      'discount': '20% OFF',
      'gradient': [Color(0xFF005C5C), Color(0xFF008080)],
    },
    {
    'image': 'assets/images/categories/banner1.png',
  },
  {
    'image': 'assets/images/categories/banner2.png',
  },
  {
    'image': 'assets/images/categories/banner3.png',
  },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: _banners.length,
          options: CarouselOptions(
            height: 160, // better banner height
            viewportFraction: 0.92, // slight side preview
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayCurve: Curves.easeInOut,
            enlargeCenterPage: false,
            onPageChanged: (i, _) => setState(() => _current = i),
          ),
          itemBuilder: (context, index, _) {
  final b = _banners[index];

  /// IMAGE BANNER
  if (b.containsKey('image')) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          b['image'],
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  /// GRADIENT BANNER (your original UI)
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: List<Color>.from(b['gradient']),
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 180,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              color: Colors.white.withOpacity(0.06),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  b['title'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                b['subtitle'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                b['discount'],
                style: const TextStyle(
                  color: AppColors.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _banners.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == _current
                    ? AppColors.primary
                    : AppColors.divider,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}