import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/header_icon_button.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';
import '../../models/playback_speed.dart';
import 'video_stage.dart';

class FullscreenPlayer extends StatelessWidget {
  const FullscreenPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoStage(fullscreen: true, header: _FullscreenHeader());
  }
}

class _FullscreenHeader extends StatelessWidget {
  const _FullscreenHeader();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<LessonPlayerCubit>();
    final outline = p.onVideo.withValues(alpha: .5);

    String subtitle(LessonPlayerState state) {
      final place = 'lesson_of'.tr(
        args: ['${state.lessonNumber}', '${state.lessonCount}'],
      );
      return '${state.course?.course.title ?? ''} · $place';
    }

    return BlocBuilder<LessonPlayerCubit, LessonPlayerState>(
      buildWhen: (previous, current) =>
          previous.speed != current.speed || previous.lesson != current.lesson,
      builder: (context, state) => Row(
        children: [
          AppBackButton(
            color: p.onVideo,
            borderColor: outline,
            onTap: cubit.exitFullscreen,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.lesson?.title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStrings.heading(22, 1.3).c(p.onVideo),
                ),
                Text(
                  subtitle(state),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppStrings.w400(12).c(p.onVideoMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: cubit.cycleSpeed,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: outline),
              ),
              child: Text(
                PlaybackSpeed.label(state.speed),
                textDirection: TextDirection.ltr,
                style: AppStrings.w400(13, 1).c(p.onVideo),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
