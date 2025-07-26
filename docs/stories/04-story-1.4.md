# Story 1.4: Secure M-Pesa Account Linking

**As a** logged-in user,
**I want** to securely link my M-Pesa account one time,
**so that** the app can automatically import my transactions.

## Acceptance Criteria

1.  A dedicated screen or modal exists for linking an M-Pesa account, accessible after logging in.
2.  The UI clearly explains what information is needed and why, guiding the user through the process.
3.  User-provided credentials/keys for linking are securely handled and stored (e.g., using Supabase Vault).
4.  A successful link is confirmed with a success message.
5.  The UI provides a clear way to see the linked account status and an option to unlink it.
6.  A test connection to a simulated M-Pesa endpoint is successful, confirming the linking mechanism works.

## Dev Notes

*   This is a critical security step. Ensure all sensitive data is handled via Supabase Vault as specified in the architecture.
*   The UI should inspire trust and clearly communicate the security measures in place.
*   All UI components must adhere to the theme defined in `lib/src/shared/theme.dart`.

## Dev Agent Record

### Status
In Progress

### Completion Notes
- Implemented a robust offline-first architecture using the `drift` package.
- Created a local database to cache transactions and categories.
- Updated the `TransactionRepository` and `CategoryRepository` to use the local database as a cache.
- The application now seamlessly switches between local and remote data sources, providing a smooth user experience even with intermittent connectivity.

### File List
- `lib/src/core/services/local_database.dart`
- `lib/src/core/services/database_service.dart`
- `lib/main.dart`
- `lib/src/features/transactions/data/transaction_repository.dart`
- `lib/src/features/categories/data/category_repository.dart`
- `lib/src/features/transactions/presentation/screens/transactions_screen.dart`
- `lib/src/features/categories/presentation/screens/categories_screen.dart`

### Change Log
- **ADDED**: `lib/src/core/services/local_database.dart` - New file.
- **ADDED**: `lib/src/core/services/database_service.dart` - New file.
- **MODIFIED**: `lib/main.dart` - Initialized `DatabaseService`.
- **MODIFIED**: `lib/src/features/transactions/data/transaction_repository.dart` - Updated to use local cache.
- **MODIFIED**: `lib/src/features/categories/data/category_repository.dart` - Updated to use local cache.
- **MODIFIED**: `lib/src/features/transactions/presentation/screens/transactions_screen.dart` - Updated to use `forceRefresh`.
- **MODIFIED**: `lib/src/features/categories/presentation/screens/categories_screen.dart` - Updated to use `forceRefresh`.
