import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/theme/app_theme.dart';

class CalendarPermissionModal extends StatelessWidget {
  const CalendarPermissionModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: context.palette.hairline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.string.grantCalendarPermission,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Без доступа к календарю пары добавить не получится. '
              'Разрешить доступ можно в настройках телефона.',
              style: TextStyle(color: context.palette.muted),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await AppSettings.openAppSettings();
                  if (context.mounted) Navigator.of(context).pop();
                },
                child: const Text('Открыть настройки'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} // CalendarBlock
