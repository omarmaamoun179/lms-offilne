import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/widgets/app_icon.dart';

class CourseSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool searching;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancel;

  const CourseSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searching,
    required this.onChanged,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Row(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([controller, focusNode]),
            builder: (context, _) => _buildBox(context),
          ),
        ),
        if (searching) ...[
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onCancel,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                'cancel'.tr(),
                style: AppStrings.w400(14).c(p.accent700),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBox(BuildContext context) {
    final p = context.palette;
    final focused = focusNode.hasFocus;
    final textStyle = AppStrings.w400(14, 1.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: p.bg,
        border: Border.all(color: focused ? p.accent : p.border),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          if (focused) BoxShadow(color: p.accent100, spreadRadius: 3),
        ],
      ),
      child: Row(
        children: [
          AppIcon(
            AppIcons.search,
            color: focused ? p.accent700 : p.neutral700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: textStyle.c(p.text),
              cursorColor: p.accent,
              decoration: InputDecoration.collapsed(
                hintText: 'courses_search_hint'.tr(),
                hintStyle: textStyle.c(p.neutral700),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            Semantics(
              button: true,
              label: 'clear'.tr(),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: AppIcon(AppIcons.close, size: 16, color: p.neutral700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
