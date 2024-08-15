# FamilyFeast

Eine Organisations-App für Haushalte, um die wöchentliche Planung von Essen und Einkäufen zu
erleichtern sowie Rezepte anzulegen und miteinander zu teilen.

## Gruppenmitglieder

- Robert Gehrmann
- Sandra Heller
- Eva-Maria Maurer
- Alexander Paul
- Dennis Roukis

## Plattformen

Die App ist für Android und iOS verfügbar, wurde jedoch nur auf Android getestet.

## Features

- Registrierung und Anmeldung mit E-Mail und Passwort
- Erstellung und Beitreten eines Haushalts
- [...]

## Technologien

- Flutter (Dart)
- Supabase Datenbank
- Google Drive
- GitHub
- Discord

## Installation

### Vorraussetzungen

- Flutter SDK
- IDE (Android Studio)
- Android Emulator oder Android-Gerät

### Initial

- Flutter installieren
- IDE (Android Studio) installieren
- Flutter-Plugin für IDE installieren
- IDE starten und Flutter SDK Pfad hinterlegen
- Projetklon herunterladen
- Packages per `flutter pub get` installieren
- Emulator starten oder Android-Gerät anschließen
- App per `flutter run` starten

### Nützliche Befehle

- `flutter doctor` - Überprüft, ob alle Voraussetzungen erfüllt sind
- `flutter test` - Führt Tests aus
- `flutter format` - Formatier den Code
- `flutter pub upgrade` - Updatet alle Packages
- `dart run build_runner watch` - Generiert Code für JSON-Serialisierung und aktualisiert bei
  Änderungen (wie für die Routen)

### Screens/Routen hinzufügen

- den Code `@RoutePage()` über der Klasse im jeweiligen Screen hinzufügen
- in `lib/routes/app_router.dart` die Route hinzufügen
- `dart run build_runner watch` ausführen, um die Routen zu generieren

## Dokumentation

Die Dokumentation erfolgt über [...]

