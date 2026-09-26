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
    final pixels = (size * MediaQuery.devicePixelRatioOf(context)).ceil();

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
                cacheWidth: pixels,
                cacheHeight: pixels,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                frameBuilder: (context, child, frame, sync) => sync
                    ? child
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          placeholder,
                          AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: child,
                          ),
                        ],
                      ),
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
