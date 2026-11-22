import 'package:compting/core/utils/currency_formatter.dart';
import 'package:flutter/material.dart';

class CurrencyText extends StatelessWidget {
  const CurrencyText(
    this.amount, {
    super.key,
    this.style,
    this.showSign = false,
    this.compact = false,
    this.maxLines = 1,
  });

  final num amount;
  final TextStyle? style;
  final bool showSign;
  final bool compact;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final text = compact
        ? CurrencyFormatter.formatCompact(amount)
        : CurrencyFormatter.format(amount, showSign: showSign);
    final baseStyle = style ?? Theme.of(context).textTheme.titleMedium;
    return Text(
      text,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: baseStyle?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
