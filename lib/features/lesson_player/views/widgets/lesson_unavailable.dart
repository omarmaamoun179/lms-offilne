import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/header_icon_button.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../view_models/lesson_player_state.dart';

class LessonUnavailable extends StatelessWidget {
  final LessonPlayerState state;

  const LessonUnavailable({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final lesson = state.lesson;
    final blocker = state.course?.current;
    final locked = state.status == PlayerStatus.locked &&
        lesson != null &&
        blocker != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: AppBackButton(),
        ),
        Expanded(
          child: locked
              ? ErrorView(
                  title: 'locked_sheet_title'.tr(),
                  message: 'locked_sheet_body'.tr(
                    args: [blocker.title, lesson.title],
                  ),
                )
              : ErrorView(message: state.failure?.message ?? ''),
        ),
      ],
    );
  }
}
