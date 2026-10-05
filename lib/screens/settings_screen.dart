import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final favorites = context.watch<FavoritesProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Тема', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('Авто')),
              ButtonSegment(value: ThemeMode.light, label: Text('Светлая')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Тёмная')),
            ],
            selected: {settings.themeMode},
            onSelectionChanged: (s) => settings.setThemeMode(s.first),
          ),
          const SizedBox(height: 24),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.favorite),
            title: const Text('Избранное'),
            subtitle: Text('Сохранено картин: ${favorites.items.length}'),
            trailing: TextButton(
              onPressed: favorites.items.isEmpty
                  ? null
                  : () => _confirmClear(context, favorites),
              child: const Text('Очистить'),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: const Text('О приложении'),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'Art Gallery',
              children: const [
                Text('Данные и картины: публичный API '
                    'Cleveland Museum of Art Open Access (CC0).'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClear(
      BuildContext context, FavoritesProvider favorites) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Очистить избранное?'),
        content: const Text('Все сохранённые картины пропадут.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
    if (ok == true) await favorites.clear();
  }
}
