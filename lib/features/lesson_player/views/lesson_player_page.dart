import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di_exports.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_toast.dart';
import '../cubit/lesson_notes_cubit.dart';
import '../cubit/lesson_player_cubit.dart';
import '../cubit/lesson_player_state.dart';
import 'widgets/fullscreen_player.dart';
import 'widgets/lesson_heading.dart';
import 'widgets/lesson_unavailable.dart';
import 'widgets/next_lesson_card.dart';
import 'widgets/notes_section.dart';
import 'widgets/notes_sheet.dart';
import 'widgets/player_failure_details.dart';
import 'widgets/player_top_bar.dart';
import 'widgets/speed_selector.dart';
import 'widgets/video_error_panel.dart';
import 'widgets/video_stage.dart';

class LessonPlayerPage extends StatelessWidget {
  final String courseId;
  final String lessonId;

  const LessonPlayerPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      key: ValueKey('${context.locale.languageCode}/$lessonId'),
      providers: [
        BlocProvider(
          create: (_) => sl<LessonPlayerCubit>()
            ..load(courseId: courseId, lessonId: lessonId),
        ),
        BlocProvider(create: (_) => sl<LessonNotesCubit>()..load(lessonId)),
      ],
      child: const _LessonPlayerView(),
    );
  }
}

class _LessonPlayerView extends StatefulWidget {
  const _LessonPlayerView();

  @override
  State<_LessonPlayerView> createState() => _LessonPlayerViewState();
}

class _LessonPlayerViewState extends State<_LessonPlayerView> {
  static const _landscape = [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ];
  static const _portrait = [DeviceOrientation.portraitUp];
  static const _settle = Duration(milliseconds: 150);

  bool _fullscreen = false;

  @override
  void dispose() {
    if (_fullscreen) _applyFullscreen(false);
    super.dispose();
  }

  Future<void> _applyFullscreen(bool fullscreen) async {
    _fullscreen = fullscreen;
    await SystemChrome.setPreferredOrientations([..._portrait, ..._landscape]);
    await Future<void>.delayed(_settle);
    await SystemChrome.setPreferredOrientations(
      fullscreen ? _landscape : _portrait,
    );
    await SystemChrome.setEnabledSystemUIMode(
      fullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LessonPlayerCubit, LessonPlayerState>(
          listenWhen: (previous, current) =>
              previous.fullscreen != current.fullscreen,
          listener: (context, state) => _applyFullscreen(state.fullscreen),
        ),
        BlocListener<LessonPlayerCubit, LessonPlayerState>(
          listenWhen: (previous, current) => current.errorMessage != null,
          listener: (context, state) =>
              showAppToast(context, state.errorMessage!, isError: true),
        ),
      ],
      child: BlocBuilder<LessonPlayerCubit, LessonPlayerState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.fullscreen != current.fullscreen ||
            previous.lesson != current.lesson,
        builder: (context, state) => PopScope(
          canPop: !state.fullscreen,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) context.read<LessonPlayerCubit>().exitFullscreen();
          },
          child: Scaffold(
            backgroundColor: state.fullscreen ? context.palette.video : null,
            body: state.fullscreen
                ? const FullscreenPlayer()
                : SafeArea(bottom: false, child: _buildBody(context, state)),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, LessonPlayerState state) {
    if (state.status == PlayerStatus.unavailable ||
        state.status == PlayerStatus.locked) {
      return LessonUnavailable(state: state);
    }

    final failed = state.status == PlayerStatus.failed;

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 40),
      children: [
        const PlayerTopBar(),
        const SizedBox(height: 16),
        failed
            ? const VideoErrorPanel()
            : const AspectRatio(aspectRatio: 16 / 9, child: VideoStage()),
        const SizedBox(height: 16),
        if (state.lesson != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: failed
                ? PlayerFailureDetails(state: state)
                : _buildDetails(context),
          ),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LessonHeading(),
        const SizedBox(height: 18),
        const SpeedSelector(),
        const NextLessonCard(),
        const SizedBox(height: 18),
        NotesSection(onAdd: () => _openNotes(context)),
      ],
    );
  }

  Future<void> _openNotes(BuildContext context) async {
    final player = context.read<LessonPlayerCubit>();
    final notes = context.read<LessonNotesCubit>();
    final at = await player.pause();
    if (!context.mounted) return;

    await showAppSheet<void>(
      context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: player),
          BlocProvider.value(value: notes),
        ],
        child: NotesSheet(at: at),
      ),
    );
  }
}
