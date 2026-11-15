---
name: customer-call-prep
description: Generate structured pre-call briefs for external customer meetings as Word documents (.docx) saved to the team's briefs folder on Drive. Pulls from company knowledge, meeting transcripts, email, wiki, tickets, product analytics, and the data warehouse in parallel. Right-click a brief in Drive → "Open with Google Docs" to view as a polished editable Google Doc. Two modes — single-call (one brief, chat reply) and batch (all of a day's external calls, Slack DM summary). Use this skill whenever the user is preparing for ANY external customer call, interview, or touchpoint, OR asks to batch-prep multiple calls. Triggers include "prep me for my next call," "I have a call with [customer]," "brief me on [company]," "customer interview prep," "what do I need to know about [account]," "prep my calls for tomorrow," "batch prep," or any mention of an upcoming external meeting that needs context.
---
# Customer Call Prep
> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent warehouse SQL, health-signal thresholds, channel names, or Slack IDs that are not in the config.
Assemble structured pre-call briefs for external customer calls. Pull from multiple sources in parallel, generate a Word document (.docx), save to the team's "{{BRIEFS_FOLDER_NAME}}" Drive folder. Right-click → "Open with Google Docs" in Drive renders the brief as a polished editable Google Doc with proper headings, tables, lists, and formatting preserved.
## Config — fill in once
| Token | Replace with |
|---|---|
| `{{COMPANY_EMAIL_DOMAIN}}` | Your company's email domain, without `@`. Internal attendees are anyone at this domain. |
| `{{USER_EMAIL}}` | How to get the signed-in user's work email. Default: the email on the connected Slack or Google account. Fallback: `$USER@{{COMPANY_EMAIL_DOMAIN}}` when `$USER` is the mailbox local-part. |
| `{{BRIEFS_FOLDER_PATH}}` | Absolute local path of the shared briefs folder. |
| `{{BRIEFS_FOLDER_NAME}}` | Folder display name in Drive. |
| `{{SHARED_DRIVE_NAME}}` | Shared drive teammates must sync so the folder exists locally. |
| `{{PRIMARY_TZ}}` | IANA timezone queried from Calendar, e.g. `Europe/Zurich`. |
| `{{PRIMARY_TZ_LABEL}}` | Short label shown in Slack, e.g. `CET`. |
| `{{SECONDARY_TZ}}` | Second office IANA timezone. Delete the secondary timezone from Slack formats if you only need one. |
| `{{SECONDARY_TZ_LABEL}}` | Short label for the second office, e.g. `CT`. |
| `{{TZ_OFFSET_HOURS}}` | Whole hours the secondary clock is **behind** the primary. Confirm for both daylight and standard time; if the gap changes by date, branch on the date. If the secondary office is ahead, use a negative number and flip the sanity check in Step 1. |
| `{{SLACK_CHANNEL_ID}}` | Channel id for the batch summary post. |
| `{{SLACK_CHANNEL_NAME}}` | Channel name, e.g. `#call-briefs`. |
| `{{VOICE_RULES}}` | One line, or a pointer to the team's writing rules. |
| `{{KNOWN_SLACK_IDS}}` | Optional fallback map used only when email lookup fails. Format: `Name = UXXXX`. Leave empty to rely on lookup alone. |
| `{{DEAL_CHANNEL_PATTERNS}}` | Slack channel patterns for deal-close threads. |
| `{{SUPPORT_CHANNEL_PATTERNS}}` | Slack channel patterns for support escalations. |
| `{{ASK_CHANNEL_PATTERNS}}` | Slack channel patterns for internal ask / support channels. |
| `{{WIKI_SPACES}}` | Wiki spaces to prefer when searching, e.g. Research, CS, Support. |
| `{{OLDER_BRIEF_FORMAT}}` | Name of any older exporter whose files this skill should replace. Leave blank to skip replacement and only reuse matching `.docx` files. |
### Tool names — map your connected MCPs
Match tools by **name** from the connected tool list. Do not hardcode server UUIDs.
| Capability | `{{TOOL}}` to fill in | If missing |
|---|---|---|
| Calendar — list events | `{{CALENDAR_LIST_EVENTS}}` | Cannot identify calls. Stop and ask which customer. |
| Company knowledge search (CRM, account, broad context) | `{{KNOWLEDGE_SEARCH}}` | Commercial + contacts + broad-context sections empty |
| Meeting transcripts | `{{MEETINGS_SEARCH}}` and `{{MEETINGS_GET}}` | Past-call summaries empty |
| Email threads | `{{EMAIL_SEARCH}}` | Recent thread context empty |
| Wiki search | `{{WIKI_SEARCH}}` | Internal research empty |
| Issue tracker search | `{{ISSUES_SEARCH}}` | Tickets empty |
| Product analytics | `{{ANALYTICS_QUERY}}` | Behavioral / funnel metrics empty |
| Data warehouse | `{{WAREHOUSE_QUERY}}` | Product usage + health signals empty |
| Drive file search | `{{DRIVE_SEARCH}}` | Drive URL resolution falls back to filename-only |
| Slack — send message | `{{SLACK_SEND}}` | Cannot post DM / channel summary; chat reply still works |
| Slack — find user | `{{SLACK_FIND_USER}}` | Fall back to plain-text names, no `<@...>` mentions |
### Data queries — paste your SQL
Leave these empty until a teammate pastes the real queries. Do not invent tables or columns. Each query should say which columns the next query and the health signals read.
**Q1 — Account-level usage (fire first).** Must return the join key Q2 needs. Name that column `<account_key>` in the comment.
```sql
-- PASTE Q1 HERE
-- Returns: <account_key>, plus the usage columns your health signals read
-- Filter: customer name, domain, or account id matching <customer_keyword>
```
**Q2 — Child-account or workspace breakdown (fire when Q1 returns `<account_key>`).** Must return the join key Q3 needs. Name that column `<workspace_key>`.
```sql
-- PASTE Q2 HERE
-- Returns: <workspace_key>, plus per-workspace usage columns
-- Filter: <account_key> from Q1, latest snapshot only
```
**Q3 — Any breakdown that needs a workspace key (fire when Q2 returns `<workspace_key>`).** Delete Q3 if you don't need a third query.
```sql
-- PASTE Q3 HERE
-- Returns: the breakdown columns the brief should quote
-- Filter: <workspace_key> from Q2
```
**Name matching.** Try the variations that actually collide in your warehouse and CRM. Write them here:
- {{NAME_MATCH_RULES}}
**Data caveats — read before quoting numbers in the brief:**
- {{DATA_CAVEAT_1}}
- {{DATA_CAVEAT_2}}
- If a metric is missing, omit it. Do not estimate.
### Health signals — define yours
After the warehouse queries return, compute these and surface whichever apply at the top of the brief. Conditions must use columns those queries actually return. Delete this whole subsection if you have no usage warehouse.
| Signal | Condition | Frame as |
|---|---|---|
| {{SIGNAL_1_NAME}} | {{SIGNAL_1_CONDITION}} | {{SIGNAL_1_FRAME}} |
| {{SIGNAL_2_NAME}} | {{SIGNAL_2_CONDITION}} | {{SIGNAL_2_FRAME}} |
Plain-language framing in the brief: name the business meaning, not the column. Shape: "Usage at 92% of the contracted plan — expansion conversation" rather than a raw ratio.
## Tone & kickoff
- **State the target day in the first user-facing message** so the user can correct early. Example: `Briefing for Mon, Jun 1 — pulling calendar...`
- **Narrate as little as possible.** The DOCX brief and the Slack post are the deliverable; the chat reply is a confirmation line. Don't liveblog every fan-out tool call.
- **Don't ask permission for each step.** The user invoked the skill — they want the briefs, not a status meeting. The only legitimate questions are mode disambiguation (Step 1) and stop-on-error reports.
## Modes
| Mode | Trigger | Output | Chat / Slack |
|---|---|---|---|
| **single-call** | Explicit single-call phrasing — "prep me for my 3pm", "brief me on Acme", "I have a call with X", "what do I need to know about [account]", any **named-customer** request | 1 DOCX | Chat reply with file path + 2-3 standout findings |
| **batch** | Any **plural-implying** call phrasing — "prep my calls for tomorrow", "prep tomorrow's calls", "prep today's calls", "prep today's remaining calls", "prep my remaining calls", "batch prep", "my calls", OR invoked by the `batch-call-prep` scheduled task | N DOCXs (one per external call) | Slack DM + channel post + per-attendee DMs |
**Mode is determined by wording, not by how many calls are found.**
- If batch wording is used but only **1 call** matches → **still run the batch flow** (DM + channel post + per-attendee DMs), just with one bullet. Do not silently downgrade to single-call.
- If batch wording is used but **0 calls** match → post the short "no external calls" DM and stop.
- If trigger is genuinely ambiguous (e.g. "prep my call" — singular but unspecified) → default to single-call mode and ask "is this for tomorrow's calls (batch) or just one call (single)?".
**Why this matters:** a teammate asking "prep today's remaining calls" expects their internal co-attendees to get pinged. Treating it as single-call because only one call remains breaks that contract — the teammate gets a brief, but their co-attendees don't know one exists.
## Scheduling — running this daily
**Installing this skill does not make it run automatically.** A skill is a passive set of instructions — it only fires when someone (or a scheduled task) invokes it with matching trigger wording. To get a daily morning brief in Slack, set up a recurring scheduled task **once per user**. Scheduled tasks are per-user; there's no team-wide install.
Two ways to wire it up — pick one:
### Option A — Desktop UI (no MCP required)
1. Open the desktop app → click the clock icon in the chat input toolbar (or `Settings → Scheduled tasks`).
2. **New task.** Configure:
   - **Prompt:** `prep tomorrow's calls`
   - **Schedule:** Mon–Fri at the time you want the brief delivered (e.g. `21:00 Sun–Thu` for night-before, or `07:00 Mon–Fri` for morning-of)
   - **Name:** `Customer call prep — daily batch`
3. Save. The app runs the task at the scheduled time, the skill picks up the batch trigger, and the brief lands in your Slack DM.
### Option B — Programmatic via the scheduled-tasks MCP
If a scheduled-tasks MCP is connected, ask in chat:
```
Create a recurring scheduled task: run "prep tomorrow's calls" every weekday at 21:00 local time. Name it "Customer call prep — daily batch".
```
Verify by listing scheduled tasks.
### Tuning the schedule
| Time | Why |
|---|---|
| **Night before, 21:00** | Brief is waiting when you start your day. Slight risk: calendar changes overnight aren't reflected |
| **Morning of, 06:30–07:30** | Latest calendar state; takes a few minutes to run, so leave buffer before your first meeting |
| **Both** | Run twice. The skill's dedup logic (Step 1.5) reuses existing briefs and won't regenerate from scratch |
A separate personal-rhythm installer (morning brief, end-of-day sweep) does not wire up call prep unless you add it there.
### Caveat — Slack notifications on the recipient end
Even with the schedule running, **self-DMs in Slack don't fire push/banner notifications** (covered in Step 5c). The brief lands in your "you to you" sidebar entry. Channel posts (Step 5d) DO notify the @-mentioned internal attendees normally. If you want a louder personal alert for yourself, consider posting to your own DM channel instead of self-DM, or rely on the channel @-mention if you're listed as an internal attendee.
## Step 0 — Resolve user and paths
Resolve the signed-in user via `{{USER_EMAIL}}`. Derive:
- `firstname` = the mailbox local-part before the first `.` or `_` (display only)
- `output_dir` = `{{BRIEFS_FOLDER_PATH}}`
- `skill_dir` = the directory containing **this** SKILL.md file (the customer-call-prep skill folder)
- `helper_script` = `<skill_dir>/call-prep-to-docx.py`
Verify `<output_dir>` exists — it's the team-shared "{{BRIEFS_FOLDER_NAME}}" folder on the `{{SHARED_DRIVE_NAME}}` shared drive, which is the canonical location for briefs. If the folder doesn't exist locally, the user hasn't added the `{{SHARED_DRIVE_NAME}}` shared drive to their Google Drive sync list. **Stop and ask them to sync it** ("Open Google Drive → Shared drives → right-click `{{SHARED_DRIVE_NAME}}` → Add to My Drive / sync"). Do not write briefs to any other location — the shared folder is where teammates expect to find them.
**Helper-script existence check (CRITICAL — prevents broken DOCX uploads):**
Verify `<helper_script>` exists:
