// token_debug_widget.dart
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/token_storage_service.dart';
import '../../services/auth_service.dart';

class TokenDebugWidget extends StatefulWidget {
  const TokenDebugWidget({Key? key}) : super(key: key);

  @override
  State<TokenDebugWidget> createState() => _TokenDebugWidgetState();
}

class _TokenDebugWidgetState extends State<TokenDebugWidget> {
  String? _token;
  // ignore: unused_field
  String? _authHeader;
  Map<String, String?> _userData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenData();
  }

  Future<void> _loadTokenData() async {
    setState(() => _isLoading = true);
    
    try {
      final token = await TokenStorageService.getAuthToken();
      final authHeader = await TokenStorageService.getAuthorizationHeader();
      final userData = await TokenStorageService.getUserData();
      
      setState(() {
        _token = token;
        _authHeader = authHeader;
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading token data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _copyToClipboard(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$label copied to clipboard'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testApiConnection() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await ApiService.testConnection();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['success'] 
                ? 'API connection successful' 
                : 'API connection failed: ${result['message']}'
            ),
            backgroundColor: result['success'] ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error testing connection: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Token Debug Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadTokenData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Authentication Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _token != null ? Icons.verified : Icons.error,
                          color: _token != null ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _token != null ? 'Authenticated' : 'Not Authenticated',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _token != null ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_userData['tokenExpiry'] != null)
                      Text(
                        'Token expires: ${_userData['tokenExpiry']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),

            // Token Information
            if (_token != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Access Token',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_token!.substring(0, 50)}...',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _copyToClipboard(_token!, 'Token'),
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy Token'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _copyToClipboard(
                                    'Bearer $_token',
                                    'Authorization Header'
                                  ),
                                  icon: const Icon(Icons.security, size: 16),
                                  label: const Text('Copy Bearer Token'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // API Testing Section
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Testing Instructions',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Steps to authorize in Swagger UI:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('1. Open: https://backend2.swecha.org/docs#'),
                            const Text('2. Click the "Authorize" button (🔒)'),
                            const Text('3. Paste the Bearer token (copied above)'),
                            const Text('4. Click "Authorize"'),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    const url = 'https://backend2.swecha.org/docs#';
                                    await _copyToClipboard(url, 'API Documentation URL');
                                  },
                                  icon: const Icon(Icons.open_in_browser, size: 16),
                                  label: const Text('Copy API URL'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _testApiConnection,
                                  icon: const Icon(Icons.wifi_protected_setup, size: 16),
                                  label: const Text('Test Connection'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // User Data Section
            if (_userData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Information',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._userData.entries.where((entry) => entry.value != null).map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  '${entry.key}:',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.key == 'token' && entry.value!.length > 20
                                      ? '${entry.value!.substring(0, 20)}...'
                                      : entry.value!,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Debug Actions
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Debug Actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await TokenStorageService.debugPrintAuthData();
                              if (mounted) {
                                _showSnackBar('Auth data printed to console', Colors.blue);
                              }
                            },
                            icon: const Icon(Icons.print, size: 16),
                            label: const Text('Print Debug Info'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final cleared = await TokenStorageService.clearAuthData();
                              if (mounted) {
                                _showSnackBar(
                                  cleared ? 'Auth data cleared' : 'Failed to clear data',
                                  cleared ? Colors.orange : Colors.red,
                                );
                                if (cleared) {
                                  _loadTokenData();
                                }
                              }
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Clear Auth Data'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}