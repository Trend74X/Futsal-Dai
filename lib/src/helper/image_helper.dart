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

/// Unique suffix used in storage filenames to bust CDN & app image caches.
/// e.g. 202609241054
String timestampSuffix() {
  final now = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  final y = now.year.toString();
  final mo = two(now.month);
  final d = two(now.day);
  final h = two(now.hour);
  final mi = two(now.minute);
  return '$y$mo$d$h$mi';
}

/// Extracts the storage object path from a public URL, or null if the URL
/// doesn't belong to the given bucket.
/// Handles: https://ref.supabase.co/storage/v1/object/public/bucket/objectPath
String? storageObjectPathFromUrl(String url, String bucketName) {
  final marker = '/object/public/$bucketName/';
  final int idx = url.indexOf(marker);
  if (idx == -1) return null;
  final objectPath = url.substring(idx + marker.length);
  return objectPath.isEmpty ? null : objectPath;
}