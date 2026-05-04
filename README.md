# 🏋️ Fit Nepal - Mobile App

Fit Nepal is a Flutter-based mobile application that allows users to discover gyms, book fitness classes, purchase membership plans, and manage their fitness journey.

---

## 🚀 Features

### 👤 User Features
- Phone number OTP authentication
- Home dashboard with active membership
- View nearby gyms (limited preview)
- Explore all gyms with search & filters
- View gym details
- Dynamic membership plans (per gym)
- Purchase plans via:
  - Khalti (sandbox)
  - eSewa (mock backend integration)
- View active membership
- Membership history
- Browse classes
- Book fitness classes
- Prevent duplicate bookings
- Cancel bookings
- Booking history
- Pull-to-refresh on all major screens

---

### 🛠️ Admin Features (inside app)
- Admin access via role-based login
- Manage Gyms
  - Add / Edit / Delete
- Manage Classes
  - Add / Edit / Delete
- Manage Membership Plans
  - Add / Edit / Delete

---

### 🔍 Smart UX
- Featured Classes (no duplicates)
- Shows:
  - Gym name if 1 gym
  - "Available at X gyms" if multiple gyms
- Limited home data for better performance:
  - 3 gyms max
  - 2 classes max
- Empty state UI
- Pull-to-refresh support

---

## 🧱 Tech Stack

- Flutter
- Dart
- Dio (API calls)
- Secure Storage
- Khalti Flutter SDK
- FastAPI Backend
- SQLite (via backend)

---

## 📁 Project Structure
lib/
├── core/
│ ├── network/
│ ├── storage/
│
├── features/
│ ├── auth/
│ ├── home/
│ ├── gyms/
│ ├── membership/
│ ├── booking/
│ ├── payment/
│ ├── profile/
│ ├── admin/
│
├── shared/
│ ├── widgets/



---

## ⚙️ Setup

### 1. Clone repository

```bash
git clone YOUR_MOBILE_REPO_URL
cd YOUR_PROJECT

### 2. Install dependencies

```bash
flutter pub get

### 3. Run app

```bash
flutter run


🔌 Backend Configuration

Update base URL:

lib/core/network/api_service.dart

```bash
baseUrl = 'http://127.0.0.1:8000/api/v1';


For Android emulator / real device:

```bash
adb reverse tcp:8000 tcp:8000



## 💳 Payment Integration

### Khalti
- Sandbox integration
- Uses Khalti test credentials

### eSewa
- Mock backend integration
- No real payment processing
- Used for simulation only


## 🔁 Payment Flow

### Select Plan
→ Choose Payment Method
→ Payment Success
→ Membership Created
→ Redirect to Home
→ Active Membership Updated


## 📌 Notes

- Admin panel is embedded in mobile app
- Future plan: separate admin dashboard (React)
- SQLite used for development
- Backend handles all business logic


## 📈 Future Improvements

- Push notifications
- Real eSewa integration
- Online payments production-ready
- Map integration
- Reviews and ratings
- Trainer profiles