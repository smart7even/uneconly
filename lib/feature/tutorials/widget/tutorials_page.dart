import 'package:flutter/material.dart';
import 'package:octopus/octopus.dart';
import 'package:uneconly/common/routing/routes.dart';
import 'package:uneconly/common/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// {@template tutorials_page}
/// TutorialsPage widget
/// {@endtemplate}
class TutorialsPage extends StatelessWidget {
  /// {@macro tutorials_page}
  const TutorialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости и ссылки'),
      ),
      body: ListView(
        children: const [
          _UsefulLinks(),
        ],
      ),
    );
  }
}

class _UsefulLinks extends StatelessWidget {
  const _UsefulLinks();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.palette.nestedSurface,
      child: Column(
        children: [
          _LinkRow(
            icon: Icons.school_outlined,
            title: 'Сайт университета',
            subtitle: 'unecon.ru',
            onTap: () => launchUrl(Uri.parse('https://unecon.ru')),
          ),
          Divider(indent: 56, color: context.palette.hairline),
          _LinkRow(
            icon: Icons.calendar_month_outlined,
            title: 'Официальное расписание',
            subtitle: 'rasp.unecon.ru',
            onTap: () => launchUrl(Uri.parse('https://rasp.unecon.ru')),
          ),
          Divider(indent: 56, color: context.palette.hairline),
          _LinkRow(
            icon: Icons.widgets_outlined,
            title: 'Виджет на главном экране',
            subtitle: 'Как добавить расписание на экран телефона',
            onTap: () => context.octopus.push(Routes.homeWidgetTutorial),
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right, color: context.palette.muted),
        onTap: onTap,
      );
}
