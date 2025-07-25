# Technology Stack

This document details the specific technologies, libraries, and tools chosen for the M-Pesa Expense Tracker project.

## 1. Core Technologies

| Layer | Technology | Version | Rationale |
| :--- | :--- | :--- | :--- |
| **Mobile App** | [Flutter](https://flutter.dev/) | 3.x | High-performance, cross-platform UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. |
| **Language** | [Dart](https://dart.dev/) | 3.x | The modern, client-optimized language for fast apps on any platform. Null-safe and AOT/JIT compiled. |
| **Backend** | [Supabase](https://supabase.com/) | Latest | The open-source Firebase alternative. Provides a full backend-as-a-service including a Postgres database, authentication, storage, and serverless functions. |
| **Database** | [PostgreSQL](https://www.postgresql.org/) | 15.x | A powerful, open-source object-relational database system with over 30 years of active development. |

## 2. Key Libraries & Packages (Flutter)

| Area | Library | Rationale |
| :--- | :--- | :--- |
| **State Management** | [Riverpod](https://riverpod.dev/) | A compile-safe and testable state management solution that makes dependency injection and state management simple and predictable. |
| **Backend Client** | [supabase_flutter](https://pub.dev/packages/supabase_flutter) | The official Flutter library for Supabase, providing a convenient and type-safe way to interact with the backend. |
| **Local Database** | [Isar](https://pub.dev/packages/isar) | A super-fast, cross-platform, and easy-to-use NoSQL database for Flutter. Ideal for offline storage and caching. |
| **HTTP Client** | [Dio](https://pub.dev/packages/dio) | A powerful HTTP client for Dart, which supports interceptors, global configuration, FormData, request cancellation, file downloading, timeout, etc. (Used if direct HTTP calls are needed outside of Supabase client). |
| **Environment Variables**| [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) | A package to load environment variables from a `.env` file, keeping sensitive keys out of the source code. |
| **Linting** | [flutter_lints](https://pub.dev/packages/flutter_lints) | The official linting rules from the Flutter team to encourage good coding practices. |

## 3. Integrations

| Service | Purpose |
| :--- | :--- |
| **M-Pesa API** | To securely fetch user transaction data for expense tracking. This will be handled via a Supabase Edge Function. |

## 4. Development & CI/CD Tools

| Area | Tool | Rationale |
| :--- | :--- | :--- |
| **Version Control** | [Git](https://git-scm.com/) | The industry-standard distributed version control system. |
| **Code Hosting** | [GitHub](https://github.com) | Provides hosting for Git repositories and powerful collaboration features, including GitHub Actions. |
| **CI/CD** | [GitHub Actions](https://github.com/features/actions) | Automates the build, test, and deployment pipeline directly from GitHub. |

This technology stack is chosen to enable rapid development, ensure high quality, and provide a scalable foundation for the application.
