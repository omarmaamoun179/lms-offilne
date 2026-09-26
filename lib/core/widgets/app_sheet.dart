import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import '../utils/app_strings.dart';
import 'app_icon.dart';

Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  final p = context.palette;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: p.bg,
    barrierColor: p.scrim,
    elevation: 12,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: context.palette.neutral300,
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }
}

class SheetErrorNote extends StatelessWidget {
  final String message;

  const SheetErrorNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.accent100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: AppIcon(AppIcons.alert, size: 16, color: p.accent800),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: AppStrings.w400(13, 1.6).c(p.accent800)),
          ),
        ],
      ),
    );
  }
}
