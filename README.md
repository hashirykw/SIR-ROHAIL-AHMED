# Sir Rohail Ahmed · Accounting website

A multi-page site for Sir Rohail Ahmed: Cambridge O Level Accounting 7707 and AS & A Level Accounting 9706, Karachi and online. Every page is one self-contained HTML file in one flat folder. The only shared file is `config.js`, which holds the settings.

## Files

| File | What it is |
|---|---|
| `index.html` | Home: hero with portrait and the 3D particle T-account, his record as a general journal, the two courses as T-accounts, the Oct/Nov 2026 recorded workshop, the pinned "one transaction, five stops" walk-through, the live accounting-equation balance, the syllabus as a chart of accounts, study tools, a full past-paper solution video, where he teaches, interview quotes |
| `courses.html` | 7707 and 9706 paper by paper (time, marks, weighting, question types), AO weightings, assessment routes, what changes in the 2027 O Level syllabus, the workshop, how classes run, Cambridge command words |
| `syllabus.html` | All 44 topics (27 for 7707, 17 for 9706) with key points, terms, formulae and 2027 notes; a tracker (to do / revising / confident) that feeds the portal; the ratio formula sheet; the accounting concepts; a glossary of 95 terms |
| `past-papers.html` | 7707 (2020–2026) and 9706 (2023–2026) question papers, mark schemes, examiner reports and grade thresholds; score tracker with trend chart; exam timer with focus mode |
| `lab.html` | Accounting Lab: double-entry trainer, depreciation and disposal, bank reconciliation, ratio analyser (O, AS and A Level formula sets), FIFO/AVCO, break-even chart, standard costing variances, NPV/IRR/payback/ARR, partnership appropriation, a 38-question MCQ drill, flashcards |
| `portal.html` | Student portal: sign in with a student ID and access code; lectures by syllabus topic, workshop recordings, announcements, marks with a trend chart; plus a study desk that gathers the visitor's own progress from the whole site |
| `admin.html` | Admin panel: issue student IDs and access codes, reset codes and devices, add lectures, post announcements, record marks, handle enrolments |
| `about.html` | His story, method, where he teaches, interview quotes, social links |
| `contact.html` | Enrolment form that opens a ready-written WhatsApp message, contact details, FAQ |
| `404.html` | Not-found page |
| `config.js` | **The only file you edit**: WhatsApp number, social links, Supabase keys, portal preview switch, real results and reviews |
| `backend.sql` | Supabase database for the portal and admin panel |
| `rohail-ahmed.webp` | Portrait cutout (transparent background) |
| `rohail-ahmed.jpg` | Share image for WhatsApp and social previews (1200 × 630) |
| `apple-touch-icon.png` | Home-screen icon |
| `vercel.json`, `robots.txt`, `sitemap.xml` | Hosting and search files |

## Confirm with Sir Rohail before launch

Everything on the site comes from a public source. Nothing is estimated. These are the points to check:

1. **WhatsApp 0306 0233883.** Taken from his YouTube video description ("WhatsApp/Call for Enrollment"). Change it in `config.js`.
2. **"20+ years".** His website says he has taught "for more than twenty years". One YouTube description (April 2026) says 16 years. The site uses 20+.
3. **Credo.** Founding member and Director of the Credo School & College System (Credo's pages and a Credo post); "founder of Credo College" (his own website). Address used: E-136–141, Block 7, Gulshan-e-Iqbal, from Credo College's site.
4. **Cambridge Online (SWK Solutions).** From the Cambridge Online faculty profile.
5. **The Professionals Core.** From a Facebook video on The Professionals Core's page that appears under his name. Remove the line in `about.html` if he no longer teaches there.
6. **Interview quotes.** From "Rohail Ahmed | Interview" on timesofyouth.com. Confirm it is him.
7. **Recorded Workshop, Oct/Nov 2026, O Level, AS and A2.** From his Instagram. Fees are not shown anywhere; every fee question goes to WhatsApp.
8. **Portrait.** The cutout comes from the Cambridge Online portrait. A higher-resolution photo with a plain background will look sharper.
9. **Video.** The home page plays his own YouTube video "O Level Accounting 7707 | Full Solution | May/June 2022 v22". Change `featuredVideo` in `config.js` to feature another.
10. **Domain.** `sitemap.xml`, `robots.txt` and each page's `<head>` use `https://sir-rohail-ahmed.vercel.app`. Find and replace it if you use another domain.

Results and student reviews sections stay hidden until real ones are added to `RESULTS` and `REVIEWS` in `config.js`.

## The portal

Out of the box `PORTAL_PREVIEW: true` lets you demo the portal and admin panel with sample data kept only in that browser; every preview screen says so. To go live:

1. supabase.com → New project (Singapore or Mumbai).
2. SQL Editor → paste all of `backend.sql` → Run.
3. Authentication → Users → Add user (admin email + password). Put the same email in the `>>> ADMIN EMAIL <<<` line of `backend.sql` and run it again.
4. Project Settings → API → copy the Project URL and the anon / publishable key into `config.js` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`). Never the service_role key.
5. Set `PORTAL_PREVIEW: false`.

Then from `/admin`: issue each student an ID (RA-1001, RA-1002, …) and a code, which you can send straight to their WhatsApp. One ID works on two devices; reset devices from the panel. Lectures take a YouTube link (unlisted works) or an .mp4 link, plus an optional notes PDF. The enrolment form also saves each enquiry to the Enrolments tab once Supabase is connected.

## Notes on content

- Syllabus content is summarised in our own words from Cambridge International's published syllabuses. Ratio formulae and command-word definitions follow Cambridge's wording.
- The MCQ drill questions, double-entry transactions and the worked example (Example Traders, Zara Stores) were written for this site and are labelled as such.
- Past papers open from PapaCambridge's public archive (© UCLES). Years are limited to the current paper format so durations and marks are right for every listed year.
- Visitor progress (syllabus ticks, paper scores, Lab streaks, drill results, theme, sound) is saved in the visitor's browser only.

## Features

- Three.js particle field (15,000 points on desktop, 6,500 on phones) that morphs between accounting forms as you scroll: T-account, A = L + E, a balance, the accounting cycle, an invoice, a ruled ledger sheet, bar charts, coin stacks, a globe. Points part around the cursor and pulse on correct answers. Quality drops automatically on slow devices; it switches off with reduced motion.
- Lenis smooth scroll, GSAP ScrollTrigger (pinned five-stop walk-through), word-by-word heading reveals, 3D tilt cards with light sheen, magnetic buttons, custom cursor, view transitions between pages.
- Light ("ledger paper") and dark themes; sound effects with an on/off switch; ⌘K / "/" command palette for pages, all 44 topics, Lab tools and timers.
- "Ask the Ledger" help bot: fees, timings, workshop, campuses, paper lengths, any ratio formula, any syllabus topic or term, and a WhatsApp hand-off with the question pre-filled.

## Deploy

Upload every file to the root of a GitHub repo and import it on Vercel (Framework preset: Other, no build command). `vercel.json` turns on clean URLs (`/lab` serves `lab.html`).

## Sources

- Cambridge O Level Accounting 7707 syllabus 2026: https://www.cambridgeinternational.org/Images/697340-2026-syllabus.pdf
- Cambridge O Level Accounting 7707 syllabus 2027–2029: https://www.cambridgeinternational.org/Images/718213-2027-2029-syllabus.pdf
- Cambridge O Level Accounting 7707 syllabus 2023–2025: https://www.cambridgeinternational.org/Images/597278-2023-2025-syllabus.pdf
- Cambridge International AS & A Level Accounting 9706 syllabus 2026–2028: https://www.cambridgeinternational.org/Images/697417-2026-2028-syllabus.pdf
- Cambridge International AS & A Level Accounting 9706 syllabus 2029: https://www.cambridgeinternational.org/Images/764396-2029-syllabus.pdf
- His website: https://www.rohailahmed.com
- Credo College, About: https://college.credo.edu.pk/about/
- Credo School, About: https://school.credo.edu.pk/about-us/
- YouTube, Class of Rohail Ahmed: https://www.youtube.com/@AccountingbySirRohail
- Featured video: https://www.youtube.com/watch?v=NVXNyyYHC3o
- Times of Youth interview: https://timesofyouth.com/rohail-ahmed-interview/
- Facebook: https://www.facebook.com/SirRohailAhmed/ · Instagram: https://www.instagram.com/rohailahmed12/ and https://www.instagram.com/classofrohailahmed/

Website by Nexlyr Solutions.
