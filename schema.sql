-- ===================================================================
-- FINAL, COMPLETE, AND CORRECTED DATABASE SCRIPT FOR RASAIN APP
--
-- This script fixes all schema issues, including all missing tables
-- and incorrect user references. This is the only schema script you need.
--
-- Instructions:
-- 1. PLEASE BACK UP YOUR DATABASE FROM THE SUPABASE DASHBOARD (if you have any data you want to save).
-- 2. Run this entire script in your Supabase SQL Editor.
-- 3. After this is successful, you can run the corrected seed scripts.
-- ===================================================================

-- =======================================
-- STEP 1: FULLY CLEAN THE PUBLIC SCHEMA (Corrected Method)
-- =======================================
-- Drop the entire public schema cascade to remove all objects
DROP SCHEMA public CASCADE;
-- Recreate the public schema
CREATE SCHEMA public;
-- Grant back the default permissions
GRANT USAGE ON SCHEMA public TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;


-- =======================================
-- STEP 2: REBUILD THE CORRECT AND COMPLETE SCHEMA
-- =======================================

-- Enable Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- ENUMS
CREATE TYPE public.message_type AS ENUM ('text', 'image');
CREATE TYPE public.message_sender AS ENUM ('user', 'ai', 'assistant');
CREATE TYPE public.notification_type AS ENUM ('recipe_recommendation', 'expiration_warning', 'low_stock', 'new_recipe', 'review', 'achievement', 'system');

-- CORE TABLES

-- User profiles table (references auth.users)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    saved_recipes_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    is_notifications_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'id',
    is_dark_mode_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own profile" ON public.user_profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users can update own profile" ON public.user_profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Users can insert own profile" ON public.user_profiles FOR INSERT WITH CHECK (id = auth.uid());

-- Recipe categories
CREATE TABLE public.recipe_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    name_id VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipes table
CREATE TABLE public.recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    estimated_cost VARCHAR(50),
    cook_time VARCHAR(50),
    prep_time VARCHAR(50),
    total_time VARCHAR(50),
    servings INTEGER,
    difficulty_level VARCHAR(20),
    description TEXT,
    nutrition_info JSONB,
    tips TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_featured BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe category mappings
CREATE TABLE public.recipe_category_mappings (
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES public.recipe_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (recipe_id, category_id)
);

-- Recipe ingredients
CREATE TABLE public.recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity VARCHAR(50),
    unit VARCHAR(50),
    price VARCHAR(50),
    image_url TEXT,
    is_optional BOOLEAN DEFAULT false,
    notes TEXT,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe instructions
CREATE TABLE public.recipe_instructions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction_text TEXT NOT NULL,
    video_url TEXT,
    image_url TEXT,
    estimated_time VARCHAR(50),
    temperature VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- PANTRY MANAGEMENT

-- Pantry item categories
CREATE TABLE public.pantry_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    name_id VARCHAR(100),
    name_en VARCHAR(100),
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User pantry items
CREATE TABLE public.pantry_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    image_url TEXT,
    quantity VARCHAR(50),
    unit VARCHAR(50),
    price VARCHAR(50),
    category_id INTEGER REFERENCES public.pantry_categories(id),
    storage_location VARCHAR(100),
    total_quantity INTEGER,
    low_stock_alert BOOLEAN DEFAULT false,
    expiration_alert BOOLEAN DEFAULT true,
    expiration_date DATE,
    purchase_date DATE,
    last_used_date DATE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE public.pantry_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can manage their own pantry items" ON public.pantry_items FOR ALL USING (auth.uid() = user_id);


-- Kitchen tools
CREATE TABLE public.kitchen_tools (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    name_id VARCHAR(255),
    name_en VARCHAR(255),
    description TEXT,
    image_url TEXT,
    category VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User's kitchen tools
CREATE TABLE public.user_kitchen_tools (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    tool_id INTEGER REFERENCES public.kitchen_tools(id) ON DELETE CASCADE,
    acquired_date DATE,
    notes TEXT,
    PRIMARY KEY (user_id, tool_id)
);

-- USER INTERACTIONS

-- Saved recipes
CREATE TABLE public.saved_recipes (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES public.recipes(id) ON DELETE CASCADE,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    PRIMARY KEY (user_id, recipe_id)
);

-- Recipe reviews
CREATE TABLE public.recipe_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    images JSONB,
    is_verified_purchase BOOLEAN DEFAULT false,
    helpful_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, user_id)
);

-- COMMUNITY FEATURES

-- Community posts
CREATE TABLE public.community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT,
    image_url TEXT,
    category VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Post likes
CREATE TABLE public.post_likes (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, post_id)
);

-- Post comments
CREATE TABLE public.post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES public.community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES public.post_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- NOTIFICATIONS

-- User notifications
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type notification_type NOT NULL,
    image_url TEXT,
    action_url TEXT,
    related_item_id UUID,
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TRIGGERS AND FUNCTIONS

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, name, email)
    VALUES (NEW.id, NEW.raw_user_meta_data->>'name', NEW.email);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create a profile when a new user signs up
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- Triggers for all tables with updated_at
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON public.recipes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_pantry_items_updated_at BEFORE UPDATE ON public.pantry_items FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_community_posts_updated_at BEFORE UPDATE ON public.community_posts FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_recipe_reviews_updated_at BEFORE UPDATE ON public.recipe_reviews FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();
CREATE TRIGGER update_post_comments_updated_at BEFORE UPDATE ON public.post_comments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- Function to update recipe rating and review count
CREATE OR REPLACE FUNCTION public.update_recipe_rating_and_review_count()
RETURNS TRIGGER AS $$
DECLARE
    new_rating DECIMAL(3,2);
    new_review_count INT;
BEGIN
    -- Determine the recipe_id from the operation
    IF (TG_OP = 'DELETE') THEN
        -- For DELETE, the recipe_id is in the OLD row
        SELECT COALESCE(AVG(rating), 0), COUNT(id)
        INTO new_rating, new_review_count
        FROM public.recipe_reviews
        WHERE recipe_id = OLD.recipe_id;

        UPDATE public.recipes
        SET rating = new_rating, review_count = new_review_count
        WHERE id = OLD.recipe_id;
    ELSE
        -- For INSERT or UPDATE, the recipe_id is in the NEW row
        SELECT COALESCE(AVG(rating), 0), COUNT(id)
        INTO new_rating, new_review_count
        FROM public.recipe_reviews
        WHERE recipe_id = NEW.recipe_id;

        UPDATE public.recipes
        SET rating = new_rating, review_count = new_review_count
        WHERE id = NEW.recipe_id;
    END IF;

    RETURN NULL; -- The result is ignored since this is an AFTER trigger
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update recipe stats after review changes
CREATE TRIGGER on_recipe_review_change
    AFTER INSERT OR UPDATE OR DELETE ON public.recipe_reviews
    FOR EACH ROW EXECUTE FUNCTION public.update_recipe_rating_and_review_count();


-- Grant permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;

-- =======================================
-- COMPLETION MESSAGE
-- =======================================
SELECT 'Rasain App Database Reset and Rebuild Completed Successfully!' as status;
