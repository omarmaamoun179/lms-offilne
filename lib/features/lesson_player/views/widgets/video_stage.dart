import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/striped_box.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';
import 'player_controls.dart';

class VideoStage extends StatelessWidget {
  final bool fullscreen;
  final Widget? header;

  const VideoStage({super.key, this.fullscreen = false, this.header});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<LessonPlayerCubit>();

    return Stack(
      fit: StackFit.expand,
      children: [
        StripedBox(
          base: p.video,
          line: p.videoStripe,
          gap: fullscreen ? 10 : 8,
        ),
        BlocSelector<LessonPlayerCubit, LessonPlayerState, bool>(
          selector: (state) => state.status == PlayerStatus.ready,
          builder: (context, ready) {
            final controller = cubit.controller;
            if (!ready || controller == null) {
              return LoadingView(color: p.onVideo);
            }

            return Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: cubit.toggleControls,
                ),
                PlayerControls(fullscreen: fullscreen, header: header),
              ],
            );
          },
        ),
      ],
    );
  }
}
