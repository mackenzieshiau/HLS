Home Language Screener

A parent and guardian-facing web app that helps schools collect Home Language Survey responses and identify when a student may need the next step in the English Learner (EL) / Emergent Bilingual (EB) identification process.

Built with TanStack Start, React 19, Tailwind CSS v4, and Lovable Cloud (Supabase) for auth, database, and storage.

---

✨ Features

For families (public)
- Parent-friendly demo screener at `/demo` with bilingual labels.
- Language picker covering every language supported by Google Translate, with an "Other" free-text fallback for parents who can't spell the language.
- Live translation of every question and the thank-you message into the parent's selected language.
- Birth date entry in addition to grade level, since grade conventions vary across cultures.
- Clear next-step recommendation at the end (does not make an official EL/EB determination).

For schools (authenticated)
- Email/password + Google sign-in via Lovable Cloud auth.
- Protected dashboard at `/dashboard` — each user only sees their own forms.
- Form builder at `/forms/:id/edit`:
  - Short answer, multiple choice, and rating question types
  - Drag-style reordering
  - Live preview
  - Save confirmation dialog
  - "Require sign-in to respond" toggle per form
- Shareable public links at `/forms/:id` — no Lovable login required for respondents (unless the toggle is on).
- Response viewer at `/forms/:id/responses` with each submission rendered as a readable question/answer table.
- Form stats on each dashboard card: total questions, breakdown by type, and number of completions.
- Profile dialog with display name, password change (live strength meter + requirements checklist), light/dark theme, and list vs. card view preference.
- Sort & filter forms by date or title, ascending or descending.

Design
- "Alpha" design system: electric blue (`#0614FF`), deep indigo, bold Inter typography, pill-shaped CTAs, surface-card pattern across all pages.
- Full-bleed hero photo with light decorative SVG graphics.
- Responsive, light + dark mode.

---

🧱 Tech stack

| Layer | Tech |
|---|---|
| Framework | [TanStack Start v1](https://tanstack.com/start) (React 19, SSR) |
| Build | Vite 7 |
| Styling | Tailwind CSS v4 (via `@import` in `src/styles.css`) |
| UI | shadcn/ui + Radix primitives + lucide-react icons |
| Routing | TanStack Router (file-based, in `src/routes/`) |
| Data | TanStack Query |
| Backend | Lovable Cloud (Supabase: Postgres + Auth + RLS) |
| Deploy target | Cloudflare Workers (edge) |
| Package manager | Bun |

---

🚀 Getting started

```bash
# install
bun install

# dev server (http://localhost:8080)
bun run dev

# production build
bun run build
```

Environment variables
The following are auto-managed by Lovable Cloud and live in `.env`:

```
VITE_SUPABASE_URL=
VITE_SUPABASE_PUBLISHABLE_KEY=
VITE_SUPABASE_PROJECT_ID=
```

Do not commit a service role key — it isn't required at runtime.

---

📁 Project structure

```
src/
├── assets/                  # hero image, static assets
├── components/
│   ├── ui/                  # shadcn primitives (button, input, dialog, ...)
│   ├── page-header.tsx      # reusable eyebrow + H1 header
│   ├── profile-dialog.tsx   # name / password / theme / view settings
│   ├── site-header.tsx
│   └── site-footer.tsx      # contains APP_VERSION
├── integrations/supabase/   # auto-generated — do not edit
├── lib/
│   └── languages.ts         # Google Translate language list + helpers
├── routes/
│   ├── __root.tsx           # root shell (fonts, providers, <Outlet />)
│   ├── index.tsx            # landing page
│   ├── demo.tsx             # public bilingual screener
│   ├── auth.tsx             # login + signup
│   ├── forms.$formId.tsx    # public form responder
│   └── _authenticated/
│       ├── route.tsx                       # auth gate
│       ├── dashboard.tsx
│       ├── forms.$formId.edit.tsx          # question builder
│       └── forms.$formId.responses.tsx     # creator response view
└── styles.css               # Tailwind v4 + design tokens
```

---

🗄️ Database schema

All tables live in `public` with RLS enabled.

- `forms` — `id`, `user_id`, `title`, `description`, `require_login`, `created_at`
- `questions` — `id`, `form_id`, `type` (`short` | `choice` | `rating`), `label`, `options jsonb`, `order`
- `responses` — `id`, `form_id`, `answers jsonb`, `submitted_at`
- `profiles` — `id`, `display_name`, `theme`, `forms_view` (auto-created via trigger on signup)
- `user_roles` + `has_role()` security-definer function (roles stored separately from profiles)

Row-Level Security highlights
- `forms`: owners can CRUD their own; public `SELECT` so shared links resolve.
- `questions`: public `SELECT` unless the parent form has `require_login = true`.
- `responses`: anonymous `INSERT` allowed only when the form is public; authenticated `INSERT` otherwise.
- All public-schema tables have explicit `GRANT`s to `anon` / `authenticated` / `service_role`.

---

🔐 Auth

- Email/password + Google OAuth via Lovable Cloud.
- Email auto-confirm is on for the demo (disable before going to production).
- Protected routes live under `src/routes/_authenticated/` and redirect unauthenticated visitors to `/auth`.

---

🌐 Routes

| Path | Public? | Description |
|---|---|---|
| `/` | ✅ | Landing page |
| `/demo` | ✅ | Bilingual demo screener |
| `/auth` | ✅ | Sign in / sign up |
| `/forms/:formId` | ✅ | Public form responder (unless `require_login`) |
| `/dashboard` | 🔒 | User's forms |
| `/forms/:formId/edit` | 🔒 (owner) | Question builder |
| `/forms/:formId/responses` | 🔒 (owner) | Submissions table |

---

⚠️ Important note

This tool does not determine EL/EB status. Official identification of an English Learner / Emergent Bilingual student requires the school's formal review process and, when applicable, a state-approved English language proficiency assessment. Home Language Screener only collects home language information and surfaces a next-step recommendation.

---

📦 Versioning

Versions follow `MM.DD.YYYY.iteration` (e.g. `06.24.2026.02`) and are displayed in the site footer (`src/components/site-footer.tsx`).

---
