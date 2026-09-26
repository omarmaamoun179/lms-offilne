import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color bg;
  final Color surface;
  final Color text;
  final Color accent;
  final Color divider;
  final Color border;
  final Color scrim;
  final Color shadow;
  final Color neutral200;
  final Color neutral300;
  final Color neutral500;
  final Color neutral700;
  final Color neutral800;
  final Color accent100;
  final Color accent300;
  final Color accent700;
  final Color accent800;
  final Color stripe;
  final Color video;
  final Color videoStripe;
  final Color onVideo;
  final Color onVideoMuted;
  final Color seekFill;
  final Color seekThumb;
  final Color shade;
  final Color brand;
  final Color onBrand;

  const AppPalette({
    required this.bg,
    required this.surface,
    required this.text,
    required this.accent,
    required this.divider,
    required this.border,
    required this.scrim,
    required this.shadow,
    required this.neutral200,
    required this.neutral300,
    required this.neutral500,
    required this.neutral700,
    required this.neutral800,
    required this.accent100,
    required this.accent300,
    required this.accent700,
    required this.accent800,
    required this.stripe,
    required this.video,
    required this.videoStripe,
    required this.onVideo,
    required this.onVideoMuted,
    required this.seekFill,
    required this.seekThumb,
    required this.shade,
    required this.brand,
    required this.onBrand,
  });

  static const AppPalette light = AppPalette(
    bg: AppColors.bg,
    surface: AppColors.neutral100,
    text: AppColors.text,
    accent: AppColors.brand,
    divider: AppColors.divider,
    border: AppColors.divider,
    scrim: AppColors.scrim,
    shadow: AppColors.shadow,
    neutral200: AppColors.neutral200,
    neutral300: AppColors.neutral300,
    neutral500: AppColors.neutral500,
    neutral700: AppColors.neutral700,
    neutral800: AppColors.neutral800,
    accent100: AppColors.blue100,
    accent300: AppColors.blue300,
    accent700: AppColors.brand,
    accent800: AppColors.blue800,
    stripe: AppColors.neutral300,
    video: AppColors.neutral900,
    videoStripe: AppColors.neutral800,
    onVideo: AppColors.white,
    onVideoMuted: AppColors.neutral300,
    seekFill: AppColors.blue400,
    seekThumb: AppColors.blue300,
    shade: AppColors.black,
    brand: AppColors.brand,
    onBrand: AppColors.white,
  );

  static const AppPalette dark = AppPalette(
    bg: AppColors.darkBg,
    surface: AppColors.darkLine,
    text: AppColors.neutral100,
    accent: AppColors.blue400,
    divider: AppColors.darkLine,
    border: AppColors.darkEdge,
    scrim: AppColors.darkScrim,
    shadow: AppColors.darkShadow,
    neutral200: AppColors.darkLine,
    neutral300: AppColors.darkLine,
    neutral500: AppColors.darkMuted,
    neutral700: AppColors.neutral400,
    neutral800: AppColors.neutral300,
    accent100: AppColors.blue900,
    accent300: AppColors.blue800,
    accent700: AppColors.blue400,
    accent800: AppColors.blue300,
    stripe: AppColors.darkEdge,
    video: AppColors.black,
    videoStripe: AppColors.neutral900,
    onVideo: AppColors.white,
    onVideoMuted: AppColors.neutral300,
    seekFill: AppColors.blue400,
    seekThumb: AppColors.blue300,
    shade: AppColors.black,
    brand: AppColors.brand,
    onBrand: AppColors.white,
  );

  @override
  AppPalette copyWith({
    Color? bg,
    Color? surface,
    Color? text,
    Color? accent,
    Color? divider,
    Color? border,
    Color? scrim,
    Color? shadow,
    Color? neutral200,
    Color? neutral300,
    Color? neutral500,
    Color? neutral700,
    Color? neutral800,
    Color? accent100,
    Color? accent300,
    Color? accent700,
    Color? accent800,
    Color? stripe,
    Color? video,
    Color? videoStripe,
    Color? onVideo,
    Color? onVideoMuted,
    Color? seekFill,
    Color? seekThumb,
    Color? shade,
    Color? brand,
    Color? onBrand,
  }) {
    return AppPalette(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      accent: accent ?? this.accent,
      divider: divider ?? this.divider,
      border: border ?? this.border,
      scrim: scrim ?? this.scrim,
      shadow: shadow ?? this.shadow,
      neutral200: neutral200 ?? this.neutral200,
      neutral300: neutral300 ?? this.neutral300,
      neutral500: neutral500 ?? this.neutral500,
      neutral700: neutral700 ?? this.neutral700,
      neutral800: neutral800 ?? this.neutral800,
      accent100: accent100 ?? this.accent100,
      accent300: accent300 ?? this.accent300,
      accent700: accent700 ?? this.accent700,
      accent800: accent800 ?? this.accent800,
      stripe: stripe ?? this.stripe,
      video: video ?? this.video,
      videoStripe: videoStripe ?? this.videoStripe,
      onVideo: onVideo ?? this.onVideo,
      onVideoMuted: onVideoMuted ?? this.onVideoMuted,
      seekFill: seekFill ?? this.seekFill,
      seekThumb: seekThumb ?? this.seekThumb,
      shade: shade ?? this.shade,
      brand: brand ?? this.brand,
      onBrand: onBrand ?? this.onBrand,
    );
  }

  @override
  AppPalette lerp(covariant AppPalette? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      text: mix(text, other.text),
      accent: mix(accent, other.accent),
      divider: mix(divider, other.divider),
      border: mix(border, other.border),
      scrim: mix(scrim, other.scrim),
      shadow: mix(shadow, other.shadow),
      neutral200: mix(neutral200, other.neutral200),
      neutral300: mix(neutral300, other.neutral300),
      neutral500: mix(neutral500, other.neutral500),
      neutral700: mix(neutral700, other.neutral700),
      neutral800: mix(neutral800, other.neutral800),
      accent100: mix(accent100, other.accent100),
      accent300: mix(accent300, other.accent300),
      accent700: mix(accent700, other.accent700),
      accent800: mix(accent800, other.accent800),
      stripe: mix(stripe, other.stripe),
      video: mix(video, other.video),
      videoStripe: mix(videoStripe, other.videoStripe),
      onVideo: mix(onVideo, other.onVideo),
      onVideoMuted: mix(onVideoMuted, other.onVideoMuted),
      seekFill: mix(seekFill, other.seekFill),
      seekThumb: mix(seekThumb, other.seekThumb),
      shade: mix(shade, other.shade),
      brand: mix(brand, other.brand),
      onBrand: mix(onBrand, other.onBrand),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
