-- =========================================
-- RASAIN APP - SCHEMA RESTORATION SCRIPT
-- This script will drop all existing tables and restore from backup
-- =========================================

-- First, drop all existing tables and dependencies
-- Note: This will remove ALL data, use with caution!

-- Drop existing policies first (if they exist)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Public recipes are viewable" ON recipes;
DROP POLICY IF EXISTS "Users can create recipes" ON recipes;
DROP POLICY IF EXISTS "Users can update own recipes" ON recipes;
DROP POLICY IF EXISTS "Users can view own pantry" ON pantry_items;
DROP POLICY IF EXISTS "Users can manage own pantry" ON pantry_items;
DROP POLICY IF EXISTS "Public posts are viewable" ON community_posts;
DROP POLICY IF EXISTS "Users can create posts" ON community_posts;
DROP POLICY IF EXISTS "Users can update own posts" ON community_posts;
DROP POLICY IF EXISTS "Users can view own messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can create own messages" ON chat_messages;
DROP POLICY IF EXISTS "Users can view own notifications" ON notifications;
DROP POLICY IF EXISTS "Users can update own notifications" ON notifications;

-- Drop existing triggers first (before dropping functions they depend on)
DROP TRIGGER IF EXISTS tr_user_profiles_updated_at ON user_profiles;
DROP TRIGGER IF EXISTS update_user_profiles_updated_at ON user_profiles;
DROP TRIGGER IF EXISTS tr_recipes_updated_at ON recipes;
DROP TRIGGER IF EXISTS update_recipes_updated_at ON recipes;
DROP TRIGGER IF EXISTS update_tools_updated_at ON tools;
DROP TRIGGER IF EXISTS tr_pantry_items_updated_at ON pantry_items;
DROP TRIGGER IF EXISTS update_pantry_items_updated_at ON pantry_items;
DROP TRIGGER IF EXISTS tr_community_posts_updated_at ON community_posts;
DROP TRIGGER IF EXISTS update_community_posts_updated_at ON community_posts;
DROP TRIGGER IF EXISTS update_recipe_reviews_updated_at ON recipe_reviews;
DROP TRIGGER IF EXISTS tr_post_comments_updated_at ON post_comments;
DROP TRIGGER IF EXISTS update_post_comments_updated_at ON post_comments;
DROP TRIGGER IF EXISTS update_chat_conversations_updated_at ON chat_conversations;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Now drop existing functions (after triggers are removed)
DROP FUNCTION IF EXISTS handle_new_user();
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS search_recipes_by_ingredients(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_recipe_recommendations(UUID, INTEGER);
DROP FUNCTION IF EXISTS get_expiring_items(UUID, INTEGER);

-- Drop existing tables (in correct order to avoid foreign key conflicts)
DROP TABLE IF EXISTS recipe_tools CASCADE;
DROP TABLE IF EXISTS tools CASCADE;
DROP TABLE IF EXISTS recipe_categories_recipes CASCADE;
DROP TABLE IF EXISTS recipe_categories CASCADE;
DROP TABLE IF EXISTS saved_recipes CASCADE;
DROP TABLE IF EXISTS recipe_reviews CASCADE;
DROP TABLE IF EXISTS recipe_instructions CASCADE;
DROP TABLE IF EXISTS recipe_ingredients CASCADE;
DROP TABLE IF EXISTS post_comments CASCADE;
DROP TABLE IF EXISTS community_posts CASCADE;
DROP TABLE IF EXISTS chat_messages CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS pantry_categories CASCADE;
DROP TABLE IF EXISTS pantry_items CASCADE;
DROP TABLE IF EXISTS recipes CASCADE;
DROP TABLE IF EXISTS user_profiles CASCADE;

-- Drop existing types
DROP TYPE IF EXISTS message_type CASCADE;
DROP TYPE IF EXISTS message_sender CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;

-- Now restore from backup schema
-- =========================================
-- RASAIN APP DATABASE SCHEMA
-- PostgreSQL Schema for Indonesian Recipe & Cooking Assistant App
-- Optimized for Supabase with built-in authentication
-- =========================================

-- Enable UUID extension for primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enable trigram extension for full-text search
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- =========================================
-- ENUMS
-- =========================================

-- Message types for chat system
CREATE TYPE message_type AS ENUM ('text', 'image');

-- Message sender types
CREATE TYPE message_sender AS ENUM ('user', 'ai', 'assistant');

-- Notification types
CREATE TYPE notification_type AS ENUM (
    'recipe_recommendation', 
    'expiration_warning', 
    'low_stock', 
    'new_recipe', 
    'review', 
    'achievement', 
    'system'
);

-- =========================================
-- CORE TABLES
-- =========================================

-- Users table (main user authentication and basic info)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT,
    email_verified BOOLEAN DEFAULT false,
    phone VARCHAR(20),
    phone_verified BOOLEAN DEFAULT false,
    last_sign_in_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- User profiles table (extended user information)
CREATE TABLE user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    image_url TEXT,
    bio TEXT,
    saved_recipes_count INTEGER DEFAULT 0,
    posts_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    is_notifications_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'id',
    is_dark_mode_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe categories
CREATE TABLE recipe_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    name_id VARCHAR(100) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50)
);

-- Recipes table
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    image_url TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    estimated_cost VARCHAR(100),
    cook_time VARCHAR(50),
    prep_time VARCHAR(50),
    total_time VARCHAR(50),
    servings INTEGER,
    difficulty_level VARCHAR(20) CHECK (difficulty_level IN ('mudah', 'sedang', 'sulit')),
    description TEXT,
    nutrition_info JSONB,
    tips TEXT,
    created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    is_featured BOOLEAN DEFAULT false,
    is_published BOOLEAN DEFAULT false,
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Recipe-Categories many-to-many relationship
CREATE TABLE recipe_categories_recipes (
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    category_id INTEGER REFERENCES recipe_categories(id) ON DELETE CASCADE,
    PRIMARY KEY (recipe_id, category_id)
);

-- Recipe ingredients
CREATE TABLE recipe_ingredients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(255) NOT NULL,
    quantity VARCHAR(50),
    unit VARCHAR(50),
    order_index INTEGER DEFAULT 0,
    notes TEXT
);

-- Recipe instructions/steps
CREATE TABLE recipe_instructions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    step_number INTEGER NOT NULL,
    instruction_text TEXT NOT NULL,
    image_url TEXT,
    timer_minutes INTEGER,
    UNIQUE(recipe_id, step_number)
);

-- Recipe reviews and ratings
CREATE TABLE recipe_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    rating DECIMAL(3,2) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(recipe_id, user_id)
);

-- Saved recipes by users
CREATE TABLE saved_recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, recipe_id)
);

-- =========================================
-- PANTRY MANAGEMENT
-- =========================================

-- Pantry categories
CREATE TABLE pantry_categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_id VARCHAR(100) NOT NULL UNIQUE,
    name_en VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50)
);

-- User pantry items
CREATE TABLE pantry_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    quantity VARCHAR(100),
    unit VARCHAR(50),
    category_id INTEGER REFERENCES pantry_categories(id),
    location VARCHAR(100),
    expiration_date DATE,
    is_running_low BOOLEAN DEFAULT false,
    image_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- TOOLS AND EQUIPMENT
-- =========================================

-- Cooking tools and equipment
CREATE TABLE tools (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    name_id VARCHAR(255) NOT NULL UNIQUE,
    name_en VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    image_url TEXT
);

-- Recipe-tools many-to-many relationship
CREATE TABLE recipe_tools (
    recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
    tool_id UUID REFERENCES tools(id) ON DELETE CASCADE,
    is_required BOOLEAN DEFAULT true,
    notes TEXT,
    PRIMARY KEY (recipe_id, tool_id)
);

-- =========================================
-- COMMUNITY FEATURES
-- =========================================

-- Community posts
CREATE TABLE community_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    image_url TEXT,
    category VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0,
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Post comments
CREATE TABLE post_comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES community_posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES post_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- AI CHAT SYSTEM
-- =========================================

-- Chat messages with AI assistant
CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    message_type message_type DEFAULT 'text',
    sender message_sender NOT NULL,
    response_data JSONB,
    related_recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- NOTIFICATIONS
-- =========================================

-- User notifications
CREATE TABLE notifications (
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

-- =========================================
-- INDEXES FOR PERFORMANCE
-- =========================================

-- User profiles indexes
CREATE INDEX idx_user_profiles_email ON user_profiles(email);

-- Recipe indexes
CREATE INDEX idx_recipes_created_by ON recipes(created_by);
CREATE INDEX idx_recipes_featured ON recipes(is_featured);
CREATE INDEX idx_recipes_published ON recipes(is_published);
CREATE INDEX idx_recipes_rating ON recipes(rating);
CREATE INDEX idx_recipes_name_gin ON recipes USING gin(name gin_trgm_ops);
CREATE INDEX idx_recipes_description_gin ON recipes USING gin(description gin_trgm_ops);

-- Recipe ingredients indexes
CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);
CREATE INDEX idx_recipe_ingredients_name_gin ON recipe_ingredients USING gin(ingredient_name gin_trgm_ops);

-- Recipe instructions indexes
CREATE INDEX idx_recipe_instructions_recipe_id ON recipe_instructions(recipe_id);
CREATE INDEX idx_recipe_instructions_step ON recipe_instructions(recipe_id, step_number);

-- Pantry items indexes
CREATE INDEX idx_pantry_items_user_id ON pantry_items(user_id);
CREATE INDEX idx_pantry_items_category ON pantry_items(category_id);
CREATE INDEX idx_pantry_items_expiration ON pantry_items(expiration_date);
CREATE INDEX idx_pantry_items_name_gin ON pantry_items USING gin(name gin_trgm_ops);

-- Community posts indexes
CREATE INDEX idx_community_posts_user_id ON community_posts(user_id);
CREATE INDEX idx_community_posts_recipe_id ON community_posts(recipe_id);
CREATE INDEX idx_community_posts_featured ON community_posts(is_featured);
CREATE INDEX idx_community_posts_created_at ON community_posts(created_at);

-- Chat messages indexes
CREATE INDEX idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX idx_chat_messages_created_at ON chat_messages(user_id, created_at);

-- Notifications indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON notifications(user_id, created_at);

-- =========================================
-- TRIGGERS AND FUNCTIONS
-- =========================================

-- Function to handle updated_at timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER tr_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_pantry_items_updated_at
    BEFORE UPDATE ON pantry_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_community_posts_updated_at
    BEFORE UPDATE ON community_posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER tr_post_comments_updated_at
    BEFORE UPDATE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.user_profiles (id, name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- =========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =========================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_instructions ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE pantry_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE community_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view own profile" ON user_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Recipe policies
CREATE POLICY "Public recipes are viewable" ON recipes
    FOR SELECT USING (is_published = true);

CREATE POLICY "Users can create recipes" ON recipes
    FOR INSERT WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Users can update own recipes" ON recipes
    FOR UPDATE USING (auth.uid() = created_by);

-- Recipe ingredients policies (follow recipe permissions)
CREATE POLICY "Recipe ingredients follow recipe permissions" ON recipe_ingredients
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM recipes 
            WHERE recipes.id = recipe_ingredients.recipe_id 
            AND (recipes.is_published = true OR recipes.created_by = auth.uid())
        )
    );

-- Recipe instructions policies (follow recipe permissions)
CREATE POLICY "Recipe instructions follow recipe permissions" ON recipe_instructions
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM recipes 
            WHERE recipes.id = recipe_instructions.recipe_id 
            AND (recipes.is_published = true OR recipes.created_by = auth.uid())
        )
    );

-- Recipe reviews policies
CREATE POLICY "Recipe reviews are viewable for published recipes" ON recipe_reviews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM recipes 
            WHERE recipes.id = recipe_reviews.recipe_id 
            AND recipes.is_published = true
        )
    );

CREATE POLICY "Users can create reviews for published recipes" ON recipe_reviews
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        EXISTS (
            SELECT 1 FROM recipes 
            WHERE recipes.id = recipe_reviews.recipe_id 
            AND recipes.is_published = true
        )
    );

-- Saved recipes policies
CREATE POLICY "Users can view own saved recipes" ON saved_recipes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own saved recipes" ON saved_recipes
    FOR ALL USING (auth.uid() = user_id);

-- Pantry items policies
CREATE POLICY "Users can view own pantry" ON pantry_items
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own pantry" ON pantry_items
    FOR ALL USING (auth.uid() = user_id);

-- Community posts policies
CREATE POLICY "Public posts are viewable" ON community_posts
    FOR SELECT USING (true);

CREATE POLICY "Users can create posts" ON community_posts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts" ON community_posts
    FOR UPDATE USING (auth.uid() = user_id);

-- Post comments policies
CREATE POLICY "Comments are viewable" ON post_comments
    FOR SELECT USING (true);

CREATE POLICY "Users can create comments" ON post_comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments" ON post_comments
    FOR UPDATE USING (auth.uid() = user_id);

-- Chat messages policies
CREATE POLICY "Users can view own messages" ON chat_messages
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create own messages" ON chat_messages
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Notifications policies
CREATE POLICY "Users can view own notifications" ON notifications
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications" ON notifications
    FOR UPDATE USING (auth.uid() = user_id);

-- =========================================
-- ADVANCED FUNCTIONS
-- =========================================

-- Function to search recipes by available ingredients
CREATE OR REPLACE FUNCTION search_recipes_by_ingredients(
    user_uuid UUID,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    recipe_id UUID,
    recipe_name VARCHAR,
    matching_ingredients BIGINT,
    total_ingredients BIGINT,
    match_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH user_pantry AS (
        SELECT LOWER(TRIM(name)) as ingredient_name
        FROM pantry_items 
        WHERE user_id = user_uuid
    ),
    recipe_matches AS (
        SELECT 
            r.id,
            r.name,
            COUNT(ri.id) as total_ingredients,
            COUNT(up.ingredient_name) as matching_ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN user_pantry up ON LOWER(ri.ingredient_name) LIKE '%' || up.ingredient_name || '%'
        WHERE r.is_published = true
        GROUP BY r.id, r.name
        HAVING COUNT(ri.id) > 0
    )
    SELECT 
        rm.id,
        rm.name,
        rm.matching_ingredients,
        rm.total_ingredients,
        ROUND((rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) * 100, 2)
    FROM recipe_matches rm
    WHERE rm.matching_ingredients > 0
    ORDER BY 
        (rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) DESC,
        rm.matching_ingredients DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get recipe recommendations based on user pantry
CREATE OR REPLACE FUNCTION get_recipe_recommendations(
    user_uuid UUID,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    recipe_id UUID,
    recipe_name VARCHAR,
    matching_ingredients BIGINT,
    total_ingredients BIGINT,
    match_percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH user_pantry AS (
        SELECT LOWER(TRIM(name)) as ingredient_name
        FROM pantry_items 
        WHERE user_id = user_uuid
    ),
    recipe_matches AS (
        SELECT 
            r.id,
            r.name,
            COUNT(ri.id) as total_ingredients,
            COUNT(up.ingredient_name) as matching_ingredients
        FROM recipes r
        JOIN recipe_ingredients ri ON r.id = ri.recipe_id
        LEFT JOIN user_pantry up ON LOWER(ri.name) LIKE '%' || up.ingredient_name || '%'
        WHERE r.is_published = true
        GROUP BY r.id, r.name
        HAVING COUNT(ri.id) > 0
    )
    SELECT 
        rm.id,
        rm.name,
        rm.matching_ingredients,
        rm.total_ingredients,
        ROUND((rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) * 100, 2)
    FROM recipe_matches rm
    WHERE rm.matching_ingredients > 0
    ORDER BY 
        (rm.matching_ingredients::DECIMAL / rm.total_ingredients::DECIMAL) DESC,
        rm.matching_ingredients DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get expiring pantry items
CREATE OR REPLACE FUNCTION get_expiring_items(user_uuid UUID, days_ahead INTEGER DEFAULT 7)
RETURNS TABLE (
    item_id UUID,
    item_name VARCHAR,
    expiration_date DATE,
    days_until_expiration INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pi.id,
        pi.name,
        pi.expiration_date,
        (pi.expiration_date - CURRENT_DATE)::INTEGER
    FROM pantry_items pi
    WHERE pi.user_id = user_uuid 
      AND pi.expiration_date IS NOT NULL
      AND pi.expiration_date <= CURRENT_DATE + INTERVAL '1 day' * days_ahead
      AND pi.expiration_date >= CURRENT_DATE
    ORDER BY pi.expiration_date ASC;
END;
$$ LANGUAGE plpgsql;

-- =========================================
-- COMPLETION MESSAGE
-- =========================================

-- Database schema restoration completed
SELECT 'Rasain App PostgreSQL Database Schema Restored Successfully!' as status;
