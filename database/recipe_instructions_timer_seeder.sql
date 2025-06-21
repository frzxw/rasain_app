-- Seeder untuk menambahkan timer_minutes pada recipe_instructions
-- Script ini akan menambahkan waktu yang realistis untuk setiap langkah memasak

-- Update existing recipe instructions dengan timer yang realistic
UPDATE recipe_instructions 
SET timer_minutes = CASE 
    -- Langkah persiapan (biasanya cepat)
    WHEN step_number = 1 THEN 
        CASE 
            WHEN LOWER(instruction_text) LIKE '%cuci%' OR LOWER(instruction_text) LIKE '%bersih%' THEN 3
            WHEN LOWER(instruction_text) LIKE '%potong%' OR LOWER(instruction_text) LIKE '%iris%' THEN 5
            WHEN LOWER(instruction_text) LIKE '%siapkan%' OR LOWER(instruction_text) LIKE '%campurkan%' THEN 2
            ELSE 3
        END
    
    -- Langkah memasak (lebih lama)
    WHEN step_number = 2 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%panaskan%' OR LOWER(instruction_text) LIKE '%tumis%' THEN 5
            WHEN LOWER(instruction_text) LIKE '%rebus%' OR LOWER(instruction_text) LIKE '%masak%' THEN 15
            WHEN LOWER(instruction_text) LIKE '%goreng%' THEN 8
            WHEN LOWER(instruction_text) LIKE '%bakar%' THEN 20
            ELSE 10
        END
    
    -- Langkah lanjutan
    WHEN step_number = 3 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%masak%' OR LOWER(instruction_text) LIKE '%rebus%' THEN 20
            WHEN LOWER(instruction_text) LIKE '%tumis%' OR LOWER(instruction_text) LIKE '%aduk%' THEN 7
            WHEN LOWER(instruction_text) LIKE '%panggang%' OR LOWER(instruction_text) LIKE '%oven%' THEN 25
            WHEN LOWER(instruction_text) LIKE '%goreng%' THEN 10
            ELSE 12
        END
    
    -- Langkah finishing
    WHEN step_number = 4 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%sajikan%' OR LOWER(instruction_text) LIKE '%hidangkan%' THEN 2
            WHEN LOWER(instruction_text) LIKE '%matang%' OR LOWER(instruction_text) LIKE '%masak%' THEN 15
            WHEN LOWER(instruction_text) LIKE '%angkat%' OR LOWER(instruction_text) LIKE '%tiriskan%' THEN 1
            ELSE 8
        END
    
    -- Langkah terakhir (biasanya penyajian)
    WHEN step_number >= 5 THEN
        CASE 
            WHEN LOWER(instruction_text) LIKE '%sajikan%' OR LOWER(instruction_text) LIKE '%hidangkan%' THEN 2
            WHEN LOWER(instruction_text) LIKE '%dinginkan%' OR LOWER(instruction_text) LIKE '%diamkan%' THEN 30
            WHEN LOWER(instruction_text) LIKE '%hias%' OR LOWER(instruction_text) LIKE '%tabur%' THEN 3
            ELSE 5
        END
    
    ELSE 5 -- Default 5 menit
END
WHERE timer_minutes IS NULL OR timer_minutes = 0;

-- Contoh data spesifik untuk resep-resep yang umum
-- Sate Ayam
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 10  -- Potong ayam dan siapkan bumbu
    WHEN 2 THEN 15  -- Marinasi ayam
    WHEN 3 THEN 5   -- Tusuk dengan sate
    WHEN 4 THEN 20  -- Bakar sate
    WHEN 5 THEN 2   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%sate%' OR LOWER(name) LIKE '%satay%'
);

-- Nasi Goreng  
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 5   -- Siapkan bahan
    WHEN 2 THEN 3   -- Panaskan wajan
    WHEN 3 THEN 8   -- Tumis bumbu
    WHEN 4 THEN 10  -- Masukkan nasi dan aduk
    WHEN 5 THEN 5   -- Masukkan telur dan sayuran
    WHEN 6 THEN 2   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%nasi goreng%'
);

-- Rendang
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 15  -- Siapkan bumbu halus
    WHEN 2 THEN 10  -- Potong daging
    WHEN 3 THEN 20  -- Tumis bumbu
    WHEN 4 THEN 45  -- Masak dengan santan (fase 1)
    WHEN 5 THEN 60  -- Masak hingga mengental (fase 2)
    WHEN 6 THEN 30  -- Masak hingga kering dan berminyak
    WHEN 7 THEN 2   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%rendang%'
);

-- Gado-gado
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 10  -- Rebus sayuran
    WHEN 2 THEN 8   -- Buat bumbu kacang
    WHEN 3 THEN 5   -- Siapkan pelengkap
    WHEN 4 THEN 3   -- Susun sayuran
    WHEN 5 THEN 2   -- Siram dengan bumbu kacang
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%gado%'
);

-- Soto Ayam
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 60  -- Rebus ayam dengan bumbu
    WHEN 2 THEN 10  -- Suwir ayam
    WHEN 3 THEN 5   -- Siapkan pelengkap
    WHEN 4 THEN 15  -- Tumis bumbu halus
    WHEN 5 THEN 20  -- Masak kuah soto
    WHEN 6 THEN 3   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%soto%'
);

-- Ayam Bakar
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 10  -- Bersihkan dan potong ayam
    WHEN 2 THEN 15  -- Marinasi dengan bumbu
    WHEN 3 THEN 5   -- Panaskan grill/bara
    WHEN 4 THEN 25  -- Bakar ayam (bolak-balik)
    WHEN 5 THEN 10  -- Olesi dengan bumbu kecap
    WHEN 6 THEN 2   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%ayam bakar%'
);

-- Gudeg
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 20  -- Siapkan nangka muda
    WHEN 2 THEN 15  -- Tumis bumbu halus
    WHEN 3 THEN 90  -- Masak nangka dengan santan (lama)
    WHEN 4 THEN 30  -- Tambahkan ayam dan telur
    WHEN 5 THEN 45  -- Masak hingga mengental
    WHEN 6 THEN 2   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%gudeg%'
);

-- Bakso
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 20  -- Giling daging dan bumbu
    WHEN 2 THEN 15  -- Bentuk bulatan bakso
    WHEN 3 THEN 30  -- Rebus bakso hingga matang
    WHEN 4 THEN 20  -- Buat kuah kaldu
    WHEN 5 THEN 5   -- Siapkan pelengkap
    WHEN 6 THEN 3   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%bakso%'
);

-- Rawon
UPDATE recipe_instructions 
SET timer_minutes = CASE step_number
    WHEN 1 THEN 45  -- Rebus daging hingga empuk
    WHEN 2 THEN 10  -- Tumis bumbu halus
    WHEN 3 THEN 5   -- Panggang kluwek
    WHEN 4 THEN 30  -- Masak bumbu dengan kaldu
    WHEN 5 THEN 20  -- Gabungkan semua bahan
    WHEN 6 THEN 3   -- Sajikan
    ELSE timer_minutes
END
WHERE recipe_id IN (
    SELECT id FROM recipes WHERE LOWER(name) LIKE '%rawon%'
);

-- Update untuk resep yang belum memiliki timer_minutes dengan nilai default yang masuk akal
UPDATE recipe_instructions 
SET timer_minutes = CASE 
    WHEN step_number = 1 THEN 5
    WHEN step_number = 2 THEN 10
    WHEN step_number = 3 THEN 15
    WHEN step_number = 4 THEN 12
    WHEN step_number = 5 THEN 8
    WHEN step_number >= 6 THEN 5
    ELSE 5
END
WHERE timer_minutes IS NULL OR timer_minutes = 0;

-- Tambahkan beberapa instruksi dengan waktu yang lebih realistis untuk testing
INSERT INTO recipe_instructions (recipe_id, step_number, instruction_text, timer_minutes, image_url) 
VALUES 
-- Contoh untuk resep baru atau yang perlu dilengkapi
-- Ganti dengan ID resep yang sesuai
(1, 1, 'Cuci bersih ayam dan potong sesuai selera', 8, null),
(1, 2, 'Haluskan bumbu: bawang merah, bawang putih, kemiri, dan cabe', 10, null),
(1, 3, 'Tumis bumbu halus hingga harum dan matang', 12, null),
(1, 4, 'Masukkan ayam, aduk rata dan masak hingga berubah warna', 15, null),
(1, 5, 'Tambahkan santan, garam, dan gula. Masak hingga ayam empuk', 45, null),
(1, 6, 'Sajikan hangat dengan nasi putih', 2, null)
ON CONFLICT (recipe_id, step_number) DO UPDATE SET
    instruction_text = EXCLUDED.instruction_text,
    timer_minutes = EXCLUDED.timer_minutes;

-- Verifikasi hasil
SELECT 
    r.name as recipe_name,
    ri.step_number,
    ri.instruction_text,
    ri.timer_minutes,
    CASE 
        WHEN ri.timer_minutes <= 5 THEN 'Cepat'
        WHEN ri.timer_minutes <= 15 THEN 'Sedang' 
        WHEN ri.timer_minutes <= 30 THEN 'Lama'
        ELSE 'Sangat Lama'
    END as duration_category
FROM recipes r
JOIN recipe_instructions ri ON r.id = ri.recipe_id
ORDER BY r.name, ri.step_number
LIMIT 50;
