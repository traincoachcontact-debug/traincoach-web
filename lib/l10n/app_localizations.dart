// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Mapeo de todas las cadenas de texto de la app
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'settings_title': 'Settings',
      'account_security_section': 'ACCOUNT & SECURITY',
      'blocked_users_title': 'Blocked Users',
      'blocked_users_subtitle': 'Manage users you have blocked',
      'notifications_section': 'NOTIFICATIONS',
      'language_section': 'LANGUAGE',
      'select_language': 'Select Language',
      'measurement_section': 'MEASUREMENT SYSTEM',
      'measurement_system_select': 'Select System',
      'system_metric': 'Metric (kg, cm)',
      'system_imperial': 'Imperial (lbs, ft)',
      'logout_title': 'Log Out',
    },
    'es': {
      'settings_title': 'Ajustes',
      'account_security_section': 'CUENTA Y SEGURIDAD',
      'blocked_users_title': 'Usuarios Bloqueados',
      'blocked_users_subtitle': 'Gestiona los usuarios que has bloqueado',
      'notifications_section': 'NOTIFICACIONES',
      'language_section': 'IDIOMA',
      'select_language': 'Seleccionar Idioma',
      'measurement_section': 'SISTEMA DE MEDICIÓN',
      'measurement_system_select': 'Seleccionar Sistema',
      'system_metric': 'Métrico (kg, cm)',
      'system_imperial': 'Imperial (lbs, ft)',
      'logout_title': 'Cerrar Sesión',
    },
    'pt': {
      'settings_title': 'Configurações',
      'account_security_section': 'CONTA E SEGURANÇA',
      'blocked_users_title': 'Usuários Bloqueados',
      'blocked_users_subtitle': 'Gerencie usuários que você bloqueou',
      'notifications_section': 'NOTIFICAÇÕES',
      'language_section': 'IDIOMA',
      'select_language': 'Selecionar Idioma',
      'measurement_section': 'SISTEMA DE MEDIÇÃO',
      'measurement_system_select': 'Selecionar Sistema',
      'system_metric': 'Métrico (kg, cm)',
      'system_imperial': 'Imperial (lbs, ft)',
      'logout_title': 'Sair',
    },
  };

  static var delegate;

  // Getters para cada cadena
  String get settings_title => _localizedValues[locale.languageCode]!['settings_title']!;
  String get account_security_section => _localizedValues[locale.languageCode]!['account_security_section']!;
  String get blocked_users_title => _localizedValues[locale.languageCode]!['blocked_users_title']!;
  String get blocked_users_subtitle => _localizedValues[locale.languageCode]!['blocked_users_subtitle']!;
  String get notifications_section => _localizedValues[locale.languageCode]!['notifications_section']!;
  String get language_section => _localizedValues[locale.languageCode]!['language_section']!;
  String get select_language => _localizedValues[locale.languageCode]!['select_language']!;
  String get measurement_section => _localizedValues[locale.languageCode]!['measurement_section']!;
  String get measurement_system_select => _localizedValues[locale.languageCode]!['measurement_system_select']!;
  String get system_metric => _localizedValues[locale.languageCode]!['system_metric']!;
  String get system_imperial => _localizedValues[locale.languageCode]!['system_imperial']!;
  String get logout_title => _localizedValues[locale.languageCode]!['logout_title']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'pt'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}