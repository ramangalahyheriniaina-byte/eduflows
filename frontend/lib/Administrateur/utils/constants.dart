import 'package:flutter/material.dart';

class AppConstants {
  // Application
  static const String appName = 'Course Manager';

  // Dates
  static const List<String> months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
  ];

  static const List<String> weekdays = [
    'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'
  ];

  static const List<String> weekdaysShort = [
    'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'
  ];

  // Couleurs (valeur hexadécimale seulement)
  static const int primaryColorValue = 0xFF6BA5BD;

  // Méthode pour obtenir la couleur
  static Color get primaryColor => const Color(primaryColorValue);
}