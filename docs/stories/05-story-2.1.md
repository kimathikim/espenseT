# Story 2.1: Automatic M-Pesa Transaction Sync

**As a** user with a linked account,
**I want** my new M-Pesa transactions to be automatically imported and displayed in the app,
**so that** I don't have to enter them manually.

## Acceptance Criteria

1.  A serverless function (Supabase Edge Function) is created to periodically fetch new transactions from the M-Pesa API for linked users.
2.  Fetched transactions are stored securely in a `transactions` table in the Supabase database, associated with the correct user.
3.  The Flutter app displays the list of imported transactions in chronological order (newest first) on a dedicated "Transactions" screen or tab.
4.  Each transaction in the list clearly shows the transaction name/description, date, and amount.
5.  The sync process is efficient and avoids creating duplicate transaction entries.
6.  The app provides a visual indicator (e.g., a pull-to-refresh spinner) to show when a sync is in progress.

## Dev Notes

*   The serverless function needs to be robust and handle potential API errors from M-Pesa gracefully.
*   The Flutter app should display the transactions in a clean, readable list.
*   All UI components must adhere to the theme defined in `lib/src/shared/theme.dart`.

## Dev Agent Record

### Status
In Progress

### Completion Notes
- Created the `Transaction` model and `TransactionRepository` to handle transaction data.
- Updated the `TransactionsScreen` to fetch and display real transaction data from the repository.
- Created the Supabase Edge Function `sync-mpesa-transactions` to fetch transactions from the M-Pesa API and store them in the database.

### File List
- `lib/src/features/transactions/domain/transaction.dart`
- `lib/src/features/transactions/data/transaction_repository.dart`
- `lib/src/features/transactions/presentation/screens/transactions_screen.dart`
- `supabase/functions/sync-mpesa-transactions/index.ts`

### Change Log
- **ADDED**: `lib/src/features/transactions/domain/transaction.dart` - New file.
- **ADDED**: `lib/src/features/transactions/data/transaction_repository.dart` - New file.
- **MODIFIED**: `lib/src/features/transactions/presentation/screens/transactions_screen.dart` - Updated to fetch and display real data.
- **ADDED**: `supabase/functions/sync-mpesa-transactions/index.ts` - New file.
