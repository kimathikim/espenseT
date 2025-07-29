-- Expense Tracker Database Schema Setup Script
-- Run this script in your Supabase SQL editor or with psql
-- This will create all necessary tables, policies, and functions

\echo 'Setting up Expense Tracker database schema...'

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create the 'categories' table
DROP TABLE IF EXISTS public.categories CASCADE;
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid NULL,
  name text NOT NULL,
  icon text NULL DEFAULT 'faFolder',
  color text NULL DEFAULT '#667eea',
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Add comments to the categories table
COMMENT ON TABLE public.categories IS 'Stores expense categories, both default (user_id is NULL) and user-created.';

-- Create the 'expenses' table
DROP TABLE IF EXISTS public.expenses CASCADE;
CREATE TABLE public.expenses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid NOT NULL,
  amount numeric NOT NULL,
  description text NULL,
  category_id uuid NOT NULL,
  transaction_date timestamp with time zone NOT NULL,
  screenshot_url text NULL,
  CONSTRAINT expenses_pkey PRIMARY KEY (id),
  CONSTRAINT expenses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id),
  CONSTRAINT expenses_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Add comments to the expenses table
COMMENT ON TABLE public.expenses IS 'Stores individual expense transactions.';

-- Create the 'mpesa_transactions' table
DROP TABLE IF EXISTS public.mpesa_transactions CASCADE;
CREATE TABLE public.mpesa_transactions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid NOT NULL,
  transaction_id text NOT NULL,
  type text NOT NULL,
  amount numeric NOT NULL,
  counterparty text NOT NULL,
  transaction_date timestamp with time zone NOT NULL,
  balance_after numeric NULL,
  raw_sms text NOT NULL,
  processed boolean NOT NULL DEFAULT false,
  CONSTRAINT mpesa_transactions_pkey PRIMARY KEY (id),
  CONSTRAINT mpesa_transactions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE,
  CONSTRAINT mpesa_transactions_unique_per_user UNIQUE (user_id, transaction_id)
);

-- Add comments to the mpesa_transactions table
COMMENT ON TABLE public.mpesa_transactions IS 'Stores raw M-Pesa transactions parsed from SMS messages.';

-- Enable Row Level Security (RLS) for all tables
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.mpesa_transactions ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for the 'categories' table
-- Drop existing policies first
DROP POLICY IF EXISTS "Allow users to see default categories" ON public.categories;
DROP POLICY IF EXISTS "Allow users to see their own categories" ON public.categories;
DROP POLICY IF EXISTS "Allow users to create their own categories" ON public.categories;
DROP POLICY IF EXISTS "Allow users to update their own categories" ON public.categories;
DROP POLICY IF EXISTS "Allow users to delete their own categories" ON public.categories;

-- 1. Users can see all default categories (where user_id is NULL)
CREATE POLICY "Allow users to see default categories" ON public.categories FOR SELECT USING (user_id IS NULL);
-- 2. Users can see their own custom categories
CREATE POLICY "Allow users to see their own categories" ON public.categories FOR SELECT USING (auth.uid() = user_id);
-- 3. Users can insert their own custom categories
CREATE POLICY "Allow users to create their own categories" ON public.categories FOR INSERT WITH CHECK (auth.uid() = user_id);
-- 4. Users can update their own custom categories
CREATE POLICY "Allow users to update their own categories" ON public.categories FOR UPDATE USING (auth.uid() = user_id);
-- 5. Users can delete their own custom categories
CREATE POLICY "Allow users to delete their own categories" ON public.categories FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for the 'expenses' table
-- Drop existing policies first
DROP POLICY IF EXISTS "Allow users to see their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Allow users to insert their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Allow users to update their own expenses" ON public.expenses;
DROP POLICY IF EXISTS "Allow users to delete their own expenses" ON public.expenses;

-- 1. Users can see their own expenses
CREATE POLICY "Allow users to see their own expenses" ON public.expenses FOR SELECT USING (auth.uid() = user_id);
-- 2. Users can insert their own expenses
CREATE POLICY "Allow users to insert their own expenses" ON public.expenses FOR INSERT WITH CHECK (auth.uid() = user_id);
-- 3. Users can update their own expenses
CREATE POLICY "Allow users to update their own expenses" ON public.expenses FOR UPDATE USING (auth.uid() = user_id);
-- 4. Users can delete their own expenses
CREATE POLICY "Allow users to delete their own expenses" ON public.expenses FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for the 'mpesa_transactions' table
-- Drop existing policies first
DROP POLICY IF EXISTS "Allow users to see their own mpesa transactions" ON public.mpesa_transactions;
DROP POLICY IF EXISTS "Allow users to insert their own mpesa transactions" ON public.mpesa_transactions;
DROP POLICY IF EXISTS "Allow users to update their own mpesa transactions" ON public.mpesa_transactions;
DROP POLICY IF EXISTS "Allow users to delete their own mpesa transactions" ON public.mpesa_transactions;

-- 1. Users can see their own M-Pesa transactions
CREATE POLICY "Allow users to see their own mpesa transactions" ON public.mpesa_transactions FOR SELECT USING (auth.uid() = user_id);
-- 2. Users can insert their own M-Pesa transactions
CREATE POLICY "Allow users to insert their own mpesa transactions" ON public.mpesa_transactions FOR INSERT WITH CHECK (auth.uid() = user_id);
-- 3. Users can update their own M-Pesa transactions
CREATE POLICY "Allow users to update their own mpesa transactions" ON public.mpesa_transactions FOR UPDATE USING (auth.uid() = user_id);
-- 4. Users can delete their own M-Pesa transactions
CREATE POLICY "Allow users to delete their own mpesa transactions" ON public.mpesa_transactions FOR DELETE USING (auth.uid() = user_id);

-- Insert default categories with proper icons and colors
INSERT INTO public.categories (name, icon, color) VALUES
('Food & Dining', 'faUtensils', '#FF6B6B'),
('Transportation', 'faCar', '#4ECDC4'),
('Shopping', 'faShoppingBag', '#45B7D1'),
('Bills & Utilities', 'faFileInvoiceDollar', '#96CEB4'),
('Entertainment', 'faGamepad', '#FFEAA7'),
('Health & Medical', 'faHeartbeat', '#DDA0DD'),
('Education', 'faGraduationCap', '#74B9FF'),
('Travel', 'faPlane', '#00B894'),
('Business', 'faBriefcase', '#6C5CE7'),
('Personal Care', 'faSpa', '#FD79A8'),
('Gifts & Donations', 'faGift', '#FDCB6E'),
('Uncategorized', 'faFolder', '#B2BEC3')
ON CONFLICT DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_categories_user_id ON public.categories(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_user_id ON public.expenses(user_id);
CREATE INDEX IF NOT EXISTS idx_expenses_category_id ON public.expenses(category_id);
CREATE INDEX IF NOT EXISTS idx_expenses_transaction_date ON public.expenses(transaction_date);
CREATE INDEX IF NOT EXISTS idx_mpesa_transactions_user_id ON public.mpesa_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_mpesa_transactions_date ON public.mpesa_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_mpesa_transactions_processed ON public.mpesa_transactions(processed);

\echo 'Database schema setup completed successfully!'
\echo 'Tables created: categories, expenses, mpesa_transactions'
\echo 'RLS policies applied for data security'
\echo 'Default categories inserted'
\echo 'Performance indexes created'
