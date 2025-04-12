import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/widget/app_button.dart';

class CalendarPermissionModal extends StatelessWidget {
  const CalendarPermissionModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Close button
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 8,
              top: 8,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: IconButton(
                color: Theme.of(context).colorScheme.onSurface,
                icon: const Icon(Icons.close),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.string.grantCalendarPermission,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  context.string.calendarPermissionDescription,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButton(
                    title: context.string.goToSettings,
                    onPressed: () async {
                      await AppSettings.openAppSettings();
                      // Close the modal after opening settings
                      Navigator.of(context).pop();
                    },
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
} // CalendarBlock
