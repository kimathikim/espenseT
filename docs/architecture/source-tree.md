# Source Tree Structure

This document defines the directory structure for the M-Pesa Expense Tracker project, covering both the Flutter application and the Supabase backend configuration.

## 1. Root Directory

The root of the project will contain configuration files and the main source directories.

```
.
├── .bmad-core/         # Core configuration for the BMad agents
├── .github/            # GitHub-specific files, including CI/CD workflows
├── docs/               # Project documentation (PRD, Architecture, Stories)
├── lib/                # Main Flutter application source code
├── supabase/           # Supabase backend configuration and functions
├── test/               # Flutter application tests
├── .gitignore          # Git ignore file
├── pubspec.yaml        # Flutter project dependencies and metadata
└── README.md           # Project overview
```

## 2. Flutter Application (`lib/`)

The Flutter application code resides in the `lib/` directory and follows a feature-first structure.

```
lib/
├── main.dart               # App entry point and initialization
└── src/
    ├── core/
    │   ├── services/       # Core singleton services (e.g., Supabase client, API client)
    │   │   ├── supabase_service.dart
    │   │   └── ...
    │   └── utils/          # Utility functions, constants, and extensions
    │       ├── constants.dart
    │       └── ...
    ├── features/
    │   ├── auth/           # Authentication feature
    │   │   ├── data/       # Data layer (repository, data sources)
    │   │   ├── domain/     # Domain layer (entities, use cases)
    │   │   ├── presentation/ # UI layer (screens, widgets, state)
    │   │   │   ├── screens/
    │   │   │   └── widgets/
    │   │   └── auth_providers.dart # Feature-specific Riverpod providers
    │   ├── transactions/   # Transaction list, detail, categorization
    │   │   └── ...         # (Follows same data/domain/presentation structure)
    │   ├── dashboard/      # Dashboard and visualizations
    │   │   └── ...
    │   └── categories/     # Category management
    │       └── ...
    └── shared/
        ├── models/         # Shared data models/entities
        ├── widgets/        # Reusable widgets used across multiple features
        └── state/          # Shared application-wide state (e.g., Riverpod providers)
```

## 3. Supabase Backend (`supabase/`)

The Supabase directory contains all backend-related code and configuration, managed via the Supabase CLI.

```
supabase/
├── functions/
│   └── sync-mpesa-transactions/
│       ├── index.ts            # Main entry point for the Edge Function
│       └── tsconfig.json       # TypeScript configuration
├── migrations/
│   └── <timestamp>_initial_schema.sql # SQL for database schema changes
└── config.toml                 # Supabase project configuration
```

This structure ensures a clear separation of concerns between the frontend and backend, and within the Flutter application itself, promoting modularity and scalability.
