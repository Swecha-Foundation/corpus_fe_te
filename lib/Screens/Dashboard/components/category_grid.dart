// Screens/Dashboard/components/category_grid.dart
import 'package:flutter/material.dart';
import '../../../constants.dart';

class CategoryGrid extends StatefulWidget {
  final String? selectedCategory;
  final Function(String?)? onCategorySelected;
  
  const CategoryGrid({
    Key? key,
    this.selectedCategory,
    this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryGrid> createState() => _CategoryGridState();
}

class _CategoryGridState extends State<CategoryGrid> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      CategoryItem(icon: '📚', title: 'Fables', gradient: _createGradient([const Color(0xFF667eea), const Color(0xFF764ba2)])),
      CategoryItem(icon: '🎉', title: 'Events', gradient: _createGradient([const Color(0xFFf093fb), const Color(0xFFf5576c)])),
      CategoryItem(icon: '🎵', title: 'Music', gradient: _createGradient([const Color(0xFF4facfe), const Color(0xFF00f2fe)])),
      CategoryItem(icon: '📍', title: 'Places', gradient: _createGradient([const Color(0xFF43e97b), const Color(0xFF38f9d7)])),
      CategoryItem(icon: '🍕', title: 'Food', gradient: _createGradient([const Color(0xFFfa709a), const Color(0xFFfee140)])),
      CategoryItem(icon: '👥', title: 'People', gradient: _createGradient([const Color(0xFFa8edea), const Color(0xFFfed6e3)])),
      CategoryItem(icon: '📖', title: 'Literature', gradient: _createGradient([const Color(0xFFffecd2), const Color(0xFFfcb69f)])),
      CategoryItem(icon: '🏛️', title: 'Architecture', gradient: _createGradient([const Color(0xFFa18cd1), const Color(0xFFfbc2eb)])),
      CategoryItem(icon: '🎯', title: 'Skills', gradient: _createGradient([const Color(0xFF6a11cb), const Color(0xFF2575fc)])),
      CategoryItem(icon: '🖼️', title: 'Images', gradient: _createGradient([const Color(0xFFfad0c4), const Color(0xFFfad0c4)])),
      CategoryItem(icon: '🎭', title: 'Culture', gradient: _createGradient([const Color(0xFFa1c4fd), const Color(0xFFc2e9fb)])),
      CategoryItem(icon: '🌸', title: 'Flora & fauna', gradient: _createGradient([const Color(0xFFffecd2), const Color(0xFFfcb69f)])),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    // ignore: deprecated_member_use
                    colors: [kPrimaryColor.withOpacity(0.1), kPrimaryColor.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '✨ Categories',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kPrimaryColor,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.selectedCategory != null)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.selectedCategory!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final animationDelay = index * 0.1;
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.5),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        animationDelay,
                        1.0,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  );
                  
                  final fadeAnimation = Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(
                        animationDelay,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                  );

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
          ),
        ],
      ),
    );
  }

  LinearGradient _createGradient(List<Color> colors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  Widget _buildCategoryTile(BuildContext context, CategoryItem category) {
    final isSelected = widget.selectedCategory == category.title;
    
    return GestureDetector(
      onTap: () {
        // Toggle selection: if already selected, deselect; otherwise, select
        final newSelection = isSelected ? null : category.title;
        
        // Call the parent callback to update the state
        if (widget.onCategorySelected != null) {
          widget.onCategorySelected!(newSelection);
        }
        
        // Add haptic feedback
        // HapticFeedback.lightImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(category.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(isSelected ? 'Deselected: ${category.title}' : 'Selected: ${category.title}'),
              ],
            ),
            backgroundColor: kPrimaryColor,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..scale(isSelected ? 1.05 : 1.0),
        decoration: BoxDecoration(
          gradient: category.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                // ignore: deprecated_member_use
                ? kPrimaryColor.withOpacity(0.3)
                // ignore: deprecated_member_use
                : Colors.black.withOpacity(0.1),
              offset: const Offset(0, 8),
              blurRadius: isSelected ? 20 : 15,
            ),
          ],
          border: isSelected 
            ? Border.all(color: Colors.white, width: 3)
            : null,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.2),
                // ignore: deprecated_member_use
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryItem {
  final String icon;
  final String title;
  final LinearGradient gradient;

  CategoryItem({
    required this.icon,
    required this.title,
    required this.gradient,
  });
}