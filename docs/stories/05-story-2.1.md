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
