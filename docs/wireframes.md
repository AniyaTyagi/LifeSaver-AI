# LifeSaver AI: UI/UX Wireframes & Design System

This document outlines the Material Design 3 system, typography, colors, interactions, and textual wireframes for the 10 screens of **LifeSaver AI**.

---

## 1. Material Design 3 Design System

### 1.1. Color Palette (Premium Dark-Glassmorphism Theme)

We avoid generic colors, opting instead for a tailored, high-contrast dark theme emphasizing focus and calm.

| Token | HSL Value | Description | Use Case |
| :--- | :--- | :--- | :--- |
| `--bg-base` | `hsl(222, 47%, 7%)` | Very dark blue-slate | App background |
| `--surface` | `hsl(222, 40%, 12%)` | Translucent dark indigo | Cards, panels, modals |
| `--primary` | `hsl(252, 100%, 75%)` | Neon violet | Highlights, primary actions |
| `--secondary` | `hsl(180, 100%, 70%)` | Electric cyan | Focus modes, time progress |
| `--accent-risk-high` | `hsl(0, 100%, 72%)` | Soft neon coral | Miss probability > 70% |
| `--accent-risk-med`| `hsl(38, 100%, 68%)` | Golden amber | Miss probability 30% - 70% |
| `--accent-risk-low`| `hsl(145, 80%, 65%)` | Mint green | Miss probability < 30% |
| `--text-primary` | `hsl(0, 0%, 98%)` | Near pure white | Headers, main text |
| `--text-secondary`| `hsl(222, 20%, 70%)` | Muted cool grey | Labels, descriptions |

### 1.2. Typography (Google Fonts)
* **Headers & Brand:** *Outfit* (Geometric, premium feel).
* **Body & UI Elements:** *Inter* (Highly legible, crisp).
* **Code & Times:** *JetBrains Mono* (Clean numbers and durations).

### 1.3. Micro-Animations & Interactivity
* **Hover State:** Translate cards up by `2px` and add shadow spread: `box-shadow: 0 8px 32px 0 rgba(147, 51, 234, 0.15)`.
* **State Transition:** Use `curve: Curves.easeInOutCubic` and `duration: Duration(milliseconds: 350)` for all layout shifts.
* **Risk Pulse:** Risk indicators with score > 80% should have a subtle, slow scale-up and fade-out pulse effect (opacity `0.6` to `1.0`).

---

## 2. Text-Based UI Wireframes (10 Screens)

### Screen 1: Onboarding
* **Concept:** Interactive slide interface introducing the autonomous coach concept.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Logo] LifeSaver AI                                    │
  │                                                        │
  │     Prevent missed deadlines before they happen.       │
  │                                                        │
  │  ┌──────────────────────────────────────────────────┐  │
  │  │ Slide 1: Connect your Google Account             │  │
  │  │ Syncs your Gmail, Calendar, and Tasks so our AI  │  │
  │  │ can analyze incoming commitments.                │  │
  │  └──────────────────────────────────────────────────┘  │
  │                                                        │
  │  [o o o] (Slide indicator)                             │
  │                                                        │
  │  [ Sign in with Google ] (Firebase OAuth trigger)      │
  │  [ Maybe Later ]                                       │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 2: Dashboard
* **Concept:** High-impact status center showing critical metrics and recommendations.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ Welcome back, Alex!              [AI Chat] [Profile]   │
  │ Productivity Score: 87% (Excellent)                    │
  ├────────────────────────────────────────────────────────┤
  │ 🚨 RISK ALERTS (Agent 2)                               │
  │  ┌──────────────────────────────────────────────────┐  │
  │  │ ! Compiler Assignment Due Friday (85% Miss Risk) │  │
  │  │ [ Resolve Now ]  [ Snooze ]                        │  │
  │  └──────────────────────────────────────────────────┘  │
  ├────────────────────────────────────────────────────────┤
  │ TODAY'S PRIORITIES (Agent 3 & 4)                       │
  │  [ ] 09:00 - 11:00  [Focus] compiler assignment block  │
  │  [ ] 14:00 - 15:00  [Meeting] Marketing Sync (Conflict)│
  ├────────────────────────────────────────────────────────┤
  │ HABIT STREAKS             │ GOAL PROGRESS              │
  │  🔥 Coding: 8 days       │ 🎓 Graduate: 74% Complete   │
  │  🏃 Run: 3 days          │ 💼 Internship Prep: 50%     │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 3: Task Manager
* **Concept:** Hierarchical task dashboard showing items grouped by risk and categories.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Tasks                                 [+ Add]   │
  │ Search Tasks...                                        │
  ├────────────────────────────────────────────────────────┤
  │ Category: [ All ] [ Academic ] [ Personal ] [ Work ]   │
  ├────────────────────────────────────────────────────────┤
  │ High Risk (>70%):                                      │
  │  [ ] File Business Taxes (78% Risk)   [DUE: 3 Days]    │
  │      * Depends on: [Gather Invoices] (Incomplete)      │
  │                                                        │
  │ Medium/Low Risk:                                       │
  │  [ ] Prep slide deck (24% Risk)       [DUE: 5 Days]    │
  │  [x] Buy groceries (0% Risk)          [Completed]      │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 4: Calendar View
* **Concept:** Hybrid schedule showing calendar events side-by-side with AI-allocated task blocks.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Calendar (June 24, 2026)                        │
  │  [ < ]   June 2026   [ > ]                             │
  │  [ M ] [ T ] [ W ] [ T ] [ F ] [ S ] [ S ]             │
  │   22    23   *24*   25    26    27    28               │
  ├────────────────────────────────────────────────────────┤
  │ 09:00 ┌──────────────────────────────────────────────┐ │
  │       │ [AI Block] Code Compiler Project (Task)      │ │
  │ 11:00 └──────────────────────────────────────────────┘ │
  │ 12:00 [Free Window]                                    │
  │ 13:00 ┌──────────────────────────────────────────────┐ │
  │       │ [GCal Event] Sync with Design Team           │ │
  │ 14:00 └──────────────────────────────────────────────┘ │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 5: AI Assistant Chat
* **Concept:** Interactive agent conversational interface with voice and quick replies.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] LifeSaver AI Coach                     [Voice]  │
  ├────────────────────────────────────────────────────────┤
  │ [Coach]: Hi Alex, I noticed your Compiler Assignment   │
  │ has a high miss probability. I have scheduled a 2-hour │
  │ focus block for this afternoon. Ready to start?        │
  │                                                        │
  │ [User]: I'm feeling too tired, can we do it tomorrow?  │
  │                                                        │
  │ [Coach (Agent 6)]: I understand. Let's break it into   │
  │ micro-steps instead. We'll start with just sketching   │
  │ the AST parser. It'll take 10 minutes. Deal?           │
  ├────────────────────────────────────────────────────────┤
  │ [ Deal, let's do it ]   [ Reschedule anyway ]          │
  │ Type or talk to coach...                           [>] │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 6: Goal Tracker
* **Concept:** High-level vision tracker indicating how daily efforts contribute to long-term goals.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Goal Progress                         [+ New]   │
  ├────────────────────────────────────────────────────────┤
  │ 🎓 Academic: Get GPA > 3.8                             │
  │  [===========================>---------] 74%           │
  │  * Contribution: 8 tasks completed. 2 tasks pending.   │
  │                                                        │
  │ 💼 Career: Secure Summer Internship                     │
  │  [=================>-------------------] 50%           │
  │  * Contribution: Resume updated. Next: Mock Interview. │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 7: Habit Tracker
* **Concept:** Streak visualization and check-in history.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Habits & Routines                     [+ Add]   │
  ├────────────────────────────────────────────────────────┤
  │ 🔥 Coding Routine (Daily)             Streak: 8 Days   │
  │  [S] [M] [T] [W] [T] [F] [S]                           │
  │  [x] [x] [x] [x] [ ] [ ] [ ]                           │
  │                                                        │
  │ 🏃 Morning Run (3x Week)               Streak: 3 Days   │
  │  [x] Check-in today                                    │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 8: Focus Mode
* **Concept:** Clean, high-impact screen that locks tasks, minimizes interface, and hosts a timer.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │                                                        │
  │                   FOCUSING ON:                         │
  │            "Compiler AST Parser Coding"                │
  │                                                        │
  │                       24:59                            │
  │                [ Progress: 1 of 3 Steps ]              │
  │                                                        │
  │           "Keep going, you are doing great!"           │
  │                                                        │
  │   [ II Pause ]      [ ■ Complete ]      [ +5 Mins ]    │
  │                                                        │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 9: Analytics Dashboard
* **Concept:** Visual representation of productivity metrics and deadlines saved.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Analytics                                       │
  ├────────────────────────────────────────────────────────┤
  │ Completion Rate: 92% (+12% this week)                  │
  │ Focus Hours: 14.5 hours                                │
  │ Deadlines Saved: 7 critical saves                      │
  ├────────────────────────────────────────────────────────┤
  │ Weekly Productivity Chart                              │
  │  100% |     *                                          │
  │   50% |   *   *   *                                    │
  │    0% └───┴───┴───┴───┴─────────────────                │
  │       Mon Tue Wed Thu ...                              │
  └────────────────────────────────────────────────────────┘
  ```

---

### Screen 10: Settings
* **Concept:** Configuration center managing API scopes, working hours, and preferences.
* **Layout:**
  ```
  ┌────────────────────────────────────────────────────────┐
  │ [Back] Settings                                        │
  ├────────────────────────────────────────────────────────┤
  │ CONNECTIONS                                            │
  │  [x] Google Calendar Sync                              │
  │  [x] Gmail Task Fetching                               │
  │  [x] Google Tasks Sync                                 │
  ├────────────────────────────────────────────────────────┤
  │ PREFERENCES                                            │
  │  Working Hours: 09:00 - 18:00                          │
  │  Coach Personality: [ Empathetic ] [ Direct ] [ Strict]│
  │  Intervention Threshold: [ High (Risk > 70%) ]         │
  └────────────────────────────────────────────────────────┘
  ```
