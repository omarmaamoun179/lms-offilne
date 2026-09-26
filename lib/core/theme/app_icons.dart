class AppIconData {
  final String body;
  final bool filled;
  final bool directional;

  const AppIconData(this.body, {this.filled = false, this.directional = false});

  String svg(double strokeWidth) => filled
      ? '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="#000">$body</svg>'
      : '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="none" stroke="#000" stroke-width="$strokeWidth" '
          'stroke-linecap="round" stroke-linejoin="round">$body</svg>';
}

class AppIcons {
  AppIcons._();

  static const AppIconData search = AppIconData(
    '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
  );

  static const AppIconData close = AppIconData(
    '<path d="M18 6 6 18"/><path d="m6 6 12 12"/>',
  );

  static const AppIconData moon = AppIconData(
    '<path d="M12 3a6 6 0 0 0 9 9 9 9 0 1 1-9-9Z"/>',
  );

  static const AppIconData sun = AppIconData(
    '<circle cx="12" cy="12" r="4"/><path d="M12 2v2"/><path d="M12 20v2"/>'
    '<path d="m4.93 4.93 1.41 1.41"/><path d="m17.66 17.66 1.41 1.41"/>'
    '<path d="M2 12h2"/><path d="M20 12h2"/>'
    '<path d="m6.34 17.66-1.41 1.41"/><path d="m19.07 4.93-1.41 1.41"/>',
  );

  static const AppIconData play = AppIconData(
    '<polygon points="6 3 20 12 6 21 6 3"/>',
    filled: true,
  );

  static const AppIconData pause = AppIconData(
    '<rect x="14" y="4" width="4" height="16" rx="1"/>'
    '<rect x="6" y="4" width="4" height="16" rx="1"/>',
    filled: true,
  );

  static const AppIconData check = AppIconData('<path d="M20 6 9 17l-5-5"/>');

  static const AppIconData lock = AppIconData(
    '<rect width="18" height="11" x="3" y="11" rx="2"/>'
    '<path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
  );

  static const AppIconData back = AppIconData(
    '<path d="m15 18-6-6 6-6"/>',
    directional: true,
  );

  static const AppIconData forward = AppIconData(
    '<path d="m9 18 6-6-6-6"/>',
    directional: true,
  );

  static const AppIconData replay10 = AppIconData(
    '<path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/>'
    '<path d="M3 3v5h5"/>',
    directional: true,
  );

  static const AppIconData forward10 = AppIconData(
    '<path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8"/>'
    '<path d="M21 3v5h-5"/>',
    directional: true,
  );

  static const AppIconData retry = AppIconData(
    '<path d="M21 12a9 9 0 1 1-9-9c2.52 0 4.93 1 6.74 2.74L21 8"/>'
    '<path d="M21 3v5h-5"/>',
  );

  static const AppIconData maximize = AppIconData(
    '<path d="M8 3H5a2 2 0 0 0-2 2v3"/><path d="M21 8V5a2 2 0 0 0-2-2h-3"/>'
    '<path d="M3 16v3a2 2 0 0 0 2 2h3"/><path d="M16 21h3a2 2 0 0 0 2-2v-3"/>',
  );

  static const AppIconData minimize = AppIconData(
    '<path d="M8 3v3a2 2 0 0 1-2 2H3"/><path d="M21 8h-3a2 2 0 0 1-2-2V3"/>'
    '<path d="M3 16h3a2 2 0 0 1 2 2v3"/><path d="M16 21v-3a2 2 0 0 1 2-2h3"/>',
  );

  static const AppIconData alert = AppIconData(
    '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3"/>'
    '<path d="M12 9v4"/><path d="M12 17h.01"/>',
  );

  static const AppIconData book = AppIconData(
    '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/>'
    '<path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  );
}
