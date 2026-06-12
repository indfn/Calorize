# ROADMAP

### Phase 1: Database Schema Refactoring (Isar)
**Goal:** Update Isar DB schemas to support multi-provider AI settings and day-of-week macro goals.
**Requirements:** [DB-01, DB-02]
**Plans:** 2 plans
Plans:
- [ ] 01-01-PLAN.md — DB Schemas
- [ ] 01-02-PLAN.md — Refactor Services

### Phase 2: AI Provider Landscape (Settings & Onboarding)
**Goal:** Design a dynamic multi-provider selection UI with routing logic.
**Requirements:** [AI-01, AI-02]
**Plans:** 2 plans
Plans:
- [ ] 02-01-PLAN.md — Food Sourcing routing
- [ ] 02-02-PLAN.md — UI for API Keys

### Phase 3: Camera Function & Widget Adjustment (Fix)
**Goal:** Update logging UI: redesign home screen bottom sheet, switch AI mode to use native camera directly, convert camera screen to purely barcode scanner, and clean native widget.
**Requirements:** [CAM-01, CAM-02]
**Plans:** 1 plans
Plans:
- [ ] 03-01-PLAN.md — Update home screen UI, refactor camera screen, and clean widget

### Phase 4: Day of Week Adjustments (UI & State)
**Goal:** Create a new "Customize Macros Across The Week" page with a 7-day interactive bar chart.
**Requirements:** [UI-01, UI-02]
**Plans:** 1 plans
Plans:
- [ ] 04-01-PLAN.md — Build 7-day chart and edit popup

### Phase 5: Notification Architecture (Fix)
**Goal:** Implement reliable, non-draining background scheduling.
**Requirements:** [NOTIF-01]
**Plans:** 1 plans
Plans:
- [ ] 05-01-PLAN.md — Android manifest and zonedSchedule

### Phase 6: UX Enhancements & Edit Logs
**Goal:** Improve AI analysis UX (unified capture-to-result view with real-time status), add edit/delete for logged meals on dashboard and progress, redesign progress food history, fix FAB popup, and fix hardcoded theming.
**Requirements:** [UX-01 through UX-07]
**Plans:** 4 plans
Plans:
- [x] 06-01-PLAN.md — Database + FoodEditSheet edit mode
- [ ] 06-02-PLAN.md — Unified analysis view + status callbacks
- [x] 06-03-PLAN.md — Error dialog + FAB fix + streak theming
- [ ] 06-04-PLAN.md — Edit tappability + progress redesign
