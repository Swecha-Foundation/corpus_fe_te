import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Custom Image Picker Utility Class
/// Provides enhanced functionality for image selection with permissions and error handling
class CustomImagePicker {
  static final ImagePicker _picker = ImagePicker();

  /// Pick a single image from camera
  static Future<XFile?> pickImageFromCamera({
    int imageQuality = 85,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // Check camera permission
      if (!await _checkCameraPermission()) {
        throw Exception('Camera permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        preferredCameraDevice: preferredCameraDevice,
      );

      return image;
    } catch (e) {
      throw Exception('Failed to capture image: $e');
    }
  }

  /// Pick a single image from gallery
  static Future<XFile?> pickImageFromGallery({
    int imageQuality = 85,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
  }) async {
    try {
      // Check storage permission
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      return image;
    } catch (e) {
      throw Exception('Failed to select image: $e');
    }
  }

  /// Pick multiple images from gallery
  static Future<List<XFile>> pickMultipleImages({
    int imageQuality = 85,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    int? maxImages,
  }) async {
    try {
      // Check storage permission
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      );

      // Limit number of images if specified
      if (maxImages != null && images.length > maxImages) {
        return images.take(maxImages).toList();
      }

      return images;
    } catch (e) {
      throw Exception('Failed to select images: $e');
    }
  }

  /// Pick video from camera
  static Future<XFile?> pickVideoFromCamera({
    Duration? maxDuration,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
  }) async {
    try {
      // Check camera permission
      if (!await _checkCameraPermission()) {
        throw Exception('Camera permission denied');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: maxDuration,
        preferredCameraDevice: preferredCameraDevice,
      );

      return video;
    } catch (e) {
      throw Exception('Failed to record video: $e');
    }
  }

  /// Pick video from gallery
  static Future<XFile?> pickVideoFromGallery({
    Duration? maxDuration,
  }) async {
    try {
      // Check storage permission
      if (!await _checkStoragePermission()) {
        throw Exception('Storage permission denied');
      }

      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: maxDuration,
      );

      return video;
    } catch (e) {
      throw Exception('Failed to select video: $e');
    }
  }

  /// Show image source selection dialog
  static Future<XFile?> showImageSourceDialog(
    BuildContext context, {
    int imageQuality = 85,
    double? maxWidth = 1920,
    double? maxHeight = 1080,
    String title = 'Select Image Source',
    String cameraText = 'Camera',
    String galleryText = 'Gallery',
    String cancelText = 'Cancel',
  }) async {
    return await showModalBottomSheet<XFile?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: cameraText,
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final image = await pickImageFromCamera(
                          imageQuality: imageQuality,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                        );
                        Navigator.pop(context, image);
                      } catch (e) {
                        _showErrorSnackBar(context, e.toString());
                      }
                    },
                  ),
                  _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: galleryText,
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        final image = await pickImageFromGallery(
                          imageQuality: imageQuality,
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                        );
                        Navigator.pop(context, image);
                      } catch (e) {
                        _showErrorSnackBar(context, e.toString());
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    cancelText,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get image file size in bytes
  static Future<int> getImageFileSize(XFile image) async {
    final File file = File(image.path);
    return await file.length();
  }

  /// Get image file size in MB
  static Future<double> getImageFileSizeInMB(XFile image) async {
    final int sizeInBytes = await getImageFileSize(image);
    return sizeInBytes / (1024 * 1024);
  }

  /// Validate image file size
  static Future<bool> validateImageSize(XFile image, {double maxSizeInMB = 5.0}) async {
    final double sizeInMB = await getImageFileSizeInMB(image);
    return sizeInMB <= maxSizeInMB;
  }

  /// Get supported image formats
  static List<String> getSupportedImageFormats() {
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  }

  /// Check if file is a valid image format
  static bool isValidImageFormat(String filePath) {
    final String extension = filePath.split('.').last.toLowerCase();
    return getSupportedImageFormats().contains(extension);
  }

  /// Delete temporary image file
  static Future<bool> deleteImageFile(XFile image) async {
    try {
      final File file = File(image.path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Check camera permission
  static Future<bool> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    return status.isGranted;
  }

  /// Check storage permission
  static Future<bool> _checkStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true; // iOS doesn't need explicit storage permission for gallery access
  }

  /// Build source option widget for dialog
  static Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show error snack bar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Image Picker Result Class
class ImagePickerResult {
  final List<XFile> images;
  final String? error;
  final bool isSuccess;

  ImagePickerResult({
    this.images = const [],
    this.error,
    this.isSuccess = false,
  });

  factory ImagePickerResult.success(List<XFile> images) {
    return ImagePickerResult(
      images: images,
      isSuccess: true,
    );
  }

  factory ImagePickerResult.error(String error) {
    return ImagePickerResult(
      error: error,
      isSuccess: false,
    );
  }
}

/// Enhanced Image Picker with batch operations
class BatchImagePicker {
  static Future<ImagePickerResult> pickImagesWithValidation({
    required BuildContext context,
    int maxImages = 10,
    double maxSizeInMB = 5.0,
    int imageQuality = 85,
    bool allowCamera = true,
    bool allowGallery = true,
  }) async {
    try {
      List<XFile> selectedImages = [];

      if (allowCamera && allowGallery) {
        // Show source selection
        final XFile? image = await CustomImagePicker.showImageSourceDialog(context);
        if (image != null) {
          selectedImages.add(image);
        }
      } else if (allowCamera) {
        final XFile? image = await CustomImagePicker.pickImageFromCamera();
        if (image != null) {
          selectedImages.add(image);
        }
      } else if (allowGallery) {
        selectedImages = await CustomImagePicker.pickMultipleImages(
          maxImages: maxImages,
          imageQuality: imageQuality,
        );
      }

      if (selectedImages.isEmpty) {
        return ImagePickerResult.error('No images selected');
      }

      // Validate images
      List<XFile> validImages = [];
      for (XFile image in selectedImages) {
        // Check file format
        if (!CustomImagePicker.isValidImageFormat(image.path)) {
          continue;
        }

        // Check file size
        if (await CustomImagePicker.validateImageSize(image, maxSizeInMB: maxSizeInMB)) {
          validImages.add(image);
        }
      }

      if (validImages.isEmpty) {
        return ImagePickerResult.error('No valid images found');
      }

      return ImagePickerResult.success(validImages);
    } catch (e) {
      return ImagePickerResult.error(e.toString());
    }
  }
}