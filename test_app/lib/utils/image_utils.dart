import 'package:flutter/material.dart';

class ImageUtils {
  static ImageProvider? getProfileImage(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }
    try {
      return NetworkImage(url);
    } catch (e) {
      return null;
    }
  }
}
