# FashionApp — Flutter + Firebase

A production-ready Flutter fashion e-commerce app inspired by Myntra/Ajio.

## Features
- 📱 Phone OTP authentication (customers)
- 🔐 Username/password admin login
- 🛍️ Product catalog with categories, search, filters
- 🟢 In Stock / 🟡 Low Stock / 🔴 Out of Stock badges
- 🛒 Cart with quantity management
- 💳 Razorpay payment integration
- 📦 Order tracking with status steps
- ❤️ Wishlist
- 🌙 Dark mode
- 📲 Push notifications (FCM)
- 🔑 Admin dashboard: products, orders, stock

## Setup

### 1. Firebase Project
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=YOUR_PROJECT_ID
```
Replace `lib/core/utils/firebase_options.dart` with the generated file.

### 2. Enable Firebase Services
- Authentication → Phone (enable)
- Cloud Firestore → Create database
- Firebase Storage → Create bucket
- Firebase Messaging → Enable

### 3. Razorpay
Edit `lib/services/payment_service.dart`:
```dart
static const String _razorpayKey = 'rzp_live_YOUR_KEY';
```

### 4. Admin Setup
Add a document to the `admin` Firestore collection manually:
```json
{
  "username": "admin",
  "password_hash": "<sha256 of your password>",
  "name": "Admin User",
  "role": "superadmin"
}
```
Generate SHA-256 hash: https://emn178.github.io/online-tools/sha256.html

### 5. Firestore Indexes
Create these composite indexes in Firebase Console:

| Collection | Fields |
|------------|--------|
| products | `is_active` ASC + `category` ASC + `created_at` DESC |
| products | `is_active` ASC + `in_stock` ASC |
| products | `tags` ARRAY + `is_active` ASC |
| orders | `user_id` ASC + `created_at` DESC |
| orders | `order_status` ASC + `created_at` DESC |

### 6. Run
```bash
flutter pub get
flutter run
```

## Folder Structure
```
lib/
  core/           # Colors, routes, theme, utils
  models/         # Data models (Product, User, Order, Cart)
  services/       # Firebase services (Auth, Product, Order, Payment, FCM)
  providers/      # Riverpod state management
  screens/        # All app screens
    auth/         # OTP login, OTP verify
    home/         # Home with banner + categories
    products/     # List, detail, search
    cart/         # Cart screen
    checkout/     # Checkout, payment, confirmation
    orders/       # My orders, order detail
    wishlist/     # Wishlist
    profile/      # Profile + settings
    admin/        # Admin login, dashboard, products, orders
  widgets/        # Shared widgets (ProductCard, StockBadge)
```

## Stock System
- `stock` (int): quantity count
- `in_stock` (bool): true if stock > 0
- `stock_status`: `in_stock` | `low_stock` (≤5) | `out_of_stock`
- Auto-decremented via Firestore transaction when order is placed
- Admin can update stock from Manage Products screen
