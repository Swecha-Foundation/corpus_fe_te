import 'package:flutter/material.dart';
import '../models/topic_category.dart';

class TopicSelectionGrid extends StatelessWidget {
  final Function(String) onTopicSelected;

  const TopicSelectionGrid({super.key, required this.onTopicSelected});

  @override
  Widget build(BuildContext context) {
    final categories = [
      TopicCategory(
        title: 'Essentials',
        icon: Icons.star,
        color: const Color(0xFF4CAF50),
      ),
      TopicCategory(
        title: 'Food',
        icon: Icons.restaurant,
        color: const Color(0xFFFF9800),
      ),
      TopicCategory(
        title: 'Events',
        icon: Icons.event,
        color: const Color(0xFF9C27B0),
      ),
      TopicCategory(
        title: 'Music',
        icon: Icons.music_note,
        color: const Color(0xFFE91E63),
      ),
      TopicCategory(
        title: 'Places',
        icon: Icons.place,
        color: const Color(0xFF795548),
      ),
      TopicCategory(
        title: 'People',
        icon: Icons.people,
        color: const Color(0xFF607D8B),
      ),
      TopicCategory(
        title: 'Animals',
        icon: Icons.pets,
        color: const Color(0xFF8BC34A),
      ),
      TopicCategory(
        title: 'Nature',
        icon: Icons.eco,
        color: const Color(0xFF4CAF50),
      ),
      TopicCategory(
        title: 'Movies',
        icon: Icons.movie,
        color: const Color(0xFFF44336),
      ),
      TopicCategory(
        title: 'Languages',
        icon: Icons.language,
        color: const Color(0xFF3F51B5),
      ),
      TopicCategory(
        title: 'Education',
        icon: Icons.school,
        color: const Color(0xFFFF5722),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () => onTopicSelected(category.title),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                    child: Icon(category.icon, color: category.color, size: 28),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        category.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E5A87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
