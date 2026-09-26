import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lms_offline/core/di/di_exports.dart';
import 'package:lms_offline/features/courses/cubit/course_details_cubit.dart';
import 'package:lms_offline/features/courses/cubit/courses_cubit.dart';
import 'package:lms_offline/features/courses/models/course_progress.dart';
import 'package:lms_offline/features/courses/views/course_details_page.dart';
import 'package:lms_offline/features/courses/views/courses_page.dart';
import 'package:lms_offline/features/lesson_player/cubit/lesson_notes_cubit.dart';
import 'package:lms_offline/features/lesson_player/cubit/lesson_player_cubit.dart';
import 'package:lms_offline/features/lesson_player/views/lesson_player_page.dart';

import 'support/fakes.dart';
import 'support/widget_harness.dart';

void main() {
  late FakeCourseRepository courses;
  late FakeLessonMediaRepository media;

  setUp(() {
    courses = FakeCourseRepository();
    media = FakeLessonMediaRepository();
    sl.registerFactory(() => CoursesCubit(courses));
    sl.registerFactory(() => CourseDetailsCubit(courses));
    sl.registerFactory(() => LessonPlayerCubit(courses, media));
    sl.registerFactory(() => LessonNotesCubit(FakeLessonNotesRepository()));
  });

  tearDown(() => sl.reset());

  testWidgets('the course list shows each course, its progress and '
      'the lesson to continue', (tester) async {
    courses.library = Right(CourseLibrary(
      studentName: 'عمر',
      courses: [
        CourseProgress(anatomyCourse(), designSampleProgress()),
        CourseProgress(physiologyCourse(), const {}),
      ],
    ));

    await pumpScreen(tester, const CoursesPage());

    expect(find.text('دوراتي'), findsOneWidget);
    expect(find.text('مقدمة في التشريح'), findsOneWidget);
    expect(find.text('أساسيات علم وظائف الأعضاء'), findsOneWidget);
    expect(find.text('دورتان'), findsOneWidget);
    expect(find.textContaining('40%'), findsOneWidget);
    expect(find.text('تابع المشاهدة'), findsOneWidget);
    expect(find.text('الغضاريف'), findsOneWidget);
    expect(find.text('توقفت عند 1:02'), findsOneWidget);
  });

  testWidgets('tapping a locked lesson explains why instead of opening it',
      (tester) async {
    courses.course = Right(
      CourseProgress(anatomyCourse(), designSampleProgress()),
    );

    await pumpScreen(tester, const CourseDetailsPage(courseId: 'anatomy'));
    await tester.tap(find.text('أنواع العضلات'));
    await tester.pumpAndSettle();

    expect(find.text('هذا الدرس لم يُفتح بعد'), findsOneWidget);
    expect(find.textContaining('«الغضاريف» أولاً'), findsOneWidget);
    expect(find.text('تابع «الغضاريف» من 1:02'), findsOneWidget);

    await tester.tap(find.text('حسناً'));
    await tester.pumpAndSettle();

    expect(find.text('هذا الدرس لم يُفتح بعد'), findsNothing);
  });

  testWidgets('a course without lessons shows the empty state',
      (tester) async {
    courses.course = Right(CourseProgress(emptyCourse(), const {}));

    await pumpScreen(
      tester,
      const CourseDetailsPage(courseId: 'pharmacology'),
    );

    expect(find.text('لا توجد دروس في هذه الدورة بعد'), findsOneWidget);
    expect(find.text('العودة إلى دوراتي'), findsOneWidget);
  });

  testWidgets('a missing video shows the error panel and retry tries again',
      (tester) async {
    final physiology = CourseProgress(
      physiologyCourse(),
      {'physiology-1': done()},
    );
    courses.lesson = Right(
      CourseLesson(physiology, physiology.lessonById('physiology-2')!),
    );

    await pumpScreen(
      tester,
      const LessonPlayerPage(
        courseId: 'physiology',
        lessonId: 'physiology-2',
      ),
    );

    expect(find.text('تعذّر تشغيل هذا الدرس'), findsOneWidget);
    expect(
      find.textContaining('video_source_error · lesson2.mp4', findRichText: true),
      findsOneWidget,
    );
    expect(media.opened, 1);

    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(media.opened, 2);
    expect(find.text('تعذّر تشغيل هذا الدرس'), findsOneWidget);
  });
}
