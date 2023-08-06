import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uneconly/common/dependencies/dependencies_scope.dart';
import 'package:uneconly/common/localization/localization.dart';

/// Flutter code sample for [CupertinoPicker].

const double _kItemExtent = 32.0;
const List<String> _languageNames = <String>[
  'Русский',
  'English',
];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedLanguage = 0;

  @override
  void initState() {
    super.initState();

    RepositoryProvider.of<DependenciesScope>(context)
        .settingsRepository
        .getLanguage()
        .then((value) {
      if (value == 'ru') {
        setState(() {
          _selectedLanguage = 0;
        });
      } else if (value == 'en') {
        setState(() {
          _selectedLanguage = 1;
        });
      } else {
        setState(() {
          final defaultLocale = Platform.localeName;
          _selectedLanguage = defaultLocale.split('_')[0] == 'ru' ? 0 : 1;
        });
      }
    });
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
        ),
      ),
      body: DefaultTextStyle(
        style: TextStyle(
          color: CupertinoColors.label.resolveFrom(context),
          fontSize: 22.0,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('${AppLocalizations.of(context)!.language}: '),
              CupertinoButton(
                padding: EdgeInsets.zero,
                // Display a CupertinoPicker with list of fruits.
                onPressed: () => _showDialog(
                  CupertinoPicker(
                    magnification: 1.22,
                    squeeze: 1.2,
                    useMagnifier: true,
                    itemExtent: _kItemExtent,
                    // This sets the initial item.
                    scrollController: FixedExtentScrollController(
                      initialItem: _selectedLanguage,
                    ),
                    // This is called when selected item is changed.
                    onSelectedItemChanged: (int selectedItem) async {
                      setState(() {
                        _selectedLanguage = selectedItem;
                      });

                      if (_selectedLanguage == 0) {
                        await RepositoryProvider.of<DependenciesScope>(context)
                            .settingsRepository
                            .saveLanguage('ru');
                      } else {
                        await RepositoryProvider.of<DependenciesScope>(context)
                            .settingsRepository
                            .saveLanguage('en');
                      }
                    },
                    children: List<Widget>.generate(
                      _languageNames.length,
                      (int index) {
                        return Center(child: Text(_languageNames[index]));
                      },
                    ),
                  ),
                ),
                // This displays the selected fruit name.
                child: Text(
                  _languageNames[_selectedLanguage],
                  style: const TextStyle(
                    fontSize: 22.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
