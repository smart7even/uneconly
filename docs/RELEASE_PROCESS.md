# Release process

The iOS release order is deliberately split into two parallel tracks:

1. Commit the complete release candidate and bump `pubspec.yaml`.
2. Upload the signed build to TestFlight.
3. At the same time, run the local core release gate on one Android emulator
   and one iOS simulator.
4. Wait for both TestFlight `VALID` and a green local gate.
5. Prepare and verify the App Store card, then submit it for review.

Run the two tracks from separate terminals:

```sh
cd ios
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios beta \
  build_name:2.0.0 build_number:60
```

```sh
make core-release-gate \
  ANDROID_DEVICE=emulator-5554 \
  IOS_DEVICE=<booted-simulator-uuid>
```

The gate regenerates sources and localization, checks the in-app version,
runs static analysis and every Flutter test, builds the Android release APK,
and executes the same real-user smoke journey on Android and iOS. Successful
completion writes ignored, machine-local evidence to
`.dart_tool/release_gate.json`. The App Store submission lane rejects missing,
stale, wrong-version, wrong-commit, or single-platform evidence.

After App Store Connect reports the TestFlight build as `VALID`:

```sh
cd ios
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios prepare_app_store_release \
  app_version:2.0.0 build_number:60
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios submit_app_store_release \
  app_version:2.0.0 build_number:60
```

## Core scenarios

The release gate must cover these product contracts:

- first launch loads the group list and selecting a group opens a usable week;
- current schedule, adjacent-week navigation, another-group viewing, and return
  to the user's own group work through the real UI;
- cached schedule content appears promptly after a full app recreation while
  network requests remain pending;
- a slow established response is bounded, and auxiliary startup services never
  block the first useful screen;
- unpublished weeks and legitimately published all-free weeks remain distinct;
- the university turquoise theme is the default, another accent can be selected,
  and the preference persists;
- calendar synchronization does not delay schedule rendering, does not touch old
  events for an unpublished week, clears a published all-free week, and remains
  duplicate-free on repeated synchronization;
- the iOS widget has a valid extension in the IPA and renders useful current or
  next-day content from both network and cache;
- push activation failure cannot block startup;
- Runner and every bundled extension use the intended version/build and the IPA
  has a valid signature before upload.

The automated suite covers the data and navigation contracts. When calendar,
widget, notification, entitlement, or native iOS code changes, also exercise
that affected system integration on the simulator or a physical device before
submission and record the evidence in `PROJECT_HANDOFF.md`.
