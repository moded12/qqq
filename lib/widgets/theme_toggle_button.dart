// 📄 lib/widgets/theme_toggle_button.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDark;

    return IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            RotationTransition(turns: animation, child: child),
        child: Icon(
          isDark ? Icons.nights_stay : Icons.wb_sunny,
          key: ValueKey<bool>(isDark),
          color: isDark ? Colors.yellow[600] : Colors.orange[600],
        ),
      ),
      onPressed: () {
        themeNotifier.toggleTheme();
      },
      tooltip: 'تبديل الوضع الليلي',
    );
  }
}
