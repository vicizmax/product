---
name: triage-feedback
description: >-
  Draft a triage review for an internal Slack feedback submission. Check Jira
  and the same Slack channel for duplicates. Use when the user asks to triage
  feedback, review a feedback channel or list, draft a reply to someone who
  filed feedback, or work the feedback queue. Triggers include "triage
  feedback", "review this feedback", "draft a response to this submission",
  and a link to a #feedback- channel or a Slack list record. Does not create
  Jira tickets and does not post to Slack unless the user explicitly says to
  post.
---

# Triage feedback

Draft a review of one Slack feedback submission. The list is the record. Jira is only for work the squad has accepted. This skill stops before either write.

## Defaults

- Pilot channel: `#feedback-mmf-6129-sqc-cancellation-flows` (`C0C94UNQYU8`)
- Form bot: `Feedback form Cancellations`
- List: `F0C839C3QGK` (Feedback tracker for MMF-6129)
- Accepted work goes in project GROW. One Epic per Initiative, summary exactly `Slack feedback for <MMF-KEY>`, parented to the Initiative in the channel name. Find that Epic by exact summary before creating another. Each accepted item is a Feature under that Epic. Set Eng Epic Type to Maintenance on the Epic. Do not file under the delivery epic.
- Reply promise once a person decides: 2 business days, in the thread.
- Show the draft in chat. Post it only when the user says to post.

## Do not

- Invent Feedback, Details, Type, Severity, or a recommendation when those fields were not read.
- Create or edit a Jira issue.
- Post or schedule a Slack message unless the user explicitly says to post. The shipped and cancelled replies in "After the pull request" are the exception: post those once, when the outcome is true and the thread does not already say it.
- Treat an emoji reaction as a decision.
- Copy `Opt…` values into the draft. Those are internal ids, not labels.
- Read or post in `#feedback-mmf-6129-testing`. That channel is archived.

## Steps

1. **Pick the item.** Use the link or message the user gave. If they said "the latest", read the pilot channel and take the newest post from the form bot.
2. **Read the Slack post and its thread.** Note the submitter, the message timestamp, and any replies already there.
3. **Read the submission fields.** The channel post is often only "@person filed feedback" plus a list URL. The writeup, Type, and Severity are on that list row.
   - Parse `list_id` (`F…`) and `record_id` (`Rec…`) from the URL.
   - Use whatever Slack read returns for the list row (message attachments, unfurl, or a list-item read).
   - If the only text is the one-line "filed feedback" post, stop after the header and write **Card not readable**. Do not guess the fields from the channel name or from MMF-6129.
4. **Check duplicates** only when step 3 produced a summary. Search Jira for that summary. Search the same Slack channel for an earlier form post about the same problem. Report a link or "none found" for each. If the card was not readable, write **Duplicate check skipped**.
5. **Recommend** one of: accept, won't do, needs info. One sentence on why. Name the gap. Do not restate the feedback text.
6. **Write one reply the submitter will read.** The channel post already shows Type, Severity, and the writeup. Do not repeat those fields. Do not add a separate "note to send." The recommendation block is for the squad. The last line is for the submitter: @ them there only, and speak to them as "you."
   - **accept:** read `mmf-` plus digits from the channel name and turn that into the Initiative key. In GROW, search for an Epic whose summary is exactly `Slack feedback for <that key>`. Reuse it. If none exists, create that Epic in GROW, parent it to the Initiative, and set Eng Epic Type to Maintenance. Then create one Feature under that Epic. Summary is the feedback title. Description includes the details, type, severity, and the Slack thread link. If creation fails, stop and say the ticket was not created. Do not say we are taking it. On success, the Jira line is that Feature, never "none found". The last line says we are taking it and includes the issue key. No date unless one was given. Do not create a second Feature if this thread already has one. Do not file under the delivery epic.
   - **won't do:** do not create an issue. The last line is the reason.
   - **needs info:** do not create an issue. The last line is one specific question, with a question emoji. If a screenshot is attached and does not show the problem, say so.

## Draft

```
Recommendation: <accept | won't do | needs info> — <why>
Jira: <new issue link on accept, or none found>
Earlier in this channel: <link or none found>

<❓ only when asking a question> @<submitter> <one or two sentences>
```

If the card was not readable, the reply is only: the submission was not readable. No recommendation.

## After a decision

A human reply in the feedback thread is a decision. Do not ignore it.

- **accept:** reuse or create the GROW Epic `Slack feedback for <MMF-KEY>` as in step 6, then create one Feature under it. Reply in the thread with that Feature link, @ the submitter, and say we are taking it. If creation fails, say the ticket was not created and do not say we are taking it. No date unless one was given. Do not create a second Feature if that thread already has one.
- **won't do:** do not create an issue. Reply in the thread with the reason, @ the submitter.
- **needs info:** do not create an issue. Reply in the thread with one question, a question emoji, and @ the submitter.

## After the pull request

A Feature from this channel can be implemented or cancelled with no note in the original thread. Check that before treating the item as done.

For each Feature under `Slack feedback for <MMF-KEY>` that links a pull request, read the thread linked from the ticket.

- **Merged:** if the thread does not already say it shipped, reply once. @ the submitter, say it shipped, and include the pull request link.
- **Closed without merge, or the Feature is cancelled:** if the thread does not already say it was cancelled, reply once. @ the submitter, say it was cancelled, and include the reason when the ticket or the pull request states one.

One reply per outcome. Do not post a second update for the same result.
