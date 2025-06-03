import 'package:flutter/material.dart';

class SidebarMenu extends StatelessWidget {
  final VoidCallback onClose;

  const SidebarMenu({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Close button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            child: Row(
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF2196F3),
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Close',
                  style: TextStyle(
                    color: Color(0xFF2196F3),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuItem(
                  icon: Icons.dashboard,
                  title: 'Dashboard',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.mic,
                  title: 'Recordings',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.person,
                  title: 'Profile',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.feedback,
                  title: 'Feedback',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.help,
                  title: 'FAQs',
                  color: const Color(0xFF2196F3),
                ),
                const SizedBox(height: 8),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: 'Help doc',
                  color: const Color(0xFF2196F3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
