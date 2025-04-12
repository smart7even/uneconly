import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';

export 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension LocalizationX on BuildContext {
  /// Returns the current localization.
  AppLocalizations get string => AppLocalizations.of(this)!;
}
