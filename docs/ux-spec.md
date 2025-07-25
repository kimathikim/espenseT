# M-Pesa Expense Tracker - UX Specification

## 1. Introduction

This document details the User Experience (UX) and User Interface (UI) design for the M-Pesa Expense Tracker application. It translates the project goals from `docs/brief.md` into a tangible visual and interactive blueprint. The wireframes described herein serve as the primary guide for the development of the user interface.

## 2. Overall UX Principles

The user experience will be guided by the following core principles:

*   **Clarity and Simplicity:** The interface will be clean, uncluttered, and easy to understand. The primary focus is on helping the user accomplish their tasks with minimal friction.
*   **Professional & Trustworthy:** As a financial application, the design will be serious and professional, using a clean layout and a professional color palette to build user trust.
*   **Efficiency:** The user flows will be designed to be as efficient as possible, with a strong emphasis on features like offline access and quick categorization.
*   **Subtle Interactivity:** Micro-interactions and subtle animations will be used to enhance the user experience and provide feedback, without being distracting.

## 3. User Flows

### 3.1. Onboarding and First Use Flow
1.  User launches the app.
2.  User is presented with the **Sign Up / Login Screen**.
3.  User creates an account or logs in.
4.  Upon first login, the user is prompted to connect their M-Pesa account.
5.  Once connected, the user is taken to the **Dashboard Screen**.
6.  The dashboard displays recently synced transactions, some of which are uncategorized.

### 3.2. Transaction Categorization Flow
1.  From the **Dashboard Screen**, the user taps on an uncategorized transaction.
2.  The user is taken to the **Expense Detail & Categorization Screen**.
3.  The user taps the "Select a Category" field.
4.  A bottom sheet appears with a list of existing categories. The user can also tap a "Create New" button here.
5.  The user selects a category from the list.
6.  (Optional) The user taps the "Upload Image" button to attach a receipt from their photo gallery.
7.  The user taps the "Save" button.
8.  The user is returned to the **Dashboard Screen**, where the transaction now shows its new category.

## 4. Wireframes

The following wireframes describe the layout and key components of each screen in the MVP. They are low-fidelity by design to focus on structure and functionality.

### 4.1. Sign Up / Login Screen
*   **Layout:** Single-column, centered layout.
*   **Components:**
    *   **App Logo:** Placeholder at the top.
    *   **Header:** "Welcome Back" or "Create Your Account".
    *   **Email Field:** Standard text input for email.
    *   **Password Field:** Secure text input with a visibility toggle icon.
    *   **Primary Button:** Full-width button ("Login" or "Sign Up").
    *   **Secondary Link:** Text link to switch between Login and Sign Up forms.
    *   **Separator:** A horizontal line with "OR" text in the middle.
    *   **Social Logins:** Buttons for "Continue with Google" and "Continue with Apple".
    *   **Forgot Password Link:** Text link at the bottom of the screen.

### 4.2. Dashboard / Home Screen
*   **Layout:** A vertical layout with a main overview card and a scrollable list.
*   **Components:**
    *   **Header:** "Hello, [User Name]" and a "Settings" gear icon.
    *   **Overview Card:** A prominent card at the top containing:
        *   Title: "Total Spending This Month".
        *   Amount: Large text displaying the total monthly spend (e.g., "KES 15,400.50").
        *   Chart: A placeholder for a pie or bar chart showing spending by category.
    *   **Transaction List Header:** Sub-heading "Recent Transactions" with a search icon/bar.
    *   **Transaction List:** A scrollable list of transactions. Each item contains:
        *   Description and Amount.
        *   Category and Date.
        *   A visual indicator (e.g., an icon or button) for uncategorized items.
    *   **Floating Action Button (FAB):** A "+" button in the bottom-right for future use (e.g., manual expense entry).

### 4.3. Expense Detail & Categorization Screen
*   **Layout:** A detailed view with clear sections for information and user input.
*   **Components:**
    *   **Header:** Title "Transaction Details", a "Back" arrow, and a "Save" button.
    - **Details Card:** A non-editable display of the transaction's Amount, Description, and Date.
    *   **Category Selector:** A clickable field showing the current category. Tapping it opens a **bottom sheet modal** with a list of categories and a "Create New" option.
    *   **Screenshot Uploader:** A dashed-border box with an "Upload Image" icon. When an image is selected, it displays a thumbnail preview with a remove button.
    *   **Notes Field:** An optional multi-line text field for users to add notes.

## 5. Visual Design and Theme

This section outlines the color palette, typography, and other visual design elements that will define the application's brand identity. The design aims to be modern, clean, and trustworthy, inspired by the provided UI mockups.

### 5.1. Color Palette

| Color Name | Hex Code | Usage |
| :--- | :--- | :--- |
| **Primary Gradient Start** | `#A060FA` | Top color for main headers and backgrounds. |
| **Primary Gradient End** | `#6A30D8` | Bottom color for main headers and backgrounds. |
| **Accent Blue (Earned)** | `#00B2FF` | Used for positive financial indicators, like "Earned". |
| **Accent Red (Spent)** | `#FF3D71` | Used for negative financial indicators, like "Spent". |
| **Icon Blue (Salary)** | `#5B67CA` | Icon and color for the 'Salary' category. |
| **Icon Red (Medicine)** | `#FD5D5D` | Icon and color for the 'Medicine' category. |
| **Icon Orange (Restaurant)**| `#FFAC3A` | Icon and color for the 'Restaurant' category. |
| **Icon Purple (Cloth)** | `#8A4DFF` | Icon and color for the 'Cloth' category. |
| **Add Button** | `#00C6AD` | Floating Action Button for adding new items. |
| **Primary Text** | `#1C1C1E` | Main text color for dark text on light backgrounds. |
| **Secondary Text** | `#8E8E93` | Lighter text for subheadings and less important info. |
| **White Text** | `#FFFFFF` | Text color for use on dark/gradient backgrounds. |
| **Main Background** | `#F2F2F7` | The primary background color for most screens. |
| **Card Background** | `#FFFFFF` | Background color for cards and distinct sections. |

### 5.2. Typography

*   **Font Family:** Poppins
*   **Weights:**
    *   **Bold:** Used for large titles, primary amounts (e.g., `$4,167.56`), and important headings.
    *   **Semi-Bold/Medium:** Used for sub-headings (e.g., category names like "Transportation") and button text.
    *   **Regular:** Used for body text, descriptions, and list item details.
*   **Sizing:** A clear type scale will be established during development to ensure consistency, ranging from small helper text (~12pt) to large screen titles (~24pt).

### 5.3. Iconography

*   **Style:** Icons should be simple, clean, and easily recognizable. A consistent style (e.g., filled or line-art) should be used throughout the application. The icons in the mockups for "Home", "Graph", "Transactions", etc., will be used as the primary reference.
