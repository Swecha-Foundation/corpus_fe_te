// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Conditional imports for web only
import 'dart:html' as html show IFrameElement;
import 'dart:ui_web' as ui_web show platformViewRegistry;

class MapPlaceholderScreen extends StatefulWidget {
  const MapPlaceholderScreen({super.key});

  @override
  State<MapPlaceholderScreen> createState() => _MapPlaceholderScreenState();
}

class _MapPlaceholderScreenState extends State<MapPlaceholderScreen> {
  bool isLoading = true;
  bool hasError = false;
  String viewId = 'map-html-view-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _loadMapForWeb();
    } else {
      // For non-web platforms, show fallback immediately
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadMapForWeb() {
    if (!kIsWeb) return;

    try {
      // Create iframe element
      final iframe = html.IFrameElement()
        ..src = 'assets/Files/Map.html' // Load from assets instead of srcdoc
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';

      // Register the view factory
      print('File loaded sucessfully');
      ui_web.platformViewRegistry.registerViewFactory(
        viewId,
        (int viewId) => iframe,
      );

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error setting up web view: $e');
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Interactive Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(122, 191, 94, 255),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Web view for Flutter Web
          if (kIsWeb && !hasError) HtmlElementView(viewType: viewId),

          // Fallback for non-web platforms or errors
          if (!kIsWeb || hasError) _buildFallbackView(),

          // Loading indicator
          if (isLoading)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Color(0xFF667eea)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading Interactive Map...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            const Color.fromARGB(146, 191, 94, 255),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    hasError ? Icons.error_outline : Icons.map_rounded,
                    size: 80,
                    color: hasError
                        ? Colors.red.shade400
                        : const Color.fromARGB(255, 190, 94, 255),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasError ? 'Map Load Error' : 'Interactive Map',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: hasError
                          ? Colors.red.shade700
                          : const Color.fromARGB(255, 190, 94, 255),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasError
                        ? 'Unable to load map content'
                        : kIsWeb
                            ? 'Map loading...'
                            : 'Map available on web platform',
                    style: TextStyle(
                      fontSize: 16,
                      color: hasError
                          ? Colors.red.shade600
                          : const Color.fromARGB(255, 190, 94, 255),
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isLoading = true;
                          hasError = false;
                        });
                        _loadMapForWeb();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 190, 94, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
