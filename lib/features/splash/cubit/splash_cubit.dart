import '../../../core/abstract/base_cubit.dart';
import '../../courses/repositories/course_repository.dart';
import 'splash_state.dart';

class SplashCubit extends BaseCubit<SplashStatus> {
  static const Duration minimumDuration = Duration(milliseconds: 1800);

  final CourseRepository _courses;
  final Duration minimum;

  SplashCubit(this._courses, {this.minimum = minimumDuration})
      : super(SplashStatus.loading);

  Future<void> start() async {
    final hold = Future<void>.delayed(minimum);
    await _courses.getLibrary();
    await hold;
    emit(SplashStatus.ready);
  }
}
