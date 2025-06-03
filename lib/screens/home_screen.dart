import 'package:flutter/material.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/topic_selection_grid.dart';
import '../widgets/voice_recording_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarOpen = false;
  String _selectedTopic = '';

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _closeSidebar() {
    setState(() {
      _isSidebarOpen = false;
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 212, 104, 234),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleSidebar,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu,
                          color: Color.fromARGB(255, 228, 85, 244),
                          size: 24,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Profile icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E5A87),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Online status
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.cloud,
                          color: Color.fromARGB(255, 126, 200, 227),
                          size: 20,
                        ),
                        Text(
                          'Online',
                          style: TextStyle(
                            color: Color.fromARGB(255, 113, 189, 226),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'A',
                      style: TextStyle(
                        color: Color.fromARGB(255, 41, 74, 109),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content area
              Expanded(
                child: _selectedTopic.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'What do you want to speak about?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pick a category to get topic ideas. Then start recording',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 57, 95, 135),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Expanded(
                            child: TopicSelectionGrid(
                              onTopicSelected: _selectTopic,
                            ),
                          ),
                        ],
                      )
                    : const VoiceRecordingSection(),
              ),
            ],
          ),

          // Sidebar overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _closeSidebar,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Row(
                  children: [
                    SidebarMenu(onClose: _closeSidebar),
                    Expanded(child: Container()),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
