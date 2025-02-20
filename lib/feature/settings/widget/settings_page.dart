import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:l/l.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/model/dependencies.dart';
import 'package:uneconly/common/utils/colors_utils.dart';
import 'package:uneconly/common/utils/pubspec.yaml.g.dart';
import 'package:uneconly/feature/settings/bloc/settings_bloc.dart';
import 'package:uneconly/feature/settings/model/settings_entity.dart';
import 'package:uneconly/feature/settings/widget/settings_tile.dart';

// const double _kItemExtent = 32.0;
// const List<String> _languageNames = <String>[
//   'Русский',
//   'English',
// ];

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // int _selectedLanguage = 0;

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

    // final dependenciesScope = Dependencies.of(context);

    // dependenciesScope.settingsRepository.getLanguage().then((value) {
    //   if (value == 'ru') {
    //     setState(() {
    //       _selectedLanguage = 0;
    //     });
    //   } else if (value == 'en') {
    //     setState(() {
    //       _selectedLanguage = 1;
    //     });
    //   } else {
    //     setState(() {
    //       final defaultLocale = Platform.localeName;
    //       _selectedLanguage = defaultLocale.split('_')[0] == 'ru' ? 0 : 1;
    //     });
    //   }
    // });
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  // void _showDialog(Widget child) {
  //   showCupertinoModalPopup<void>(
  //     context: context,
  //     builder: (BuildContext context) => Container(
  //       height: 216,
  //       padding: const EdgeInsets.only(top: 6.0),
  //       // The Bottom margin is provided to align the popup above the system navigation bar.
  //       margin: EdgeInsets.only(
  //         bottom: MediaQuery.of(context).viewInsets.bottom,
  //       ),
  //       // Provide a background color for the popup.
  //       color: CupertinoColors.systemBackground.resolveFrom(context),
  //       // Use a SafeArea widget to avoid system overlaps.
  //       child: SafeArea(
  //         top: false,
  //         child: child,
  //       ),
  //     ),
  //   );
  // }

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
        child: BlocProvider(
          create: (context) => SettingsBLoC(
            repository: Dependencies.of(context).settingsRepository,
          )..add(
              const SettingsEvent.read(),
            ),
          child: BlocBuilder<SettingsBLoC, SettingsState>(
            builder: (context, state) {
              final selectedColor = getColorFromString(state.data.themeColor);

              return Center(
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
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SettingsTile(
                          title: AppLocalizations.of(context)!.appVersion,
                          description: version,
                        ),
                        const SizedBox(height: 15),
                        SettingsTile(
                          title: AppLocalizations.of(context)!.licenses,
                          description:
                              AppLocalizations.of(context)!.showLicenses,
                          onPressed: () {
                            showLicensePage(
                              context: context,
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        SettingsTile(
                          title: AppLocalizations.of(context)!.cache,
                          description: AppLocalizations.of(context)!.clearCache,
                          onPressed: () async {
                            final settingsRepository =
                                Dependencies.of(context).settingsRepository;

                            try {
                              final isCacheEmpty =
                                  await settingsRepository.isAppCacheEmpty();

                              if (isCacheEmpty) {
                                l.vvvv('Nothing to clear');

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .cacheIsEmpty,
                                      ),
                                    ),
                                  );
                                }

                                return;
                              }

                              l.vvvv('Cache is not empty and may be cleared');
                              await settingsRepository.clearAppCache();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .cacheIsCleared,
                                    ),
                                  ),
                                );
                              }
                            } on Exception catch (e) {
                              l.vvvv(e);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(context)!
                                          .errorWhileCleaningCache,
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        child: Text(
                          '${AppLocalizations.of(context)!.theme}: ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
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
                              context.read<SettingsBLoC>().add(
                                    SettingsEvent.update(
                                      entity: SettingsEntity(
                                        themeColor: getStringFromColor(
                                          colors[index],
                                        ),
                                      ),
                                    ),
                                  );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                                border: selectedColor == colors[index]
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
                                    borderRadius:
                                        BorderRadius.circular(10 / 1.25),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

class ColoredWidget extends StatefulWidget {
  final VoidCallback? onPressed;

  const ColoredWidget({
    super.key,
    this.onPressed,
  });

  @override
  State<ColoredWidget> createState() => _ColoredWidgetState();
}

class _ColoredWidgetState extends State<ColoredWidget> {
  Color color = Colors.black;

  @override
  void initState() {
    super.initState();
    color = _generateColor();
  }

  Color _generateColor() {
    final random = Random();

    return Color.fromARGB(
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
      random.nextInt(255),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed,
      child: Container(
        color: color,
        height: 100,
        width: 100,
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
