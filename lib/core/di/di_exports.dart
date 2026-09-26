import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/theme_cubit.dart';
import '../data/theme_store.dart';
import '../localization/content_language.dart';
import '../../features/courses/repositories/course_repository.dart';
import '../../features/courses/view_models/course_details_view_model.dart';
import '../../features/courses/view_models/courses_view_model.dart';
import '../../features/lesson_player/repositories/lesson_media_repository.dart';
import '../../features/lesson_player/repositories/lesson_notes_repository.dart';
import '../../features/lesson_player/view_models/lesson_notes_view_model.dart';
import '../../features/lesson_player/view_models/lesson_player_view_model.dart';

export '../app/theme_cubit.dart';
export '../localization/content_language.dart';

part 'injection_container.dart';

final GetIt sl = GetIt.instance;
