import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/app_navigation.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../view_models/lesson_player_state.dart';
import '../../view_models/lesson_player_view_model.dart';
import 'lesson_heading.dart';
import 'speed_selector.dart';

class PlayerFailureDetails extends StatelessWidget {
  final LessonPlayerState state;

  const PlayerFailureDetails({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final code = state.failure?.code ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LessonHeading(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'retry'.tr(),
                icon: AppIcons.retry,
                iconSize: 16,
                height: 46,
                fontSize: 14.5,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                expand: true,
                onPressed: context.read<LessonPlayerViewModel>().retry,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                label: 'back_to_course'.tr(),
                variant: AppButtonVariant.secondary,
                height: 46,
                fontSize: 14.5,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                expand: true,
                onPressed: context.goBack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.divider)),
          ),
          child: Text.rich(
            TextSpan(
              text: '${'error_code'.tr()} ',
              children: [
                TextSpan(
                  text: '$code · ${state.lesson!.videoFileName}',
                  style: AppStrings.mono(12, 1.8),
                ),
              ],
            ),
            style: AppStrings.w400(12, 1.8).c(p.neutral700),
          ),
        ),
        const SizedBox(height: 18),
        const SpeedSelector(enabled: false),
      ],
    );
  }
}
