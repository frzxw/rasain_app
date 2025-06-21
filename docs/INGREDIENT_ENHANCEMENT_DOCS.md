# Modern Recipe Detail - Ingredient Display Enhancement

## Perubahan yang Dibuat

### ✅ Ingredient Quantity dengan Unit

Sekarang bahan-bahan di resep akan menampilkan quantity beserta unit yang lengkap:

#### Sebelum:
- Hanya menampilkan: `2`
- Atau: `250`

#### Sesudah:
- Menampilkan: `2 buah`
- Atau: `250 gram`
- Atau: `1 sendok makan`
- Atau: `500 ml`

### 🔧 Implementasi

1. **Method `_formatQuantityWithUnit()`** - Memformat quantity dan unit dengan proper
2. **Data Mapping** - Memastikan data `unit` diteruskan dari recipe ke widget
3. **Display Logic** - Menampilkan quantity + unit dalam satu container yang rapi

### 📋 Format Yang Didukung

- **Quantity saja**: Jika hanya ada quantity, akan ditampilkan angka saja
- **Unit saja**: Jika hanya ada unit, akan ditampilkan unit saja  
- **Quantity + Unit**: Format: "2 buah", "250 gram", "1 sdm"
- **Decimal handling**: 1.5 kg, 2.25 cup, dll

### 🎨 Visual

Quantity dengan unit ditampilkan dalam container dengan:
- Background: Primary color dengan opacity 0.1
- Text color: Primary color
- Border radius: 8px
- Font weight: Medium (500)
- Font size: 12px

### 💾 Data Structure Expected

```json
{
  "name": "Ayam",
  "quantity": 500,
  "unit": "gram",
  "image_url": "...",
  "price": "Rp 25000"
}
```

Atau:

```json
{
  "name": "Bawang merah", 
  "quantity": 3,
  "unit": "buah",
  "image_url": "...",
  "price": "Rp 5000"
}
```

### 🔄 Backward Compatibility

- Jika tidak ada unit, hanya quantity yang ditampilkan
- Jika tidak ada quantity, hanya unit yang ditampilkan  
- Jika keduanya kosong, container tidak ditampilkan

## Testing

Untuk testing, pastikan data resep memiliki field:
- `quantity`: Number atau String
- `unit`: String (contoh: "gram", "buah", "sendok makan", "ml", "kg")
