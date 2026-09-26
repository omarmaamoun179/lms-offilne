import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../di/di_exports.dart';
import '../localization/localization_service.dart';
import 'app.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];

  _registerFontLicenses();

  await initDependencies();

  sl<ThemeCubit>().restore();

  runApp(LocalizationService.wrap(const App()));
}

void _registerFontLicenses() {
  const fonts = {
    'Amiri': 'amiri',
    'Cormorant Garamond': 'cormorantgaramond',
    'Lora': 'lora',
    'Noto Naskh Arabic': 'notonaskharabic',
  };

  LicenseRegistry.addLicense(() async* {
    for (final MapEntry(key: family, value: file) in fonts.entries) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/$file.txt',
      );
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
