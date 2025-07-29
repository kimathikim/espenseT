# Supabase Presentation: Expense Tracker App

## Slide 1: Title Slide

**Expense Tracker: Powered by Supabase**

A deep dive into how we built a secure, real-time, and scalable expense tracking application using the Supabase platform.

---

## Slide 2: Introduction to the App

**What is Expense Tracker?**

- A mobile application for tracking personal expenses.
- Automated expense logging via M-Pesa SMS parsing.
- Manual expense entry with categorization.
- Secure user accounts and data management.

---

## Slide 3: Why Supabase?

**The Perfect Backend for Our App**

- **All-in-one Platform:** Database, Authentication, Storage, and more in a single, integrated solution.
- **PostgreSQL Power:** The full power of a relational database, including functions and triggers.
- **Row Level Security (RLS):** Fine-grained access control to protect user data.
- **Real-time Capabilities:** Instantly sync data across devices.
- **Scalability:** A platform that grows with our user base.

---

## Slide 4: Core Feature 1: Supabase Database

**The Foundation of Our App**

- **Tables:**
    - `categories`: Stores default and user-created expense categories.
    - `expenses`: Holds individual transaction records.
    - `mpesa_transactions`: Raw data from M-Pesa SMS for automated processing.
- **Relationships:** Clear foreign key relationships between tables.
- **Indexes:** Optimized for fast query performance.

---

## Slide 5: Core Feature 2: Supabase Auth & RLS

**Secure by Default**

- **Authentication:** Supabase Auth for easy and secure user sign-up and login.
- **Row Level Security (RLS):**
    - Implemented on all tables (`categories`, `expenses`, `mpesa_transactions`).
    - Policies ensure users can only access and manage their own data.
    - Example Policy: `CREATE POLICY "Allow users to see their own expenses" ON public.expenses FOR SELECT USING (auth.uid() = user_id);`

---

## Slide 6: Core Feature 3: Database Functions & Triggers

**Automating Workflows**

- **PostgreSQL Function:** `convert_mpesa_to_expense()`
- **Trigger:** `trigger_convert_mpesa_to_expense`
- **How it works:**
    1. A new M-Pesa SMS is parsed and inserted into `mpesa_transactions`.
    2. The trigger fires and executes the function.
    3. The function automatically creates a new record in the `expenses` table.
    4. The `mpesa_transactions` record is marked as processed.
- **Benefit:** This powerful automation happens entirely within the database, reducing client-side logic and ensuring data consistency.

---

## Slide 7: Core Feature 4: Supabase Storage (Hypothetical)

**Storing Expense Receipts**

- While not in the current schema, we can easily extend the app to use Supabase Storage.
- **Use Case:** Allow users to upload and attach receipt images to their expenses.
- **Implementation:**
    - Add a `receipt_url` column to the `expenses` table.
    - Use the Supabase client to upload files to a "receipts" bucket.
    - Apply RLS policies to the storage bucket to protect user files.

---

## Slide 8: Real-time Functionality

**Data Sync Across Devices**

- Supabase's real-time capabilities allow us to subscribe to database changes.
- When a new expense is added (either manually or via the M-Pesa trigger), the UI updates instantly.
- This provides a seamless and responsive user experience.

---

## Slide 9: Conclusion

**Supabase: The Right Choice for Expense Tracker**

- **Rapid Development:** The all-in-one platform allowed us to build and iterate quickly.
- **Security:** RLS provides robust data protection out of the box.
- **Scalability:** We are confident that Supabase can handle our future growth.
- **Powerful Features:** Database functions and triggers enabled complex, automated workflows.

---

## Slide 10: Q&A

**Questions?**
