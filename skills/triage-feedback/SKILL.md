---
name: triage-feedback
description: >-
  Draft a triage review for an internal Slack feedback submission. Check the
  issue tracker and the same Slack channel for duplicates. Use when the user
  asks to triage feedback, review a feedback channel or list, draft a reply
  to someone who filed feedback, or work the feedback queue. Triggers include
  "triage feedback", "review this feedback", "draft a response to this
  submission", and a link to the feedback channel or a Slack list record.
  Show the draft in chat. Create an issue only on accept. Post to Slack only
  when the user says to post, except the shipped and cancelled replies.
---
# Triage feedback
> **Template.** Fill in every `{{TOKEN}}` in the config block before installing this skill. Leave runtime values in `<angle brackets>` alone — the agent resolves those on each run. Do not invent list fields, a channel, a parent key, or an issue type that is not in the config.
>
> If accepted feedback is filed in the same project as delivery work, reuse `{{EPIC_PROJECT}}` and `{{EPIC_TYPE_FIELD}}` from the refine template. `{{FEEDBACK_ISSUE_TYPE}}` and `{{FEEDBACK_EPIC_TYPE}}` are for this queue. They are not the delivery epic's type.
Draft a review of one Slack feedback submission. The list is the record. `{{ISSUE_TRACKER}}` is only for work the squad has accepted.
## Config — fill in once
| Token | Replace with |
|---|---|
| `{{FEEDBACK_CHANNEL_NAME}}` | Pilot channel name. |
| `{{FEEDBACK_CHANNEL_ID}}` | Channel id. |
| `{{DO_NOT_READ_CHANNELS}}` | Channels to never read or post in (archived, test). Leave blank if none. |
| `{{FORM_BOT_NAME}}` | Name of the bot that posts a submission. |
| `{{LIST_ID}}` | Slack list id for this tracker. |
| `{{LIST_NAME}}` | List name, for people reading the config. |
| `{{FIELD_TITLE}}` | List column for the title. |
| `{{FIELD_DETAILS}}` | List column for the writeup. |
| `{{FIELD_TYPE}}` | List column for the type. |
| `{{FIELD_SEVERITY}}` | List column for the severity. |
| `{{ISSUE_TRACKER}}` | Tracker to search, and to write on accept. |
| `{{EPIC_PROJECT}}` | Project accepted feedback is filed in. |
| `{{PARENT_KEY_RULE}}` | How to read the parent issue key from the channel name. |
| `{{FEEDBACK_EPIC_SUMMARY}}` | Exact epic summary. Include the parent key. One epic per parent. |
| `{{EPIC_TYPE_FIELD}}` | Field that records the epic type. Leave blank to skip. |
| `{{FEEDBACK_EPIC_TYPE}}` | Value to set on that field for the feedback epic. |
| `{{FEEDBACK_ISSUE_TYPE}}` | Issue type for one accepted item, created under the feedback epic. |
| `{{REPLY_PROMISE}}` | What you promise once a person decides, and where (for example a number of business days, in the thread). |
| `{{INTERNAL_ID_HINT}}` | Raw option ids to never copy into the draft. Use the label instead. |
## Defaults
- Pilot channel: `{{FEEDBACK_CHANNEL_NAME}}` (`{{FEEDBACK_CHANNEL_ID}}`)
- Form bot: `{{FORM_BOT_NAME}}`
- List: `{{LIST_ID}}` (`{{LIST_NAME}}`)
- Accepted work goes in `{{EPIC_PROJECT}}`. One epic per parent issue, summary exactly `{{FEEDBACK_EPIC_SUMMARY}}`, parented to the issue from `{{PARENT_KEY_RULE}}`. Find that epic by exact summary before creating another. Each accepted item is a `{{FEEDBACK_ISSUE_TYPE}}` under that epic. Set `{{EPIC_TYPE_FIELD}}` to `{{FEEDBACK_EPIC_TYPE}}` on the epic when both tokens are set. Do not file under the delivery epic.
- Reply promise once a person decides: `{{REPLY_PROMISE}}`
- Show the draft in chat. Post it only when the user says to post.
## Do not
- Invent `{{FIELD_TITLE}}`, `{{FIELD_DETAILS}}`, `{{FIELD_TYPE}}`, `{{FIELD_SEVERITY}}`, or a recommendation when those fields were not read.
- Create or edit an issue except the accept path in step 6 and in "After a decision".
- Post or schedule a Slack message unless the user explicitly says to post. The shipped and cancelled replies in "After the pull request" are the exception: post those once, when the outcome is true and the thread does not already say it.
- Treat an emoji reaction as a decision.
- Copy `{{INTERNAL_ID_HINT}}` into the draft. Those are internal ids, not labels.
- Read or post in `{{DO_NOT_READ_CHANNELS}}` when that token is set.
- Guess card fields from the channel name or from the parent key.
- Fill a `{{TOKEN}}` from memory of another team's channel, list, or project.
## Steps
1. **Pick the item.** Use the link or message the user gave. If they said "the latest", read `{{FEEDBACK_CHANNEL_NAME}}` and take the newest post from `{{FORM_BOT_NAME}}`.
2. **Read the Slack post and its thread.** Note the submitter, the message timestamp, and any replies already there.
3. **Read the submission fields.** The channel post is often only "@person filed feedback" plus a list URL. The writeup, `{{FIELD_TYPE}}`, and `{{FIELD_SEVERITY}}` are on that list row.
   - Parse `list_id` and `record_id` from the URL.
   - Use whatever Slack read returns for the list row (message attachments, unfurl, or a list-item read).
   - If the only text is the one-line "filed feedback" post, stop after the header and write **Card not readable**. Do not guess the fields.
4. **Check duplicates** only when step 3 produced a summary. Search `{{ISSUE_TRACKER}}` for that summary. Search the same Slack channel for an earlier form post about the same problem. Report a link or "none found" for each. If the card was not readable, write **Duplicate check skipped**.
5. **Recommend** one of: accept, won't do, needs info. One sentence on why. Name the gap. Do not restate the feedback text.
6. **Write one reply the submitter will read.** The channel post already shows `{{FIELD_TYPE}}`, `{{FIELD_SEVERITY}}`, and the writeup. Do not repeat those fields. Do not add a separate "note to send." The recommendation block is for the squad. The last line is for the submitter: @ them there only, and speak to them as "you."
   - **accept:** derive the parent key with `{{PARENT_KEY_RULE}}`. In `{{EPIC_PROJECT}}`, search for an epic whose summary is exactly `{{FEEDBACK_EPIC_SUMMARY}}`. Reuse it. If none exists, create that epic in `{{EPIC_PROJECT}}`, parent it to that issue, and set `{{EPIC_TYPE_FIELD}}` to `{{FEEDBACK_EPIC_TYPE}}` when both are set. Then create one `{{FEEDBACK_ISSUE_TYPE}}` under that epic. Summary is the feedback title. Description includes the details, type, severity, and the Slack thread link. If creation fails, stop and say the ticket was not created. Do not say we are taking it. On success, the tracker line is that issue, never "none found". The last line says we are taking it and includes the issue key. No date unless one was given. Do not create a second issue of that type if this thread already has one. Do not file under the delivery epic.
   - **won't do:** do not create an issue. The last line is the reason.
   - **needs info:** do not create an issue. The last line is one specific question, with a question emoji. If a screenshot is attached and does not show the problem, say so.
## Draft
```
Recommendation: <accept | won't do | needs info> — <why>
{{ISSUE_TRACKER}}: <new issue link on accept, or none found>
Earlier in this channel: <link or none found>
<question emoji only when asking a question> @<submitter> <one or two sentences>
```
If the card was not readable, the reply is only: the submission was not readable. No recommendation.
## After a decision
A human reply in the feedback thread is a decision. Do not ignore it.
- **accept:** reuse or create the epic `{{FEEDBACK_EPIC_SUMMARY}}` as in step 6, then create one `{{FEEDBACK_ISSUE_TYPE}}` under it. Reply in the thread with that issue link, @ the submitter, and say we are taking it. If creation fails, say the ticket was not created and do not say we are taking it. No date unless one was given. Do not create a second issue of that type if that thread already has one.
- **won't do:** do not create an issue. Reply in the thread with the reason, @ the submitter.
- **needs info:** do not create an issue. Reply in the thread with one question, a question emoji, and @ the submitter.
## After the pull request
A `{{FEEDBACK_ISSUE_TYPE}}` from this channel can be implemented or cancelled with no note in the original thread. Check that before treating the item as done.
For each `{{FEEDBACK_ISSUE_TYPE}}` under `{{FEEDBACK_EPIC_SUMMARY}}` that links a pull request, read the thread linked from the ticket.
- **Merged:** if the thread does not already say it shipped, reply once. @ the submitter, say it shipped, and include the pull request link.
- **Closed without merge, or the issue is cancelled:** if the thread does not already say it was cancelled, reply once. @ the submitter, say it was cancelled, and include the reason when the ticket or the pull request states one.
One reply per outcome. Do not post a second update for the same result.
## Edge cases
- **Unfilled tokens:** if a `{{TOKEN}}` is still literal when the skill runs, stop and name the token. Do not guess a channel, a list, or a project.
- **Card not readable:** header only. No recommendation and no duplicate search.
