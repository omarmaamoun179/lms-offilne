# Thaheen · ذهين — Mini Offline LMS

A small student app for Thaheen, an Arabic‑first learning platform for
health‑sciences students. Students browse their courses, open a course's
sections and lessons, and watch video lessons that unlock one after another.
Progress, notes and preferences are saved on the device.

**Everything runs offline.** There is no backend and no network call: the
course catalog, videos, thumbnails and fonts are bundled with the app.

---

## Contents

1. [How to run](#how-to-run)
2. [What's in the app](#whats-in-the-app)
3. [Architecture](#architecture)
4. [Why these choices](#why-these-choices)
5. [Progress rules](#progress-rules)
6. [Arabic‑first and RTL](#arabicfirst-and-rtl)
7. [States and errors](#states-and-errors)
8. [Tests](#tests)
9. [Data and assets](#data-and-assets)
10. [Trade‑offs and known issues](#tradeoffs-and-known-issues)
11. [What I'd do with more time](#what-id-do-with-more-time)
12. [Time spent](#time-spent)
13. [Demo](#demo)

---

## How to run

Requires **Flutter stable 3.47.x** (Dart `^3.13.3`), null‑safe.

```bash
flutter pub get
flutter run                     # starts in Arabic (RTL)
flutter test                    # 46 tests: 42 unit + 4 widget
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```

A quick tour for reviewers:

| Try this | What you should see |
|---|---|
| Launch the app | Brand‑blue native splash → animated splash → course list |
| Tap **العظام** in «مقدمة في التشريح» | The lesson plays; leave and come back — it resumes where you stopped |
| Tap a locked lesson | A friendly sheet explaining which lesson to finish first |
| Watch past **90%** (the tick on the seek bar) | «اكتمل الدرس» badge, and the next lesson unlocks |
| Speed **1x / 1.25x / 1.5x / 2x** | Applies immediately and is remembered for the next lesson |
| The ⤢ button on the video | Fullscreen landscape; back or ⤡ returns |
| **+ إضافة عند …** under the video | A note saved at the current second; tap its time to jump there |
| Search «وظائف» | Matching course with the match underlined |
| Open «مبادئ علم الأدوية» | Empty state: a course with no lessons |
| Finish «بنية القلب», then open «الدورة الدموية الصغرى» | Error state: its video file is missing on purpose |
| Moon / **EN** buttons | Dark mode and the Arabic ⇄ English switch |

> Screens wait **800 ms** before showing data on purpose, so every loading
> state can be seen. The delay lives in each repository as `loadingDelay`;
> set it to zero to remove it.
>
> Debug builds open inside `device_preview`'s frame and toolbar, to check
> other phones, tablets, orientations and text sizes without a simulator.
> Run `flutter run --dart-define=DEVICE_PREVIEW=false` for the plain app;
> release builds never include it.

---

## What's in the app

**Required features — all implemented**

- **Courses screen:** thumbnail, title, instructor, lesson count and
  progress %, plus a **"Continue watching"** card for the most recently
  watched unfinished lesson.
- **Course details:** sections and lessons with durations; each lesson shows
  *not started / in progress / completed* (and *locked*). Sequential unlock
  across sections; tapping a locked lesson explains why.
- **Lesson player:** play/pause, ±10 s, seek bar, current time and duration,
  speed 1x/1.25x/1.5x/2x, fullscreen landscape, resume from the last
  position, automatic completion at 90%, and a **Next lesson** card that
  respects the unlock rule.
- **Local persistence:** positions and completed lessons survive restarts.
- **Arabic‑first RTL**, with an Arabic/English switch.
- **Loading, empty and error states**, no red screens.
- **Tests** for the 90% rule, the unlock rule and the progress %.

**Bonus — all implemented**

Dark mode · course search · per‑lesson notes · remembered playback speed ·
widget tests · app icon and animated splash screen.

---

## Architecture

**Feature‑first**, with a light clean‑architecture split inside each feature:

```
lib/
├── core/                        shared infrastructure, no feature logic
│   ├── abstract/                BaseCubit (ignores emits after close)
│   ├── app/                     bootstrap, App widget, ThemeCubit
│   ├── data/                    guardedStorage (try/catch → Either), ThemeStore
│   ├── domain/                  Failure (sealed) + exception → failure mapper
│   ├── exceptions/              typed exceptions thrown inside repositories
│   ├── di/                      get_it registrations
│   ├── localization/            easy_localization setup, content language
│   ├── routing/                 go_router config and navigation helpers
│   ├── theme/                   palette (light/dark), icons, theme
│   ├── utils/                   typography, colors, formatting, text search
│   └── widgets/                 shared UI: buttons, sheets, toast, states…
└── features/
    ├── courses/
    │   ├── models/              Course, LessonProgress, CourseProgress (rules)
    │   ├── repositories/        CourseRepository (assets + local storage)
    │   ├── cubit/               CoursesCubit, CourseDetailsCubit + states
    │   └── views/               pages + views/widgets
    ├── lesson_player/
    │   ├── models/              LessonNote, PlaybackSpeed
    │   ├── repositories/        LessonMediaRepository, LessonNotesRepository
    │   ├── cubit/               LessonPlayerCubit, LessonNotesCubit + states
    │   └── views/               player page + controls, seek bar, notes…
    └── splash/                  SplashCubit + animated splash page
```

Data flows one way:

```
View ──reads state / calls methods──▶ Cubit ──▶ Repository ──▶ bundled JSON
  ▲                                    │                      SharedPreferences
  └──────────── emits state ◀──────────┘                      video_player
```

- **Data** — repositories are the only code that touches assets, storage or
  the video plugin. Every method returns `Either<Failure, T>` and runs inside
  `guardedStorage`, so no exception crosses into the UI. A malformed JSON
  becomes an `UnexpectedFailure`; a missing video becomes a `CacheFailure`
  with the code `video_source_error`.
- **Logic** — the rules (unlock, progress %, 90% completion) are plain Dart
  in the models, so they are tested without Flutter. Cubits turn repository
  results into immutable states.
- **UI** — pages create their cubit (`BlocProvider`) and a private view widget
  consumes it. Pages stay under 200 lines; parts live in `views/widgets/`.
- **DI** with `get_it`; **navigation** with `go_router`, using nested routes
  (`/courses/:courseId/lessons/:lessonId`) so back always does the expected
  thing.

---

## Why these choices

### Feature‑first, and "clean" only where it pays

Everything about courses lives in `features/courses`, everything about
playing a lesson in `features/lesson_player`. A reviewer (or a new teammate)
finds a screen, its state and its data in one folder, and a feature can be
changed or removed without touching the others.

Inside a feature I kept three layers — data, logic, UI — but deliberately
**not** the full clean‑architecture ceremony (separate entities, data
sources and one use case per call). With one local source per feature, those
layers would be pass‑throughs. The task says *don't over‑engineer*, so the
repository *is* the data layer, and the only abstraction kept is the one
that matters later: the repository interface. When a backend arrives, a
remote implementation slots in behind `CourseRepository` and nothing above
it changes.

### Cubit (flutter_bloc)

- **Explicit, immutable state.** Each screen has one state class
  (`Equatable`, `copyWith`), so what the UI can show is written down in one
  place — loading, loaded, error, searching, fullscreen…
- **Less ceremony than Bloc.** Screens here react to method calls
  (`load`, `search`, `togglePlay`, `setSpeed`), not to event streams that
  need transforming, so events would add boilerplate without benefit.
- **Easy to test.** A cubit is a plain class: give it a fake repository,
  call a method, check the state. No widget tree needed.
- **Fine‑grained rebuilds.** The player emits the position several times a
  second; `BlocSelector`/`buildWhen` keep that to the seek bar and time labels
  instead of rebuilding the page.
- **Used consistently** — every feature, including the theme and the splash.

Riverpod would have worked equally well; I chose Cubit because it keeps logic
in ordinary classes, pairs simply with `get_it`, and is widely known.

### SharedPreferences for local storage

What the app stores is small and key‑value shaped:

| Key | Content |
|---|---|
| `lesson_progress` | JSON map: lesson id → position, completed, updated at |
| `lesson_notes.<lessonId>` | JSON list of notes for that lesson |
| `playback_speed` | last chosen speed |
| `theme_mode`, `locale` | preferences |

For this, SharedPreferences is the simplest correct tool: it is the official
plugin, needs no code generation, schema or migrations, reads synchronously
after start‑up, and survives restarts. Writes happen every 5 s while playing,
on pause, on completion and when the player closes.

What I considered instead: **Hive/Isar** bring a database and code
generation that this amount of data doesn't need; **sqflite/Drift** are the
right move once data grows or needs queries — for example notes search or
syncing with a server — and the repository interface means only the
repository changes.

### video_player

- **Official Flutter plugin**, backed by AVPlayer on iOS and ExoPlayer on
  Android; plays bundled assets and exposes seeking, playback speed and
  errors (`value.hasError`).
- **Small and predictable.** Nothing to fight when building custom controls.
- **Custom controls instead of Chewie**, because the design needs things a
  stock skin doesn't give: a seek bar that fills right‑to‑left in Arabic, a
  90% completion tick, mirrored ±10 s buttons, a speed selector and notes
  tied to the current second. Chewie's stock controls would have needed
  replacing almost entirely to match that.
- `media_kit` or `better_player` bring more (extra codecs, DRM, caching) but
  are heavier; not needed for bundled MP4s.

### go_router, easy_localization, get_it

`go_router` gives URL‑style nested routes and a clean splash → courses
hand‑off. `easy_localization` handles Arabic plural forms (دورتان، 3 دورات،
11 دورة…) and switches the language at runtime. `get_it` keeps construction in
one file (`core/di/injection_container.dart`).

---

## Progress rules

All in plain Dart (`CourseProgress`, `LessonProgress`) and unit‑tested:

- **Unlock:** the first unfinished lesson of the course is open; every lesson
  after it is locked. Order runs across sections.
- **Completion:** a lesson completes when the position reaches **90%** of
  its duration. Completion is sticky — rewinding later keeps it completed.
- **Progress %:** completed lessons ÷ total lessons of the course.
- **Resume:** reopening a lesson continues from the saved position, unless
  it was within the last 5%, where it restarts from the beginning.
- **Continue watching:** the most recently updated lesson that is started
  but not finished.

---

## Arabic‑first and RTL

- Arabic by default, full RTL layout; English (LTR) via the **EN** button.
  Course content comes from a per‑language JSON file with the same ids, so
  progress carries across a language switch.
- Directional icons mirror (back, next, ±10 s); play/pause does not.
- The seek bar fills right‑to‑left with the current time on the right, and
  the completion tick sits at 90% from the start side.
- Percentages are wrapped in a left‑to‑right isolate: without it, Flutter
  renders "57%" as "%57" inside Arabic text (covered by a test).
- Latin digits for times and counts, as in the design.
- Fonts are bundled for offline use: Amiri and Noto Naskh Arabic for Arabic,
  Cormorant Garamond and Lora for Latin.

---

## States and errors

| State | Where |
|---|---|
| Loading | Course list skeleton; spinners on details and the video; notes placeholders |
| Empty | A course with no lessons; no search results; no notes yet |
| Error: missing/corrupt video | Error panel over the video, retry, back to course, and the error code (`video_source_error · lesson2.mp4`); course progress is kept |
| Error: data can't be read | Error view (with retry on the course list), e.g. corrupt saved data |
| Transient errors | Toast (e.g. progress couldn't be saved) |

Repositories never throw; cubits turn every `Failure` into state, so data
problems reach the UI as designed states, never as exceptions.

---

## Tests

```bash
flutter test      # 46 tests
```

**Unit tests (42)**

| File | Covers |
|---|---|
| `course_progress_test.dart` (14) | Unlock rule (fresh course, design sample, across sections, finished course), progress %, lesson numbering, section durations, "continue watching", and the **90% rule**: exact threshold, one millisecond before, completion recorded, stays completed after rewinding, unknown duration, reaching 90% unlocks the next lesson |
| `course_repository_test.dart` (7) | Both language files parse with the same ids; every video and thumbnail is bundled (except the deliberately missing one); saved progress comes back and unlocks the next lesson; unknown course/lesson are failures; corrupt saved data is an `UnexpectedFailure` |
| `lesson_player_repositories_test.dart` (5) | Missing video → `video_source_error`; speed defaults to 1x and is remembered; unknown saved speed falls back; notes are per lesson, trimmed, newest first |
| `courses_cubit_test.dart` (6) | Load, load failure, search (including Arabic hamza forms), hiding "continue watching" while searching, quiet refresh keeping the list on failure |
| `splash_cubit_test.dart` (3) | Waits for data, hands off even on failure, respects the minimum time |
| `translations_test.dart` (4) | Arabic and English have the same keys; every key used in code exists; error messages are translated; nothing blank |
| `percent_format_test.dart` (3) | The RTL percent fix renders the sign after the digits |

**Widget tests (4)** — `screens_widget_test.dart`, rendering real screens in
Arabic at phone size with fake repositories:

1. The course list shows each course, its progress and the lesson to continue.
2. Tapping a locked lesson opens the explanation sheet, not the lesson.
3. A course without lessons shows the empty state.
4. A missing video shows the error panel, and **retry** tries again.

---

## Data and assets

`assets/data/courses.ar.json` and `courses.en.json` follow the suggested
shape with a few deliberate changes:

```json
{
  "student": { "name": "عمر" },
  "courses": [
    {
      "id": "anatomy",
      "title": "مقدمة في التشريح",
      "instructor": "د. سارة العتيبي",
      "thumbnail": "assets/images/anatomy.jpg",
      "sections": [
        {
          "id": "anatomy-skeletal",
          "title": "الجهاز الهيكلي",
          "lessons": [
            { "id": "anatomy-1", "title": "العظام", "duration_seconds": 12,
              "video": "assets/videos/thaheen_offline_video_assets/lesson_bones.mp4" }
          ]
        }
      ]
    }
  ]
}
```

- **One file per language** (same ids) because the app switches between
  Arabic and English at runtime, and content should switch with it.
- **`duration_seconds`** is spelled with its unit and shown before the video
  loads (the list needs durations without opening every file).
- **A third course with no sections** («مبادئ علم الأدوية») exists to show
  the empty state; the other two have 2 sections and 5 lessons each.
- **`student.name`** feeds the greeting.

**Videos.** Anatomy lessons العظام, المفاصل and أنواع العضلات play real
12‑second clips from `assets/videos/thaheen_offline_video_assets/`. The other
lessons play small placeholder clips (a few hundred KB each) generated with
`tool/sample_videos.swift` (AVFoundation, no ffmpeg). The physiology lesson
«الدورة الدموية الصغرى» has **no video file on purpose**, to demonstrate the
missing‑video error.

**Thumbnails** are public‑domain plates from Wikimedia Commons: Vesalius,
*De humani corporis fabrica* (1543); Gray's *Anatomy*, heart and lungs
(1918); Köhler's *Medizinal‑Pflanzen*, foxglove (1887).

**App icon and splash** are generated from the design with
`tool/app_icon.swift` and `flutter_native_splash`.

---

## Trade‑offs and known issues

- **Completion is position‑based.** Dragging the seek bar past 90% completes
  the lesson. Counting actually‑watched seconds would stop skipping, at the
  cost of more state; it's the first thing I'd change for a real LMS.
- **The deliberately missing video blocks its course.** Because unlock is
  sequential, physiology lessons after «الدورة الدموية الصغرى» can't be
  reached. That's the rule working as specified, but a real app would offer
  "report a problem" or let support unlock it.
- **Fullscreen is button‑only.** The app is portrait‑locked; rotating the
  phone doesn't enter fullscreen by itself.
- **Loading delay.** The 800 ms wait before data appears is intentional (to
  show loading states) and would be removed for release.
- **Whole‑map writes.** Progress is one JSON map rewritten on each save —
  fine for a handful of lessons, not for thousands.
- **Notes** can be added and used to seek, but not edited or deleted yet.
- **Platforms.** Checked most on the iOS simulator; the Android release APK
  builds, with less hands‑on time on Android devices.

---

## What I'd do with more time

### Downloadable, encrypted lessons

Real courses are too large to bundle, so lessons would be downloaded — and
paid content shouldn't sit on the device as plain MP4 files anyone can copy.

1. **Download** over HTTPS with resumable range requests, in the background,
   into app‑private storage that is excluded from backups.
2. **Encrypt at rest** with AES‑256‑GCM in fixed‑size chunks (e.g. 1 MB), so
   seeking only decrypts the chunks it needs. Each file gets its own random
   key, and those keys are wrapped by a device key kept in the iOS Keychain /
   Android Keystore (`flutter_secure_storage`).
3. **Play without writing plaintext to disk:** a small HTTP server bound to
   `127.0.0.1` (random port and token) decrypts chunks on the fly and serves
   byte ranges to `video_player`, which then streams it like any URL.
4. **Verify integrity** with a SHA‑256 from the course manifest, so a damaged
   download shows the existing "missing or corrupt video" state and offers a
   re‑download.
5. **Know the limits:** client‑side encryption stops casual copying (file
   managers, backups, sharing), not a determined attacker on a rooted
   device. For strong protection, use platform DRM — Widevine via ExoPlayer
   and FairPlay via AVPlayer — with a license server.

The architecture already allows this: only `LessonMediaRepository`'s
implementation changes. The player cubit and UI keep consuming
`Either<Failure, VideoPlayerController>`.

### Also

- **Watched‑time completion** (see trade‑offs) and server‑side progress sync.
- **Drift (SQLite)** once notes and progress grow, with note editing and search.
- **More widget and golden tests** (player controls, RTL/LTR screenshots in
  both themes) and **integration tests** on real devices.
- **CI** (GitHub Actions): analyze, test and build the APK on every push.
- Auto‑rotate into fullscreen, tablet layouts, and an accessibility pass
  (screen‑reader labels on every control, larger text sizes).
- Crash reporting and basic analytics.

---

## Time spent

About **4–6 hours**.

---

## Demo

- **APK:** `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
  (link: _add before sending_)
- **Screen recording (2–3 min):** _add link before sending_
