# Clean City

A focused, community-driven Flutter app enabling citizens to report urban issues (garbage, potholes, broken lights, etc.) using real-time location and map technology, with instant cloud-based submission.

---

## 🏗️ System Design Overview

- **Frontend:**  
  - Built with Flutter for cross-platform deployment.
  - Modern UI/UX with responsive layouts (`flutter_screenutil`).
  - State management with `flutter_bloc`.
  - Screens: Home (Map), Report Issue, Authentication, Profile.

- **Backend & Storage:**  
  - Firebase Authentication for secure user login/registration.
  - Cloud Firestore for storing reports and user data.
  - Firebase Storage for uploading report images.
  - Environment config and secrets managed via `.env` & `flutter_dotenv`.

- **Core Services:**  
  - Google Maps for map display and geolocation.
  - Device location via `geolocator` and `location`.
  - Media handling with `image_picker`, `image_cropper`, and `flutter_image_compress`.
  - Network requests via `dio` (if needed for external APIs).

**Typical Flow:**  
1. User opens the app and authenticates.
2. User views map centered on current location.
3. User taps "Report Issue", fills quick form, and attaches photo.
4. Location is auto-filled; user submits.
5. Report is uploaded to Firestore (with media in Storage) and appears on the map for authorities.

---

## 🌟 Key Features

- **🌍 Location-based Reporting:** One-tap issue reporting from your current location using maps.
- **📸 Photo Evidence:** Attach photos to make reports actionable.
- **🔒 Secure & Private:** User authentication and data privacy by design.
- **📊 Real-time Updates:** Issues appear instantly for city authorities.
- **🧭 Easy Navigation:** Intuitive map and search UI.

---

## 📲 Screenshots
![Home Screen](assets/images/screenshots/home.png)
![Report Issue](assets/images/screenshots/report.png)
![Map View](assets/images/screenshots/map_view.png)

---

## 🛠️ Technologies Used

- **Flutter** (UI framework)
- **google_maps_flutter** (Maps)
- **geolocator**, **location** (GPS/location)
- **firebase_core**, **firebase_auth**, **cloud_firestore**, **firebase_storage** (Cloud backend)
- **image_picker**, **image_cropper**, **flutter_image_compress** (Media)
- **flutter_bloc** (State management)
- **flutter_dotenv** (Environment config)

---

## 💡 Showcase

- Instantly report garbage, potholes, or broken infrastructure from anywhere in your city.
- Attach photos and details—location is auto-captured via GPS.
- All reports are securely stored in the cloud for city authorities to act upon.
- Help make your city cleaner and safer, one report at a time.

---


Built with ❤️ using Flutter & Google Maps.
