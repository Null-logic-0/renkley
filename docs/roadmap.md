# Renkley — Full Jira Backlog

> Status legend: 
. ✅ Built 
· 🎯 Last remaining task 
· ❌ Not built (documented roadmap, not MVP work)

---

## STATUS SUMMARY

**✅ Built and functional:** 
Auth (login/signup/OAuth/password reset), 
App Shell (sidebar + topbar + account menu), 
Onboarding Wizard, 
Settings (password update + account deletion), 
Overview dashboard.

**🎯 Last remaining task:** 
Point the sidebar links for unbuilt screens (Competitors, Prompts, Mentions, Keywords, SEO Audit, Reports, 
Analytics, 
Team, 
Billing, and Settings' workspace/brand-tracking/notification sections) at a single reusable not found fallback instead of a dead link or 404.

**❌ Everything else below is the documented roadmap** 
— scoped intentionally, not built, and not required for the MVP/portfolio version. 
This is what "planned but not yet implemented" looks like when it's designed rather than abandoned.

---

# EPIC: Auth — Login & Signup Page ✅ BUILT

## Ticket 1 — [Auth] Build login/signup page (view + backend)
**Goal:** 
Two-column auth page (brand aside + form panel), 
login/signup toggle, 
responsive collapse.
**Requirements:**
- Brand aside: logo, headline, testimonial card, stats footer
- Form panel shared: logo, Google button, OR divider, email + password fields, submit, mode-switch link
- Login: forgot-password link, "keep me signed in" checkbox
- Signup: full-name field, terms checkbox, trial-info footer
- Toggle updates copy/fields with no reload; responsive below ~820px

**Backend:** 
`has_secure_password` or Devise; routes for sessions/registrations; validations (presence, email format/uniqueness, password length); remember-me session; terms_accepted virtual attribute
**Dependencies:** 
None

## Ticket 2 — [Auth] Add Google OAuth sign-in ✅ BUILT
**Goal:** 
Wire "Continue with Google" to real OAuth flow.
**Requirements:** 
Find-or-create user from Google profile; graceful failure/cancel handling
**Technical:** 
`omniauth-google-oauth2` + `omniauth-rails_csrf_protection`; encrypted credentials
**Dependencies:** 
Ticket 1

## Ticket 3 — [Auth] Build password reset request page (view + backend) ✅ BUILT
**Goal:** 
"Reset your password" screen + email-based reset flow.
**Requirements:** 
Single email field, "Send reset link" button, confirmation state, no account-enumeration, "Back to sign in" link
**Backend:** 
Secure time-limited (30 min) single-use token; async email via mailer/job; rate limiting
**Dependencies:** 
Ticket 1

---

# EPIC: App Shell — Sidebar, Topbar & Account Menu ✅ BUILT

## Ticket 1 — [Layout] Build sidebar navigation
**Goal:** 
Left sidebar: grouped nav (Monitor/Optimize/Insights), active state, badge counter, collapse toggle.
**Requirements:** 
Logo + wordmark; sections (Overview, AI Visibility, Competitors, Prompts, Mentions | Keywords, SEO Audit | Reports, Analytics); active-item highlight; badge pill on Prompts; "Collapse sidebar" pinned at bottom
**Technical:** 
Shared partial `_sidebar.html.erb`; active state via current route helper; Stimulus collapse persisted in localStorage
**Dependencies:** 
None (becomes shared layout)

## Ticket 2 — [Layout] Build topbar (search, date filter, notifications, export)
**Goal:** Global search (⌘K), date-range filter dropdown, notification bell, "Export report" button, user identity block.
**Requirements:** Debounced search; range dropdown persisted in URL query params; unread-indicator dot; export triggers real export
**Dependencies:** Ticket 1; Ticket 3 for account dropdown

## Ticket 3 — [Account] Build user account dropdown & logout
**Goal:** 
Dropdown from topbar user block: identity summary, Team/Billing/Settings links, Log out.
**Requirements:** 
Avatar/name/email header; menu items; destructive-styled Log out; closes on outside-click/Escape
**Dependencies:** 
Ticket 2; `sessions#destroy` from Auth epic

---

# EPIC: Design System — Reusable UI Components (HOT PRIORITY, but optional for solo MVP)

## Ticket 0 — [UI] Build reusable component partials & styles
**Goal:** 
Shared partials for Button, Input, Toggle, Segmented Control, Tag/Pill, Card, Avatar, Dropdown/Popover, Validation Checklist, Danger Banner.
**Technical:** 
Rails partials or ViewComponent; dev-only style-guide preview page
**Note for MVP:** 
Skip formalizing this if you're not building more screens — only worth it if continuing past MVP.

---

# EPIC: Onboarding Wizard ✅ BUILT

## Ticket 1 — [Onboarding] Build 4-step onboarding wizard (view + backend)
**Goal:** 
Post-signup flow: website scan → competitor review → prompt review → automated setup.
**Requirements:** 
Shared header/progress rail; Step 1 URL input triggers scan; Step 2 competitor add/remove list; Step 3 prompt add/remove list; Step 4 animated setup checklist tied to a real multi-stage background job
**Dependencies:** 
Auth epic; feeds into dashboard data

---

# EPIC: Settings Page — PARTIALLY BUILT

## Ticket 1 — [Settings] Build workspace & brand tracking settings ❌ NOT BUILT
Workspace name/domain/category/default platform fields; brand alias tag list; scan frequency segmented control.

## Ticket 2 — [Settings] Build notification preferences ❌ NOT BUILT
5 toggle rows (weekly digest, competitor alerts, citation alerts, drop warnings, product updates).

## Ticket 3 — [Settings] Build password update & workspace deletion ✅ BUILT
Live-validated password change form; danger-zone delete-workspace with confirm; page-level Save/Discard bar.

---

# EPIC: Dashboard — Overview ✅ BUILT

## Ticket 1 — [Dashboard] Build Overview screen
**Goal:** 
Landing dashboard: score, platform breakdown, prompt tracking, mentions timeline, citations, recommendations.
**Requirements:** 
Hero + scan status; score strip (primary ring + 3 metric cells); platform breakdown cards; expandable competitor comparison rows; prompt tracking table w/ tabs; mentions timeline + citation analysis two-column section; AI-generated recommendations list; reports strip
**Technical:** 
Split into partials; shared charting approach; real data aggregation from scans/prompts/competitors
**Dependencies:** 
App Shell

---

# EPIC: Dashboard — Remaining Screens ❌ NOT BUILT (stub with "Coming soon" for now)

## Ticket 2 — [Dashboard] Build AI Visibility screen
Platform-filterable KPI cards, trend chart, share-of-voice donut, visibility funnel, topic breakdown.

## Ticket 3 — [Dashboard] Build Competitors screen
Leaderboard, head-to-head comparison tool, win/loss list, recent movement feed.

## Ticket 4 — [Dashboard] Build Prompts screen
Full prompt table (extends Overview's condensed version) with tab filters.

## Ticket 5 — [Dashboard] Build Mentions screen
Sentiment-tagged mention feed; "Export mentions" (reuses Reports export infra).

## Ticket 6 — [Dashboard] Build Keywords screen
Keyword table: rank, search volume, AI visibility. Likely needs external SEO data provider.

## Ticket 7 — [Dashboard] Build SEO Audit screen
Crawl-based health score ring + issue list; "Run new audit" triggers async crawler job.

## Ticket 8 — [Dashboard] Build Reports screen
Full report card grid (extends Overview's strip); "New report" config dialog; async export generation.

## Ticket 9 — [Dashboard] Build Analytics screen
Visibility/mentions/citation trend charts; business-impact correlation (likely needs external analytics/CRM integration).

## Ticket 10 — [Dashboard] Build Team screen
Member list, "Invite member" dialog, role-based access control.

## Ticket 11 — [Dashboard] Build Billing screen
Plan/usage summary, billing history. Needs Stripe (or similar) integration — scope as its own dedicated spike.
