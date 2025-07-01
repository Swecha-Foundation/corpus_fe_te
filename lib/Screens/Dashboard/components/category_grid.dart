// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../responsive.dart'; // Make sure you have your Responsive helper
import '../../../services/category_api_service.dart'; // Import your API helper

class CategoryGrid extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;
  final bool isEnglish; // Add language state

  const CategoryGrid({
    Key? key,
    this.selectedCategory,
    this.onCategorySelected,
    required this.isEnglish, // Require language state
  }) : super(key: key);

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  List<CategoryItem> categories = [];
  bool isLoading = true;
  String? errorMessage;

  // Map of category names to their icons and gradients
  final Map<String, Map<String, dynamic>> categoryMapping = {
    'fables': {'icon': '📚', 'gradient': [const Color(0xFF667eea), const Color(0xFF764ba2)]},
    'events': {'icon': '🎉', 'gradient': [const Color(0xFFf093fb), const Color(0xFFf5576c)]},
    'music': {'icon': '🎵', 'gradient': [const Color(0xFF4facfe), const Color(0xFF00f2fe)]},
    'places': {'icon': '📍', 'gradient': [const Color(0xFF43e97b), const Color(0xFF38f9d7)]},
    'food': {'icon': '🍕', 'gradient': [const Color(0xFFfa709a), const Color(0xFFfee140)]},
    'people': {'icon': '👥', 'gradient': [const Color(0xFFa8edea), const Color(0xFFfed6e3)]},
    'literature': {'icon': '📖', 'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)]},
    'architecture': {'icon': '🏛️', 'gradient': [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)]},
    'skills': {'icon': '🎯', 'gradient': [const Color(0xFF6a11cb), const Color(0xFF2575fc)]},
    'images': {'icon': '🖼️', 'gradient': [const Color(0xFFfad0c4), const Color(0xFFfad0c4)]},
    'culture': {'icon': '🎭', 'gradient': [const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)]},
    'flora_&_fauna': {'icon': '🌸', 'gradient': [const Color(0xFFffecd2), const Color(0xFFfcb69f)]},
    'education': {'icon': '🎓', 'gradient': [const Color(0xFF89f7fe), const Color(0xFF66a6ff)]},
    'vegetation': {'icon': '🌿', 'gradient': [const Color(0xFF85ffbd), const Color(0xFFfffb7d)]},
  };

  // Map for Telugu translations
  final Map<String, String> _categoryTitleMapping = {
    'fables': 'కథలు',
    'events': 'సంఘటనలు',
    'music': 'సంగీతం',
    'places': 'ప్రదేశాలు',
    'food': 'ఆహారం',
    'people': 'ప్రజలు',
    'literature': 'సాహిత్యం',
    'architecture': 'వాస్తుశిల్పం',
    'skills': 'నైపుణ్యాలు',
    'images': 'చిత్రాలు',
    'culture': 'సంస్కృతి',
    'flora_&_fauna': 'వృక్షజాలం & జంతుజాలం',
    'education': 'విద్య',
    'vegetation': 'వృక్షసంపద',
  };


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fetchCategories();
  }
  
  @override
  void didUpdateWidget(covariant CategoryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refetch categories if the language changes
    if (widget.isEnglish != oldWidget.isEnglish) {
      _fetchCategories();
    }
  }

  Future<void> _fetchCategories() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiHelper.getCategories();

      if (result['success']) {
        final List<dynamic> categoriesData = result['data'];

        setState(() {
          categories = categoriesData.map((categoryData) {
            final String name = categoryData['name'] ?? '';
            // Get the English title from the API
            final String englishTitle = categoryData['title'] ?? name;
            // Determine the title based on the selected language
            final String title = widget.isEnglish
                ? englishTitle
                : (_categoryTitleMapping[name] ?? englishTitle);

            final mapping = categoryMapping[name] ??
                {
                  'icon': '📋',
                  'gradient': [
                    const Color(0xFF667eea),
                    const Color(0xFF764ba2)
                  ]
                };
            return CategoryItem(
              icon: mapping['icon'],
              title: title,
              apiName: englishTitle, // Store the original English name for selection logic
              gradient: _createGradient(mapping['gradient']),
            );
          }).toList();
          isLoading = false;
          errorMessage = null;
        });
        _animationController.forward(from: 0.0);
      } else {
        setState(() {
          isLoading = false;
          errorMessage = result['message'] ?? 'Failed to load categories';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred while loading categories';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
            blurRadius: 30,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      kPrimaryColor.withOpacity(0.1),
                      kPrimaryColor.withOpacity(0.05)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isEnglish ? '✨ Categories' : '✨ వర్గాలు', // Localized header
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Conditional content based on state
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            )
          else if (errorMessage != null)
            _buildErrorState()
          else
            _buildResponsiveGrid(), // Use the new responsive grid builder
        ],
      ),
    );
  }
  
  /// Builds the responsive grid using LayoutBuilder.
  Widget _buildResponsiveGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on the available width.
        final int crossAxisCount;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 6; // For large desktops
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 5; // For desktops
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 4; // For tablets
        } else if (constraints.maxWidth > 400) {
          crossAxisCount = 3; // For large phones
        } else {
          crossAxisCount = 2; // For small phones
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // Dynamically set column count
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95, // Adjusted for better look
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            // Animation for each grid item
            return AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final animationDelay = (index * 0.05).clamp(0.0, 1.0);
                final slideAnimation = Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(animationDelay, 1.0, curve: Curves.easeOutCubic),
                ));
                final fadeAnimation = Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(animationDelay, 1.0, curve: Curves.easeOut),
                ));

                return SlideTransition(
                  position: slideAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: _buildCategoryTile(context, categories[index]),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Builds the error state widget with a retry button.
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCategories, // Call fetch again on retry
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(widget.isEnglish ? 'Retry' : 'మళ్లీ ప్రయత్నించండి'),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Creates a LinearGradient from a list of colors.
  LinearGradient _createGradient(List<Color> colors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  /// Builds a single, interactive category tile.
  Widget _buildCategoryTile(BuildContext context, CategoryItem category) {
    final isSelected = widget.selectedCategory == category.apiName;

    return GestureDetector(
      onTap: () {
        final newSelection = isSelected ? null : category.apiName;
        widget.onCategorySelected?.call(newSelection);
        
        final String selectedText = widget.isEnglish ? 'Selected' : 'ఎంచుకున్నవి';
        final String deselectedText = widget.isEnglish ? 'Deselected' : 'ఎంపిక తీసివేయబడింది';

        // Optional: Show a snackbar on selection
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Text(category.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(isSelected ? '$deselectedText: ${category.title}' : '$selectedText: ${category.title}'),
          ]),
          backgroundColor: kPrimaryColor,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: category.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected ? kPrimaryColor.withOpacity(0.4) : Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
              blurRadius: isSelected ? 20 : 15,
            ),
          ],
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.8), width: 3) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(category.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                category.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black38)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A data class for a category item.
class CategoryItem {
  final String icon;
  final String title;
  final String apiName; // The original name from the API for consistent selection
  final LinearGradient gradient;

  CategoryItem({
    required this.icon,
    required this.title,
    required this.apiName,
    required this.gradient,
  });
}
