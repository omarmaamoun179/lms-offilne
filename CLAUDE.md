# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`../cloack_vendor` and `../cloack` hold worked examples of the patterns below.

## Commands

Use Flutter 3.47.3 (Dart 3.13). 3.35.2 cannot satisfy `sdk: ^3.13.3`.

```bash
F=/Users/omar/flutter_ver/flutter_3.47.3/bin/flutter
$F pub get
$F analyze                        # must be clean — no issues, not "no errors"
$F test
$F run
```

**Do not run `dart format`.** The code is not formatted with the current
formatter, so it rewrites unrelated indentation across most files. Match the
surrounding style by hand: `=>` bodies continue at 6 spaces with their block
indented 8.

**No comments in any file** — not `//`, `///` or `/* */` in Dart, not `#` in
YAML, tests included. Reasoning worth keeping goes in this file.

### Build-time switches

```bash
flutter run --dart-define=USE_MOCK_DATA=false      # the live API instead of fixtures
flutter run --dart-define=BASE_URL=https://staging.example.com/v1/
```

`useMockData` (`core/di/injection_container.dart`) defaults to **true** and
only decides which data source each repository is built with.

`lib/main.dart` is one line; everything before the first frame is in
`core/app/bootstrap.dart`: binding → localization → DI → session restore →
`runApp`. Nothing may reach the network before `runApp` (the requests
inspector's controller is created disabled by whoever asks first).

## This app: Thaheen, offline

The student screens from the Claude Design project "Thaheen Flutter Learning
App" (`Thaheen Screens.dc.html`, design system "Classical"). There is **no
server yet**: the fixture backend, API contract, auth/`SessionNotifier`,
route guard and `USE_MOCK_DATA`/`BASE_URL` sections below describe where the
app goes once one exists; none of that code is here today.

- **Content** is `assets/data/courses.<ar|en>.json` (same ids in both),
  picked by `ContentLanguage`. Progress, notes, playback speed and theme live
  in `SharedPreferences` (`lesson_progress`, `lesson_notes.<lessonId>`,
  `playback_speed`, `theme_mode`).
- **Feature layout** (asked for by the user):
  `features/<name>/{models, views, views/widgets, cubit, repositories}`.
  `cubit/` holds `x_cubit.dart` + `x_state.dart`; cubits (`BaseCubit`)
  depend on repositories directly and there are no use cases. The repository
  *is* the data layer, so every repository method runs inside
  `guardedStorage`. `lesson_player` reuses the `courses` models and
  `CourseRepository`.
- **Rules** are plain model code so they unit-test without a player:
  sequential unlock and progress % in `CourseProgress`, the 90% completion
  rule in `LessonProgress.reachesCompletion` / `LessonProgress.watched`
  (completion is sticky: rewinding keeps it). The player saves progress
  every 5 s, on pause and on close, and `CourseRepository.progressChanges`
  makes the list and details refresh quietly.
- **Type**: `AppStrings.w400/w600(size, height)` is Lora with Noto Naskh
  Arabic as fallback, `AppStrings.heading(size, height)` is Cormorant
  Garamond with Amiri; default height 1.55 (the design system's body). Fonts
  are bundled (offline) with their OFL texts registered in `bootstrap`.
- **Palette** tokens are named after the light design's CSS variables; the
  dark palette maps each to the step the dark frames (1k, 1l) use instead.
- **Sample videos** come from `tool/sample_videos.swift` (no ffmpeg needed):
  `swiftc -O tool/sample_videos.swift -o /tmp/sample_videos` then
  `/tmp/sample_videos <out.mp4> <seconds> <title> <subtitle>` per lesson.
  `assets/videos/physiology/lesson2.mp4` is **missing on purpose** so the
  design's video-error state (1h) is reachable; a test asserts it.
- **App icon** follows `Thaheen App Icon.dc.html`: «ذهين» in white Amiri on
  the brand blue `#1D5999`. Regenerate every size from the repo root with
  `swiftc -O tool/app_icon.swift -o /tmp/app_icon && /tmp/app_icon`: it
  writes each iOS size listed in `AppIcon.appiconset/Contents.json` (opaque,
  as the App Store requires) and, per Android density, a rounded legacy
  `ic_launcher.png` plus the adaptive `ic_launcher_foreground.png` (the design
  scaled to the 72 dp viewport, inside the 66 dp safe zone). The background is
  `@color/ic_launcher_background`, and the foreground doubles as the
  Android 13 monochrome layer.

Found the hard way:

- Awaiting a cached `SynchronousFuture` (e.g.
  `AssetManifest.loadFromAssetBundle`) and then throwing in the same async
  body reports the error as uncaught even though `guardedStorage` returns a
  `Left`. Read such values in their own `async` helper first.
- The engine renders `57%` as `%57` inside Arabic text. Use
  `percentLabel` (`core/utils/percent_format.dart`, an LTR isolate) and wrap
  percentages in `ar.json` in `⁦…⁩`.
- iOS (26 simulator) applies the supported-orientation mask one request late,
  so the fullscreen switch first allows every orientation, waits 150 ms, then
  narrows (`_applyFullscreen` in `lesson_player_page.dart`).
- go_router reuses a page when only its path parameter changes: key the
  page's `BlocProvider` on that parameter as well as the locale.
- `easy_localization` exports intl's `TextDirection`; add
  `hide TextDirection` where Flutter's is meant.
- The hooks in `.claude/settings.json` call `flutter_3.41.1`, which is not
  installed, so the format/analyze hooks do nothing: run 3.47.3 by hand.

## The fixture backend

`FixtureBackend` (a lazy singleton) stands in for the server: it answers
every endpoint **in the contract's exact JSON shape** and keeps the state a
server would. A mock data source is `await _backend.wait()` then
`Model.fromJson(_backend.x(lang))`, so the models are exercised against the
contract even with no backend. The language comes from `ContentLanguage`
(the same language the remote sends as `Accept-Language`).

## The API contract, as core reads it

- **Base URL** in `core/utils/constants.dart` (trailing slash required).
  Paths in `ApiEndPoint`.
- **No envelope.** A 2xx body *is* the resource; `checkedResponse(response)`
  returns an `ApiResponse` whose `.json` is that body, and throws on failure.
- **Errors** are `{"error": {"code", "message", "field", "details"}}`. `code`
  is stable and reaches the cubit as `Failure.code`; `message` is already
  localised and safe to show; a `field` makes it a `ValidationFailure` keyed
  by that field.
- **Lists** are cursor pages: `{items, next_cursor}` → `Paged<T>`
  (`hasMore` is `nextCursor != null`, never the row count).
- **Locale** goes out as `Accept-Language`; content comes back already
  localised. The app translates only its own chrome.
- **Auth**: tokens live in `TokenStore`. A 401 on a call sent with the stored
  token ends the session (`NetworkServiceImpl` → `AuthCubit.sessionExpired`).
  Public calls pass `skipAuthRefresh: true`.

## Architecture

Clean architecture per feature under `lib/features/<name>/`:
`data/` + `domain/` + `presentation/`. Data flows one way: **data source →
repository → use case → cubit → widget**. A cubit depends on use cases, never
on a repository. Only the data layer knows about HTTP or storage; everything
above sees `Either<Failure, T>` (dartz).

A feature may import another feature's `domain` entities; it never imports
another feature's `data` from `presentation`.

### Dependency injection

`get_it` as `sl`, wired once by `initDependencies()` in
`core/di/injection_container.dart` (a `part of` `di_exports.dart`). A feature
adds its own `_registerXFeature()` there. `registerSingleton` for core
services, `registerLazySingleton` for data sources, repositories, use cases
and app-wide cubits, `registerFactory` for one cubit per screen. Each data
source is `useMockData ? XMockDataSource(sl<FixtureBackend>(),
sl<ContentLanguage>()) : XRemoteDataSource(sl<NetworkService>())`.

App-wide cubits, provided in `core/app/app.dart`: `NetworkCubit` and
`AuthCubit` (the signed-in user; the only thing that calls
`SessionNotifier.signedIn()`/`signedOut()`). State that belongs to an account
follows `SessionNotifier`, not another cubit.

### Error handling — MANDATORY

`Either` for all fallible operations; errors are caught in the DATA SOURCE,
never in the repository. The error type is `Failure`
(`core/domain/failure.dart`, sealed): `NetworkFailure` (offline, retryable),
`ServerFailure`, `CacheFailure`, `UnexpectedFailure`, `ValidationFailure`
(carries `fieldErrors`). Every failure may carry the API's `code`.

- **Data source**: every method returns `Future<Either<Failure, T>>` and its
  whole body runs inside `guardedRequest('XDataSource.method', () async {…},
  fallbackMessage: '<key>')` (`guardedStorage` for local storage). Parsing
  stays inside, so a bad payload becomes `UnexpectedFailure`, never a
  connection error. Never return an empty list or a fallback on failure.
- **Repository**: no try/catch. Single calls are pass-through; multi-step
  flows fold once and guard side effects.
- **Cubit**: never catches; folds into an emitted state; both branches emit.
  The one exception to "`Future<void>` + emit": an action whose caller must
  react to *its own* outcome returns `Future<Failure?>`, because every page
  under the shell stays mounted and a state listener would fire on all of
  them.

`mapExceptionToFailure` is where a message becomes displayable: above it,
`Failure.message` is always safe to show. Any sentinel used as a message
(`fallbackMessage`, `messageForStatus`) needs an entry in
`assets/translations/` and in `errorMessageKeys` in
`test/translations_test.dart`.

### Routing

One `GoRouter` in `core/routing/app_router.dart`, paths in `routes.dart`.
Tabs live in a `StatefulShellRoute`. **Detail screens nest under the tab they
were opened from** — `/<tab>/<segment>/<id>` — so the tab bar stays and back
stays inside the tab. Open them through the `AppNavigation` extension
(`pushInTab(segment)` and the helpers built on it), which prefixes the
current tab. Guest-only screens are root routes.

The guard reads `SessionNotifier`. A guest on a protected path is sent to
`/auth?from=<location>` and, once signed in, back to `from`.
`test/route_guard_test.dart` asserts every registered path is classified.
Guest actions that need an account go through `requireSignIn(context)`.

Pages that show server content key their `BlocProvider` on the locale —
`BlocProvider(key: ValueKey(context.locale.languageCode), …)` — so switching
language re-reads the content in the new language.

## Presentation conventions

**Page files stay under 200 lines, 250 absolute maximum.** Widgets go in the
feature's `presentation/widgets/`; layout specific to one page stays in that
page as a `_buildX` method. **Provider placement:** `XPage` creates the
`BlocProvider`, a separate `_XView` consumes it.

**Styling** follows the design's CSS one to one:

- Colors: `context.palette` (`AppPalette`), named after the design's CSS
  variables.
- Type: `AppStrings.w800(13, 1.3)` is `font: 800 13px/1.3`. Color at the call
  site: `.c(p.text)`. Letter-spacing (`.spaced`) never goes on Arabic;
  `SectionLabel` tracks Latin only.
- Icons: `AppIcon(AppIcons.x, …)` renders the design's own SVG paths
  (`flutter_svg`); directional ones mirror in RTL.
- Shared widgets in `core/widgets/`: `AppHeader`, `HeaderIconButton`,
  `AppButton`, `SectionLabel`, `SectionHeading`, `QuantityStepper`,
  `StatGrid`, `PillChip`/`ChipStrip`, `LabeledField`/`AppTextField`/
  `PhoneField`, `EmptyState`, `LoadingView`/`ErrorView`, `NetworkPhoto`
  (an empty image list shows the design's neutral placeholder),
  `PagedScrollListener`, `showAppToast`, `showConfirmSheet`.

**Cubits** extend `BaseCubit`. A state's `copyWith` **clears**
`errorMessage` unless passed again. **Errors are shown in a toast**
(`showAppToast(context, message, isError: true)`); inside a bottom sheet use
`SheetErrorNote`.

Paginated lists: `PagedScrollListener(isLoading:, onEndOfPage:, child:)`
over one scrollable; the cubit guards `loadMore` (in flight / no cursor),
keeps a generation counter, and keeps the list when a next page fails. Search
boxes that hit the server debounce in the cubit with rxdart
(`debounceTime(500ms).distinct()`), and query objects omit absent values.

## Localization

`easy_localization`, Arabic and English, Arabic by default and RTL. Keys in
`assets/translations/{en,ar}.json` — **both files hold the same key set**
(`test/translations_test.dart`). User-facing chrome is always `'key'.tr()`.
Switch language only through `LocalizationService.change`, which updates the
UI locale and the `Accept-Language` the API and fixtures answer in.
