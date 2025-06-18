// Untuk memperbaiki masalah review_text vs comment

/*
PANDUAN LANGKAH-LANGKAH SOLUSI:

1. Buka file lib/services/recipe_service.dart

2. TEMUKAN DAN GANTI semua kode yang menggunakan 'review_text' dengan 'comment'
   - Cari semua kemunculan string 'review_text' dan ganti dengan 'comment'

3. Perbaikan untuk submitRecipeReview:
   - Jalankan kode berikut di Supabase SQL Editor:

```sql
-- Tambahkan kebijakan akses untuk review
DROP POLICY IF EXISTS "Allow users to update their own reviews" ON public.recipe_reviews;
CREATE POLICY "Allow users to update their own reviews" 
   ON public.recipe_reviews
   FOR UPDATE
   TO authenticated
   USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow authenticated users to insert reviews" ON public.recipe_reviews;
CREATE POLICY "Allow authenticated users to insert reviews" 
   ON public.recipe_reviews
   FOR INSERT
   TO authenticated
   WITH CHECK (auth.uid() = user_id);

GRANT SELECT, INSERT, UPDATE ON TABLE public.recipe_reviews TO authenticated;
```

4. Perbaikan untuk instructions:
   - Pastikan kode mengakses kolom 'instruction_text' dan bukan 'text'
   - Pastikan policy RLS memberikan akses publik ke recipe_instructions
*/

// KODE YANG BENAR UNTUK REVIEW (GUNAKAN INI):

// Untuk menambahkan review
await _supabaseService.client.from('recipe_reviews').insert({
  'user_id': userId,
  'recipe_id': recipeId,
  'rating': rating,
  'comment': comment, // Menggunakan 'comment' bukan 'review_text'
  'created_at': DateTime.now().toIso8601String(),
});

// Untuk memperbarui review yang sudah ada
await _supabaseService.client
  .from('recipe_reviews')
  .update({
    'rating': rating,
    'comment': comment, // Menggunakan 'comment' bukan 'review_text'
    'updated_at': DateTime.now().toIso8601String(),
  })
  .eq('user_id', userId)
  .eq('recipe_id', recipeId);
