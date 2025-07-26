# Story 3.2: Spending Breakdown Visualization

**As a** user,
**I want** to see a visual breakdown of my spending by category on the dashboard,
**so that** I can easily identify where my money is going.

## Acceptance Criteria

1.  The dashboard includes a chart (e.g., a pie chart or a bar graph) that visually represents the proportion of spending in each category for the current month.
2.  The chart is easy to read and understand, with clear labels for each category and its corresponding spending amount or percentage.
3.  The chart accurately reflects the data from categorized transactions and updates automatically as transactions are categorized or re-categorized.
4.  Tapping on a segment of the chart provides a more detailed view or filters the transaction list to show only transactions from that category.
5.  The chart includes a legend or labels that are legible on various mobile screen sizes.
6.  "Uncategorized" spending is represented as a distinct category in the chart.

## Dev Notes

*   Choose a charting library for Flutter that is performant and easy to customize (e.g., `fl_chart`).
*   The chart should be visually appealing and consistent with the app's overall design.
*   All UI components must adhere to the theme defined in `lib/src/shared/theme.dart`.
