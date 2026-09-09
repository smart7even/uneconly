# TestFlight deployment

The TestFlight lanes authenticate with an App Store Connect API key. They do
not use an Apple ID password, an app-specific password, or a reusable Fastlane
web session, so the upload step does not require interactive two-factor
authentication.

## One-time App Store Connect setup

Create an API key in App Store Connect and download its `.p8` private key. The
file can only be downloaded once.

- A team API key is the appropriate option for this build-sign-upload lane:
  unlike an individual key, it can authenticate Xcode automatic provisioning.
  Team keys are account-wide, so select the least role that still covers the
  intended App Store Connect operations.
- Individual API keys are created by each person from their App Store Connect
  profile. The central `Users and Access > Integrations > Individual Keys`
  page only lists keys that team members have created; it is not the creation
  screen. Individual keys inherit that person's app access and do not support
  Xcode provisioning.

Keep the `.p8` file outside the repository and restrict its permissions:

```sh
mkdir -p "$HOME/.config/uneconly"
mv /path/to/AuthKey_KEYID.p8 "$HOME/.config/uneconly/"
chmod 600 "$HOME/.config/uneconly/AuthKey_KEYID.p8"
```

Set these variables in the shell or a local secret manager:

```sh
export APP_STORE_CONNECT_API_KEY_ID="KEYID"
export APP_STORE_CONNECT_API_KEY_PATH="$HOME/.config/uneconly/AuthKey_KEYID.p8"
```

For a team key, also set its issuer ID. Omit this variable for an individual
key:

```sh
export APP_STORE_CONNECT_API_ISSUER_ID="00000000-0000-0000-0000-000000000000"
```

Never commit the key or these values to the repository.

For local use, the same variables can be stored in
`~/.config/uneconly/app-store-connect.env`; the Fastfile loads that file when
it exists. Keep it outside the repository with permissions `600`.

## Install the pinned Fastlane version

Fastlane requires Ruby 3 or later. On an Apple Silicon Mac with Homebrew Ruby:

```sh
cd ios
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle install
```

Keep that Ruby path active when running `bundle exec` if the shell otherwise
selects macOS system Ruby.

## Build and upload

From the `ios` directory:

Verify the API key without changing App Store Connect:

```sh
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios verify_app_store_connection
```

Build and upload:

```sh
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios beta
```

The lane updates Flutter's release configuration, passes the team API key to
`xcodebuild` for automatic provisioning, exports an App Store Connect IPA, and
then uploads it. The Flutter version and build number are applied to the app
and every extension so App Store Connect sees matching versions. Flutter reads
them from `pubspec.yaml`; they can be overridden explicitly:

```sh
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios beta \
  build_name:1.15.0 build_number:50
```

To upload an IPA that has already been built:

```sh
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios upload_beta \
  ipa:/absolute/path/to/uneconly.ipa
```

To test signing and export without uploading anything:

```sh
PATH="/opt/homebrew/opt/ruby/bin:$PATH" bundle exec fastlane ios build_beta
```

The lanes upload the build and exit without assigning testers, changing beta
metadata, or submitting an external TestFlight review. Those actions remain a
separate, deliberate App Store Connect step.

## Signing boundary

The team API key authenticates both App Store Connect upload and Xcode automatic
provisioning. `xcodebuild` may create or update signing assets when the current
ones are absent or expired. This requires the key to have the appropriate
Certificates, Identifiers & Profiles permissions.
