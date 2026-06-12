---
phase: 06
plan: 02
subsystem: AI Analysis
tags: ["analysis", "ui", "status-callbacks", "unified-view"]
requires: []
provides: ["Unified analysis flow with real-time status"]
affects: ["dashboard_screen", "camera_logging_screen", "ai_routing_service", "food_sourcing_service"]
tech-stack:
  added: []
  patterns: ["Status callback pattern via Void Function(String)", "State machine widget pattern"]
key-files:
  created: []
  modified:
    - lib/services/ai_routing_service.dart
    - lib/services/food_sourcing_service.dart
    - lib/widgets/analyze_view.dart
    - lib/screens/dashboard_screen.dart
    - lib/screens/camera_logging_screen.dart
decisions:
  - "onStatusChanged callback passed through service chain: AnalyzeView → FoodSourcingService → AiRoutingService → API methods"
  - "Error handling kept in AnalyzeView inline instead of separate error dialog from old flow"
  - "CameraLoggingScreen uses a local non-nullable 'file' capture to satisfy Dart closure type promotion"
metrics:
  duration: "~15 min"
  completed_date: "2026-06-12"
---

# Phase 6 Plan 2: Create Unified Analysis View with Real-Time Status Callbacks

Replace the disjointed three-step analysis flow (photo → context dialog → spinner dialog) with a single unified AnalyzeView widget that shows photo thumbnail, context input, animated spinner, and live status text in one card, with real-time status callbacks flowing through the entire service chain.

## Context

The AI analysis flow had 3 disjointed dialogs: photo capture, then "Add Context" dialog, then "Analyzing image..." dialog. These were replaced with one unified view showing photo, context input, then spinner + real-time status text.

## Summary of Changes

### Task 1: `onStatusChanged` callback in AiRoutingService

**Files modified:** `lib/services/ai_routing_service.dart`

- Added optional `void Function(String status)? onStatusChanged` parameter to `sendImageRequest()`
- Passed `onStatusChanged` to each API method (`_callGemini`, `_callOpenAI`, `_callAnthropic`, `_callCustom`)
- Each API method calls `onStatusChanged` at key stages:
  - `'Sending to ${provider.apiType} provider...'` — before switch dispatch
  - `'Connecting to ${provider.name} (${provider.modelId})...'` — before HTTP request
  - `'Parsing response from ${provider.name}...'` — after successful HTTP response, before JSON parsing

### Task 2: `onStatusChanged` callback in FoodSourcingService

**Files modified:** `lib/services/food_sourcing_service.dart`

- Added optional `void Function(String status)? onStatusChanged` parameter to `analyzeImage()`
- Calls `onStatusChanged?.call('Analyzing with ${provider.name} (${provider.modelId})...')` before each provider attempt
- Calls `onStatusChanged?.call('${provider.name} failed, trying next...')` before fallback/retry
- Passes `onStatusChanged` through to `AiRoutingService().sendImageRequest()`

### Task 3: AnalyzeView widget

**Files modified:** `lib/widgets/analyze_view.dart`

- StatefulWidget with 4-phase state machine:
  - **Phase 1 — Input:** Photo thumbnail (ClipRRect, 200px height) + editable TextFormField (5 lines, context hint) + Cancel/Analyze buttons
  - **Phase 2 — Analyzing:** Photo stays visible, context becomes read-only display, CircularProgressIndicator + live status text, Cancel button
  - **Phase 3 — Success:** Calls `onSuccess(FoodLog)` which parent handles by opening FoodEditSheet
  - **Phase 4 — Error:** Shows error in error-colored container with Back/Try Again buttons
- Uses `GoogleFonts.inter` and `Theme.of(context).colorScheme` throughout
- Error messages parsed from exception text for user-friendly display

### Task 4: DashboardScreen flow replacement

**Files modified:** `lib/screens/dashboard_screen.dart`

- Replaced `_handleAiAnalysis()` — removed old context dialog + progress dialog + error dialog (108 lines → 32 lines)
- Now shows AnalyzeView in a `showDialog` with `barrierDismissible: false`
- On success: pops AnalyzeView, opens `FoodEditSheet`
- On error: AnalyzeView shows inline error with Try Again
- Removed unused imports (`flutter/services.dart`, `ai_providers_screen.dart`)
- Removed dead `_parseErrorMessage` method

### Task 5: CameraLoggingScreen flow replacement

**Files modified:** `lib/screens/camera_logging_screen.dart`

- Replaced `_captureAndAnalyze()` for both `fromGallery: true` and `fromGallery: false` paths
- Both paths now use AnalyzeView dialog instead of separate context dialog + analysis
- Fixed deep-link mode navigation: pops AnalyzeView then entire camera screen after edit sheet closes
- Uses local non-nullable `file` variable for Dart closure type promotion
- Removed unused import (`ai_providers_screen.dart`) and dead `_parseErrorMessage` method

## Verification

`flutter analyze` passes with **0 errors, 0 warnings** from plan-related files. The only remaining warning is a pre-existing unused import in `settings_screen.dart`.

## Deviations from Plan

None — plan executed exactly as written.

## Commits

| Hash | Message |
|------|---------|
| `133bbae` | feat(06-02): add onStatusChanged callback to AiRoutingService and FoodSourcingService |
| `9cb393b` | feat(06-02): replace disjointed AI analysis flow with unified AnalyzeView |
| `d51df6f` | fix(06-02): resolve analyzer warnings in AnalyzeView and CameraLoggingScreen |

## Self-Check: PASSED
