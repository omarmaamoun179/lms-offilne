import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_icons.dart';
import '../theme/app_palette.dart';
import 'app_icon.dart';

class HeaderIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double size;
  final String? semanticLabel;

  const HeaderIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.borderColor,
    this.size = 40,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: semanticLabel != null,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor ?? context.palette.border),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const AppBackButton({super.key, this.onTap, this.color, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      semanticLabel: 'back'.tr(),
      borderColor: borderColor,
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: AppIcon(AppIcons.back, color: color),
    );
  }
}
