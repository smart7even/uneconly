import 'package:flutter/material.dart';
import 'package:uneconly/common/localization/localization.dart';
import 'package:uneconly/common/theme/app_theme.dart';

const _homeWidgetTutorialVideoUrl = String.fromEnvironment(
  'HOME_WIDGET_TUTORIAL',
);

class HomeWidgetTutorial extends StatelessWidget {
  const HomeWidgetTutorial({
    super.key,
    this.videoUrl = _homeWidgetTutorialVideoUrl,
  });

  final String videoUrl;

  void _showVideo(BuildContext context) {
    if (videoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Видео сейчас недоступно')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HomeWidgetVideoPage(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.string.homeWidget),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text(
            'Расписание — прямо на главном экране',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Виджет показывает ближайшие пары без открытия приложения.',
            style: TextStyle(color: context.palette.muted),
          ),
          const SizedBox(height: 24),
          const _Step(
            number: 1,
            title: 'Нажмите и удерживайте пустое место',
            subtitle: 'На главном экране телефона откроется меню настройки.',
          ),
          const _Step(
            number: 2,
            title: 'Выберите «Виджеты»',
            subtitle: 'Иногда пункт находится в меню «Настроить экран».',
          ),
          const _Step(
            number: 3,
            title: 'Найдите Uneconly и добавьте виджет',
            subtitle: 'Размер и положение можно изменить после добавления.',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.palette.nestedSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: context.palette.accent),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Названия пунктов могут немного отличаться в зависимости от модели телефона.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('home-widget-video-link'),
              onPressed: () => _showVideo(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Посмотреть видео'),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeWidgetVideoPage extends StatelessWidget {
  const HomeWidgetVideoPage({
    required this.videoUrl,
    super.key,
  });

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Видеоинструкция')),
      body: ColoredBox(
        color: context.palette.nestedSurface,
        child: SafeArea(
          child: Center(
            child: Image.network(
              videoUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              semanticLabel: 'Как добавить виджет Uneconly',
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;

                final expectedBytes = loadingProgress.expectedTotalBytes;
                return CircularProgressIndicator(
                  value: expectedBytes == null
                      ? null
                      : loadingProgress.cumulativeBytesLoaded / expectedBytes,
                );
              },
              errorBuilder: (context, error, stackTrace) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_outlined,
                      size: 40,
                      color: context.palette.muted,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Не удалось загрузить видео',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Проверьте подключение к интернету и попробуйте снова.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: context.palette.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  final int number;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 22),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.palette.ink,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$number',
                style: TextStyle(
                  color: context.palette.surface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: context.palette.muted)),
                ],
              ),
            ),
          ],
        ),
      );
}
