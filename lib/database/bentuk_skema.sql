-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.chat_conversations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  title character varying,
  last_message_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chat_conversations_pkey PRIMARY KEY (id),
  CONSTRAINT chat_conversations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.chat_messages (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  message text NOT NULL,
  message_type USER-DEFINED DEFAULT 'text'::message_type,
  sender USER-DEFINED NOT NULL,
  response_data jsonb,
  related_recipe_id uuid,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chat_messages_pkey PRIMARY KEY (id),
  CONSTRAINT chat_messages_related_recipe_id_fkey FOREIGN KEY (related_recipe_id) REFERENCES public.recipes(id),
  CONSTRAINT chat_messages_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.community_posts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  title character varying NOT NULL,
  content text NOT NULL,
  recipe_id uuid,
  image_url text,
  category character varying,
  like_count integer DEFAULT 0,
  comment_count integer DEFAULT 0,
  view_count integer DEFAULT 0,
  is_featured boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT community_posts_pkey PRIMARY KEY (id),
  CONSTRAINT community_posts_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT community_posts_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id)
);
CREATE TABLE public.ingredients (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  icon text,
  CONSTRAINT ingredients_pkey PRIMARY KEY (id)
);
CREATE TABLE public.notifications (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  title character varying NOT NULL,
  message text NOT NULL,
  notification_type USER-DEFINED NOT NULL,
  image_url text,
  action_url text,
  related_item_id uuid,
  is_read boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT notifications_pkey PRIMARY KEY (id),
  CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.pantry_categories (
  id integer NOT NULL DEFAULT nextval('pantry_categories_id_seq'::regclass),
  name character varying NOT NULL,
  name_id character varying NOT NULL UNIQUE,
  name_en character varying NOT NULL,
  description text,
  icon character varying,
  CONSTRAINT pantry_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.pantry_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  name character varying NOT NULL,
  quantity character varying,
  unit character varying,
  category_id integer,
  location character varying,
  expiration_date date,
  is_running_low boolean DEFAULT false,
  image_url text,
  notes text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pantry_items_pkey PRIMARY KEY (id),
  CONSTRAINT pantry_items_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT pantry_items_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.pantry_categories(id)
);
CREATE TABLE public.post_comments (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  post_id uuid NOT NULL,
  user_id uuid NOT NULL,
  parent_comment_id uuid,
  content text NOT NULL,
  like_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT post_comments_pkey PRIMARY KEY (id),
  CONSTRAINT post_comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT post_comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES public.community_posts(id),
  CONSTRAINT post_comments_parent_comment_id_fkey FOREIGN KEY (parent_comment_id) REFERENCES public.post_comments(id)
);
CREATE TABLE public.post_likes (
  user_id uuid NOT NULL,
  post_id uuid NOT NULL,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT post_likes_pkey PRIMARY KEY (user_id, post_id),
  CONSTRAINT post_likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.recipe_categories (
  id integer NOT NULL DEFAULT nextval('recipe_categories_id_seq'::regclass),
  name character varying NOT NULL UNIQUE,
  description text,
  CONSTRAINT recipe_categories_pkey PRIMARY KEY (id)
);
CREATE TABLE public.recipe_categories_recipes (
  recipe_id uuid NOT NULL,
  category_id integer NOT NULL,
  CONSTRAINT recipe_categories_recipes_pkey PRIMARY KEY (recipe_id, category_id),
  CONSTRAINT recipe_categories_recipes_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.recipe_categories(id),
  CONSTRAINT recipe_categories_recipes_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id)
);
CREATE TABLE public.recipe_category_mappings (
  recipe_id uuid NOT NULL,
  category_id integer NOT NULL,
  CONSTRAINT recipe_category_mappings_pkey PRIMARY KEY (recipe_id, category_id)
);
CREATE TABLE public.recipe_ingredients (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  recipe_id uuid NOT NULL,
  ingredient_name character varying NOT NULL,
  quantity character varying,
  unit character varying,
  order_index integer DEFAULT 0,
  notes text,
  ingredient_id uuid,
  amount text,
  CONSTRAINT recipe_ingredients_pkey PRIMARY KEY (id),
  CONSTRAINT fk_ingredient FOREIGN KEY (ingredient_id) REFERENCES public.ingredients(id),
  CONSTRAINT recipe_ingredients_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id)
);
CREATE TABLE public.recipe_instructions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  recipe_id uuid NOT NULL,
  step_number integer NOT NULL,
  instruction_text text NOT NULL,
  image_url text,
  timer_minutes integer,
  CONSTRAINT recipe_instructions_pkey PRIMARY KEY (id),
  CONSTRAINT recipe_instructions_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id)
);
CREATE TABLE public.recipe_reviews (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  recipe_id uuid NOT NULL,
  user_id uuid NOT NULL,
  rating numeric NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
  comment text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT recipe_reviews_pkey PRIMARY KEY (id),
  CONSTRAINT recipe_reviews_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id),
  CONSTRAINT recipe_reviews_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id)
);
CREATE TABLE public.recipe_tools (
  recipe_id uuid NOT NULL,
  tool_id uuid NOT NULL,
  is_required boolean DEFAULT true,
  notes text,
  CONSTRAINT recipe_tools_pkey PRIMARY KEY (recipe_id, tool_id),
  CONSTRAINT recipe_tools_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id),
  CONSTRAINT recipe_tools_tool_id_fkey FOREIGN KEY (tool_id) REFERENCES public.tools(id)
);
CREATE TABLE public.recipes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  slug character varying NOT NULL UNIQUE,
  image_url text,
  rating numeric DEFAULT 0.0,
  review_count integer DEFAULT 0,
  estimated_cost character varying,
  cook_time character varying,
  prep_time character varying,
  total_time character varying,
  servings integer,
  difficulty_level character varying CHECK (difficulty_level::text = ANY (ARRAY['mudah'::character varying, 'sedang'::character varying, 'sulit'::character varying]::text[])),
  description text,
  nutrition_info jsonb,
  tips text,
  created_by uuid,
  is_featured boolean DEFAULT false,
  is_published boolean DEFAULT false,
  view_count integer DEFAULT 0,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT recipes_pkey PRIMARY KEY (id),
  CONSTRAINT recipes_created_by_fkey FOREIGN KEY (created_by) REFERENCES auth.users(id)
);
CREATE TABLE public.saved_recipes (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid NOT NULL,
  recipe_id uuid NOT NULL,
  notes text,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT saved_recipes_pkey PRIMARY KEY (id),
  CONSTRAINT saved_recipes_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipes(id),
  CONSTRAINT saved_recipes_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.tools (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name character varying NOT NULL,
  name_id character varying NOT NULL UNIQUE,
  name_en character varying NOT NULL,
  description text,
  category character varying,
  image_url text,
  CONSTRAINT tools_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_kitchen_tools (
  user_id uuid NOT NULL,
  tool_id uuid NOT NULL,
  acquired_date date,
  notes text,
  CONSTRAINT user_kitchen_tools_pkey PRIMARY KEY (user_id, tool_id),
  CONSTRAINT user_kitchen_tools_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id)
);
CREATE TABLE public.user_profiles (
  id uuid NOT NULL,
  name character varying NOT NULL,
  email character varying NOT NULL UNIQUE,
  image_url text,
  bio text,
  saved_recipes_count integer DEFAULT 0,
  posts_count integer DEFAULT 0,
  followers_count integer DEFAULT 0,
  following_count integer DEFAULT 0,
  is_notifications_enabled boolean DEFAULT true,
  language character varying DEFAULT 'id'::character varying,
  is_dark_mode_enabled boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT user_profiles_pkey PRIMARY KEY (id),
  CONSTRAINT user_profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id)
);
CREATE TABLE public.users (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  email character varying NOT NULL UNIQUE,
  password_hash text,
  email_verified boolean DEFAULT false,
  phone character varying,
  phone_verified boolean DEFAULT false,
  last_sign_in_at timestamp with time zone,
  created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);