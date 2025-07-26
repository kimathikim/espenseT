# Story 2.2: Manual Transaction Categorization

**As a** user,
**I want** to assign my transactions to predefined categories,
**so that** I can organize my spending.

## Acceptance Criteria

1.  The app provides a default list of expense categories (e.g., Food, Transport, Bills, Shopping, Entertainment).
2.  Tapping on a transaction in the list opens a detail view or a modal.
3.  From the detail view, the user can select a category from the default list to assign to the transaction.
4.  Once a category is assigned, it is displayed next to the transaction in the main list.
5.  Transactions that have not been categorized are clearly marked as "Uncategorized".

## Dev Notes

*   The default categories should be seeded into the database for new users.
*   The UI for category selection should be intuitive and fast.
*   All UI components must adhere to the theme defined in `lib/src/shared/theme.dart`.
