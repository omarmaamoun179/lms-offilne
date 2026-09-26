import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/section_heading.dart';
import '../../cubit/lesson_notes_cubit.dart';
import '../../cubit/lesson_notes_state.dart';
import '../../cubit/lesson_player_cubit.dart';
import '../../cubit/lesson_player_state.dart';
import '../../models/lesson_note.dart';

class NotesSection extends StatelessWidget {
  final VoidCallback onAdd;

  const NotesSection({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final player = context.read<LessonPlayerCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading(
          title: 'my_notes'.tr(),
          size: 19,
          gap: 6,
          trailing: BlocSelector<LessonPlayerCubit, LessonPlayerState, int>(
            selector: (state) => state.position.inSeconds,
            builder: (context, seconds) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onAdd,
              child: Text(
                'add_note_at'.tr(args: [Duration(seconds: seconds).clock]),
                style: AppStrings.w400(13).c(p.accent700),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        BlocBuilder<LessonNotesCubit, LessonNotesState>(
          builder: (context, state) => switch (state.status) {
            NotesStatus.loading => _buildSkeleton(context),
            NotesStatus.error => _buildMessage(context, state.errorMessage),
            NotesStatus.loaded when state.notes.isEmpty =>
              _buildMessage(context, 'notes_empty'.tr()),
            NotesStatus.loaded => Column(
                children: [
                  for (final note in state.notes)
                    NoteRow(note: note, onSeek: player.seekTo),
                ],
              ),
          },
        ),
      ],
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final fill = context.palette.neutral200;
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(2),
          ),
        );

    return Column(
      children: [
        for (final width in const [.8, .55])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                bar(30, 10),
                const SizedBox(width: 12),
                Expanded(
                  child: FractionallySizedBox(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: width,
                    child: bar(double.infinity, 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMessage(BuildContext context, String? message) {
    return Text(
      message ?? '',
      style: AppStrings.w400(13, 1.7).c(context.palette.neutral700),
    );
  }
}

class NoteRow extends StatelessWidget {
  final LessonNote note;
  final ValueChanged<Duration> onSeek;
  final bool divided;

  const NoteRow({
    super.key,
    required this.note,
    required this.onSeek,
    this.divided = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: EdgeInsets.symmetric(vertical: divided ? 12 : 5),
      decoration: divided
          ? BoxDecoration(border: Border(bottom: BorderSide(color: p.divider)))
          : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSeek(note.position),
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                note.position.clock,
                style: AppStrings.w400(12).c(p.accent700).tabular,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              note.text,
              textAlign: TextAlign.justify,
              style: AppStrings.w400(13.5, 1.8).c(p.text),
            ),
          ),
        ],
      ),
    );
  }
}
