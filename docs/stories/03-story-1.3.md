# Story 1.3: Social Login (Google & Apple)

**As a** new or existing user,
**I want** to sign up or log in using my Google or Apple account,
**so that** I can access the app quickly without creating a new password.

## Acceptance Criteria

1.  "Sign in with Google" and "Sign in with Apple" buttons are present on the login/signup screen.
2.  Tapping a button initiates the respective native social sign-in flow.
3.  Upon successful social authentication, a new user is created in Supabase auth (if they don't exist), or the existing user is logged in.
4.  The user is redirected to the app's main screen.
5.  Errors during the social sign-in flow are handled gracefully.

## Dev Notes

*   Follow the official Supabase documentation for implementing Google and Apple sign-in with Flutter.
*   This will require configuration in the Google Cloud Console and Apple Developer portal.
