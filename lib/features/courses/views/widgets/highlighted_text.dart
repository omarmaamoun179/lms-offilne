import 'package:flutter/material.dart';

import '../../../../core/utils/text_search.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlight;
  final String suffix;

  const HighlightedText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    required this.highlight,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final match = TextSearch.find(text, query);
    if (match == null) return Text('$text$suffix', style: style);

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: match.textBefore(text)),
          TextSpan(
            text: match.textInside(text),
            style: TextStyle(
              decoration: TextDecoration.underline,
              decorationColor: highlight,
              decorationThickness: 1.5,
            ),
          ),
          TextSpan(text: '${match.textAfter(text)}$suffix'),
        ],
      ),
    );
  }
}
