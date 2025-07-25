# Story 2.5: Instant Transaction Search

**As a** user,
**I want** to quickly find a specific transaction,
**so that** I can review its details or check my spending.

## Acceptance Criteria

1.  A search bar is prominently displayed on the "Transactions" screen.
2.  As the user types, the transaction list filters in real-time to show matching results.
3.  The search functionality queries the transaction name/description, category, and amount.
4.  The search works correctly with both online and locally cached (offline) data.
5.  Clearing the search bar restores the full, unfiltered list of transactions.

## Dev Notes

*   Search performance is key. The implementation should be fast and responsive, even with a large number of transactions.
*   Consider how the search will interact with the local cache for the offline feature.
