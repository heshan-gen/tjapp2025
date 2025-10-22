import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final Color? iconColor;

  const LanguageSelectorWidget({
    super.key,
    this.iconColor,
  });

  @override
  Widget build(final BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (final context, final languageProvider, final child) {
        return PopupMenuButton<AppLanguage>(
          tooltip: languageProvider.languageTooltip,
          icon: Icon(
            languageProvider.languageIcon,
            color: iconColor,
          ),
          onSelected: (final AppLanguage language) {
            languageProvider.setLanguage(language);
          },
          itemBuilder: (final BuildContext context) => [
            PopupMenuItem<AppLanguage>(
              value: AppLanguage.english,
              child: Row(
                children: [
                  Icon(
                    languageProvider.currentLanguage == AppLanguage.english
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 20,
                    color:
                        languageProvider.currentLanguage == AppLanguage.english
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'English',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppLanguage>(
              value: AppLanguage.sinhala,
              child: Row(
                children: [
                  Icon(
                    languageProvider.currentLanguage == AppLanguage.sinhala
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 20,
                    color:
                        languageProvider.currentLanguage == AppLanguage.sinhala
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'සිංහල',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            PopupMenuItem<AppLanguage>(
              value: AppLanguage.tamil,
              child: Row(
                children: [
                  Icon(
                    languageProvider.currentLanguage == AppLanguage.tamil
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    size: 20,
                    color: languageProvider.currentLanguage == AppLanguage.tamil
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'தமிழ்',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
