part of 'di_exports.dart';

Future<void> initDependencies() async {
  await _registerCore();
  _registerCoursesFeature();
  _registerLessonPlayerFeature();
}

Future<void> _registerCore() async {
  sl.registerSingleton<SharedPreferences>(
    await SharedPreferences.getInstance(),
  );
  sl.registerSingleton<AssetBundle>(rootBundle);
  sl.registerSingleton<ContentLanguage>(ContentLanguage());
  sl.registerSingleton<ThemeStore>(ThemeStore(sl<SharedPreferences>()));
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<ThemeStore>()));
}

void _registerCoursesFeature() {
  sl.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(
      sl<AssetBundle>(),
      sl<SharedPreferences>(),
      sl<ContentLanguage>(),
    ),
  );

  sl.registerFactory(() => CoursesViewModel(sl<CourseRepository>()));
  sl.registerFactory(() => CourseDetailsViewModel(sl<CourseRepository>()));
}

void _registerLessonPlayerFeature() {
  sl.registerLazySingleton<LessonMediaRepository>(
    () => LessonMediaRepositoryImpl(
      sl<AssetBundle>(),
      sl<SharedPreferences>(),
    ),
  );
  sl.registerLazySingleton<LessonNotesRepository>(
    () => LessonNotesRepositoryImpl(sl<SharedPreferences>()),
  );

  sl.registerFactory(
    () => LessonPlayerViewModel(
      sl<CourseRepository>(),
      sl<LessonMediaRepository>(),
    ),
  );
  sl.registerFactory(() => LessonNotesViewModel(sl<LessonNotesRepository>()));
}

Future<void> resetDependencies() => sl.reset();
