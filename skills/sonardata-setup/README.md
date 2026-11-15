# sonardata-setup

Diagnoses your Claude Code environment for Sonar data work. Runs ~12 parallel checks, writes a color-coded HTML report to `~/Desktop/sonardata-setup.html`, and opens it automatically. Every issue in the report has a copy button with the exact fix command.

## What it checks

- **Env var access** — Portkey/Anthropic API key, JFrog token, AWS profile (checked across shell profile, active process, and `settings.json` env block)
- **System tools** — Java 21+, Python3, pip3, uvx, Node.js 18+, npm/npx, AWS CLI
- **AWS SSO** — session validity for the `sonarcloud-prod` profile
- **MCP servers** — SonarData, Glean, Atlan, Mixpanel (configuration check + live connectivity test)

## Prerequisites

- Claude Code (CLI or Desktop — both work)
- AWS SSO profile `sonarcloud-prod` configured (`aws configure sso --profile sonarcloud-prod`)
- Portkey API key set in your shell profile, `~/.claude/settings.json` env block, or via `launchctl setenv`

## Install

Both Claude Code CLI and Desktop read from `~/.claude/skills/`, so the install is the same for both.

**Option 1 — curl:**

```bash
mkdir -p ~/.claude/skills/sonardata-setup
read -rs GITHUB_PAT
curl -H "Authorization: token $GITHUB_PAT" \
  -o ~/.claude/skills/sonardata-setup/SKILL.md \
  "https://raw.githubusercontent.com/SonarSource/augmented-product-craft/master/share/shubham.mehrotra/skills/sonardata-setup/SKILL.md"
```

`read -rs` prompts for your GitHub personal access token without echoing it and without writing it to shell history. The token needs `repo` scope. If the repo is public, drop the `read` line and the `-H "Authorization: ..."` flag entirely.

**Option 2 — copy from local clone:**

```bash
mkdir -p ~/.claude/skills/sonardata-setup
cp path/to/augmented-product-craft/share/shubham.mehrotra/skills/sonardata-setup/SKILL.md \
   ~/.claude/skills/sonardata-setup/SKILL.md
```

## Usage

Restart Claude Code after install (or start a new session), then type:

```
/sonardata-setup
```

The report opens in your browser within ~30 seconds.
