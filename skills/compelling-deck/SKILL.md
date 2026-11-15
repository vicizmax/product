---
name: compelling-deck
description: Turns any topic into a persuasive, audience-centred slide deck on the <specify template>, using a proven arc of hook, agenda, objective and "what's in it for you", then the core content, then a close built on one key takeaway, objection handling and a restated payoff. Use whenever someone wants a presentation, talk, deck or slides that need to land, convince or engage, e.g. "make a deck on X", "I need slides to present Y to the leadership team", "build me a talk about Z", "turn this topic into a compelling presentation", "help me pitch this idea internally", even if they don't say "compelling". Not for customer sales pitches to a named account (use sonar-customer-pitch-deck) or for simply rebranding an existing deck (use sonar-deck-builder directly).
---

# Compelling Deck

Build a deck that changes what the audience thinks or does, not one that just lists information. Every deck follows the same arc, because it mirrors how people decide whether to pay attention: *why should I care → what will I get → show me → what do I do with this → what about my doubts → remind me why it matters to me.*

The finished deck is built on the <specify template> with the <deck building> skill. This skill owns the story and content; the deck builder owns layouts and branding.

## Step 1: Get the brief, asking only what you must

Read the request (and any files or links) first and infer as much as you can. Only ask about things that are both missing and would materially change the deck. Asking too much is a failure mode here: the user wants a collaborator, not a form.

What you need:

| Item | Why it matters | Usually inferable? |
|---|---|---|
| **Topic** | The subject | Always given |
| **Audience** | Drives the hook, language, WIIFM and objections. The single most important input. | Often (e.g. "for the exec team") |
| **Desired outcome** | What the audience should think, feel or do afterwards. The key takeaway is built from this. | Sometimes |
| **Content source** | See below. Always confirm unless the user already said. | Rarely |
| **Presenter credibility** | Decides whether an intro slide is needed | Sometimes |
| **Length** | Talk time or slide count | Default: ~20 min, 10–15 slides |

**Content source** is always the user's call, so ask it each time unless they've already told you. Offer these options:
- Research (web search, plus internal sources available in the session such as Google Drive, Confluence, Slack or Glean)
- Only material they provide (notes, files, links) plus general knowledge
- Both

Batch every question into a single AskUserQuestion call (at most four questions, with sensible options and a recommended default first). If the only gap is the content source, ask just that. Never ask about anything you can reasonably default; state the defaults you picked instead.

## Step 2: Find the story before writing slides

Work this out before touching the outline. A deck with a muddy core message can't be rescued by good slides.

1. **Key takeaway**: one sentence the audience should remember if they forget everything else. Make it specific and arguable ("Moving code review left cuts our release delays in half"), not a topic label ("Code review best practices").
2. **WIIFM (what's in it for me)**: the concrete benefit to *this* audience in their terms: time, money, risk, career, less pain, a goal they already have. Different audiences get different WIIFMs for the same topic.
3. **Tension**: the gap between where the audience is now and where they could be. This powers the hook and keeps the middle section moving.
4. **Likely objections**: 2–4 genuine doubts this audience would raise (cost, effort, "we tried this", "not my priority", risk, credibility of the data). Think from their seat, not yours.
5. **Credibility check**: does the audience already know and trust the presenter on this topic? If yes, skip the intro. Include it only if they don't know the presenter, or if the topic needs authority the presenter has and the audience may not assume.

## Step 3: Gather the content

Follow the source the user chose. When researching, prefer recent, specific, citable evidence: numbers, named examples, short stories, quotes. One strong proof point beats five vague ones. Put sources in the speaker notes, not on the slides.

If research turns up something that contradicts the user's intended takeaway, tell them rather than quietly steering around it.

## Step 4: Write the outline

Use this structure. Slide titles are **action titles**: full-sentence headlines that state the slide's point, so reading the titles alone tells the whole story.

### Opening
1. **Hook**: earns attention in the first 30 seconds. Pick what fits the audience: a surprising stat, a provocative question, a short story, a bold claim, or a "what if". It should open the tension from Step 2. Never open with the agenda or the presenter's bio.
2. **Agenda**: 3–5 items, each phrased as something the audience gets or cares about, not as internal section names. Not "Background / Data / Recommendations" but "Why release delays keep happening / What the fastest teams do differently / What it takes for us to get there".
3. **Objective + WIIFM**: what we're here to achieve together and, explicitly, what's in it for them.
4. **Why listen to me** *(optional, only if Step 2 says so)*: one slide, framed around relevance to them ("I've run this rollout at three teams like yours"), not a CV.

### Core content
One slide per idea, following the agenda order. Each section should move the audience along the tension toward the takeaway. Guidelines:
- One message per slide; the title says it, the body proves it.
- Evidence over assertion: a chart, example, number or quote on most slides.
- Keep text light: roughly 3 bullets or fewer, or a visual. Detail belongs in speaker notes.
- Speak in the audience's language and keep tying back to their WIIFM.
- Vary the rhythm (data slide, story slide, comparison, single big statement) so it doesn't feel like a wall of bullets.

### Close
1. **Key takeaway**: the single sentence from Step 2, alone or nearly alone on the slide.
2. **Objection handling**: address the 2–4 likely objections head on. Frame each as "You might be thinking…" followed by a short, evidence-backed answer. Use one slide for all of them, or one per objection if they're weighty. Raising objections before the audience does builds trust.
3. **Takeaway restated as WIIFM**: the same core message, now framed as the payoff for them, plus a clear next step or call to action where it fits.

Write speaker notes for every slide: what to say, the transition to the next slide, and sources.

## Step 5: Build the deck

Hand the outline (titles, body content, visual suggestions, speaker notes) to the `sonar-marketing:sonar-deck-builder` skill and follow its instructions to produce the .pptx. Let it choose layouts from its catalog; suggest a layout type when a slide clearly needs one (big statement, chart, comparison, quote).

Don't stop to get the outline approved unless the brief was thin or the stakes are clearly high. Build it, then invite changes.

## Step 6: Deliver

Present the .pptx and, in a few lines, give:
- The key takeaway and the WIIFM you built around
- Any defaults you assumed (audience, length) and the objections you chose to address
- An offer to adjust the tone, cut to a shorter version, or swap the hook

## Quality check before delivering

- Read only the slide titles in order: do they tell the full story on their own?
- Is the hook about the audience's world, not the presenter's?
- Does every agenda item say why the audience should care?
- Does the close land on one takeaway, not three?
- Are the objections ones this audience would really raise?
- Does the final slide say what's in it for them, in their words?
