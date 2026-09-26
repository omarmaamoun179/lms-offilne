import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';
import 'seek_bar.dart';

class PlayerControls extends StatelessWidget {
  final bool fullscreen;
  final Widget? header;

  const PlayerControls({super.key, this.fullscreen = false, this.header});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LessonPlayerCubit, LessonPlayerState>(
      buildWhen: (previous, current) =>
          previous.controlsVisible != current.controlsVisible ||
          previous.playing != current.playing ||
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) => IgnorePointer(
        ignoring: !state.controlsVisible,
        child: AnimatedOpacity(
          opacity: state.controlsVisible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildScrim(context),
              if (header != null)
                PositionedDirectional(
                  top: 22,
                  start: 64,
                  end: 64,
                  child: header!,
                ),
              Center(child: _buildTransport(context, state)),
              PositionedDirectional(
                start: fullscreen ? 64 : 14,
                end: fullscreen ? 64 : 14,
                bottom: fullscreen ? 23 : 5,
                child: _buildTimeline(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrim(BuildContext context) {
    final shade = context.palette.shade;
    final alphas = fullscreen
        ? const <double>[.55, 0, 0, .6]
        : const <double>[.2, .15, .15, .5];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            for (final alpha in alphas) shade.withValues(alpha: alpha),
          ],
          stops: const [0, .3, .65, 1],
        ),
      ),
    );
  }

  Widget _buildTransport(BuildContext context, LessonPlayerState state) {
    final cubit = context.read<LessonPlayerCubit>();
    final gap = SizedBox(width: fullscreen ? 56 : 36);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SkipButton(
          icon: AppIcons.replay10,
          label: 'skip_back'.tr(),
          large: fullscreen,
          onTap: () => cubit.seekBy(-LessonPlayerCubit.skipStep),
        ),
        gap,
        _PlayPauseButton(
          playing: state.playing,
          large: fullscreen,
          onTap: cubit.togglePlay,
        ),
        gap,
        _SkipButton(
          icon: AppIcons.forward10,
          label: 'skip_forward'.tr(),
          large: fullscreen,
          onTap: () => cubit.seekBy(LessonPlayerCubit.skipStep),
        ),
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, LessonPlayerState state) {
    final p = context.palette;
    final cubit = context.read<LessonPlayerCubit>();
    final style = AppStrings.w400(fullscreen ? 13 : 12, 1).c(p.onVideo).tabular;
    final gap = SizedBox(width: fullscreen ? 14 : 10);

    return Row(
      children: [
        Text(state.position.clock, style: style),
        gap,
        Expanded(
          child: SeekBar(
            value: state.fraction,
            thumbSize: fullscreen ? 15 : 13,
            onSeek: (fraction) => cubit.seekTo(state.totalDuration * fraction),
          ),
        ),
        gap,
        Text(state.totalDuration.clock, style: style),
        gap,
        Semantics(
          button: true,
          label: (fullscreen ? 'fullscreen_exit' : 'fullscreen_enter').tr(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: cubit.toggleFullscreen,
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: AppIcon(
                fullscreen ? AppIcons.minimize : AppIcons.maximize,
                size: fullscreen ? 20 : 18,
                color: p.onVideo,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SkipButton extends StatelessWidget {
  final AppIconData icon;
  final String label;
  final bool large;
  final VoidCallback onTap;

  const _SkipButton({
    required this.icon,
    required this.label,
    required this.large,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.square(
          dimension: large ? 44 : 40,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AppIcon(
                icon,
                size: large ? 32 : 28,
                color: p.onVideo,
                strokeWidth: large ? 1.4 : 1.5,
              ),
              Text(
                '10',
                style: AppStrings.w600(large ? 10 : 9, 1).c(p.onVideo),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool playing;
  final bool large;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.playing,
    required this.large,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final iconSize = large ? 24.0 : 22.0;

    return Semantics(
      button: true,
      label: (playing ? 'pause' : 'play').tr(),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: large ? 68 : 60,
          height: large ? 68 : 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: p.onVideo.withValues(alpha: .7)),
          ),
          child: playing
              ? AppIcon(AppIcons.pause, size: iconSize, color: p.onVideo)
              : PlayGlyph(size: iconSize, color: p.onVideo),
        ),
      ),
    );
  }
}
