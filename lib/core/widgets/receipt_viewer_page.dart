import 'package:cached_network_image/cached_network_image.dart';
import 'package:compting/core/constants/app_colors.dart';
import 'package:compting/features/transactions/presentation/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Penampil gambar bukti transaksi/nota menggunakan signed URL dari bucket private.
class ReceiptImageWidget extends ConsumerStatefulWidget {
  const ReceiptImageWidget({
    super.key,
    required this.receiptUrl,
    this.height = 180,
    this.fit = BoxFit.cover,
  });

  final String receiptUrl;
  final double height;
  final BoxFit fit;

  @override
  ConsumerState<ReceiptImageWidget> createState() => _ReceiptImageWidgetState();
}

class _ReceiptImageWidgetState extends ConsumerState<ReceiptImageWidget> {
  late Future<String?> _resolvedUrlFuture;

  @override
  void initState() {
    super.initState();
    _resolvedUrlFuture = _resolve();
  }

  @override
  void didUpdateWidget(covariant ReceiptImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receiptUrl != widget.receiptUrl) {
      _resolvedUrlFuture = _resolve();
    }
  }

  Future<String?> _resolve() {
    return ref
        .read(receiptStorageServiceProvider)
        .resolveReceiptUrl(widget.receiptUrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _resolvedUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: widget.height,
            color: AppColors.background,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final resolvedUrl = snapshot.data;
        if (snapshot.hasError ||
            resolvedUrl == null ||
            !resolvedUrl.startsWith('https://')) {
          return _BrokenReceiptPlaceholder(height: widget.height);
        }

        return CachedNetworkImage(
          imageUrl: resolvedUrl,
          height: widget.height,
          width: double.infinity,
          fit: widget.fit,
          placeholder: (_, _) => Container(
            height: widget.height,
            color: AppColors.background,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (_, _, _) =>
              _BrokenReceiptPlaceholder(height: widget.height),
        );
      },
    );
  }
}

class ReceiptViewerPage extends StatelessWidget {
  const ReceiptViewerPage({
    super.key,
    required this.receiptUrl,
    this.title = 'Bukti Transaksi / Nota',
  });

  final String receiptUrl;
  final String title;

  static Future<void> open(
    BuildContext context, {
    required String receiptUrl,
    String title = 'Bukti Transaksi / Nota',
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReceiptViewerPage(
          receiptUrl: receiptUrl,
          title: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4.5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ReceiptImageWidget(
              receiptUrl: receiptUrl,
              height: 460,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

class _BrokenReceiptPlaceholder extends StatelessWidget {
  const _BrokenReceiptPlaceholder({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.background,
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
            SizedBox(height: 6),
            Text(
              'Gagal memuat foto struk',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
