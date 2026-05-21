# SpendArc

SpendArc is a modern offline-first personal finance tracker built with Flutter using Clean Architecture, BLoC, and scalable production-level engineering practices.

This project is designed as a Senior Flutter Developer assessment implementation, demonstrating advanced state management, custom rendering, offline synchronization, and maintainable architecture design.

---

# Features

## Finance Dashboard

* Budget overview with visual progress
* Expense tracking system
* Transaction history management
* Summary analytics dashboard

## Custom Animations

* Circular Arc Meter using CustomPainter
* Line chart built from scratch using Canvas API
* Spring-based swipe-to-delete animation
* Particle burst animation on successful transaction addition

## State Management (BLoC)

* flutter_bloc architecture
* Immutable state handling
* Optimistic UI updates
* Rollback on failure
* Inter-bloc communication support

## Offline-First System

* Local storage using Hive
* Instant offline data rendering
* Background synchronization
* Diff-based update system
* Connectivity-aware updates

## Testing

* Unit tests for business logic
* Widget tests for UI components
* Repository and UseCase testing
* Bloc testing using bloc_test

---

# Architecture

SpendArc follows strict Clean Architecture principles for scalability and maintainability.

## Layers

### Presentation Layer

Responsible for:

* UI rendering
* BLoC state management
* User interactions
* Animations and UI logic

### Domain Layer

Responsible for:

* Business logic
* UseCases
* Entities
* Repository abstractions

### Data Layer

Responsible for:

* API integration
* Local database (Hive)
* Data models
* Repository implementation

---

# Tech Stack

* Flutter
* flutter_bloc
* get_it
* hive
* dartz
* go_router
* equatable
* connectivity_plus
* uuid
* intl

---

# Project Structure

lib/
│
├── core/
│   ├── error/
│   │   ├── failures.dart
│   │   ├── exceptions.dart
│   │   └── error_handler.dart
│   │
│   ├── usecase/
│   │   └── usecase.dart
│   │
│   ├── utils/
│   │   ├── constants.dart
│   │   ├── helpers.dart
│   │   └── extensions.dart
│   │
│   ├── di/
│   │   └── injector.dart
│   │
│   ├── network/
│   │   ├── api_client.dart
│   │   └── network_info.dart
│   │
│   └── theme/
│       ├── app_theme.dart
│       ├── colors.dart
│       └── text_styles.dart
│
├── features/
│   └── spend_arc/
│       ├── data/
│       │   ├── models/
│       │   ├── datasources/
│       │   └── repositories/
│       │
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       │
│       ├── presentation/
│       │   ├── bloc/
│       │   ├── pages/
│       │   ├── widgets/
│       │   └── animations/
│
├── app.dart
└── main.dart

---

# Key Engineering Decisions

## Clean Architecture

Ensures separation of concerns, scalability, testability, and maintainability by dividing the codebase into presentation, domain, and data layers.

## BLoC State Management

Provides predictable state transitions, reactive UI updates, and separation of business logic from UI.

## Either<Failure, T>

Used from dartz to handle errors in a functional way, replacing exception-based flow with explicit success/failure handling.

## Offline-First Approach

The application prioritizes local data rendering first, then synchronizes with remote sources in the background to ensure fast and reliable UX.

## Custom Render System

CustomPainter is used for advanced UI components like arc meter and line chart to achieve high performance and full rendering control.

---

# Getting Started

## Install dependencies

```bash
flutter pub get
```

## Run application

```bash
flutter run
```

## Generate Hive adapters

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

# Testing

```bash
flutter test
```

---

# Notes

* Built with production-level architecture principles
* Designed for scalability and maintainability
* Avoids business logic inside UI layer
* Optimized for interview evaluation and senior-level assessment scenarios
