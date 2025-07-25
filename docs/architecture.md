# M-Pesa Expense Tracker Architecture

## 1. Overview

This document outlines the technical architecture for the M-Pesa Expense Tracker mobile application. It is based on the requirements and technical assumptions defined in the Product Requirements Document (PRD).

### 1.1. Guiding Principles

* **Simplicity:** The architecture will prioritize simplicity and ease of development, leveraging managed services where possible.
* **Security:** Security is paramount. All data will be encrypted in transit and at rest, and user authentication will be robust.
* **Scalability:** The architecture will be designed to scale to support a growing user base.
* **Offline-First:** The application will be designed to be fully functional offline, with seamless data synchronization.

### 1.2. Technology Stack

| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **Mobile App** | Flutter | Cross-platform development for iOS and Android from a single codebase. |
| **Backend** | Supabase | Provides a comprehensive suite of backend services (database, auth, serverless functions, storage) that simplifies development. |
| **Database** | PostgreSQL | The underlying database for Supabase, offering a powerful and reliable relational database. |

## 2. System Architecture Diagram

*(A diagram will be generated here once the components are defined)*

## 3. Flutter Application Architecture

### 3.1. Directory Structure

The Flutter application will follow a standard feature-based directory structure to promote modularity and separation of concerns.

```
lib/
├── src/
│   ├── core/
│   │   ├── services/       # Core services (e.g., Supabase client, API client)
│   │   └── utils/          # Utility functions
│   ├── features/
│   │   ├── auth/           # Authentication feature (screens, state, services)
│   │   ├── transactions/   # Transaction list, detail, categorization
│   │   ├── dashboard/      # Dashboard and visualizations
│   │   └── categories/     # Category management
│   └── shared/
│       ├── models/         # Data models
│       ├── widgets/        # Reusable widgets
│       └── state/          # Shared application state
└── main.dart               # App entry point
```

### 3.2. State Management

We will use a robust state management solution like **Riverpod** or **Bloc** to manage application state. The choice will be finalized based on developer preference and the specific needs of the application, but the goal is to ensure a predictable and maintainable state layer.

### 3.3. Offline Support

Offline support is a critical requirement. We will implement this using a local database on the device, such as **Drift (moor)** or **Isar**, to store a local copy of the user's transactions and categories.

The offline synchronization process will be as follows:

1. The app fetches data from Supabase and stores it in the local database.
2. When the user makes changes offline (e.g., categorizing a transaction), the change is written to the local database and added to a "sync queue."
3. When the app comes back online, a background process will read the sync queue and push the changes to the Supabase backend.
4. The app will handle potential conflicts gracefully (e.g., if data was changed on another device).

## 4. Supabase Backend Architecture

The backend is built entirely on Supabase, leveraging its core services for the database, authentication, and serverless functions.

### 4.1. Database Schema

The database will use PostgreSQL. The following tables are essential for the MVP. Row Level Security (RLS) will be enabled on all tables to ensure users can only access their own data.

#### `categories`

Stores the expense categories created by users.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | Primary Key, Default: `uuid_generate_v4()` | Unique identifier for the category. |
| `user_id` | `uuid` | Foreign Key to `auth.users.id` | The user who owns this category. |
| `name` | `text` | Not Null | The name of the category (e.g., "Food"). |
| `icon` | `text` | Nullable | An optional icon identifier for the category. |
| `color` | `text` | Nullable | An optional hex color code for the category. |
| `is_default`| `boolean`| Default: `false` | `true` if this is a default category provided by the app. |
| `created_at`| `timestamptz`| Default: `now()` | Timestamp of when the category was created. |

#### `transactions`

Stores all M-Pesa transactions for all users.

| Column | Type | Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | `uuid` | Primary Key, Default: `uuid_generate_v4()` | Unique identifier for the transaction. |
| `user_id` | `uuid` | Foreign Key to `auth.users.id` | The user who owns this transaction. |
| `category_id`| `uuid` | Foreign Key to `categories.id`, Nullable | The category assigned to this transaction. |
| `mpesa_ref` | `text` | Not Null, Unique per user | The unique transaction reference from M-Pesa. |
| `description` | `text` | Not Null | The transaction description from M-Pesa. |
| `amount` | `numeric` | Not Null | The transaction amount. |
| `transaction_date` | `timestamptz`| Not Null | The date and time of the transaction. |
| `created_at`| `timestamptz`| Default: `now()` | Timestamp of when the record was created. |

### 4.2. Serverless Functions (Supabase Edge Functions)

#### `sync-mpesa-transactions`

* **Trigger:** This function will be triggered on a schedule (e.g., every 15 minutes) via a cron job.
* **Purpose:**
    1. Iterate through all users who have linked their M-Pesa accounts.
    2. For each user, securely retrieve their M-Pesa API credentials.
    3. Connect to the M-Pesa API and fetch any new transactions since the last sync.
    4. Insert the new transactions into the `transactions` table, ensuring no duplicates are created by checking the `mpesa_ref`.
* **Language:** TypeScript.

#### Function Directory Structure

The serverless function will be located in the `supabase/functions` directory as recommended by Supabase.

```
supabase/
└── functions/
    └── sync-mpesa-transactions/
        └── index.ts       # Main entry point for the function
```

## 5. Security & Authentication

Security is a top priority. The architecture incorporates security at multiple layers.

* **Authentication:**
  * User authentication (email/password and social logins) will be handled directly by **Supabase Auth**. This provides a secure, managed solution for user identity.
  * JWTs (JSON Web Tokens) issued by Supabase Auth will be used to authenticate all requests from the Flutter app to the backend.
* **Data Privacy:**
  * **Row Level Security (RLS)** will be strictly enforced on all database tables. Policies will ensure that a user can only ever read or write their own data.
  * Sensitive data, such as M-Pesa API credentials, will be stored using **Supabase Vault**, which provides encrypted storage for secrets. Serverless functions will have restricted access to retrieve these secrets only when needed.
* **API Security:**
  * All communication between the Flutter app and Supabase will be over HTTPS, encrypting data in transit.

## 6. API Design

The primary API will be the one provided by Supabase. The Flutter application will interact with the backend using the `supabase-flutter` client library. This library provides a type-safe and efficient way to:

* Perform CRUD (Create, Read, Update, Delete) operations on the database tables.
* Call serverless functions.
* Manage user authentication.
* Listen for real-time database changes (e.g., for automatically updating the transaction list).

This approach eliminates the need to design and build a custom REST or GraphQL API, significantly speeding up development.

## 7. Deployment & Testing

* **CI/CD:**
  * A CI/CD pipeline will be set up using **GitHub Actions**.
  * The pipeline will automatically:
        1. Run linter checks and format the code.
        2. Execute unit and integration tests.
        3. Build the Flutter application for both iOS and Android.
        4. Deploy the Supabase Edge Functions.
        5. (Future) Automate deployment to the Apple App Store and Google Play Store.
* **Testing Strategy:**
  * **Unit Tests:** Each widget and service in the Flutter app will have corresponding unit tests to verify its behavior in isolation.
  * **Integration Tests:** We will write integration tests to verify the app's interaction with Supabase, ensuring that data is correctly written to and read from the database.
  * **End-to-End (E2E) Tests:** (Post-MVP) E2E tests will be considered to simulate user flows from start to finish.
