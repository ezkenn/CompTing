import 'dart:io';

import 'package:compting/core/config/app_env.dart';
import 'package:compting/core/services/image_compression_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReceiptStorageService {
  ReceiptStorageService({
    required this.client,
    ImageCompressionService? compressionService,
  }) : _compressionService = compressionService ?? ImageCompressionService();

  static const int signedUrlTtlSeconds = 60 * 15; // 15 menit

  final SupabaseClient client;
  final ImageCompressionService _compressionService;

  /// Mengunggah foto nota ke bucket private dan mengembalikan object path.
  Future<String> uploadReceipt({
    required File file,
    required String userId,
  }) async {
    final compressed = await _compressionService.compressReceipt(file);

    final fileName =
        '$userId/${DateTime.now().millisecondsSinceEpoch}_receipt.jpg';

    try {
      await client.storage.from(AppEnv.receiptBucket).uploadBinary(
            fileName,
            compressed.bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
    } finally {
      await _compressionService.cleanupTempFile(compressed.file);
    }

    return fileName;
  }

  /// Menghasilkan signed URL berbatas waktu untuk path objek di bucket private.
  /// Juga mendukung URL publik legacy dari proyek Supabase yang sama.
  Future<String?> resolveReceiptUrl(String storedPathOrUrl) async {
    final trimmed = storedPathOrUrl.trim();
    if (trimmed.isEmpty) return null;

    final objectPath = _extractObjectPath(trimmed);
    if (objectPath != null) {
      return client.storage
          .from(AppEnv.receiptBucket)
          .createSignedUrl(objectPath, signedUrlTtlSeconds);
    }

    // Tolak URL tidak aman atau domain luar proyek Supabase
    final uri = Uri.tryParse(trimmed);
    final allowedHost = Uri.tryParse(AppEnv.supabaseUrl)?.host;
    if (uri != null &&
        uri.scheme == 'https' &&
        allowedHost != null &&
        allowedHost.isNotEmpty &&
        uri.host == allowedHost) {
      return trimmed;
    }

    return null;
  }

  String? _extractObjectPath(String value) {
    if (!value.contains('://')) {
      // Pastikan path tidak mengandung path traversal
      if (value.contains('..') || value.startsWith('/')) {
        return null;
      }
      return value;
    }

    final uri = Uri.tryParse(value);
    final allowedHost = Uri.tryParse(AppEnv.supabaseUrl)?.host;
    if (uri == null ||
        uri.scheme != 'https' ||
        allowedHost == null ||
        allowedHost.isEmpty ||
        uri.host != allowedHost) {
      return null;
    }

    final publicPrefix = '/storage/v1/object/public/${AppEnv.receiptBucket}/';
    if (uri.path.startsWith(publicPrefix)) {
      return Uri.decodeComponent(uri.path.substring(publicPrefix.length));
    }

    final authPrefix =
        '/storage/v1/object/authenticated/${AppEnv.receiptBucket}/';
    if (uri.path.startsWith(authPrefix)) {
      return Uri.decodeComponent(uri.path.substring(authPrefix.length));
    }

    return null;
  }
}
