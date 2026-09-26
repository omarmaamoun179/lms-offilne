import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/courses/cubit/course_details_cubit.dart';
import '../../features/courses/cubit/courses_cubit.dart';
import '../../features/courses/repositories/course_repository.dart';
import '../../features/lesson_player/cubit/lesson_notes_cubit.dart';
import '../../features/lesson_player/cubit/lesson_player_cubit.dart';
import '../../features/lesson_player/repositories/lesson_media_repository.dart';
import '../../features/lesson_player/repositories/lesson_notes_repository.dart';
import '../../features/splash/cubit/splash_cubit.dart';
import '../app/theme_cubit.dart';
import '../data/theme_store.dart';
import '../localization/content_language.dart';
import '../security/secure_video_server.dart';
import '../security/video_key.dart';

export '../app/theme_cubit.dart';
export '../localization/content_language.dart';

part 'injection_container.dart';

final GetIt sl = GetIt.instance;
