import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/header_icon_button.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';

class PlayerTopBar extends StatelessWidget {
  const PlayerTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const AppBackButton(),
          const SizedBox(width: 12),
          Expanded(
            child: BlocSelector<LessonPlayerCubit, LessonPlayerState, String>(
              selector: _crumb,
              builder: (context, crumb) => Text(
                crumb,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppStrings.w400(12.5).c(p.neutral700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _crumb(LessonPlayerState state) {
    final lesson = state.lesson;
    final course = state.course;
    if (lesson == null || course == null) return '';

    final paused = state.status == PlayerStatus.ready &&
        !state.playing &&
        state.position > Duration.zero;
    if (paused) {
      return '${lesson.title} · '
          '${'paused_at'.tr(args: [state.position.clock])}';
    }

    return [course.course.title, ?state.section?.title].join(' · ');
  }
}
