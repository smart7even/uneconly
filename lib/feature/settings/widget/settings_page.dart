import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/utils/colors_utils.dart';

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
  int _selectedColor = 0;

  List<MaterialColor> colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.indigo,
    Colors.teal,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
  ];

  @override
  void initState() {
    super.initState();

    final dependenciesScope = Dependencies.of(context);

    dependenciesScope.settingsRepository.getLanguage().then((value) {
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

    dependenciesScope.settingsRepository.getTheme().then((value) {
      if (value == null) {
        setState(() {
          _selectedColor = 0;
        });
      } else {
        final materialColor = getColorFromString(value);

        final selectedColor = colors.indexWhere(
          (element) => element == materialColor,
        );

        setState(() {
          _selectedColor = selectedColor;
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     Text('${AppLocalizations.of(context)!.language}: '),
              //     CupertinoButton(
              //       padding: EdgeInsets.zero,
              //       // Display a CupertinoPicker with list of fruits.
              //       onPressed: () => _showDialog(
              //         CupertinoPicker(
              //           magnification: 1.22,
              //           squeeze: 1.2,
              //           useMagnifier: true,
              //           itemExtent: _kItemExtent,
              //           // This sets the initial item.
              //           scrollController: FixedExtentScrollController(
              //             initialItem: _selectedLanguage,
              //           ),
              //           // This is called when selected item is changed.
              //           onSelectedItemChanged: (int selectedItem) async {
              //             setState(() {
              //               _selectedLanguage = selectedItem;
              //             });

              //             if (_selectedLanguage == 0) {
              //               await RepositoryProvider.of<DependenciesScope>(
              //                 context,
              //               ).settingsRepository.saveLanguage('ru');
              //             } else {
              //               await RepositoryProvider.of<DependenciesScope>(
              //                 context,
              //               ).settingsRepository.saveLanguage('en');
              //             }
              //           },
              //           children: List<Widget>.generate(
              //             _languageNames.length,
              //             (int index) {
              //               return Center(child: Text(_languageNames[index]));
              //             },
              //           ),
              //         ),
              //       ),
              //       // This displays the selected fruit name.
              //       child: Text(
              //         _languageNames[_selectedLanguage],
              //         style: const TextStyle(
              //           fontSize: 22.0,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),

              // Open ListSectionInsetExample widget
              // CupertinoButton(
              //   onPressed: () {
              //     Navigator.of(context).push(
              //       CupertinoPageRoute<void>(
              //         builder: (BuildContext context) {
              //           return const ListSectionInsetExample();
              //         },
              //       ),
              //     );
              //   },
              //   child: const Text('Open ListSectionInsetExample'),
              // ),

              Text('${AppLocalizations.of(context)!.theme}: '),
              const SizedBox(height: 10),
              // horizontal list of themes
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: colors.length,
                  // remove shrinkWrap if there will be a lot of themes
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        await Dependencies.of(context)
                            .settingsRepository
                            .saveTheme(
                              getStringFromColor(colors[index]),
                            );
                        setState(() {
                          _selectedColor = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: _selectedColor == index
                              ? Border.all(
                                  color: Colors.blue,
                                  width: 2,
                                )
                              : null,
                        ),
                        child: Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10 / 1.25),
                              color: colors[index],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      width: 10,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CupertinoListSectionInsetApp extends StatelessWidget {
  const CupertinoListSectionInsetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: ListSectionInsetExample(),
    );
  }
}

class ListSectionInsetExample extends StatefulWidget {
  const ListSectionInsetExample({super.key});

  @override
  State<ListSectionInsetExample> createState() =>
      _ListSectionInsetExampleState();
}

class _ListSectionInsetExampleState extends State<ListSectionInsetExample> {
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListSectionInsetExample'),
      ),
      body: CupertinoListSection.insetGrouped(
        header: const Text('My Settings'),
        children: <CupertinoListTile>[
          CupertinoListTile.notched(
            title: const Text('Open pull request'),
            leading: Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.activeGreen,
            ),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const _SecondPage(text: 'Open pull request');
                },
              ),
            ),
          ),
          CupertinoListTile.notched(
            title: const Text('Push to master'),
            leading: Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.systemRed,
            ),
            additionalInfo: const Text('Not available'),
          ),
          CupertinoListTile.notched(
            title: const Text('View last commit'),
            leading: Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.activeOrange,
            ),
            additionalInfo: const Text('12 days ago'),
            trailing: const CupertinoListTileChevron(),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const _SecondPage(text: 'Last commit');
                },
              ),
            ),
          ),
          CupertinoListTile.notched(
            title: const Text('Notifications'),
            leading: Container(
              width: double.infinity,
              height: double.infinity,
              color: CupertinoColors.activeBlue,
            ),
            trailing: CupertinoSwitch(
              value: _isNotificationsEnabled,
              onChanged: (value) {
                setState(
                  () {
                    _isNotificationsEnabled = value;
                  },
                );
              },
            ),
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute<void>(
                builder: (BuildContext context) {
                  return const _SecondPage(text: 'Last commit');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondPage extends StatelessWidget {
  const _SecondPage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}
