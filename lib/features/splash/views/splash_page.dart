import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/di_exports.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theme/app_palette.dart';
import '../cubit/splash_cubit.dart';
import '../cubit/splash_state.dart';
import 'widgets/splash_footer.dart';
import 'widgets/splash_wordmark.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SplashCubit>()..start(),
      child: const _SplashView(),
    );
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView();

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with TickerProviderStateMixin {
  static const Duration _introDuration = Duration(milliseconds: 1400);
  static const Duration _finishDuration = Duration(milliseconds: 300);
  static const double _loadingShare = .85;

  late final AnimationController _intro =
      AnimationController(vsync: this, duration: _introDuration);
  late final AnimationController _progress =
      AnimationController(vsync: this, duration: SplashCubit.minimumDuration);
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    _intro.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _begin() {
    FlutterNativeSplash.remove();
    if (!mounted) return;

    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      _progress.value = _loadingShare;
      return;
    }
    _intro.forward();
    _progress.animateTo(_loadingShare, curve: Curves.easeOutCubic);
  }

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;

    final still = MediaQuery.disableAnimationsOf(context);
    await _progress.animateTo(
      1,
      duration: still ? Duration.zero : _finishDuration,
      curve: Curves.easeOut,
    );
    if (mounted) context.go(AppRoutes.courses);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return BlocListener<SplashCubit, SplashStatus>(
      listener: (context, status) {
        if (status == SplashStatus.ready) _leave();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: p.brand,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Center(child: SplashWordmark(animation: _intro)),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: SplashFooter(intro: _intro, progress: _progress),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
