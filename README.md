# Uneconly

Uneconly is cross-platform schedule app for SPbSUE university meant to make accessing, sharing and remembering schedule simple and accessible from any device

<a href="https://play.google.com/store/apps/details?id=com.roadmapik.uneconly">
    <img
        alt="Get it on Google Play"
        src="https://play.google.com/intl/en_us/badges/images/generic/en_badge_web_generic.png"
        width="330"
        height="128"
    />
</a>

<a href="https://apps.apple.com/ru/app/uneconly/id6448684369">
    <img
        alt="Get it on Mac App Store"
        src="assets/Download_on_the_Mac_App_Store_Badge_US-UK_RGB_blk_092917.svg"
        width="330"
        height="128"
    />
</a>

Currently Uneconly is in early release stage with many features to come later. You can view upcoming tasks in [Uneconly project](https://github.com/users/smart7even/projects/2)

Other options to view schedule: 
- [Official website](https://rasp.unecon.ru) 
- [Uneconly Telegram bot](https://t.me/schedule_unecon_bot)

# Bot

As mentioned above, there is fully functioning Uneconly Telegram bot where you can access your schedule

Github repository (Bot and Backend for Uneconly App): https://github.com/smart7even/schedule-bot

# Test coverage report

Generate test coverage report

```
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Open test coverage report

```
open coverage/html/index.html
```

