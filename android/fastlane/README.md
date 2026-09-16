fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## Android

### android verify_google_play_connection

```sh
[bundle exec] fastlane android verify_google_play_connection
```

Verify Google Play API access without changing store state

### android validate_release

```sh
[bundle exec] fastlane android validate_release
```

Build, inspect, and validate a production release without publishing it

### android release

```sh
[bundle exec] fastlane android release
```

Build, validate, and publish a completed production release to Google Play

### android deploy

```sh
[bundle exec] fastlane android deploy
```

Backward-compatible alias for the production release lane

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
