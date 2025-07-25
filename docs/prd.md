# M-Pesa Expense Tracker Product Requirements Document (PRD)

## Goals and Background Context

### Goals

*   Provide users a seamless and automated way to track M-Pesa transactions.
*   Empower users to easily categorize expenses, even when offline.
*   Enable users to gain clear insights into their spending habits through simple visualizations.
*   Deliver a secure, private, and user-friendly mobile application tailored for the Kenyan market.
*   Achieve high user adoption and retention, establishing the app as a leading personal finance tool in Kenya.

### Background Context

Managing personal finances in Kenya is often a manual and time-consuming process. While M-Pesa is a ubiquitous transaction platform, it lacks integrated tools for expense tracking and financial analysis. This forces users to rely on inefficient methods like spreadsheets or generic apps that aren't tailored to the local context.

This project aims to solve this problem by creating a mobile application that automatically syncs M-Pesa transactions, allows for immediate and offline categorization, and provides insightful spending analysis. By offering a simple, automated, and secure solution, we will empower young professionals and students in Kenya to take control of their financial lives and achieve their goals.

### Change Log

| Date | Version | Description | Author |
| :--- | :--- | :--- | :--- |
| 2025-07-26 | 1.0 | Initial PRD draft from Project Brief | John (PM) |

---

## Requirements

### Functional

1.  **FR1:** Users must be able to create an account and log in using email/password.
2.  **FR2:** Users must be able to create an account and log in using social providers (Google/Apple).
3.  **FR3:** Users must be able to securely link their M-Pesa account once after onboarding.
4.  **FR4:** The system must automatically fetch and display new M-Pesa transactions for the linked account.
5.  **FR5:** Users must be able to assign transactions to a set of default expense categories.
6.  **FR6:** Users must be able to create new custom expense categories.
7.  **FR7:** The application must support full functionality for categorizing transactions while the user is offline, syncing the data upon reconnection.
8.  **FR8:** Users must be able to search for transactions by name, category, or amount.
9.  **FR9:** The application must display a dashboard summarizing total spending for the current month.
10. **FR10:** The dashboard must display a visual breakdown of spending by category (e.g., pie chart or bar graph).

### Non-Functional

1.  **NFR1:** The application must be a mobile application.
2.  **NFR2:** The user interface must be simple, intuitive, and user-friendly for the target audience.
3.  **NFR3:** All user data, especially financial information, must be stored securely and kept private.
4.  **NFR4:** The application must be performant, with transaction syncing, categorization, and search completing quickly.
5.  **NFR5:** The backend will be built on Supabase.

---

## User Interface Design Goals

### Overall UX Vision

The user experience should be effortless, intuitive, and empowering. The primary goal is to help users understand their spending with minimal friction. The app should feel clean, modern, and trustworthy, encouraging regular engagement through a simple and visually appealing interface.

### Key Interaction Paradigms

*   **Automated First:** The app should automate as much as possible, from transaction syncing to smart categorization suggestions (a future goal).
*   **Direct Manipulation:** Users should be able to categorize transactions with a simple tap or swipe.
*   **Visual Feedback:** The app will use clear charts and graphs to provide instant visual feedback on spending patterns.

### Core Screens and Views

*   **Onboarding:** A simple, multi-step process for account creation and linking the M-Pesa account.
*   **Dashboard / Home Screen:** The main view showing a monthly spending summary, a category breakdown chart, and a list of recent transactions.
*   **Transaction List:** A searchable list of all transactions with clear labels for category and amount.
*   **Transaction Detail View:** A view to see more details about a single transaction and change its category.
*   **Category Management:** A screen to view, add, and edit custom expense categories.

### Accessibility: WCAG AA

To ensure the app is usable by a wide audience, we will aim for WCAG 2.1 Level AA compliance.

### Branding

*(Assumption)* The branding should be modern, clean, and professional, using a color palette that inspires trust and financial confidence. We will avoid overly playful or complex designs. The logo and color scheme should be simple and memorable.

### Target Device and Platforms: Mobile Only

The initial version of the application will be developed exclusively for mobile platforms (iOS and Android).

---

## Technical Assumptions

### Repository Structure: Monorepo

A monorepo is recommended to simplify dependency management and streamline development across the mobile app and any future backend services.

### Service Architecture: Serverless

Given the use of Supabase, a serverless architecture is the natural fit. Business logic can be implemented in serverless functions (e.g., for handling M-Pesa webhooks) while leveraging Supabase for database, authentication, and other backend services.

### Testing Requirements: Unit + Integration

The project will require both unit tests for individual functions and components, as well as integration tests to ensure that the application correctly interacts with the Supabase backend and any external services.

### Additional Technical Assumptions and Requests

*   **Language/Framework:** The mobile application will be built using **Flutter** to target both iOS and Android from a single codebase.
*   **CI/CD:** A CI/CD pipeline will be established early on to automate testing and deployment processes.
*   **Offline Support:** The application's architecture must be designed from the ground up to support the offline categorization feature, with a robust data synchronization mechanism.

---

## Epic List

1.  **Epic 1: Foundation & User Onboarding:** Establish the core project setup, including the Flutter application, Supabase integration, and a complete, secure user onboarding flow.
2.  **Epic 2: Core Expense Tracking:** Implement the primary features of the application, including automatic M-Pesa transaction syncing, manual and offline categorization, and transaction search.
3.  **Epic 3: Spending Insights & Visualization:** Develop the user-facing dashboard to provide a clear summary and visual breakdown of spending habits.

---

## Epic 1: Foundation & User Onboarding

This epic establishes the core project setup, including the Flutter application, Supabase integration, and a complete, secure user onboarding flow. It ensures that users can create an account, log in, and securely connect their M-Pesa account, laying the groundwork for all subsequent features.

### Story 1.1: Project Setup & Boilerplate

*   **As a** developer,
*   **I want** a new Flutter project initialized with Supabase integration,
*   **so that** I have a foundational structure to build upon.

#### Acceptance Criteria

1.  A new Flutter project is created and configured for both iOS and Android.
2.  The Supabase Flutter library is added as a dependency.
3.  Configuration for connecting to a Supabase instance (using environment variables for keys) is in place.
4.  The project is checked into a Git repository with a proper .gitignore file.
5.  A basic placeholder screen (e.g., "Welcome") is visible after the splash screen when the app runs.

### Story 1.2: Email/Password Sign-Up & Login

*   **As a** new user,
*   **I want** to sign up and log in with my email and password,
*   **so that** I can securely access the application.

#### Acceptance Criteria

1.  A sign-up screen exists with fields for email and password, including input validation (email format, password strength).
2.  A login screen exists with fields for email and password.
3.  Upon successful sign-up, a new user is created in the Supabase `auth.users` table, and the user is logged in.
4.  Upon successful login, the user is authenticated and granted access to the app's main screen.
5.  Clear error messages are shown for failures (e.g., "Email already in use," "Invalid credentials").
6.  A "Log Out" capability exists within the app that signs the user out and returns them to the login screen.

### Story 1.3: Social Login (Google & Apple)

*   **As a** new or existing user,
*   **I want** to sign up or log in using my Google or Apple account,
*   **so that** I can access the app quickly without creating a new password.

#### Acceptance Criteria

1.  "Sign in with Google" and "Sign in with Apple" buttons are present on the login/signup screen.
2.  Tapping a button initiates the respective native social sign-in flow.
3.  Upon successful social authentication, a new user is created in Supabase auth (if they don't exist), or the existing user is logged in.
4.  The user is redirected to the app's main screen.
5.  Errors during the social sign-in flow are handled gracefully.

### Story 1.4: Secure M-Pesa Account Linking

*   **As a** logged-in user,
*   **I want** to securely link my M-Pesa account one time,
*   **so that** the app can automatically import my transactions.

#### Acceptance Criteria

1.  A dedicated screen or modal exists for linking an M-Pesa account, accessible after logging in.
2.  The UI clearly explains what information is needed and why, guiding the user through the process.
3.  User-provided credentials/keys for linking are securely handled and stored (e.g., using Supabase Vault).
4.  A successful link is confirmed with a success message.
5.  The UI provides a clear way to see the linked account status and an option to unlink it.
6.  A test connection to a simulated M-Pesa endpoint is successful, confirming the linking mechanism works.

---

## Epic 2: Core Expense Tracking

This epic implements the primary features of the application, including automatic M-Pesa transaction syncing, manual and offline categorization, and transaction search. It delivers the core value proposition of the app.

### Story 2.1: Automatic M-Pesa Transaction Sync

*   **As a** user with a linked account,
*   **I want** my new M-Pesa transactions to be automatically imported and displayed in the app,
*   **so that** I don't have to enter them manually.

#### Acceptance Criteria

1.  A serverless function (Supabase Edge Function) is created to periodically fetch new transactions from the M-Pesa API for linked users.
2.  Fetched transactions are stored securely in a `transactions` table in the Supabase database, associated with the correct user.
3.  The Flutter app displays the list of imported transactions in chronological order (newest first) on a dedicated "Transactions" screen or tab.
4.  Each transaction in the list clearly shows the transaction name/description, date, and amount.
5.  The sync process is efficient and avoids creating duplicate transaction entries.
6.  The app provides a visual indicator (e.g., a pull-to-refresh spinner) to show when a sync is in progress.

### Story 2.2: Manual Transaction Categorization

*   **As a** user,
*   **I want** to assign my transactions to predefined categories,
*   **so that** I can organize my spending.

#### Acceptance Criteria

1.  The app provides a default list of expense categories (e.g., Food, Transport, Bills, Shopping, Entertainment).
2.  Tapping on a transaction in the list opens a detail view or a modal.
3.  From the detail view, the user can select a category from the default list to assign to the transaction.
4.  Once a category is assigned, it is displayed next to the transaction in the main list.
5.  Transactions that have not been categorized are clearly marked as "Uncategorized".

### Story 2.3: Custom Category Creation & Management

*   **As a** user,
*   **I want** to create and manage my own expense categories,
*   **so that** I can organize my spending in a way that makes sense to me.

#### Acceptance Criteria

1.  A "Categories" management screen exists within the app.
2.  On this screen, users can see the list of default and custom categories.
3.  Users can add a new category by providing a name and optionally an icon/color.
4.  Users can edit the name/icon/color of their custom categories.
5.  Users can delete their custom categories. (The app should handle how transactions assigned to a deleted category are treated, e.g., revert to "Uncategorized").
6.  Custom categories appear in the category selection list when categorizing a transaction.

### Story 2.4: Offline Categorization

*   **As a** user,
*   **I want** to be able to categorize my transactions even when I don't have an internet connection,
*   **so that** I can manage my expenses on the go.

#### Acceptance Criteria

1.  The app caches transactions and categories locally on the device.
2.  Users can fully access the transaction list and assign/change categories while the device is offline.
3.  Any changes made offline are saved locally.
4.  When the app reconnects to the internet, it automatically syncs the offline changes to the Supabase backend.
5.  The UI provides a subtle indicator of the app's online/offline status or sync status.

### Story 2.5: Instant Transaction Search

*   **As a** user,
*   **I want** to quickly find a specific transaction,
*   **so that** I can review its details or check my spending.

#### Acceptance Criteria

1.  A search bar is prominently displayed on the "Transactions" screen.
2.  As the user types, the transaction list filters in real-time to show matching results.
3.  The search functionality queries the transaction name/description, category, and amount.
4.  The search works correctly with both online and locally cached (offline) data.
5.  Clearing the search bar restores the full, unfiltered list of transactions.

---

## Epic 3: Spending Insights & Visualization

This epic develops the user-facing dashboard to provide a clear summary and visual breakdown of spending habits, turning raw transaction data into actionable financial insights.

### Story 3.1: Monthly Spending Summary

*   **As a** user,
*   **I want** to see a clear summary of my total spending for the current month on a dashboard,
*   **so that** I can quickly understand my overall financial activity.

#### Acceptance Criteria

1.  A dedicated "Dashboard" or "Home" screen is the first screen shown after login.
2.  The dashboard prominently displays the total amount of money spent across all categorized and uncategorized transactions for the current calendar month.
3.  The summary figure updates in near real-time as new transactions are synced or categorized.
4.  The summary correctly handles calculations and displays the total with the appropriate currency symbol (KSh).
5.  If there is no spending for the month, the summary displays "KSh 0.00".

### Story 3.2: Spending Breakdown Visualization

*   **As a** user,
*   **I want** to see a visual breakdown of my spending by category on the dashboard,
*   **so that** I can easily identify where my money is going.

#### Acceptance Criteria

1.  The dashboard includes a chart (e.g., a pie chart or a bar graph) that visually represents the proportion of spending in each category for the current month.
2.  The chart is easy to read and understand, with clear labels for each category and its corresponding spending amount or percentage.
3.  The chart accurately reflects the data from categorized transactions and updates automatically as transactions are categorized or re-categorized.
4.  Tapping on a segment of the chart provides a more detailed view or filters the transaction list to show only transactions from that category.
5.  The chart includes a legend or labels that are legible on various mobile screen sizes.
6.  "Uncategorized" spending is represented as a distinct category in the chart.
