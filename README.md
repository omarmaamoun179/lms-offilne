# Thaheen · ذهين — Mini Offline LMS

A small student app for Thaheen, an Arabic-first learning platform for
health-sciences students. Students browse their courses, open a course's
sections and lessons, and watch video lessons that unlock one after another.
Progress, notes and preferences are saved on the device.

**Works fully offline.** The course catalog, videos, thumbnails and fonts are
bundled with the app. There is no backend, no API call and no external network
request. Internally, a localhost-only connection streams decrypted video to the
native player ([details](#offline-video-protection)).

---

## Contents

1. [How to run](#how-to-run)
2. [Features](#features)
3. [Architecture & technical decisions](#architecture--technical-decisions)
4. [Progress rules](#progress-rules)
5. [RTL & localization](#rtl--localization)
6. [States & error handling](#states--error-handling)
7. [Tests](#tests)
8. [Trade-offs & known issues](#trade-offs--known-issues)
9. [What I'd do with more time](#what-id-do-with-more-time)
10. [Time spent](#time-spent)
11. [Demo](#demo)

---

## How to run

Requires **Flutter stable 3.47.x** (Dart `^3.13.3`).

```bash
flutter pub get
flutter run                     # starts in Arabic (RTL)
flutter test                    # 58 tests: 54 unit + 4 widget
tool/build_release.sh android   # obfuscated release APKs, one per CPU architecture
```

**Quick tour**

| Try this | What you should see |
|---|---|
| Launch the app | Brand-blue native splash → animated splash → course list |
| Play **العظام** in «مقدمة في التشريح», leave, reopen it | It resumes where you stopped |
| Tap a locked lesson | A sheet explaining which lesson to finish first |
| Watch past the **90%** tick on the seek bar | «اكتمل الدرس», and the next lesson unlocks |
| Change the speed, then tap ⤢ | Speed applies at once and is remembered; fullscreen landscape |
| Search «وظائف»; tap the moon and **EN** buttons | Match underlined; dark mode; Arabic ⇄ English |
| Open «مبادئ علم الأدوية» | Empty state: a course with no lessons |
| Finish «بنية القلب», then open «الدورة الدموية الصغرى» | Error state: its video is missing on purpose |

> Every screen waits **800 ms** before showing data on purpose, so each loading
> state can be seen. The delay is `loadingDelay` in each repository; set it to
> zero to remove it.

---

## Features

**Required — all implemented**

- **Courses:** thumbnail, title, instructor, lesson count and progress %, plus
  a **Continue watching** card.
- **Course details:** sections and lessons with durations and status
  (not started / in progress / completed / locked). Unlock is sequential across
  sections; tapping a locked lesson explains why.
- **Lesson player:** play/pause, ±10 s, seek bar, current time and duration,
  speed 1x/1.25x/1.5x/2x, fullscreen landscape, resume, automatic completion at
  90%, and a **Next lesson** card that respects the unlock rule.
- **Persistence:** positions and completed lessons survive restarts.
- **Arabic-first RTL**, loading/empty/error states, and unit tests for the
  progress rules.

**Bonus:** dark mode, course search, per-lesson notes, remembered playback
speed, widget tests, app icon and animated splash.

**Also:** an Arabic ⇄ English switch. Lesson videos ship encrypted, and release
builds are obfuscated.

---

## Architecture & technical decisions

The code is organized feature-first, with a light data / logic / UI split
inside each feature:

```
lib/
├── core/                    shared infrastructure: DI, routing, theme, localization,
│                            Failure + guardedStorage, shared widgets, security
└── features/
    ├── courses/
    │   ├── models/          Course, LessonProgress, CourseProgress (the rules)
    │   ├── repositories/    CourseRepository (bundled JSON + SharedPreferences)
    │   ├── cubit/           CoursesCubit, CourseDetailsCubit
    │   └── views/           pages + widgets
    ├── lesson_player/       same layout: LessonPlayerCubit, LessonNotesCubit,
    │                        LessonMediaRepository, LessonNotesRepository
    └── splash/              SplashCubit + animated splash
```

```
View ──calls──▶ Cubit ──▶ Repository ──▶ bundled JSON · SharedPreferences · video_player
  ▲               │
  └──── state ◀───┘
```

- **Data:** only repositories touch assets, storage or the video plugin. Every
  call returns `Either<Failure, T>`.
- **Logic:** unlock, progress % and the 90% rule are plain Dart in the models,
  so they're tested without Flutter.
- **UI:** each page creates its cubit (`BlocProvider`) and a private view
  consumes it. Pages stay under 200 lines.

### Feature-first, with clean architecture only where it pays

Each feature keeps its screen, state and data in one folder. That makes a
feature easy to find, and it can be changed or removed without touching the
others.

I deliberately left out the full clean-architecture ceremony: one use case per
call, separate data-source interfaces and pass-through entity layers. Each
feature has one small local source, and the brief says not to over-engineer, so
those layers would only forward calls.

The repository acts as the data layer. The business and progress rules stay in
plain Dart, and the UI consumes Cubit state. The one abstraction I kept is the
repository interface, because it's the one that matters later: a remote
implementation can sit behind `CourseRepository` without changing the cubits or
the UI.

### Cubit (flutter_bloc)

- **Explicit, immutable state:** each screen has one `Equatable` state, so
  loading, loaded, error, searching and fullscreen are defined in one place.
- **Less ceremony than Bloc:** screens react to method calls (`load`, `search`,
  `togglePlay`, `setSpeed`), so events would add boilerplate without benefit.
- **Easy to test:** give a cubit a fake repository, call a method, check the
  state.
- **Selective rebuilds:** the player emits its position several times a second.
  `BlocSelector` and `buildWhen` limit those rebuilds to the seek bar and the
  time labels.
- **Used consistently:** in every feature, including the theme and the splash.

Riverpod would have been an equally valid choice. I chose Cubit because it
keeps logic in plain classes and pairs simply with `get_it`.

### SharedPreferences

The stored data is small and key-value shaped:

- `lesson_progress`: one JSON map with each lesson's position, completion and
  last update
- `lesson_notes.<lessonId>`
- `playback_speed`
- `theme_mode`
- the saved `locale`

For data like this, SharedPreferences is the simplest correct choice. It's
official and needs no schema, migrations or code generation. Progress is saved
after every 5 s of playback, on pause, on reaching 90% and when the player
closes.

It isn't what I'd use for a production LMS. Large offline catalogs, richer
notes, querying and search, or server sync call for a database such as
Drift/SQLite or Isar. Only the repository implementations would need to change.

### video_player

`video_player` is the official plugin, backed by AVPlayer on iOS and ExoPlayer
on Android. It is lightweight, supports seeking, playback speed and error
reporting, and leaves room for custom controls.

The design needs controls a stock skin such as Chewie doesn't provide:

- a seek bar that fills from the right in Arabic, with a 90% marker
- mirrored ±10 s buttons
- a speed selector and fullscreen
- notes tied to timestamps

Heavier players such as media_kit and better_player add codecs, DRM and
caching that this app doesn't need.

### go_router, get_it, easy_localization

- **go_router:** nested routes (`/courses/:courseId/lessons/:lessonId`), so
  back always returns to the course.
- **get_it:** keeps object construction in one file,
  `core/di/injection_container.dart`.
- **easy_localization:** switches the language at runtime and handles Arabic
  plural forms.

### Bundled content

- **Course files:** `assets/data/courses.ar.json` and `courses.en.json`, one per
  language with the **same ids**, so progress carries across a language switch.
  Lessons carry `duration_seconds`, so lists show durations without opening
  each video.
- **Courses:** two have 2 sections × 5 lessons. «مبادئ علم الأدوية» has none, to
  show the empty state. «الدورة الدموية الصغرى» has no video file on purpose, to
  show the error state.
- **Videos:** three anatomy lessons (العظام، المفاصل، أنواع العضلات) are real
  12-second clips. The rest are small placeholder clips generated with
  `tool/sample_videos.swift`.
- **Thumbnails:** public-domain plates from Wikimedia Commons: Vesalius (1543),
  Gray's *Anatomy* (1918) and Köhler's *Medizinal-Pflanzen* (1887).

### Offline video protection

Lesson videos ship only as encrypted `.enc` files. They use AES-256-GCM, which
is authenticated encryption, so a modified or truncated file is rejected.

When a lesson opens, it is decrypted in memory and served to `video_player`
from a small HTTP server. The server is bound to `127.0.0.1` and sits behind a
random per-session token. No decrypted copy is written to disk. Release builds
are obfuscated, and the key isn't stored as a single value in the binary.

This is lightweight client-side protection, not DRM. The key ships with the
app, so a determined attacker on a rooted or jailbroken device can still
recover the content. For a paid-content platform I'd use server-issued,
per-user keys and platform DRM (Widevine/FairPlay).

- **Code and workflow:** the code is in `lib/core/security/`. After adding or
  replacing an MP4 in `media/videos/`, run `dart run tool/encrypt_videos.dart`.
  Those plain sources are kept in the repository for the tool and one test.
  They are never bundled into the app.
- **Platform settings it depends on:**
  - Android: the `INTERNET` permission, for the loopback socket.
  - Android: `network_security_config.xml`, which allows plain HTTP to
    `127.0.0.1` only.
  - iOS: `NSAllowsLocalNetworking`.
- **Backups:** `android:allowBackup="false"` keeps progress and notes out of
  Android cloud backup. On Android 12+ this does not stop device-to-device
  transfer.

---

## Progress rules

All rules are plain Dart (`LessonProgress`, `CourseProgress`) and unit-tested.

| Rule | Behavior |
|---|---|
| **Sequential unlock** | The first incomplete lesson is available; every lesson after it is locked. The order continues across sections. |
| **Completion** | A lesson completes when its position reaches **≥ 90%** of its duration. A video of unknown length never completes. |
| **Sticky completion** | Once a lesson is completed, rewinding doesn't make it incomplete. |
| **Course progress** | Completed lessons ÷ total lessons. |
| **Resume** | Reopening a lesson continues from the saved position. If that position is in the last 5%, it restarts from the beginning. |
| **Continue watching** | The most recently updated lesson that is started but not finished. |

---

## RTL & localization

- **Default and switching:** Arabic is the default, with a full RTL layout.
  English (LTR) is one tap away via **EN**. Content comes from the matching
  language file with the same ids, so progress survives the switch.
- **Icons:** directional icons mirror (back, next, ±10 s); play/pause doesn't.
- **Seek bar:** in Arabic it fills from the right. The current time sits on the
  start side, and taps and drags map to the same direction. The 90% marker is
  measured from the start side too.
- **Percentages:** they're wrapped in a left-to-right isolate. Without it,
  Flutter renders "57%" as "%57" inside Arabic text. A test covers this.
- **Search:** it folds Arabic letter variants (أ/إ/آ → ا, ى → ي, ة → ه), and
  the match is underlined in the original text.
- **Digits and fonts:** times and counts use Latin digits, as in the design.
  Fonts are bundled for offline use: Amiri and Noto Naskh Arabic for Arabic,
  Cormorant Garamond and Lora for Latin.

---

## States & error handling

Repositories run every call inside `guardedStorage`, which maps any exception
to a typed `Failure` (`CacheFailure`, `UnexpectedFailure`, each with an
optional `code`). Cubits fold failures into state, so expected data and media
errors reach the UI as designed states, not red screens.

| Situation | What the user sees |
|---|---|
| Loading | Skeletons on the course list and notes; spinners on course details and the video |
| Empty | A course without lessons; no search results; no notes yet |
| Missing or corrupt video | An error panel in place of the video, with retry, back to course, and the code (`video_source_error · lesson2.enc`); progress is kept |
| Data can't be read (e.g. corrupt saved progress) | An error view; the course list offers retry |
| Progress couldn't be saved | A toast; playback continues |

---

## Tests

```bash
flutter test      # 58 tests: 54 unit + 4 widget
```

| Area | Tests | Covers |
|---|---|---|
| Progress rules (`course_progress_test`) | 14 | Exactly 90% and 1 ms below it, sticky completion, unknown duration, sequential unlock (fresh, mid-course, across sections, finished), progress %, continue watching |
| Repositories (`course_repository_test`, `lesson_player_repositories_test`) | 13 | Both language files parse with the same ids; every video and thumbnail is bundled except the deliberate missing one; saved progress round-trips and unlocks the next lesson; unknown course/lesson and corrupt saved data are failures; missing video → `video_source_error`; remembered speed; per-lesson notes |
| Cubits (`courses_cubit_test`, `splash_cubit_test`) | 9 | Load and failure, search with Arabic letter variants, continue card hidden while searching, background refresh keeps the list on failure; the splash waits for data and still hands off on failure |
| Localization (`translations_test`, `percent_format_test`) | 7 | Arabic and English share one key set, every key used exists, error messages are translated; the RTL percent fix |
| Video protection (`video_cipher_test`, `secure_video_server_test`) | 11 | Any byte range decrypts exactly; tampered, truncated, wrong-key and plain files are rejected; loopback-only server that answers the range requests players make |
| Widgets (`screens_widget_test`) | 4 | Course list with progress and continue card; a locked lesson opens the explanation sheet; empty course; a missing video shows the error panel and retry works |

---

## Trade-offs & known issues

- **Completion is position-based.** Seeking past 90% completes a lesson. A real
  LMS would track watched ranges or time; it's the first thing I'd change.
- **The missing video blocks its course.** Unlock is sequential, so the
  physiology lessons after «الدورة الدموية الصغرى» can't be reached. That is the
  rule working as specified. A real app would offer "report a problem" or a
  support override.
- **The 800 ms loading delay** is only there to show loading states. It would
  be removed for release.
- **Whole-map writes.** Progress is one JSON map rewritten on every save. That
  is fine for a few lessons, not for thousands, and SharedPreferences won't
  scale to a large synced catalog.
- **Notes are simple:** you can add them and seek to them, but not edit or
  delete them.
- **Fullscreen is button-only.** The app is portrait-locked, so rotating the
  phone doesn't enter fullscreen.
- **Video protection is not DRM.** Screen recording isn't blocked, deliberately,
  so the app can be recorded for demos. A lesson's whole encrypted file stays in
  memory while it plays, which is fine for short lessons but not for long
  lectures.
- **Large text:** at 200% text size on an iPhone SE-sized screen, a few screens
  overflow.
- **Platforms:** most hands-on testing was on the iOS simulator, before video
  encryption was added.
  - Encrypted playback is covered by unit tests and was checked with
    AVFoundation on macOS.
  - Both the iOS app and the Android APK build.
  - Neither has been run on a device since this change.

---

## What I'd do with more time

1. **Downloads:** background, resumable course downloads over HTTPS into
   app-private storage, in the same `.enc` format, reading chunks from disk
   instead of memory.
2. **Structured storage:** Drift (SQLite) for larger catalogs, progress and
   notes, including note editing and search.
3. **Backend sync** of progress, behind the existing repository interfaces.
4. **Stronger content protection:** per-user keys issued by a server, wrapped
   by a device key (iOS Keychain / Android Keystore), and Widevine/FairPlay for
   paid content.
5. **Watched-time completion**, based on watched ranges instead of position.
6. **More tests:** golden tests of the player controls in RTL/LTR and both
   themes, and integration tests on real devices.
7. **CI:** analyze, test and build the APK on every push.
8. **Polish:** tablet layouts, an accessibility pass (screen-reader labels, the
   largest text sizes), crash reporting and basic analytics.

---

## Time spent

About **4–6 hours**.

---

## Demo

- **Repository:** _add link before sending_
- **APK:** `tool/build_release.sh android` →
  `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (most phones).
  Link: _add before sending_
- **Screen recording (2–3 min):** _add link before sending_
