import 'package:flutter/material.dart';
import 'package:org.swecha.telugu_corpus_collection/Screens/Welcome/welcome_screen.dart';
import 'package:org.swecha.telugu_corpus_collection/constants.dart';
import 'package:org.swecha.telugu_corpus_collection/services/token_storage_service.dart';
import 'package:org.swecha.telugu_corpus_collection/Screens/Dashboard/dashboard_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize WebView Platform
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    WebViewPlatform.instance = WebKitWebViewPlatform();
  } else {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Auth',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFBE5EFF),
            shape: const StadiumBorder(),
            maximumSize: const Size(double.infinity, 56),
            minimumSize: const Size(double.infinity, 56),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: kPrimaryLightColor,
          iconColor: kPrimaryColor,
          prefixIconColor: kPrimaryColor,
          contentPadding: EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String _userName = '';
  String _phoneNumber = '';

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('Checking authentication status...');
      
      // Add a small delay to ensure SharedPreferences is ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Debug: Print current auth data
      await TokenStorageService.debugPrintAuthData();
      
      final isAuth = await TokenStorageService.isAuthenticated();
      print('Authentication result: $isAuth');
      
      if (isAuth) {
        // Get user data if authenticated
        final userData = await TokenStorageService.getUserData();
        _userName = userData['userName'] ?? 'User';
        _phoneNumber = userData['phoneNumber'] ?? '';
        
        print('User authenticated: $_userName, $_phoneNumber');
      } else {
        print('User not authenticated');
        // Ensure clean state if not authenticated
        await TokenStorageService.clearAuthData();
      }
      
      if (mounted) {
        setState(() {
          _isAuthenticated = isAuth;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error checking auth status: $e');
      // If there's any error, default to not authenticated and clear data
      await TokenStorageService.clearAuthData();
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kPrimaryColor, kPrimaryColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withOpacity(0.3),
                      offset: const Offset(0, 8),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
              ),
              const SizedBox(height: 16),
              const Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: kPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _isAuthenticated 
        ? DashboardScreen(
            userName: _userName,
            phoneNumber: _phoneNumber,
          )
        : const WelcomeScreen();
  }
}
