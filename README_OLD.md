# 🚴 Ride Crew

**Your intelligent cycling assistant** - A Local-First Flutter app for amateur cyclists.

## 📋 Overview

Ride Crew is a comprehensive cycling assistant that helps you with:
- 🌤️ **Weather-based outfit suggestions**
- 📊 **Biometric tracking** (HRV, sleep, weight)
- 🗺️ **GPX route planning**
- 🔧 **Bicycle maintenance tracking**

## 🏗️ Architecture

- **Framework:** Flutter (Dart)
- **Database:** Isar (Local-First, embedded)
- **Design:** Material 3
- **External APIs:** Open-Meteo (free weather data)
- **Cost:** 100% free - no backend required!

## 🚀 Current Status: FASE 2 Complete ✅

### Implemented Features

**FASE 1: Database & Setup**
- ✅ Flutter project setup with Material 3
- ✅ Isar database configuration
- ✅ 4 core data models:
  - `UserProfile` - Biometric data & thermal sensitivity
  - `Bicycle` - Bike management & maintenance
  - `PlannedRide` - Route planning with GPX support
  - `HealthSnapshot` - Daily health metrics
- ✅ `DatabaseService` singleton with full CRUD operations
- ✅ Google Fonts integration (Inter)
- ✅ Light/Dark theme support

**FASE 2: Outfit Suggestion Logic**
- ✅ `OutfitService` - Intelligent outfit recommendations
- ✅ Temperature-based clothing suggestions (5 ranges)
- ✅ Thermal sensitivity adjustments (1-5 scale)
- ✅ Wind protection logic (>20 km/h, >30 km/h)
- ✅ Elevation-based recommendations (>500m = windbreaker)
- ✅ Detailed reasoning generation
- ✅ 21 comprehensive unit tests

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user_profile.dart        # Biometric data
│   ├── bicycle.dart             # Bike management
│   ├── planned_ride.dart        # Route planning
│   ├── health_snapshot.dart     # Daily health metrics
│   ├── clothing_item.dart       # Clothing enum
│   ├── weather_conditions.dart  # Weather data
│   └── outfit_suggestion.dart   # Outfit recommendations
└── services/
    ├── database_service.dart    # Database singleton
    └── outfit_service.dart      # Outfit algorithm
```

## 🗺️ Roadmap

### FASE 2: Core Logic ✅
- ✅ Outfit suggestion algorithm ("Butler Advice")
- ✅ Thermal sensitivity calculations
- [ ] Weather integration with Open-Meteo API

### FASE 3: GPX & Maps
- [ ] GPX file import & parsing
- [ ] Route visualization with flutter_map
- [ ] Elevation & distance extraction

### FASE 4: Dashboard
- [ ] Readiness score (HRV + sleep)
- [ ] Upcoming ride preview
- [ ] Health trends (7-day sparklines)
- [ ] Apple Health / Google Fit sync

### FASE 5: Onboarding & Backup
- [ ] 3-step onboarding wizard
- [ ] JSON backup/restore
- [ ] First bike setup

## 🔍 Database Inspection

To inspect the Isar database during development:

```bash
flutter pub run isar_inspector
```

## 📄 License

This project is private and not licensed for public use.

## 👨‍💻 Development

Built with ❤️ using Flutter and Isar for a truly local-first experience.
