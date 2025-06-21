# 🍳 Rasain App - Modern Recipe & Cooking Timer

## 📱 Overview

Rasain App adalah aplikasi resep modern dengan fitur cooking timer interaktif, mode memasak step-by-step, dan sistem review terintegrasi. Dibuat dengan Flutter dan Supabase.

## ✨ Key Features

### 🍽️ Recipe Management
- **Modern Recipe Detail Page** - UI yang indah dan user-friendly
- **Ingredient List** - Menampilkan quantity dan unit yang jelas
- **Step-by-Step Instructions** - Panduan memasak yang detail

### ⏱️ Cooking Timer System
- **Interactive Cooking Timer** - Timer countdown dengan animasi
- **Cooking Mode** - Full-screen step-by-step cooking experience
- **Live Clock** - Jam real-time saat memasak
- **Session Timer** - Track total waktu memasak

### 🎨 User Experience
- **Responsive Design** - Optimized untuk berbagai ukuran layar
- **Animated UI** - Smooth animations dan transitions
- **Color-coded Progress** - Visual feedback yang jelas
- **Modern Material Design** - Clean dan intuitive interface

### 💾 Database Features
- **Supabase Integration** - Real-time database
- **Row Level Security** - Secure data access
- **Recipe Instructions Timer** - Database-driven cooking timers
- **User Profiles** - Personalized experience

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Supabase
- **Database**: PostgreSQL
- **State Management**: Provider
- **Routing**: GoRouter
- **Authentication**: Supabase Auth

## 📁 Project Structure

```
rasain_app/
├── lib/
│   ├── core/                    # Core utilities
│   │   ├── config/             # App configuration
│   │   ├── constants/          # App constants
│   │   ├── theme/              # Theme and styling
│   │   └── widgets/            # Reusable widgets
│   ├── features/               # Feature modules
│   │   ├── auth/               # Authentication
│   │   ├── recipe_detail/      # Recipe detail & cooking
│   │   ├── chat/               # Chat features
│   │   └── admin/              # Admin features
│   ├── models/                 # Data models
│   ├── services/               # API services
│   └── cubits/                 # State management
├── database/                   # Database files
│   ├── schema.sql              # Database schema
│   ├── *_seeder.sql           # Data seeders
│   └── *_fix.sql              # Database fixes
├── scripts/                    # Utility scripts
│   └── database/               # Database scripts
├── docs/                       # Documentation
└── public/                     # Public assets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd rasain_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Supabase credentials
   ```

4. **Setup database**
   ```bash
   # Run database schema and seeders
   # See database/ folder for SQL files
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🗄️ Database Setup

### 1. Schema Setup
```sql
-- Run database/schema.sql in your Supabase SQL editor
```

### 2. Timer Seeder
```powershell
# Use PowerShell scripts for easy setup
.\scripts\database\quick_timer_setup.ps1
```

### 3. Verification
```sql
SELECT COUNT(*) as total,
       COUNT(CASE WHEN timer_minutes > 0 THEN 1 END) as with_timer
FROM recipe_instructions;
```

## 🎯 Key Features Implementation

### Recipe Detail with Cooking Timer
- **ModernRecipeDetailScreen** - Main recipe view
- **ModernIngredientList** - Enhanced ingredient display
- **ModernInstructionSteps** - Step-by-step with timers
- **CookingModeView** - Full-screen cooking experience

### Timer System
- **CookingTimer** - Animated countdown widget
- **LiveClock** - Real-time clock display
- **CookingSessionTimer** - Session time tracking
- **CompactTimerDisplay** - Lightweight timer

### Database Integration
- **Recipe Service** - API integration
- **Timer Seeder** - Populate cooking times
- **RLS Policies** - Secure data access

## 📚 Documentation

Detailed documentation available in `docs/` folder:

- **Cooking Timer Documentation** - Timer system details
- **Database Setup Guide** - Database configuration
- **PowerShell Setup Guide** - Script usage
- **Feature Documentation** - Individual feature docs

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Developer**: [Your Name]
- **Project**: Provis Semester 4 - Tugas 3

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- Material Design for UI guidelines

---

## 📱 Screenshots

[Add screenshots of your app here]

## 🔗 Links

- [Supabase Dashboard](https://supabase.com/dashboard)
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design](https://material.io/)

---

**Status**: ✅ **Production Ready**  
**Version**: 1.0.0  
**Last Updated**: June 2025
