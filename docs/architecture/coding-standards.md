# Coding Standards

This document outlines the coding standards and best practices to be followed for the M-Pesa Expense Tracker Flutter project. Adhering to these standards will ensure code consistency, readability, and maintainability.

## 1. Formatting

*   **Automatic Formatting:** All code will be formatted using the default Flutter formatter (`flutter format`). This is non-negotiable and will be enforced by a CI check.
*   **Line Length:** Maximum line length is 80 characters. Use trailing commas to encourage vertical formatting by the formatter.

## 2. Naming Conventions

*   **Files:** Use `snake_case` for file names (e.g., `user_repository.dart`).
*   **Classes and Enums:** Use `PascalCase` (e.g., `Transaction`, `AuthService`).
*   **Variables, Methods, and Functions:** Use `camelCase` (e.g., `userName`, `fetchTransactions()`).
*   **Constants:** Use `camelCase` (e.g., `const supabaseUrl = '...'`).
*   **Private Members:** Prefix private members with an underscore (`_`) (e.g., `_privateVariable`, `_privateMethod()`).

## 3. Code Organization

*   **Imports:**
    *   Organize imports in the following order:
        1.  `dart:` imports
        2.  `package:` imports (external packages)
        3.  Project-relative imports (`import 'features/...'`)
    *   Sort imports alphabetically within each group.
    *   Use relative imports for files within the same feature directory.
*   **Widget Structure:**
    *   Keep widget build methods small and focused.
    *   Extract complex parts of a widget into smaller, private widgets or methods.
    *   Prefer creating new `StatelessWidget` or `StatefulWidget` classes over helper methods that return widgets, as this improves performance and widget tree readability.

## 4. State Management (Riverpod)

*   **Providers:**
    *   Providers should be defined in the files where they are most relevant (e.g., a `transactionsRepositoryProvider` in `transactions_repository.dart`).
    *   Name providers using `camelCase` and a `Provider` suffix (e.g., `authServiceProvider`).
    *   Keep providers focused on a single responsibility.

## 5. Asynchronous Code

*   **`async`/`await`:** Use `async`/`await` for all asynchronous operations. Avoid using `.then()` unless necessary.
*   **Error Handling:** Use `try`/`catch` blocks to handle potential errors in asynchronous operations gracefully. Do not swallow errors silently.

## 6. Documentation

*   **Public APIs:** All public classes, methods, and functions must have Dartdoc comments explaining their purpose, parameters, and return values.
*   **Complex Logic:** Add inline comments to explain complex or non-obvious parts of the code.

## 7. Linting

*   We will use the `flutter_lints` package as a base and may add stricter rules as the project evolves.
*   All code must pass linting checks before being merged.
