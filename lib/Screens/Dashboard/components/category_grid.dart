// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../constants.dart'; // Make sure you have your constants file

/// A data class for holding category information including display colors and an icon.
class CategoryInfo {
  final String apiName; // A unique identifier for the category
  final String englishName;
  final String englishDescription;
  final String teluguName;
  final String teluguDescription;
  final List<Color> gradientColors; // Colors for the background gradient
  final IconData icon; // The display icon for the category

  CategoryInfo({
    required this.apiName,
    required this.englishName,
    required this.englishDescription,
    required this.teluguName,
    required this.teluguDescription,
    required this.gradientColors,
    required this.icon,
  });
}

class CategoryGrid extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;
  final bool isEnglish;

  const CategoryGrid({
    Key? key,
    this.selectedCategory,
    this.onCategorySelected,
    required this.isEnglish,
  }) : super(key: key);

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> {
  // Static list of categories with descriptions, unique colors, and icons.
  final List<CategoryInfo> _categories = [
    CategoryInfo(
      apiName: 'folk_tales',
      englishName: 'Folk Tales',
      englishDescription: 'Stories passed orally across generations',
      teluguName: 'జానపద కథలు',
      teluguDescription: 'తరతరాలుగా చెప్పబడుతున్న కథలు',
      gradientColors: [const Color(0xFF667eea), const Color(0xFF764ba2)],
      icon: Icons.auto_stories_outlined,
    ),
    CategoryInfo(
      apiName: 'folk_songs',
      englishName: 'Folk Songs',
      englishDescription:
          'Documenting traditional music reflecting the cultural heritage of the region',
      teluguName: 'జానపద పాటలు',
      teluguDescription:
          'ప్రాంతం యొక్క సాంస్కృతిక వారసత్వాన్ని ప్రతిబింబించే సాంప్రదాయ సంగీతాన్ని నమోదు చేయడం',
      gradientColors: [const Color(0xFF4facfe), const Color(0xFF00f2fe)],
      icon: Icons.music_note_outlined,
    ),
    CategoryInfo(
      apiName: 'traditional_skills',
      englishName: 'Traditional Skills',
      englishDescription:
          'Gathering data on local artisanal and craft practices (e.g., weaving, pottery)',
      teluguName: 'సాంప్రదాయ నైపుణ్యాలు',
      teluguDescription:
          'స్థానిక చేతివృత్తులు మరియు నైపుణ్యాల (ఉదా., నేత, కుండలు) పై డేటాను సేకరించడం',
      gradientColors: [const Color(0xFF43e97b), const Color(0xFF38f9d7)],
      icon: Icons.handyman_outlined,
    ),
    CategoryInfo(
      apiName: 'local_cultural_history',
      englishName: 'Local Cultural History',
      englishDescription:
          'Collecting data on cultural events, rituals, and customs that define the local communities',
      teluguName: 'స్థానిక సాంస్కృతిక చరిత్ర',
      teluguDescription:
          'స్థానిక సంఘాలను నిర్వచించే సాంస్కృతిక కార్యక్రమాలు, ఆచారాలు మరియు సంప్రదాయాలపై డేటాను సేకరించడం',
      gradientColors: [const Color(0xFFf093fb), const Color(0xFFf5576c)],
      icon: Icons.groups_2_outlined,
    ),
    CategoryInfo(
      apiName: 'local_history',
      englishName: 'Local History',
      englishDescription:
          'Compiling historical events and figures significant to your region',
      teluguName: 'స్థానిక చరిత్ర',
      teluguDescription:
          'మీ ప్రాంతానికి ముఖ్యమైన చారిత్రక సంఘటనలు మరియు వ్యక్తులను సంకలనం చేయడం',
      gradientColors: [const Color(0xFFa18cd1), const Color(0xFFfbc2eb)],
      icon: Icons.account_balance_outlined,
    ),
    CategoryInfo(
      apiName: 'food_agriculture',
      englishName: 'Food & Agriculture',
      englishDescription:
          'Documenting traditional recipes and cooking methods, along with their cultural significance. Include recipes, tools, practices',
      teluguName: 'ఆహారం & వ్యవసాయం',
      teluguDescription:
          'సాంప్రదాయ వంటకాలు మరియు వంట పద్ధతులను, వాటి సాంస్కృతిక ప్రాముఖ్యతతో పాటు నమోదు చేయడం. వంటకాలు, ఉపకరణాలు, పద్ధతులను చేర్చండి',
      gradientColors: [const Color(0xFFfa709a), const Color(0xFFfee140)],
      icon: Icons.agriculture_outlined,
    ),
    CategoryInfo(
      apiName: 'newspapers_pre_1980',
      englishName: 'Newspapers older than 1980s',
      englishDescription:
          'From libraries or archives, scanned or physical copies',
      teluguName: '1980ల కంటే పాత వార్తాపత్రికలు',
      teluguDescription:
          'గ్రంథాలయాలు లేదా ఆర్కైవ్‌ల నుండి, స్కాన్ చేయబడిన లేదా భౌతిక కాపీలు',
      gradientColors: [const Color(0xFFa8edea), const Color(0xFFfed6e3)],
      icon: Icons.newspaper_outlined,
    ),
    CategoryInfo(
      apiName: 'flora_fauna',
      englishName: 'Flora & Fauna',
      englishDescription:
          'Document significant plants, trees, animals, and birds native to your region',
      teluguName: 'వృక్షజాలం & జంతుజాలం',
      teluguDescription:
          'మీ ప్రాంతానికి చెందిన ముఖ్యమైన మొక్కలు, చెట్లు, జంతువులు మరియు పక్షులను నమోదు చేయండి',
      gradientColors: [const Color(0xFF85ffbd), const Color(0xFFfffb7d)],
      icon: Icons.forest_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Lighter background for the whole widget
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
              widget.isEnglish ? '✨ Categories' : '✨ వర్గాలు',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kPrimaryColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildResponsiveGrid(),
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
          crossAxisCount = 4; // For large desktops
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 3; // For desktops/tablets
        } else if (constraints.maxWidth > 550) {
          crossAxisCount = 2; // For large phones
        } else {
          crossAxisCount = 1; // For small phones
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 2.5, // Adjusted for new layout
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryTile(context, _categories[index]);
          },
        );
      },
    );
  }

  /// Builds a single, interactive category tile with a light skin.
  Widget _buildCategoryTile(BuildContext context, CategoryInfo category) {
    final isSelected = widget.selectedCategory == category.apiName;
    final String name =
        widget.isEnglish ? category.englishName : category.teluguName;
    final String description = widget.isEnglish
        ? category.englishDescription
        : category.teluguDescription;

    return GestureDetector(
      onTap: () {
        final newSelection = isSelected ? null : category.apiName;
        widget.onCategorySelected?.call(newSelection);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white, // Light background for the tile
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: kPrimaryColor, width: 2) // Highlight border
              : Border.all(color: Colors.grey.shade200), // Default border
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? kPrimaryColor.withOpacity(0.15)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: category.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            // Text Content
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black87, // Black text for readability
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '$name: ',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
