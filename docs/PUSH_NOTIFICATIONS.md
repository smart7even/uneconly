# Push notification verification

This runbook covers safe verification of Uneconly push notifications. It does
not contain credentials or device identifiers.

## Build configuration boundary

Android builds with real push delivery require
`android/app/google-services.json`. The production file is intentionally
ignored by Git and must be provisioned from the developer's local secret
storage or injected by CI before a release build. Do not print its contents in
CI logs. A clean checkout without that file is suitable for source review and
Flutter tests but is not a production-ready Android push build.

iOS signing and APNs/App Store Connect credentials are likewise machine-local
or service-managed and must not be added to the repository. See the separate
TestFlight deployment guide for the local Fastlane setup.

## What each test proves

- A simulator smoke test proves that the application can request notification
  permission, display a notification, and open after a notification tap.
- A physical-device TestFlight test proves the complete production path:
  AppMetrica campaign -> production APNs -> Uneconly.

Do not treat a successful simulator notification as proof that AppMetrica or
production APNs is configured correctly.

## End-to-end iOS test with TestFlight

Use a physical iPhone and the latest TestFlight build that contains the Push
SDK. At the time this guide was written, the first such build was `2.0.0 (56)`.

1. Install or update Uneconly from TestFlight.
2. Open the app with a working internet connection and allow notifications.
   If permission was denied previously, enable it under iOS Settings ->
   Notifications -> Uneconly. Reinstalling the app is useful when a completely
   clean first-launch test is required.
3. Keep the app open for a short time so that AppMetrica can receive the new
   session and push token.
4. In AppMetrica, open Reports -> Profile list. Find this device using only
   temporary filters such as:
   - platform: iOS;
   - application version and build number;
   - device model and OS version;
   - the most recent activity time.
5. Open the matching profile and copy its `appmetrica_device_id` for the test.
   Do not add this value to the repository, documentation, screenshots, issue
   descriptions, or logs.
6. Open Push campaigns, create a push for Uneconly, and enter a clearly
   recognizable test title and message. Keep the default action Open
   application for the first test.
7. In Test on the device, select the saved test device. If the list is empty,
   create one with the temporary AppMetrica Device ID from the profile and mark
   it for push-notification testing.
8. Click Test. Do not launch the campaign for the full audience merely to test
   one device.

The profile and token can take several minutes to appear after the first app
launch. If the device is missing, reopen Uneconly, confirm that the phone is
online and notification permission is enabled, then check Profile list again.

AppMetrica does not publish a separate guaranteed refresh interval for Profile
list. SDK events are buffered and sent in batches; its documented worst-case
event acceptance window is up to seven days. Do not wait that long before
checking configuration, however. If a TestFlight device is still absent after
30-60 minutes, first:

1. Confirm that the selected AppMetrica application is the production
   `Uneconly` application, not the development application. TestFlight is a
   release build and reports to production.
2. Clear all existing Profile list segmentation, then add only application
   version `2.0.0`. Add build number, device model, OS version, and last-start
   time as columns instead of requiring every value in the first filter.
3. Expand the profile-card event date range beyond its default week if needed.
4. Reopen the TestFlight app online and leave it active briefly. Then refresh
   the report after another few minutes.
5. Check the profile's notification-enabled attribute. A visible analytics
   profile does not by itself prove that AppMetrica received a usable APNs
   token.

The 30-60 minute checkpoint is an operational troubleshooting threshold, not
an AppMetrica SLA.

## Required scenarios

Send a separate recognizable test notification in each state:

1. Uneconly is in the foreground: the notification is shown and the app remains
   usable.
2. Uneconly is in the background: the notification appears in Notification
   Center; tapping it returns to the existing application session.
3. Uneconly is terminated from the app switcher: the notification appears;
   tapping it launches Uneconly and the schedule opens normally.
4. After the tap, AppMetrica's push-campaign report records an open. Allow time
   for reporting delay.

Also verify that an ordinary app launch still works when the phone is offline
or AppMetrica is temporarily unavailable. Push initialization must never block
schedule startup.

The production path is accepted when all three app states receive the test
notification, both tap paths work, and no startup or schedule regression is
observed. On iOS, the default delivered metric may only be confirmed when the
notification is opened unless separate delivery statistics are configured.

## Simulator smoke test

The simulator does not receive the real AppMetrica-to-production-APNs message.
Use it only for a deterministic UI/lifecycle smoke test.

Run Uneconly on a booted iOS simulator, accept notification permission, and
create a temporary payload outside the repository:

```sh
cat > /tmp/uneconly-notification.apns <<'JSON'
{
  "aps": {
    "alert": {
      "title": "Uneconly test",
      "body": "Local simulator notification"
    },
    "sound": "default",
    "badge": 1
  }
}
JSON
```

Deliver it while the app is installed:

```sh
xcrun simctl push booted com.roadmapik.uneconly \
  /tmp/uneconly-notification.apns
```

Repeat after putting the app in the background and after terminating it:

```sh
xcrun simctl terminate booted com.roadmapik.uneconly
xcrun simctl push booted com.roadmapik.uneconly \
  /tmp/uneconly-notification.apns
```

Tap the notification and confirm that Uneconly launches. UI interaction can be
automated with Meta `idb` when repeatability is needed, but the injected
notification still proves only the local simulator path.

## Troubleshooting

- No iOS permission prompt: inspect iOS Settings -> Notifications -> Uneconly.
  The app intentionally avoids repeatedly showing the system request.
- Test device is absent in AppMetrica: allow several minutes, reopen the
  TestFlight build online, confirm that the production AppMetrica application
  is selected, clear old segmentation, and then filter Profile list by version
  and recent time.
- Debug build does not receive the AppMetrica test push: use TestFlight. The
  current AppMetrica certificate is for the production APNs environment.
- Notification arrives but tapping does not open the app: repeat the terminated
  scenario and record the iOS version, Uneconly build number, campaign name,
  and non-sensitive timestamps.
- Nothing arrives: confirm the installed build, iOS notification permission,
  selected test profile, production iOS credentials in AppMetrica, and that the
  profile has a recent push token.

## Secret-handling boundary

Never commit or paste the following into project documentation:

- APNs `.p8` or `.p12` files and their passwords;
- App Store Connect, Firebase, or AppMetrica credentials;
- FCM service-account JSON;
- APNs/FCM push tokens;
- AppMetrica Device IDs or other real device identifiers.

Store credentials in the machine-local secret location or a secret manager.
Documentation should contain only placeholders and navigation instructions.
Blur identifiers before attaching screenshots.

## References

- [Launching an AppMetrica push campaign](https://appmetrica.yandex.com/docs/en/push/marketing)
- [Managing AppMetrica test devices](https://appmetrica.yandex.com/docs/en/settings/test-devices)
- [Configuring iOS push credentials](https://appmetrica.yandex.com/docs/en/sdk/ios/push/ios-settings)
