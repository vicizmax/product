---
name: deepen-task
description: >-
  Rewrite a task for a deeper version of it, not a bigger one. Before rewriting it: (1) say what a top professional in this field would do here that I'm asking for; (2) name the rawest material they would start from instead of what has already been digested for me; (3) name the specific methods and tools they would use; (4) say what, other than you or me, would show the result is right. Then rewrite my prompt to ask for exactly that. Use when the
  user asks for a deeper version of a task or prompt, says "not a bigger
  one", "go deeper", "sharpen this prompt", "rewrite my prompt", or
  "/deepen-task".
user-invocable: true
---

# Deepen the task

The user wants a deeper version of this task, not a bigger one.

Take the task they name. If they name none, use the task already in the conversation. If more than one task is in play, ask which one.

In the four steps, "I" and "me" are the user. "You" is the agent.

Do the four steps in order. Then rewrite the prompt. Do not run the rewritten prompt unless they ask.

## Before rewriting

1. Say what a top professional in this field would do here that I'm asking for.
2. Name the rawest material they would start from instead of what has already been digested for me.
3. Name the specific methods and tools they would use.
4. Say what, other than you or me, would show the result is right.

## Then rewrite

Rewrite the prompt to ask for exactly that.

The rewrite keeps the same job. It does not add a second deliverable, a wider audience, or a neighboring project.

## Output

```
## What a top professional would do

## Raw material

## Methods and tools

## What shows it is right

## Rewritten prompt
```

The rewritten prompt is something the user can hand back and run. It names the raw material, the method, and the check from the four answers above.
