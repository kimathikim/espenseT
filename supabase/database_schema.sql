-- Create the 'categories' table
CREATE TABLE public.categories (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid NULL,
  name text NOT NULL,
  icon_name text NULL,
  CONSTRAINT categories_pkey PRIMARY KEY (id),
  CONSTRAINT categories_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE
);

-- Add comments to the categories table
COMMENT ON TABLE public.categories IS 'Stores expense categories, both default (user_id is NULL) and user-created.';

-- Create the 'expenses' table
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

-- Enable Row Level Security (RLS) for both tables
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for the 'categories' table
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
-- 1. Users can see their own expenses
CREATE POLICY "Allow users to see their own expenses" ON public.expenses FOR SELECT USING (auth.uid() = user_id);
-- 2. Users can insert their own expenses
CREATE POLICY "Allow users to insert their own expenses" ON public.expenses FOR INSERT WITH CHECK (auth.uid() = user_id);
-- 3. Users can update their own expenses
CREATE POLICY "Allow users to update their own expenses" ON public.expenses FOR UPDATE USING (auth.uid() = user_id);
-- 4. Users can delete their own expenses
CREATE POLICY "Allow users to delete their own expenses" ON public.expenses FOR DELETE USING (auth.uid() = user_id);

-- Insert default categories
INSERT INTO public.categories (name, icon_name) VALUES
('Food', 'icon_food'),
('Transport', 'icon_transport'),
('Shopping', 'icon_shopping'),
('Bills', 'icon_bills'),
('Entertainment', 'icon_entertainment'),
('Health', 'icon_health'),
('Other', 'icon_other');
