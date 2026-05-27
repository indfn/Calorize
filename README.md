# Calorize

![Android](https://img.shields.io/badge/Platform-Android-3DDC84?style=flat&logo=android&logoColor=white)
![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![License](https://img.shields.io/badge/License-CC_BY--NC_4.0-lightgrey?style=flat)

> **The intelligent, privacy-first, customizable nutrition tracker.**  
> Snap a photo, scan a barcode, or log manually—all without your health data leaving your device.

---

## ✨ Features

*   **Food Content Analysis:** Snap a photo of your meal. Calorize can use any **AI Provider API** to analyze images and identify ingredients, estimate portion sizes, and calculate calories instantly.
*   **Privacy First:** **No servers. No accounts.** All data is stored locally on your device using an **Isar Database**. Your health data belongs to you.
*   **Barcode Scanner:** Instant nutritional data for packaged goods via OpenFoodFacts.
    **Individual Day Goal Configuration** Set varying goals for each specific day of the week, for those who want to follow custom plans.
*   **Deep Analytics:** Interactive charts for weight, BMI, and calorie trends.
*   **Rolling History:** Detailed food logs are kept for 7 days, while long-term stats are saved forever.
*   **Home Screen Widgets:** View your remaining calories and macros at a glance.
*   **Smart Reminders:** Never forget to log Breakfast, Lunch, or Dinner.

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

### 3. Onboarding & Setup

When you first open Calorize, the app will guide you through a quick onboarding process to personalize your experience:
*   **Profile details:** Enter your age, gender, weight, and height.
*   **Activity Level:** Select how active you are to ensure accurate expenditure estimates.
*   **Dietary Goals:** Choose between maintaining, losing, or gaining weight.
*   **Diet Preference:** Select from standard, high-protein, or keto splits, or define your own.

Based on your answers, Calorize calculates a **suggested TDEE (Total Daily Energy Expenditure)** and a **custom macro split** tailored to your goals:
*   **Calories:** Calculated using the **Mifflin-St Jeor Equation** to determine your BMR, adjusted by your activity level and weight goals (using a standard 7700 kcal/kg fat equivalent).
*   **Macros:** Derived from your calorie target using preconfigured ratios for **Balanced**, **High Protein**, **Low Carb**, or **Low Fat** diets.
*   **Micros:** Automatically sets daily targets for Fiber (based on age/gender), Sugar (<10% of calories), and Sodium (2300mg limit).

#### Finalize your configuration in Settings:
Once onboarded, head over to the **Settings** tab to fully set up your app:
*   **AI Providers:** To use the "Snap" food analysis feature, you'll need to add an API key (e.g., Gemini, OpenAI, or Anthropic). You can configure up to 10 providers with smart fallback routing.
*   **Theme:** Toggle between Light and Dark mode (persisted at the OS level for a seamless splash screen experience).
*   **Notifications:** Enable and grant permissions for meal reminders to ensure you stay on track.
*   **Data Management:** Import or export your JSON food logs to keep your data safe or migrate between devices.

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
