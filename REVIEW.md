---
phase: post-audit-fixes
reviewed: 2026-05-25T10:00:00Z
depth: deep
files_reviewed: 18
files_reviewed_list:
  - lib/utils/macro_calculator.dart
  - lib/screens/settings/settings_screen.dart
  - lib/screens/dashboard_screen.dart
  - lib/widgets/fab_sheet.dart
  - lib/widgets/progress/calorie_chart.dart
  - lib/services/notification_service.dart
  - lib/services/background_service.dart
  - lib/screens/home_screen.dart
  - lib/screens/settings/ai_providers_screen.dart
  - lib/widgets/ai_provider_form.dart
  - lib/services/food_sourcing_service.dart
  - lib/services/ai_routing_service.dart
  - lib/screens/onboarding/onboarding_screen.dart
  - lib/screens/settings/weekly_macros_screen.dart
  - lib/widgets/macro_adjustment_dialog.dart
  - lib/widgets/macro_edit_popup.dart
  - lib/services/database_service.dart
  - lib/main.dart
findings:
  critical: 6
  warning: 10
  info: 15
  total: 31
status: issues_found
---

# Code Review Report

**Reviewed:** 2026-05-25T10:00:00Z
**Depth:** deep (cross-file analysis)
**Files Reviewed:** 18
**Status:** issues_found

## Summary

Reviewed 18 Dart files (6 services, 6 screens, 4 widgets, 1 utility, 1 entry point) plus cross-referenced 5 model files. The codebase is well-structured overall with clear architectural boundaries, but several **HIGH-severity issues** were found:

1. **Silent data loss**: Calling `_updateProfile()` on any profile field change destroys all custom weekly macro goals.
2. **Security**: AI API keys stored in plaintext on disk and one provider exposes keys via URL query parameters.
3. **Crash risk**: Unvalidated JSON decoding from AI model responses will crash on malformed output.
4. **Logic bug**: Age calculation ignores whether the birthday has passed in the current year, affecting BMR.

Total: **6 HIGH**, **10 MEDIUM**, **15 INFO** findings.

---

## Critical Issues

### CR-01: Weekly Goals Silently Destroyed on Any Profile Change (Data Loss)

**Files:** `lib/screens/settings/settings_screen.dart:123-131` → `lib/services/database_service.dart:361-383`
**Severity:** HIGH
**Category:** Bug — Data Loss

**Issue:**
Every call to `_updateProfile()` (triggered by ANY profile field change — gender, weight, height, activity, goal, diet preference) invokes `DatabaseService().applyConstantGoals()`, which executes `profile.weeklyGoals = []` — **erasing all custom per-day macro goals** the user may have configured.

**Call chain:**
1. User edits Gender in settings → `_updateProfile()` (line 165)
2. → `DatabaseService().applyConstantGoals()` (line 123)
3. → `profile.weeklyGoals = []` (database_service.dart:365)
4. → Creates 7 identical constant goals from day 1

This means any user who customizes their weekly macros in `WeeklyMacrosScreen` will have those customizations silently wiped the next time they change any profile field.

**Fix:**
`_updateProfile()` should update the profile's base goals without touching the weekly goals. The `applyConstantGoals` call should be removed from `_updateProfile()` or replaced with a method that only updates the profile-level defaults without clearing weekly overrides:

```dart
// In settings_screen.dart _updateProfile(), remove the applyConstantGoals call
// Instead, simply save the profile with updated base goals:

final isar = DatabaseService().isar;
await isar.writeTxn(() async {
  await isar.userProfiles.put(_userProfile!);
});
// REMOVE: await DatabaseService().applyConstantGoals(...)
```

---

### CR-02: AI API Keys Stored in Plaintext in Unencrypted Local Database

**Files:** `lib/data/models/ai_provider.dart:9`, `lib/widgets/ai_provider_form.dart:117`, `lib/screens/onboarding/onboarding_screen.dart:136`
**Severity:** HIGH
**Category:** Security — Credential Storage

**Issue:**
API keys are stored in the `AIProvider.apiKey` field, which is persisted via Isar. Isar databases are stored as flat files on the filesystem with **no encryption**. On Android, any app with file access or a rooted device can read `getApplicationDocumentsDirectory()/isar` and extract all API keys.

**Fix:**
Use `flutter_secure_storage` for API key storage. Store only a reference ID in Isar:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
final keyId = 'ai_key_${provider.providerId}_${provider.name}';
await _storage.write(key: keyId, value: provider.apiKey);
provider.apiKey = null; // Don't store in Isar
```

---

### CR-03: API Key Exposed in URL Query Parameter (Gemini Provider)

**File:** `lib/services/ai_routing_service.dart:58`
**Severity:** HIGH
**Category:** Security — Credential Exposure

**Issue:**
The Gemini API key is appended as a URL query parameter:
```dart
'${provider.baseUrl}/models/${provider.modelId}:generateContent?key=${provider.apiKey}'
```
URL query parameters are commonly logged by proxies, load balancers, CDNs, and server access logs, exposing the secret.

**Fix:**
Use the `x-goog-api-key` header instead:
```dart
final response = await http.post(
  Uri.parse(url.replaceAll('?key=${provider.apiKey}', '')),
  headers: {
    'Content-Type': 'application/json',
    'x-goog-api-key': provider.apiKey ?? '',
  },
  body: jsonEncode({...}),
);
```

---

### CR-04: Unvalidated AI Response JSON Causes Crash on Malformed Output

**File:** `lib/services/food_sourcing_service.dart:88-101`
**Severity:** HIGH
**Category:** Bug — Crash / Security

**Issue:**
The AI model response is parsed with `jsonDecode` and fields are accessed with unchecked bracket notation (`data['name']`, `data['macros']['p']`). If the AI returns:
- Malformed JSON → `jsonDecode` throws `FormatException`
- Missing keys → `data['macros']` returns `null`, then `data['macros']['p']` throws `NoSuchMethodError`
- Wrong types → `(data['macros']['p'] as num).toDouble()` throws `TypeError`

The outer `catch (e)` on line 102 catches these, but the inner try block on lines 282-318 in `dashboard_screen.dart` catches and shows "Analysis failed" — the crash is contained but creates a poor UX.

**Fix:**
Add explicit null/type validation on the parsed JSON:

```dart
final data = jsonDecode(jsonStr);
if (data is! Map) throw FormatException('Response is not a JSON object');

final name = data['name'];
if (name is! String) throw FormatException('Missing or invalid name');

final macros = data['macros'];
if (macros is! Map) throw FormatException('Missing macros');

return FoodLog()
  ..foodName = name
  ..calories = (data['calories'] as num?)?.toInt() ?? 0
  ..timestamp = DateTime.now()
  ..macros = Macros()
  ..macros.protein = (macros['p'] as num?)?.toDouble() ?? 0
  ..macros.carbs = (macros['c'] as num?)?.toDouble() ?? 0
  ..macros.fat = (macros['f'] as num?)?.toDouble() ?? 0;
```

---

### CR-05: Age Calculation Ignores Birthday in Current Year

**Files:** `lib/screens/onboarding/onboarding_screen.dart:162`, `lib/screens/settings/settings_screen.dart:75`
**Severity:** HIGH
**Category:** Bug — Logic Error

**Issue:**
```dart
final age = DateTime.now().year - _dob.year;
```
This calculates age as a simple year difference. A user born on December 31, 2000 will show as age 26 on January 1, 2026, even though they are still 25. This affects BMR calculation (which depends on age), making it approximately 1% too low for users who haven't had their birthday yet this year.

**Fix:**
```dart
int calculateAge(DateTime birthDate) {
  final now = DateTime.now();
  int age = now.year - birthDate.year;
  final hasHadBirthday = now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  if (!hasHadBirthday) age--;
  return age;
}
```

---

### CR-06: Hardcoded `image/jpeg` MIME Type Causes AI Provider Failures

**Files:** `lib/services/food_sourcing_service.dart:83` → `lib/services/ai_routing_service.dart:69,122,167`
**Severity:** HIGH
**Category:** Bug — Provider Compatibility

**Issue:**
The image is always sent with `mime_type: 'image/jpeg'` / `media_type: 'image/jpeg'`. However, `ImagePicker` can return PNG images (especially screenshots), HEIC images (iOS), or other formats. Providers may:
1. Reject the request if the MIME type doesn't match the actual data
2. Decode the image incorrectly

**Fix:**
Detect the actual MIME type from the image bytes or file extension:

```dart
String _detectMimeType(Uint8List bytes) {
  if (bytes.length >= 8) {
    if (bytes[0] == 0xFF && bytes[1] == 0xD8) return 'image/jpeg';
    if (bytes[0] == 0x89 && bytes[1] == 0x50) return 'image/png';
    if (bytes[0] == 0x47 && bytes[1] == 0x49) return 'image/gif';
    if (bytes[0] == 0x52 && bytes[1] == 0x49) return 'image/webp';
  }
  return 'image/jpeg'; // fallback
}
```

Pass `mimeType` through `FoodSourcingService.analyzeImage()` and use it in all three AI provider call methods.

---

## Warnings

### WR-01: `mounted` Not Checked in Slider `onChanged` Callbacks

**File:** `lib/screens/settings/settings_screen.dart:362-366`, `368-370`, `396-398`
**Severity:** MEDIUM
**Category:** Bug — `setState` After Dispose

**Issue:**
```dart
onChanged: (value) { setState(() { _userProfile!.maxRollover = value.round(); }); },
```
Slider `onChanged` callbacks can fire after the widget is disposed (e.g., if the user navigates away while a slider is being dragged). `setState()` after dispose throws a `FlutterError`.

**Fix:**
Check `mounted` in all callback closures:
```dart
onChanged: (value) {
  if (!mounted) return;
  setState(() { _userProfile!.maxRollover = value.round(); });
},
```

---

### WR-02: `_handleLaunch` Use-After-Dispose Risk

**File:** `lib/main.dart:75-116`
**Severity:** MEDIUM
**Category:** Bug — Potential Crash

**Issue:**
`_handleLaunch` uses `Future.delayed(300ms)` before accessing `_navigatorKey.currentContext`. If the app is backgrounded or disposed during those 300ms, the context is stale. The null check on line 80 partially mitigates this, but `Navigator.of(context)` and `showModalBottomSheet` on lines 89-112 can still operate on a context whose widget tree is being torn down.

**Fix:**
Track disposability with a mounted-like flag:
```dart
bool _isDisposed = false;

@override
void dispose() {
  _isDisposed = true;
  super.dispose();
}

void _handleLaunch(Uri? uri) {
  if (uri == null || _isDisposed) return;
  // ... navigation
}
```

---

### WR-03: `cleanOldLogs` Permanently Deletes Food Logs After 7 Days

**File:** `lib/services/database_service.dart:32-41`
**Severity:** MEDIUM
**Category:** Bug — Data Loss

**Issue:**
```dart
Future<void> cleanOldLogs() async {
  final cutoff = DateTime.now().subtract(const Duration(days: 7));
  await isar.writeTxn(() async {
    await isar.foodLogs.filter()
        .timestampLessThan(cutoff)
        .deleteAll();
  });
}
```
Every app startup permanently deletes all food logs older than 7 days. Users who open the app infrequently will lose all historical data. The "Export Food Logs" and "All Food Logs" features become unusable for long-term tracking.

**Fix:**
Either:
1. Remove auto-cleanup entirely (let users manage their data), or
2. Increase the retention window to 90+ days, or
3. Make the retention period a user-configurable setting

---

### WR-04: `watchTodayFoodLogs` Uses Stale Time Boundary

**File:** `lib/services/database_service.dart:64-72`
**Severity:** MEDIUM
**Category:** Bug — Stale Data

**Issue:**
```dart
Stream<List<FoodLog>> watchTodayFoodLogs() {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return isar.foodLogs.filter()
      .timestampBetween(startOfDay, endOfDay)
      .watch(fireImmediately: true);
}
```
The `startOfDay`/`endOfDay` bounds are evaluated once when the stream is created. If the dashboard stays open past midnight, the stream will still filter by the previous day's date until the widget is rebuilt.

**Fix:**
Use a periodic timer to recreate the stream at midnight, or use a wider filter and filter client-side.

---

### WR-05: Notification Permissions Request Result Ignored

**File:** `lib/services/notification_service.dart:68`
**Severity:** MEDIUM
**Category:** Bug — Silent Failure

**Issue:**
```dart
await requestPermissions();
```
The return value (`bool`) is discarded. If the user denies permission, `scheduleDailyNotifications` continues to schedule notifications that will never show. No feedback is given to the user.

**Fix:**
Check the permission result and surface feedback:
```dart
final granted = await requestPermissions();
if (!granted) {
  debugPrint('⚠️ Notification permissions denied by user');
  // Optionally show a snackbar explaining how to enable
}
```

---

### WR-06: `_showTimePicker` Async Callback Without `mounted` Check

**File:** `lib/screens/settings/settings_screen.dart:978-1075`
**Severity:** MEDIUM
**Category:** Bug — `setState` After Dispose

**Issue:**
`_showTimePicker` is `async` and calls `await showModalBottomSheet(...)`. Inside the sheet builder, callbacks call `setState()` without checking if the widget is still mounted.

**Fix:**
Add mounted checks before `setState` calls in time picker callbacks, or use a `@override dispose()` pattern.

---

### WR-07: Temp File Leaked on Share Cancellation

**File:** `lib/screens/settings/settings_screen.dart:461-476`
**Severity:** MEDIUM
**Category:** Bug — Resource Leak

**Issue:**
```dart
await file.writeAsString(json);
await Share.shareXFiles([XFile(file.path)], text: 'Calorize Food Logs Export');
file.delete(); // Not awaited and not in finally block
```
If `Share.shareXFiles` throws or the user cancels the share, `file.delete()` is never reached. Temp files accumulate in the app's temp directory.

**Fix:**
```dart
try {
  await file.writeAsString(json);
  await Share.shareXFiles([XFile(file.path)], text: 'Calorize Food Logs Export');
} finally {
  await file.delete(); // Also add 'await'
}
```

---

### WR-08: Dead Code — `macro_adjustment_dialog.dart` Never Imported

**File:** `lib/widgets/macro_adjustment_dialog.dart` (entire file, 834 lines)
**Severity:** MEDIUM
**Category:** Code Quality — Dead Code

**Issue:**
A `grep` for `macro_adjustment_dialog` across the entire `lib/` directory returns zero results. This 834-line widget (`MacroAdjustmentDialog`) is dead code. It contains its own macro adjustment UI with sliders, presets, and save-as-preset functionality — all unreachable.

**Fix:**
Remove the file or wire it into the UI (e.g., from the WeeklyMacrosScreen or the main macro adjustment entry point).

---

### WR-09: Dead Parameters in `_pushWidgetData`

**File:** `lib/services/background_service.dart:56-80`
**Severity:** MEDIUM
**Category:** Code Quality — Dead Code

**Issue:**
The `_pushWidgetData` method accepts `int proteinGoal` and `int fatGoal` parameters (lines 57-58), and the caller computes and passes these values (line 52). However, neither `proteinGoal` nor `fatGoal` is included in the JSON payload sent to the widget (lines 61-70). They are dead parameters.

**Fix:**
Remove the unused parameters or include them in the JSON payload if the widget needs them:
```dart
Future<void> _pushWidgetData(
  int caloriesLeft, int caloriesConsumed, int caloriesGoal, int progress,
  int proteinLeft, int carbsLeft, int fatsLeft,
  // int proteinGoal, int fatGoal,  // REMOVE if unused
) async {
```

---

### WR-10: Placeholder MethodChannel Package Name

**File:** `lib/main.dart:55`
**Severity:** MEDIUM
**Category:** Bug — Interoperability

**Issue:**
```dart
static const platform = MethodChannel('com.example.calorize/widget');
```
The `com.example` prefix is a placeholder/template value. The actual Android package likely uses a different identifier (e.g., `com.calorize.app`). If mismatched, `onWidgetClick` callbacks from Android widgets will never reach the Dart handler.

**Fix:**
Update the channel name to match the actual Android package name from `android/app/build.gradle`.

---

## Info

### IN-01: Duplicate Macro Ratio Tables in `MacroCalculator`

**File:** `lib/utils/macro_calculator.dart:78-90` and `:106-128`
**Severity:** INFO
**Category:** Code Quality — Duplication

The same diet ratio tables are defined in both `getRatiosForDiet()` and `calculateMacros()`. If one is updated without the other, they'll diverge. Extract the ratios into a single `static const` map.

---

### IN-02: `print()` Used Instead of `debugPrint()` in Production Code

**File:** `lib/services/food_sourcing_service.dart:58`
**Severity:** INFO
**Category:** Code Quality — Convention

```dart
print('Error fetching product: $e');
```
In Flutter, `print()` outputs directly and cannot be filtered. Use `debugPrint()` which respects the `--dart-define` debug flags and can be silenced in production.

---

### IN-03: No HTTP Timeout on AI Provider API Calls

**File:** `lib/services/ai_routing_service.dart:60,107,150,199`
**Severity:** INFO
**Category:** Code Quality — Robustness

All `http.post()` calls use the default timeout (usually 60 seconds). If an AI provider hangs, the UI will be blocked for a full minute. Add a timeout:

```dart
final response = await http.post(
  Uri.parse(url),
  headers: {...},
  body: jsonEncode({...}),
).timeout(const Duration(seconds: 30));
```

---

### IN-04: `file.delete()` Without `await` (Race Condition)

**File:** `lib/screens/settings/settings_screen.dart:468`
**Severity:** INFO
**Category:** Bug — Incomplete Operation

```dart
file.delete(); // Missing 'await'
```
The `File.delete()` call returns `Future<void>` but is not awaited. The file may remain on disk.

---

### IN-05: Height Formatting Can Produce Invalid 12+ Inches

**File:** `lib/screens/settings/settings_screen.dart:484-488`
**Severity:** INFO
**Category:** Bug — Display

```dart
final inches = (inchesTotal % 12).round();
```
When rounding pushes inches to 12, the format becomes `5' 12"` instead of `6' 0"`. Recalculate feet after rounding:

```dart
final totalInches = (inchesTotal).round();
final feet = totalInches ~/ 12;
final inches = totalInches % 12;
```

---

### IN-06: Prompt Injection Surface via User Context

**File:** `lib/services/food_sourcing_service.dart:114`
**Severity:** INFO
**Category:** Security — Prompt Injection

The `userContext` string is directly interpolated into the AI prompt without sanitization. While the user is the attacker in this case (they can type anything), it's a defense-in-depth concern. Consider trimming length and escaping special characters.

---

### IN-07: Age-Based BMR Uses Whole-Year Difference Only

**File:** `lib/utils/macro_calculator.dart:3-17`
**Severity:** INFO
**Category:** Code Quality — Accuracy

The Mifflin-St Jeor equation uses age as a whole number. The precision impact of the year-difference bug (CR-05) is modest for BMR (≈1%), but the fix suggested in CR-05 should be applied.

---

### IN-08: `watchRecentFoodLogs` Uses Stale Cutoff

**File:** `lib/services/database_service.dart:329-335`
**Severity:** INFO
**Category:** Bug — Stale Data

Same pattern as WR-04: `DateTime.now()` is evaluated once at stream creation time. If the stream is long-lived, the cutoff won't move.

---

### IN-09: Empty Exports Imported but Unused

**File:** `lib/widgets/macro_adjustment_dialog.dart:1` (`dart:convert`)
**File:** `lib/services/database_service.dart:1` (`dart:convert`)
**Severity:** INFO
**Category:** Code Quality — Cleanup

`dart:convert` is imported and used in both files (for `jsonEncode`/`jsonDecode`). Actually, these are used. Let me correct: the `dart:convert` import in `macro_adjustment_dialog.dart` IS used (line 98: `jsonDecode`, line 105: `jsonEncode`). No issue. ✅

---

### IN-10: `isMetric` Icons Use `MediaQuery` Instead of Inherited Widget

**File:** `lib/screens/settings/settings_screen.dart:324-327`
**Severity:** INFO
**Category:** Code Quality — Best Practice

```dart
MediaQuery.platformBrightnessOf(context)
```
Prefer `WidgetsBinding.instance.platformDispatcher.platformBrightness` for brightness checks — `MediaQuery.platformBrightnessOf` was deprecated in some Flutter versions.

---

### IN-11: `maxY: 0` Edge Case in Weekly Calorie Chart

**File:** `lib/screens/settings/weekly_macros_screen.dart:309-311`
**Severity:** INFO
**Category:** Bug — Display

If all macro goals are zero, `_maxCalories()` returns 0, setting `maxY: 0` on the chart. This may cause rendering issues or an empty chart with no visible bars.

---

### IN-12: Notification PlatformException Catch Too Narrow

**File:** `lib/services/notification_service.dart:132,203`
**Severity:** INFO
**Category:** Code Quality — Robustness

Only `PlatformException` with code `exact_alarms_not_permitted` is handled. Other platform exceptions (e.g., `SCHEDULE_EXACT_ALARM` permission denied on different Android versions) are silently swallowed.

---

### IN-13: Macro Slider Values Inconsistently Rounded

**File:** `lib/widgets/macro_adjustment_dialog.dart:656`
**Severity:** INFO
**Category:** Code Quality — UX

```dart
value: value.clamp(10.0, 70.0),
```
The slider range is clamped but the label shows `value.round()`. When rebalancing (lines 127-169), `roundToDouble()` creates small jumps. Consider using `_normalizePercentages()` after each slider change too.

---

### IN-14: Streak Calculation Assumes Sorted Unique Dates (Correctly Handled)

**File:** `lib/services/database_service.dart:221-224`
**Severity:** INFO
**Category:** Code Quality — Defensive

The streak code uses `.toSet().toList()` then `.sort()`, so the uniqueness and sorting are explicit. This is correct but the `datesMetGoal` list could be large if the user has many years of data. Consider a database-level query limit.

---

### IN-15: `database_service.dart` — `generateSampleData` Uses `DateTime(now.year, now.month, now.day - 7)` Which Can Roll Back Months

**File:** `lib/services/database_service.dart:439`
**Severity:** INFO
**Category:** Code Quality — Clarity

Dart's `DateTime` auto-normalizes negative day values by rolling back months. This works correctly but is non-obvious. Prefer `now.subtract(const Duration(days: 7))` for clarity.

---

## Cross-File Analysis Summary

### Import Graph
```
main.dart
  ├── database_service.dart → background_service.dart
  ├── notification_service.dart
  ├── theme_provider.dart
  └── home_screen.dart
        ├── dashboard_screen.dart
        │     ├── database_service.dart
        │     ├── food_sourcing_service.dart → ai_routing_service.dart
        │     └── fab_sheet.dart
        ├── progress_screen.dart
        └── settings_screen.dart
              ├── database_service.dart
              ├── notification_service.dart
              ├── macro_calculator.dart
              ├── weekly_macros_screen.dart → macro_edit_popup.dart
              └── ai_providers_screen.dart → ai_provider_form.dart

(dead): macro_adjustment_dialog.dart ← NOT IMPORTED ANYWHERE
```

### Consistency Observations

| Concern | Status |
|---------|--------|
| API type dispatch aligns with provider model | ✅ Consistent |
| MacroGoal fields used consistently across save sites | ✅ Consistent |
| `getTdeeGoalForDay` fallback chain (dayGoal → profile → 2000) | ✅ Consistent |
| Isar singleton pattern used everywhere | ✅ Consistent |
| `_updateProfile()` in settings calls `applyConstantGoals` | ❌ **CR-01** (destroys goals) |
| AI response JSON keys match across service files | ✅ Consistent |
| Notification scheduling pattern duplicated | ✅ Consistent (DRY within service) |

### Duplication Hotspots
- Macro ratio tables: `macro_calculator.dart` (2 copies)
- Height/weight picker logic: `settings_screen.dart` + `onboarding_screen.dart` (largely duplicated)
- AI provider selection UI: `ai_provider_form.dart` + `onboarding_screen.dart` (similar)

---

## Recommendations

### Immediate (HIGH)
1. **Remove `applyConstantGoals` from `_updateProfile()`** — prevents silent weekly goal loss
2. **Add `flutter_secure_storage`** for API key storage
3. **Move Gemini API key from URL query to `x-goog-api-key` header**
4. **Add JSON response validation** in `food_sourcing_service.dart`
5. **Fix age calculation** to account for birthday month/day
6. **Detect actual image MIME type** instead of hardcoding `image/jpeg`

### Short-term (MEDIUM)
7. Add `mounted` guards to all async callbacks in settings screen
8. Fix `_handleLaunch` use-after-dispose in main.dart
9. Make log retention configurable (remove 7-day hardcoded cleanup)
10. Fix notification permission flow (check and surface results)
11. Add `await` and `finally` to temp file cleanup in export
12. Update MethodChannel package name from `com.example`

### Code Quality (INFO)
13. Deduplicate macro ratio tables in `macro_calculator.dart`
14. Remove dead code `macro_adjustment_dialog.dart` or wire it in
15. Remove dead parameters from `_pushWidgetData`
16. Add HTTP timeouts to AI API calls
17. Fix height rounding logic to avoid invalid imperial values

---

_Reviewed: 2026-05-25T10:00:00Z_
_Reviewer: gsd-code-reviewer agent_
_Depth: deep_
