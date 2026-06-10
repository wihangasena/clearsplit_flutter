-- Supabase Schema for ClearSplit App
-- Run these queries in Supabase SQL Editor

-- Create users table (extends auth.users)
CREATE TABLE IF NOT EXISTS public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL UNIQUE,
  display_name VARCHAR(255) NOT NULL,
  avatar VARCHAR(50),
  color VARCHAR(7),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create people table (contacts/friends)
CREATE TABLE IF NOT EXISTS public.people (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  avatar VARCHAR(50),
  color VARCHAR(7),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create groups table
CREATE TABLE IF NOT EXISTS public.groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  emoji VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create group_members join table
CREATE TABLE IF NOT EXISTS public.group_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  person_id UUID NOT NULL REFERENCES public.people(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(group_id, person_id)
);

-- Create expenses table
CREATE TABLE IF NOT EXISTS public.expenses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  group_id UUID REFERENCES public.groups(id) ON DELETE SET NULL,
  title VARCHAR(255) NOT NULL,
  amount DECIMAL(10, 2) NOT NULL,
  paid_by UUID NOT NULL REFERENCES public.people(id) ON DELETE CASCADE,
  category VARCHAR(50),
  split_method VARCHAR(50) DEFAULT 'equal', -- 'equal', 'amount', 'percentage'
  note TEXT,
  settled BOOLEAN DEFAULT FALSE,
  personal BOOLEAN DEFAULT FALSE,
  date TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create expense_participants join table
CREATE TABLE IF NOT EXISTS public.expense_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  expense_id UUID NOT NULL REFERENCES public.expenses(id) ON DELETE CASCADE,
  person_id UUID NOT NULL REFERENCES public.people(id) ON DELETE CASCADE,
  share_amount DECIMAL(10, 2),
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(expense_id, person_id)
);

-- Create grocery_items table
CREATE TABLE IF NOT EXISTS public.grocery_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id UUID NOT NULL REFERENCES public.groups(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  tag VARCHAR(50),
  qty VARCHAR(100),
  claimed_by UUID REFERENCES public.people(id) ON DELETE SET NULL,
  bought_by UUID REFERENCES public.people(id) ON DELETE SET NULL,
  price DECIMAL(10, 2),
  done BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_people_user_id ON public.people(user_id);
CREATE INDEX idx_groups_user_id ON public.groups(user_id);
CREATE INDEX idx_group_members_group_id ON public.group_members(group_id);
CREATE INDEX idx_group_members_person_id ON public.group_members(person_id);
CREATE INDEX idx_expenses_user_id ON public.expenses(user_id);
CREATE INDEX idx_expenses_group_id ON public.expenses(group_id);
CREATE INDEX idx_expenses_paid_by ON public.expenses(paid_by);
CREATE INDEX idx_expense_participants_expense_id ON public.expense_participants(expense_id);
CREATE INDEX idx_expense_participants_person_id ON public.expense_participants(person_id);
CREATE INDEX idx_grocery_items_group_id ON public.grocery_items(group_id);

-- Enable RLS (Row Level Security)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.people ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.grocery_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for users
CREATE POLICY "Users can read their own data" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- RLS Policies for people
CREATE POLICY "Users can read their people" ON public.people
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their people" ON public.people
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their people" ON public.people
  FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for groups
CREATE POLICY "Users can read their groups" ON public.groups
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert groups" ON public.groups
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their groups" ON public.groups
  FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for expenses
CREATE POLICY "Users can read their expenses" ON public.expenses
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert expenses" ON public.expenses
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their expenses" ON public.expenses
  FOR UPDATE USING (auth.uid() = user_id);

-- RLS Policies for grocery items
CREATE POLICY "Users can read group grocery items" ON public.grocery_items
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.groups WHERE id = group_id AND user_id = auth.uid()
    )
  );

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_people_updated_at BEFORE UPDATE ON public.people
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_groups_updated_at BEFORE UPDATE ON public.groups
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON public.expenses
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_grocery_items_updated_at BEFORE UPDATE ON public.grocery_items
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
