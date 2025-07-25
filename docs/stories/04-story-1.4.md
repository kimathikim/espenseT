# Story 1.4: Secure M-Pesa Account Linking

**As a** logged-in user,
**I want** to securely link my M-Pesa account one time,
**so that** the app can automatically import my transactions.

## Acceptance Criteria

1.  A dedicated screen or modal exists for linking an M-Pesa account, accessible after logging in.
2.  The UI clearly explains what information is needed and why, guiding the user through the process.
3.  User-provided credentials/keys for linking are securely handled and stored (e.g., using Supabase Vault).
4.  A successful link is confirmed with a success message.
5.  The UI provides a clear way to see the linked account status and an option to unlink it.
6.  A test connection to a simulated M-Pesa endpoint is successful, confirming the linking mechanism works.

## Dev Notes

*   This is a critical security step. Ensure all sensitive data is handled via Supabase Vault as specified in the architecture.
*   The UI should inspire trust and clearly communicate the security measures in place.
