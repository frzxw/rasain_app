-- Fix untuk tabel recipe_reviews
-- Jalankan ini di SQL Editor Supabase

-- 1. Pastikan RLS sudah benar
ALTER TABLE public.recipe_reviews DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access for recipe_reviews" ON public.recipe_reviews;
CREATE POLICY "Allow public read access for recipe_reviews" 
   ON public.recipe_reviews
   FOR SELECT
   USING (true);

-- 2. Policy untuk insert/update oleh pengguna yang login
DROP POLICY IF EXISTS "Allow authenticated users to insert reviews" ON public.recipe_reviews;
CREATE POLICY "Allow authenticated users to insert reviews" 
   ON public.recipe_reviews
   FOR INSERT
   TO authenticated
   WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow users to update their own reviews" ON public.recipe_reviews;
CREATE POLICY "Allow users to update their own reviews" 
   ON public.recipe_reviews
   FOR UPDATE
   TO authenticated
   USING (auth.uid() = user_id);

-- 3. Aktifkan kembali RLS dengan policy yang baru
ALTER TABLE public.recipe_reviews ENABLE ROW LEVEL SECURITY;

-- 4. Tetapkan izin
GRANT SELECT ON TABLE public.recipe_reviews TO anon;
GRANT SELECT, INSERT, UPDATE ON TABLE public.recipe_reviews TO authenticated;

-- 5. Fix untuk recipe_instructions
ALTER TABLE public.recipe_instructions DISABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow public read access for recipe_instructions" ON public.recipe_instructions;
CREATE POLICY "Allow public read access for recipe_instructions" 
   ON public.recipe_instructions
   FOR SELECT
   USING (true);
ALTER TABLE public.recipe_instructions ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE public.recipe_instructions TO anon;
GRANT SELECT ON TABLE public.recipe_instructions TO authenticated;
