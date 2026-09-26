import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';

class SplashWordmark extends StatelessWidget {
  final Animation<double> animation;

  const SplashWordmark({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        double phase(double begin, double end) => Curves.easeOutCubic
            .transform(Interval(begin, end).transform(animation.value));

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _rise(
              phase(0, .55),
              14,
              Text(
                'brand_wordmark'.tr(),
                style: AppStrings.heading(72, 1.3).c(p.onBrand),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 64 * phase(.35, .75),
              height: 1,
              color: p.onBrand.withValues(alpha: .6),
            ),
            const SizedBox(height: 20),
            _rise(
              phase(.5, 1),
              8,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'splash_tagline'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStrings.w400(15).c(p.onBrand),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _rise(double value, double distance, Widget child) {
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, distance * (1 - value)),
        child: child,
      ),
    );
  }
}
