import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di_exports.dart';
import '../../../../core/localization/localization_service.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';
import '../../../../core/widgets/header_icon_button.dart';

class CoursesHeader extends StatelessWidget {
  final String studentName;

  const CoursesHeader({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greetingKey(DateTime.now()).tr(args: [studentName]),
                style: AppStrings.w400(13).c(p.accent700),
              ),
              const CoursesTitle(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              _buildLanguageButton(context),
              const SizedBox(width: 8),
              _buildThemeButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton(BuildContext context) {
    final p = context.palette;
    final arabic = context.locale == LocalizationService.arabic;
    final style = arabic
        ? AppStrings.w400(12, 1).c(p.text).spaced(.48)
        : AppStrings.w400(15, 1).c(p.text);

    return HeaderIconButton(
      semanticLabel: 'language_switch_label'.tr(),
      onTap: () => LocalizationService.change(
        context,
        LocalizationService.other(context.locale),
      ),
      child: Text('language_switch'.tr(), style: style),
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    final p = context.palette;
    final dark = context.isDark;

    return HeaderIconButton(
      semanticLabel: (dark ? 'theme_light' : 'theme_dark').tr(),
      borderColor: dark ? p.accent : null,
      onTap: () => context.read<ThemeCubit>().toggle(isDark: dark),
      child: AppIcon(
        dark ? AppIcons.sun : AppIcons.moon,
        color: dark ? p.accent : p.text,
      ),
    );
  }

  static String _greetingKey(DateTime now) => switch (now.hour) {
        >= 5 && < 12 => 'greeting_morning',
        >= 12 && < 17 => 'greeting_afternoon',
        _ => 'greeting_evening',
      };
}

class CoursesTitle extends StatelessWidget {
  const CoursesTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'courses_title'.tr(),
      style: AppStrings.heading(34, 1.35).c(context.palette.text),
    );
  }
}
