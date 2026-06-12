# REQUIREMENTS

## Phase 1: Database Schema Refactoring (Isar)
- DB-01: Support multi-provider AI settings
- DB-02: Support day-of-week macro goals

## Phase 2: AI Provider Landscape (Settings & Onboarding)
- AI-01: Dynamic multi-provider selection UI (Presets: OpenAI, Google, Anthropic, Custom)
- AI-02: Routing logic (Round Robin vs. Fill Up First)

## Phase 3: Camera Function & Widget Adjustment (Fix)
- CAM-01: Split the logging approach (Manual Entry top; Barcode vs AI Analyze bottom)
- CAM-02: Remove "+ Log your food" button from Flutter UI widget and native Kotlin widget

## Phase 4: Day of Week Adjustments (UI & State)
- UI-01: "Customize Macros Across The Week" page with a 7-day interactive bar chart
- UI-02: Redesign edit popup to be compact, allow manual calorie entry, and operate dynamically

## Phase 5: Notification Architecture (Fix)
- NOTIF-01: Implement reliable, non-draining background scheduling (breakfast, lunch, dinner)

## Phase 6: UX Enhancements & Edit Logs
- UX-01: Unified capture-to-result analysis view with photo preview and real-time status
- UX-02: FAB sheet closes when navigating to sub-screens
- UX-03: AlertDialog for errors instead of raw SnackBar
- UX-04: Edit/delete logged meals via FoodEditSheet edit mode
- UX-05: Progress page food history redesign (newest-first, sleeker cards)
- UX-06: Real-time AI provider status text during analysis
- UX-07: Photo preview during context entry
