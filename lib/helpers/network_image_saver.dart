import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_constants.dart';
import '../widgets/snackbars.dart';

class NetworkImageSaver {
  static Future<void> saveToGallery(String? imageUrl) async {
    final resolvedUrl = MediaUrlHelper.resolve(imageUrl);
    if (resolvedUrl == null) {
      CustomSnackBar.failure(message: 'Image URL is not available');
      return;
    }

    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      CustomSnackBar.failure(
        message: 'Gallery permission is required to save this image',
      );
      return;
    }

    try {
      final response = await http.get(Uri.parse(resolvedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.bodyBytes),
        quality: 100,
        name: 'swatcher_${DateTime.now().millisecondsSinceEpoch}',
      );

      final saved =
          result is Map
              ? result['isSuccess'] == true || result['filePath'] != null
              : result != null;

      if (!saved) {
        throw Exception('Image could not be saved');
      }

      CustomSnackBar.success(message: 'Image saved to gallery');
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  static Future<bool> _requestPermission() async {
    if (Platform.isIOS) {
      final status = await Permission.photosAddOnly.request();
      return status.isGranted || status.isLimited;
    }

    final photosStatus = await Permission.photos.request();
    if (photosStatus.isGranted || photosStatus.isLimited) {
      return true;
    }

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }
}
