import 'dart:async';

import 'package:flutter/services.dart';

enum ImageFormat { jpeg, png }

class ImageResizer {
  static const MethodChannel _channel = const MethodChannel('io.siteplan.image_resizer');

  static Future<void> resize(String imagePath, String targetPath, int maxSize, {ImageFormat format = ImageFormat.png}) async {
		await _channel.invokeMethod('resize', {
			'imagePath': imagePath,
			'targetPath': targetPath,
			'maxSize': maxSize,
			'format': format.index,
		});
	}
}
