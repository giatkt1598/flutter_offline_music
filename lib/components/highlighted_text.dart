import 'package:flutter/material.dart';
import 'package:remove_diacritic/remove_diacritic.dart';

class HighlightedText extends StatelessWidget {
  final String fullText;
  final String highlightedText;
  final TextStyle? style;
  const HighlightedText({
    super.key,
    required this.fullText,
    required this.highlightedText,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (highlightedText.isEmpty) {
      return Text(fullText, style: style);
    }

    String normalizedText = removeDiacritics(fullText.toLowerCase());
    String normalizedQuery = removeDiacritics(highlightedText.toLowerCase());

    int startIndex = normalizedText.indexOf(normalizedQuery);
    if (startIndex == -1) {
      return Text(fullText, style: style);
    }

    int endIndex = startIndex + highlightedText.length;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: fullText.substring(0, startIndex),
            style: style ?? Theme.of(context).textTheme.bodyMedium,
          ),
          TextSpan(
            text: fullText.substring(startIndex, endIndex),
            style:
                style?.copyWith(color: Colors.red) ??
                TextStyle(color: Colors.red),
          ),
          TextSpan(
            text: fullText.substring(endIndex),
            style: style ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
