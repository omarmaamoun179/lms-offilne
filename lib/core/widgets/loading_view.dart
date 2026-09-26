import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import 'app_button.dart';
import 'empty_state.dart';

class LoadingView extends StatelessWidget {
  final Color? color;

  const LoadingView({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 1.5,
          color: color ?? context.palette.accent,
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;

  const ErrorView({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: EmptyState(
          icon: AppIcons.alert,
          title: title ?? 'load_failed_title'.tr(),
          message: message,
          action: onRetry == null
              ? null
              : AppButton(
                  label: 'retry'.tr(),
                  icon: AppIcons.retry,
                  iconSize: 16,
                  height: 44,
                  fontSize: 14.5,
                  onPressed: onRetry,
                ),
        ),
      ),
    );
  }
}
