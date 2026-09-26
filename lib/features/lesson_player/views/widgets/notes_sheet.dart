import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../cubit/lesson_notes_cubit.dart';
import '../../cubit/lesson_notes_state.dart';
import '../../cubit/lesson_player_cubit.dart';
import 'notes_section.dart';

class NotesSheet extends StatefulWidget {
  final Duration at;

  const NotesSheet({super.key, required this.at});

  @override
  State<NotesSheet> createState() => _NotesSheetState();
}

class _NotesSheetState extends State<NotesSheet> {
  final _text = TextEditingController();
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    final failure = await context
        .read<LessonNotesCubit>()
        .add(widget.at, _text.text);
    if (!mounted) return;

    if (failure == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = failure.message;
    });
  }

  void _seek(Duration position) {
    context.read<LessonPlayerCubit>().seekTo(position);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final size = MediaQuery.sizeOf(context);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * .75),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: BlocBuilder<LessonNotesCubit, LessonNotesState>(
            builder: (context, state) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(child: SheetHandle()),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        'lesson_notes'.tr(),
                        style: AppStrings.heading(24).c(p.text),
                      ),
                    ),
                    Text(
                      'notes_count'.plural(state.notes.length),
                      style: AppStrings.w400(12.5).c(p.neutral700),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildComposer(context),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  SheetErrorNote(message: _error!),
                ],
                const SizedBox(height: 8),
                for (final note in state.notes)
                  NoteRow(note: note, onSeek: _seek, divided: true),
                const SizedBox(height: 14),
                Text(
                  'notes_seek_hint'.tr(),
                  style: AppStrings.w400(12, 1.7).c(p.neutral700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComposer(BuildContext context) {
    final p = context.palette;
    final style = AppStrings.w400(14.5, 1.85);
    final canSave = !_saving && _text.text.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: p.bg,
        border: Border.all(color: p.accent),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: p.accent100, spreadRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'note_at'.tr(args: [widget.at.clock]),
            style: AppStrings.w400(12).c(p.accent700).tabular,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _text,
            autofocus: true,
            minLines: 2,
            maxLines: 6,
            onChanged: (_) => setState(() {}),
            style: style.c(p.text),
            cursorColor: p.accent,
            decoration: InputDecoration.collapsed(
              hintText: 'note_hint'.tr(),
              hintStyle: style.c(p.neutral700),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'cancel'.tr(),
                variant: AppButtonVariant.plain,
                height: 36,
                fontSize: 13.5,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              AppButton(
                label: 'save'.tr(),
                height: 36,
                fontSize: 13.5,
                onPressed: canSave ? _save : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
