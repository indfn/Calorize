---
phase: 06-ux-enhancements
plan: 03
subsystem: "UI Error Handling, FAB interaction, Streak theming"
tags: ["error-dialog", "alert-dialog", "fab", "streak-theming", "clipboard"]
requires: []
provides: ["Error dialog pattern", "FAB closing behavior", "Theme-compliant streak popup"]
affects: ["dashboard_screen.dart", "camera_logging_screen.dart"]
tech-stack:
  added: ["Clipboard (flutter/services.dart)"]
  patterns: ["_parseErrorMessage for user-friendly error formatting", "Context-preserving error dialogs"]
key-files:
  created: []
  modified:
    - "lib/screens/dashboard_screen.dart"
    - "lib/screens/camera_logging_screen.dart"
decisions:
  - "Retry re-invokes the full analysis flow rather than reusing the same image"
  - "Copy Context uses Clipboard.setData with a brief SnackBar confirmation"
  - "Error dialog uses theme colors throughout — no hardcoded red backgrounds"
metrics:
  duration: "12m"
  completed: "2026-06-12"
---

# Phase 06 Plan 03: Fix Error Popup, FAB Closing, and Streak Theming — Summary

Replace error SnackBars with AlertDialogs that preserve user context text and provide actionable retry/configure/dismiss buttons. Fix the FAB bottom sheet to dismiss before navigating to any action. Verify streak popup uses theme-aware surface color.

## Tasks Executed

| # | Task | Type | Files | Status | Commit |
|---|------|------|-------|--------|--------|
| 1 | Replace AI error SnackBar with AlertDialog in DashboardScreen | `auto` | `dashboard_screen.dart` | ✅ | `610f676` (merged with 3,4) |
| 2 | Replace error SnackBar in CameraLoggingScreen | `auto` | `camera_logging_screen.dart` | ✅ | `9a62344` |
| 3 | Fix FAB sheet not closing before navigation | `auto` | `dashboard_screen.dart` | ✅ | `610f676` (merged with 1,4) |
| 4 | Verify streak popup theming fix | `auto` | `dashboard_screen.dart` | ✅ Verified — already fixed | `610f676` |

## Changes Made

### Task 1 — Dashboard AI Error Dialog

- **Before:** Red SnackBar with "Configure AI" action when analysis fails
- **After:** AlertDialog showing:
  - User-friendly parsed error message via `_parseErrorMessage()`
  - "Your context:" section showing the user's typed context (if non-empty)
  - **Copy Context** button — copies context text to clipboard via `Clipboard.setData()`, shows "Context copied!" SnackBar
  - **Dismiss** button — closes dialog
  - **Configure AI** button — conditional, only when error is provider-related (No AI providers / API key)
  - **Try Again** button — re-invokes `_handleAiAnalysis()` to restart the full flow

### Task 2 — CameraLoggingScreen Error Dialog

- Same AlertDialog pattern as Task 1 applied to `_captureAndAnalyze()` catch block
- Try Again calls `_captureAndAnalyze(fromGallery: fromGallery)` to restart
- Preserves deep-link screen pop (`Navigator.pop`) after dialog dismisses when `!initialBarcodeMode`

### Task 3 — FAB Sheet Dismissal

- **Before:** Callbacks passed directly `_handleManualEntry`, `_handleBarcodeScan`, `_handleAiAnalysis`
- **After:** Each callback wrapped: `Navigator.pop(context)` first, then handler call
- Ensures FAB bottom sheet is dismissed before any navigation occurs

### Task 4 — Streak Popup Theming

- Verified: `const Color(0xFFF4F6F8)` already replaced with `Theme.of(context).colorScheme.surfaceContainerHighest` (line 155)

### Added `_parseErrorMessage()` Method

Added as a private helper method to both `_DashboardScreenState` and `_CameraLoggingScreenState`:

| Error Pattern | User-Friendly Message |
|---|---|
| `No AI providers` | "No AI providers configured. Add one in Settings." |
| `API error: 401` / `API error: 403` | "Authentication failed. Check your API key." |
| `API error: 429` | "Rate limit exceeded. Please try again later." |
| `API error: 5...` | "The AI provider server returned an error. Try again." |
| `Connection refused` / `SocketException` | "Could not connect to the AI provider. Check your internet connection." |
| Default | "An unexpected error occurred. Please try again." |

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None.

## Threat Flags

No new security-relevant surface introduced.

## Verification

```bash
$ flutter analyze
# 0 errors, 0 warnings, 52 info-level issues (all pre-existing)
```

## Self-Check: PASSED

All claims verified:
- ✅ `dashboard_screen.dart`: Contains `AlertDialog`, `Clipboard.setData`, `_parseErrorMessage`, `Navigator.pop(context)` in FAB callbacks
- ✅ `camera_logging_screen.dart`: Contains `AlertDialog`, `Clipboard.setData`, `_parseErrorMessage`
- ✅ `flutter analyze`: 0 errors
- ✅ Task 4: `const Color(0xFFF4F6F8)` not present in dashboard_screen.dart
