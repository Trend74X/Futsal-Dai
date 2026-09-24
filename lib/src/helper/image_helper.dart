import 'dart:developer';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;

Future<File> compressToWebp(String sourcePath, {String prefix = 'profile'}) async {
  final dir = await path_provider.getTemporaryDirectory();
  final targetPath = p.join(
    dir.absolute.path,
    '${prefix}_${DateTime.now().millisecondsSinceEpoch}.webp',
  );

  log('compressToWebp: src=$sourcePath (exists=${File(sourcePath).existsSync()}) -> dst=$targetPath');

  final compressedXFile = await FlutterImageCompress.compressAndGetFile(
    sourcePath,
    targetPath,
    format: CompressFormat.webp,
    quality: 80,
    minWidth: 500,
    minHeight: 500,
  );

  if (compressedXFile == null) {
    log('compressToWebp: FAILED (returned null) — webp unsupported on this platform?');
    throw Exception('Failed to compress image');
  }

  final out = File(compressedXFile.path);
  log('compressToWebp: OK path=${out.path} size=${await out.length()} bytes');
  return out;
}

String contentTypeForImage(File file) {
  final ext = p.extension(file.path).toLowerCase();
  return switch (ext) {
    '.jpg' || '.jpeg' => 'image/jpeg',
    '.png' => 'image/png',
    '.gif' => 'image/gif',
    _ => 'image/webp',
  };
}