// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum para el sistema de medición
enum MeasurementSystem { metric, imperial }

class SettingsProvider with ChangeNotifier {
  Locale? _locale;
  MeasurementSystem _measurementSystem = MeasurementSystem.metric; // Por defecto

  // Getters para acceder a los valores actuales
  Locale? get locale => _locale;
  MeasurementSystem get measurementSystem => _measurementSystem;

  SettingsProvider() {
    _loadSettings(); // Cargar ajustes guardados al iniciar
  }

  // --- Lógica para el Idioma ---
  void setLocale(Locale newLocale) {
    if (_locale == newLocale) return;
    _locale = newLocale;
    _saveLocaleToPrefs(newLocale); // Guardar en SharedPreferences
    notifyListeners(); // Notificar a los widgets que escuchan para que se reconstruyan
  }

  Future<void> _saveLocaleToPrefs(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  // --- Lógica para el Sistema de Medición ---
  void setMeasurementSystem(MeasurementSystem newSystem) {
    if (_measurementSystem == newSystem) return;
    _measurementSystem = newSystem;
    _saveMeasurementSystemToPrefs(newSystem);
    notifyListeners();
  }

  Future<void> _saveMeasurementSystemToPrefs(MeasurementSystem system) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('measurementSystem', system.toString());
  }

  // --- Cargar Ajustes Guardados ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Cargar idioma
    final languageCode = prefs.getString('languageCode');
    if (languageCode != null) {
      _locale = Locale(languageCode);
    }

    // Cargar sistema de medición
    final systemString = prefs.getString('measurementSystem');
    if (systemString != null && systemString == MeasurementSystem.imperial.toString()) {
      _measurementSystem = MeasurementSystem.imperial;
    } else {
      _measurementSystem = MeasurementSystem.metric;
    }

    // Notificar a los oyentes después de cargar
    notifyListeners();
  }
}