# 🍎 Calorize

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-CC_BY--NC_4.0-lightgrey?style=flat)

> **The intelligent, privacy-first nutrition tracker.**  
> Snap a photo, scan a barcode, or log manually—all without your health data leaving your device.

---

## ✨ Features

*   **👁️ Food Content Analysis:** Snap a photo of your meal. Calorize uses **Gemini API** to identify ingredients, estimate portion sizes, and calculate calories instantly.
*   **🔒 Privacy First:** **No servers. No accounts.** All data is stored locally on your device using an **Isar Database**. Your health data belongs to you.
*   **📷 Barcode Scanner:** Instant nutritional data for packaged goods via OpenFoodFacts.
*   **📊 Deep Analytics:** Interactive charts for weight, BMI, and calorie trends.
*   **🔄 Rolling History:** Detailed food logs are kept for 7 days, while long-term stats are saved forever.
*   **📱 Home Screen Widgets:** View your remaining calories and macros at a glance.
*   **⏰ Smart Reminders:** Never forget to log Breakfast, Lunch, or Dinner.

---

## 📲 How to Install (Android)

Since Calorize is open-source and privacy-focused, it is not currently on the Play Store. You can install it directly on your phone.

### 1. Download the APK
Go to the [**Releases**](https://github.com/yourusername/calorize/releases) page on this repository and download the latest `app-release.apk` file to your phone.

### 2. Install
Open the downloaded file. Your phone will likely warn you about installing unknown apps.
*   Tap **Settings** (on the popup).
*   Toggle **"Allow from this source"**.
*   Tap **Install**.

### 3. ⚠️ Important: Enable Alarms & Notifications
Because this app is installed manually, modern Android versions (13+) restrict some permissions by default. To make sure **Daily Reminders** work:

1.  Open **Calorize** and go to **Settings**.
2.  Tap the **"Open Settings to Fix"** button (under Notifications) OR go to your phone's **Settings > Apps > Calorize**.
3.  Tap **Alarms & Reminders** → Turn **ON**.

---

## 🚀 How to Use

1.  **Onboarding:** Enter your height, weight, and goals. The app calculates your daily calorie budget automatically.
2.  **Log Food:**
    *   Tap the big **+** button.
    *   **Snap:** Take a picture of your food. AI will estimate the calories.
    *   **Scan:** Scan a barcode on a package.
    *   **Manual:** Type it in yourself.
3.  **Track Progress:** Swipe to the **Progress** tab to see your weight trends and weekly calorie averages.
4.  **Widgets:** Long-press your home screen to add the Calorize widgets for quick access and display information.

---

## 🛠️ Building from Source (For Developers)

If you want to modify the code or build it yourself:

1.  Clone the repo:
    ```bash
    git clone https://github.com/indfn/Calorize
    ```
2.  Run code generation:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```
3.  Build the APK:
    ```bash
    flutter run --release
    ```

---

## ⚖️ License

**Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)**

*   ✅ **Free to use:** You can download, use, and modify this app for personal use.
*   ❌ **No Commercial Use:** You cannot sell this app, use it for paid services, or monetize it without permission.

See the [LICENSE](LICENSE) file for details.
