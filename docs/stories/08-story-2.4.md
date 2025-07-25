# Story 2.4: Offline Categorization

**As a** user,
**I want** to be able to categorize my transactions even when I don't have an internet connection,
**so that** I can manage my expenses on the go.

## Acceptance Criteria

1.  The app caches transactions and categories locally on the device.
2.  Users can fully access the transaction list and assign/change categories while the device is offline.
3.  Any changes made offline are saved locally.
4.  When the app reconnects to the internet, it automatically syncs the offline changes to the Supabase backend.
5.  The UI provides a subtle indicator of the app's online/offline status or sync status.

## Dev Notes

*   This is a key architectural feature. Refer to the architecture document for the detailed offline support strategy.
*   The local database choice (Drift or Isar) will be critical here.
