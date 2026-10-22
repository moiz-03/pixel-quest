# Pixel Quest — What's Next

**A focused roadmap of everything that could be built, prioritized by impact.**
**Last updated:** October 2026

---

## How to read this document

Each item includes:
- **Impact** — how much it moves the needle for users
- **Effort** — rough estimate in focused sessions
- **Depends on** — what must ship first
- **Why it matters** — the specific problem it solves

Priority tiers:
- 🔥 **Critical** — blocks core product value
- ⭐ **High** — significant user experience gain
- 💡 **Medium** — nice to have, improves retention
- ✨ **Polish** — finishing touches, deferred

---

## 🔥 Critical — Do First

### 1. Cloud Sync with Firestore

**Impact:** 🔥🔥🔥 Critical
**Effort:** 1–2 sessions
**Depends on:** Nothing

**The problem:** All user data lives in `SharedPreferences`. Uninstall the app, clear app data, switch phones — quests, XP, and level are gone. There is no way to recover an account's progress.

**What to build:**
- Add `cloud_firestore` dependency
- New service: `lib/services/firestore_service.dart`
- Firestore structure:
  ```
  users/{uid}/
    level, currentXp, xpToNext, totalXp, streak, updatedAt
    quests/{questId}/
      title, category, xp, completed, updatedAt
  ```
- Write-through caching: `Prefs` mirrors every mutation for instant display, Firestore syncs in background
- On launch: read cache → render → fetch Firestore → reconcile → re-render
- Firestore security rules scoped to `request.auth.uid == uid`

**What it unlocks:**
- Login from any device with the same account
- Data survives uninstall
- Foundation for every social feature below

---

### 2. Real Terms of Service & Privacy Policy

**Impact:** 🔥🔥🔥 Critical (for shipping)
**Effort:** 1 hour
**Depends on:** Nothing

**The problem:** Both URLs in `register_screen.dart` currently point to `https://flutter.dev`. App Store and Play Store reviewers will reject the app if these are placeholders.

**What to build:**
- Two hosted pages (GitHub Pages, Notion public page, or a static site)
- Replace both URLs in `register_screen.dart`
- Optional: in-app WebView so users stay in context

**What it unlocks:**
- Eligibility for app store submission
- GDPR/CCPA compliance baseline

---

### 3. Streak System

**Impact:** 🔥🔥 High
**Effort:** 1 session
**Depends on:** Nothing

**The problem:** The STREAK card has shown `0` forever. Streaks are the single most effective retention mechanic in habit apps — Duolingo's entire model is built on it.

**What to build:**
- Store `lastCompletedDate` and `currentStreak` per user
- On any quest completion:
  - Same day → no change
  - Yesterday → increment streak
  - Older → reset to 1
- Visual: growing flame icon in the header, streak milestones highlighted
- Optional: "streak freeze" (one free skip per week)

**What it unlocks:**
- Daily return habit
- A second progress axis independent of XP
- Tangible loss aversion ("I'll lose my 47-day streak!")

---

## ⭐ High Priority — Next Wave

### 4. Recurring Quests

**Impact:** ⭐⭐ High
**Effort:** 2 sessions
**Depends on:** Cloud sync (recommended)

**The problem:** A habit tracker where you must manually recreate "Drink Water" every day is not a habit tracker. It's a to-do list.

**What to build:**
- Add `schedule` field to `Quest`: `Once` | `Daily` | `Weekdays` | `Weekly` | `Custom days`
- Auto-reset completion at midnight (local time) for recurring quests
- Track per-day completion history for the heatmap (see #6)
- UI: schedule picker in the Add/Edit sheet

**What it unlocks:**
- True daily habit tracking
- Meaningful streaks
- Data for time-based insights

---

### 5. Local Notifications

**Impact:** ⭐⭐ High
**Effort:** 1–2 sessions
**Depends on:** Recurring quests

**The problem:** Users forget to open the app. Even a great habit tracker dies if nobody remembers to check it.

**What to build:**
- `flutter_local_notifications` + `timezone` packages
- Per-quest reminder time (e.g., "Drink Water at 8 AM")
- Daily summary notification (e.g., 7 PM if any quests are incomplete)
- Streak-at-risk alert (8 PM if streak would break)
- Request permission at first quest creation (not at app launch)

**What it unlocks:**
- Daily active usage
- Streak preservation
- Personalized engagement

**Platform notes:** Android 13+ needs `POST_NOTIFICATIONS` permission. iOS needs `UNUserNotificationCenter` setup in `Info.plist`.

---

### 6. Stats Tab

**Impact:** ⭐⭐ High
**Effort:** 2 sessions
**Depends on:** Recurring quests (for time-based data)

**The problem:** The Stats tab has been a placeholder ("Coming soon") since day one. Users have no way to see their progress over time.

**What to build:**
Using `fl_chart`:
- **7-day completion rate** — line or bar chart
- **30-day XP earned** — bar chart
- **Category breakdown** — pie chart
- **Heatmap calendar** — GitHub-style, one square per day, shaded by completions
- **Records section** — best streak, total quests done, longest session
- **Weekly comparison** — "You earned 20% more XP than last week"

**What it unlocks:**
- Users feel their progress tangibly
- Discovery of patterns ("I never do Fitness quests on weekends")
- Satisfying visual payoff for consistency

---

### 7. Leaderboard

**Impact:** ⭐⭐ High
**Effort:** 1 session
**Depends on:** Cloud sync

**The problem:** Habit tracking is lonely. There's no external pressure to keep going.

**What to build:**
- Firestore query: `users` ordered by `totalXp desc`, limit 100
- Show top 20 with tier badge, username, and total XP
- Highlight the current user's row
- Two views: **All-time** and **This week**
- Optional: friends-only leaderboard (needs friend system #10)

**What it unlocks:**
- Competitive motivation
- Social proof ("I'm #12 globally — I can pass #11")
- Reason to keep playing after reaching top tier

**Watch out for:** Cheating. Add basic sanity checks — cap reasonable XP/day, flag accounts with suspicious patterns.

---

## 💡 Medium Priority — Value Adders

### 8. Achievements & Badges

**Impact:** 💡 Medium
**Effort:** 1 session
**Depends on:** Nothing

**The problem:** Levels and tiers provide one reward axis. More axes = more reasons to engage.

**What to build:**
- Achievement definitions stored locally or in Firestore
- Unlockable badges, each with icon, name, and description
- Progress shown as a grid of locked/unlocked cards

**Example achievements:**

| Badge | Requirement |
|---|---|
| First Steps | Create your first quest |
| Consistency | 7-day streak |
| Marathon | 30-day streak |
| Category Master | Complete 25 quests in one category |
| Century Club | 100 total quests completed |
| Night Owl | Complete a quest after 10 PM |
| Early Bird | Complete a quest before 6 AM |
| Perfectionist | Complete every quest in one day |
| Climber | Reach Champion tier |
| Legend | Reach Legend tier |

**What it unlocks:**
- Long-tail goals beyond tier progression
- More feedback loops = more dopamine

---

### 9. Profile & Customization

**Impact:** 💡 Medium
**Effort:** 1–2 sessions
**Depends on:** Cloud sync

**The problem:** Users are "Player" with no way to personalize their identity. The app feels generic.

**What to build:**
- Avatar picker (preset pixel-art icons or upload)
- Display name editing (updates `displayName` in Firebase Auth)
- Bio / tagline
- Tier-colored username in leaderboards
- **Unlockable themes** — new color palettes earned at tier milestones
- Sound effect toggle (quest complete, tier up)

**What it unlocks:**
- Emotional investment in the profile
- Reward loop tied to progression
- Distinct identity in social features

---

### 10. Friends System

**Impact:** 💡 Medium
**Effort:** 2 sessions
**Depends on:** Cloud sync, leaderboard

**The problem:** Global leaderboards are impersonal. Users care about beating their actual friends.

**What to build:**
- Add friend by username or email
- Friend requests (send, accept, decline)
- Friends-only leaderboard
- Optional: nudge a friend ("Hey, your streak is at risk!")
- Privacy controls (public / friends-only / private profile)

**What it unlocks:**
- Real social accountability
- Organic growth (invite friends)
- Higher engagement for existing users

---

### 11. Daily / Weekly Challenges

**Impact:** 💡 Medium
**Effort:** 1 session
**Depends on:** Cloud sync

**The problem:** Once a user is at the top tier, there's no new content. Endgame problem.

**What to build:**
- Curated challenges that rotate (e.g., "Complete 5 Health quests this week")
- Bonus XP for completing
- Special badge for finishing
- Weekly reset

**What it unlocks:**
- Fresh content every week
- Reason to return for non-tier players
- A place for seasonal events

---

### 12. Account Deletion Flow

**Impact:** 💡 Medium (compliance)
**Effort:** 1 hour
**Depends on:** Nothing

**The problem:** Both Apple and Google now require in-app account deletion. Without it, the app cannot be published.

**What to build:**
- Settings → "Delete Account"
- Confirmation dialog with clear warning
- On confirm: delete Firestore data, delete Firebase Auth user, clear Prefs
- Verify: user cannot log back in with the same credentials

**What it unlocks:**
- App store compliance
- User trust

---

## ✨ Polish — Ship-Ready Touches

### 13. Analytics & Crash Reporting

**Impact:** ✨ Polish
**Effort:** 1 session
**Depends on:** Nothing

**What to build:**
- `firebase_analytics` — track signups, quest creation, tier-ups, retention
- `firebase_crashlytics` — catch every uncaught error, group by stack trace
- Custom events: `quest_completed`, `tier_up`, `streak_milestone`

**What it unlocks:**
- Insight into real user behavior
- Early warning when something breaks in production

---

### 14. Offline Mode Polish

**Impact:** ✨ Polish
**Effort:** 1 session
**Depends on:** Cloud sync

**What to build:**
- Small "offline" indicator in the header when Firestore is unreachable
- Pending writes queue indicator
- Retry logic with exponential backoff
- Manual "sync now" button in Settings

**What it unlocks:**
- Confidence that data isn't lost in spotty coverage
- Transparent state to the user

---

### 15. Home Screen Widgets

**Impact:** ✨ Polish
**Effort:** 2 sessions
**Depends on:** Recurring quests

**What to build:**
- **Android**: `home_widget` package, one 2×2 widget showing today's quests + streak
- **iOS**: WidgetKit via Swift bridge (more complex)

**What it unlocks:**
- Passive reminders
- Constant visibility without opening the app

---

### 16. Apple Watch / Wear OS Companion

**Impact:** ✨ Polish
**Effort:** 3+ sessions
**Depends on:** Cloud sync, recurring quests

**What to build:**
- Minimal companion app: see today's quests, tick them off
- Sync via Firebase from the phone app

**What it unlocks:**
- Fastest possible check-in flow
- Hardcore user satisfaction

---

## 🧹 Tech Debt & Cleanup

### 17. Widget Extraction

**Impact:** ✨ Polish
**Effort:** 1 session
**Depends on:** Nothing

Extract these from `home_screen.dart` into `lib/widgets/`:

- `XpProgressBar` — the segmented XP bar
- `StatCard` — the streak/total XP card
- `QuestTile` — the individual quest row
- `TierUpDialog` — the celebration dialog
- `EmptyState` — the "no quests yet" placeholder

**Why:** `home_screen.dart` is ~700 lines. Extracting makes it scannable and lets you test widgets in isolation.

---

### 18. Deprecation Cleanup

**Impact:** ✨ Polish
**Effort:** 15 minutes
**Depends on:** Nothing

Find and fix remaining deprecations:
- `Color.withOpacity()` → `Color.withValues(alpha:)`
- Any lingering `(_, __, ___)` → `(_, _, _)`
- Unused imports flagged by `flutter analyze`

Run once to see everything:
```powershell
flutter analyze
dart fix --apply
```

---

### 19. Automated Tests

**Impact:** ✨ Polish
**Effort:** 2–3 sessions
**Depends on:** Nothing

**What to build:**
- **Unit tests** — `Validators`, `Tier.forLevel`, XP computation, quest serialization
- **Widget tests** — Login form validation, QuestSheet add/edit flows
- **Integration tests** — full signup → create quest → complete → verify XP flow

**What it unlocks:**
- Confidence to refactor
- Faster iteration
- Fewer regressions

---

### 20. CI Pipeline

**Impact:** ✨ Polish
**Effort:** 1 session
**Depends on:** Tests

**What to build:**
- GitHub Actions workflow
- On push: `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`
- Badge in the README

**What it unlocks:**
- Instant feedback on every commit
- No regressions sneaking into `main`

---

### 21. Stricter Lints

**Impact:** ✨ Polish
**Effort:** 30 minutes
**Depends on:** Nothing

Add to `analysis_options.yaml`:
```yaml
linter:
  rules:
    - prefer_final_locals
    - prefer_const_constructors
    - prefer_const_declarations
    - unnecessary_lambdas
    - avoid_print
    - require_trailing_commas
    - sort_child_properties_last
```

Then run `dart fix --apply` to auto-fix what's possible.

---

## 🚀 Suggested Sequence

### Sprint 1 — Ship-Ready Core (1 week)
1. Cloud sync with Firestore
2. Real ToS / Privacy URLs
3. Streak system
4. Account deletion flow

*Outcome: App is publishable and data-safe.*

### Sprint 2 — Engagement (1–2 weeks)
5. Recurring quests
6. Local notifications
7. Stats tab with charts

*Outcome: Daily habit loop is complete.*

### Sprint 3 — Social (1 week)
8. Leaderboard
9. Achievements

*Outcome: Competitive motivation layer.*

### Sprint 4 — Polish (1 week)
10. Profile customization
11. Friends system
12. Analytics + crash reporting

*Outcome: Retention mechanics in place.*

### Sprint 5 — Launch (1 week)
13. App icons, screenshots, store listings
14. Beta test with 10–20 users
15. Public release

*Outcome: Live on stores.*

---

## Prioritization Cheat Sheet

| Feature | User value | Effort | Ship in |
|---|---|---|---|
| Cloud sync | 🔥🔥🔥 | 1–2 | Sprint 1 |
| ToS / Privacy | 🔥🔥🔥 | 1h | Sprint 1 |
| Streak system | 🔥🔥 | 1 | Sprint 1 |
| Account deletion | 🔥🔥 | 1h | Sprint 1 |
| Recurring quests | ⭐⭐ | 2 | Sprint 2 |
| Notifications | ⭐⭐ | 1–2 | Sprint 2 |
| Stats tab | ⭐⭐ | 2 | Sprint 2 |
| Leaderboard | ⭐⭐ | 1 | Sprint 3 |
| Achievements | 💡 | 1 | Sprint 3 |
| Profile / themes | 💡 | 1–2 | Sprint 4 |
| Friends | 💡 | 2 | Sprint 4 |
| Daily challenges | 💡 | 1 | Post-launch |
| Widgets | ✨ | 2 | Post-launch |
| Watch app | ✨ | 3+ | Post-launch |
| Tests | ✨ | 2–3 | Ongoing |
| CI | ✨ | 1 | Sprint 1 (quick win) |
| Lint cleanup | ✨ | 30m | Sprint 1 (quick win) |

---

## What to do in your next session

If you have **one hour:** Set up GitHub Actions CI + fix all `flutter analyze` warnings. Immediate quality lift.

If you have **one day:** Start Firestore integration. This is the single highest-value feature left to build.

If you have **one week:** Do Sprint 1. Ship-ready core.

If you have **one month:** Do Sprints 1–3. You have a competitive habit tracker.

---

**Document owner:** Development team
**Next review:** After Sprint 1 completes