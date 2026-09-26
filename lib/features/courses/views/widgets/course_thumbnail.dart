import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/striped_box.dart';

class CourseThumbnail extends StatelessWidget {
  final String? asset;
  final double size;

  const CourseThumbnail({super.key, this.asset, this.size = 86});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final placeholder = StripedBox(base: p.neutral200, line: p.stripe);

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.divider),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox.square(
        dimension: size,
        child: asset == null
            ? placeholder
            : Image.asset(
                asset!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
