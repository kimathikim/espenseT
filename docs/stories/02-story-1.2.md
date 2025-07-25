# Story 1.2: Email/Password Sign-Up & Login

**As a** new user,
**I want** to sign up and log in with my email and password,
**so that** I can securely access the application.

## Acceptance Criteria

1.  A sign-up screen exists with fields for email and password, including input validation (email format, password strength).
2.  A login screen exists with fields for email and password.
3.  Upon successful sign-up, a new user is created in the Supabase `auth.users` table, and the user is logged in.
4.  Upon successful login, the user is authenticated and granted access to the app's main screen.
5.  Clear error messages are shown for failures (e.g., "Email already in use," "Invalid credentials").
6.  A "Log Out" capability exists within the app that signs the user out and returns them to the login screen.

## Dev Notes

*   Leverage the `supabase-flutter` library for all authentication operations.
*   Focus on a clean, simple UI for the forms as defined in the architecture document.
