# Story 2.3: Custom Category Creation & Management

**As a** user,
**I want** to create and manage my own expense categories,
**so that** I can organize my spending in a way that makes sense to me.

## Acceptance Criteria

1.  A "Categories" management screen exists within the app.
2.  On this screen, users can see the list of default and custom categories.
3.  Users can add a new category by providing a name and optionally an icon/color.
4.  Users can edit the name/icon/color of their custom categories.
5.  Users can delete their custom categories. (The app should handle how transactions assigned to a deleted category are treated, e.g., revert to "Uncategorized").
6.  Custom categories appear in the category selection list when categorizing a transaction.

## Dev Notes

*   Ensure that Row Level Security is correctly configured so users can only manage their own custom categories.
*   The UI should be simple and follow the overall design language of the app.
