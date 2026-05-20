import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;

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

      await Gal.putImageBytes(
        Uint8List.fromList(response.bodyBytes),
        name: 'swatcher_${DateTime.now().millisecondsSinceEpoch}',
      );

      CustomSnackBar.success(message: 'Image saved to gallery');
    } on GalException catch (e) {
      CustomSnackBar.failure(message: e.type.message);
    } catch (error) {
      CustomSnackBar.failure(
        message: error.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  static Future<bool> _requestPermission() async {
    if (await Gal.hasAccess()) return true;
    return Gal.requestAccess();
  }
}
