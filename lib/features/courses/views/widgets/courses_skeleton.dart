import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import 'courses_header.dart';

class CoursesSkeleton extends StatelessWidget {
  const CoursesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      children: [
        const CoursesTitle(),
        const SizedBox(height: 20),
        Opacity(
          opacity: .5,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: p.divider),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _bar(context, .30, 10),
              const SizedBox(height: 12),
              _bar(context, .55, 18),
              const SizedBox(height: 12),
              _bar(context, .70, 10),
              const SizedBox(height: 12),
              Container(height: 2, color: p.neutral200),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _row(context, .75, .50, top: 16),
        _row(context, .85, .45),
        const SizedBox(height: 20),
        Text(
          'courses_loading'.tr(),
          textAlign: TextAlign.center,
          style: AppStrings.w400(13).c(p.neutral700),
        ),
      ],
    );
  }

  Widget _bar(BuildContext context, double width, double height) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: width,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: context.palette.neutral200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    double title,
    double meta, {
    double top = 0,
  }) {
    final p = context.palette;

    return Container(
      padding: EdgeInsets.only(top: top, bottom: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: p.divider)),
      ),
      child: Row(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: p.neutral200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _bar(context, title, 16),
                  const SizedBox(height: 10),
                  _bar(context, meta, 10),
                  const SizedBox(height: 48),
                  Container(height: 2, color: p.neutral200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
