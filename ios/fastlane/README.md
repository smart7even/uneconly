fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios build_beta

```sh
[bundle exec] fastlane ios build_beta
```

Build a signed App Store Connect IPA without uploading it

### ios beta

```sh
[bundle exec] fastlane ios beta
```

Build a release IPA and upload it to App Store Connect for TestFlight

### ios upload_beta

```sh
[bundle exec] fastlane ios upload_beta
```

Upload an existing IPA to App Store Connect for TestFlight

### ios verify_app_store_connection

```sh
[bundle exec] fastlane ios verify_app_store_connection
```

Verify App Store Connect API access without uploading anything

### ios prepare_app_store_release

```sh
[bundle exec] fastlane ios prepare_app_store_release
```

Create or update App Store version 2.0.0, metadata, screenshots, and build selection

### ios submit_app_store_release

```sh
[bundle exec] fastlane ios submit_app_store_release
```

Submit the prepared App Store version for review and release automatically after approval

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
