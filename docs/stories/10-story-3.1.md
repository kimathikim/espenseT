# Story 3.1: Monthly Spending Summary

**As a** user,
**I want** to see a clear summary of my total spending for the current month on a dashboard,
**so that** I can quickly understand my overall financial activity.

## Acceptance Criteria

1.  A dedicated "Dashboard" or "Home" screen is the first screen shown after login.
2.  The dashboard prominently displays the total amount of money spent across all categorized and uncategorized transactions for the current calendar month.
3.  The summary figure updates in near real-time as new transactions are synced or categorized.
4.  The summary correctly handles calculations and displays the total with the appropriate currency symbol (KSh).
5.  If there is no spending for the month, the summary displays "KSh 0.00".

## Dev Notes

*   The calculation should be performed efficiently, likely on the client-side from the locally cached data to ensure responsiveness.
*   The UI should be clean and the summary figure should be the most prominent element on the dashboard.
