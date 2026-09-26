import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../models/playback_speed.dart';
import '../../view_models/lesson_player_state.dart';
import '../../view_models/lesson_player_view_model.dart';

class SpeedSelector extends StatelessWidget {
  final bool enabled;

  const SpeedSelector({super.key, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Opacity(
      opacity: enabled ? 1 : .45,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'playback_speed'.tr(),
              style: AppStrings.w400(12.5).c(p.neutral700),
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  border: Border.all(color: p.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: BlocSelector<LessonPlayerViewModel, LessonPlayerState,
                    double>(
                  selector: (state) => state.speed,
                  builder: (context, speed) => Row(
                    children: [
                      for (final (index, option)
                          in PlaybackSpeed.options.indexed)
                        Expanded(
                          child: _buildOption(
                            context,
                            option,
                            first: index == 0,
                            selected: enabled && option == speed,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context,
    double option, {
    required bool first,
    required bool selected,
  }) {
    final p = context.palette;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.read<LessonPlayerViewModel>().setSpeed(option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? p.accent100 : null,
          border: first ? null : Border(left: BorderSide(color: p.border)),
        ),
        foregroundDecoration: selected
            ? BoxDecoration(border: Border.all(color: p.accent))
            : null,
        child: Text(
          PlaybackSpeed.label(option),
          style: AppStrings.w400(14, 1.3)
              .c(selected ? p.accent800 : p.text)
              .tabular,
        ),
      ),
    );
  }
}
