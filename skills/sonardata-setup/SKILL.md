---
name: sonardata-setup
description: Diagnoses and configures the Sonar data analysis stack for Claude Code — checks system tools (Java, Python, uvx, AWS CLI), MCP servers (SonarData, Glean, Atlan, Mixpanel), AWS/Redshift access, and Portkey API key. Runs parallel checks, presents a status board, fixes what it can automatically, and gives exact copy-paste commands for the rest. Invoke with /sonardata-setup.
---

# SonarData Setup & Diagnostic Skill

You are helping someone configure their Claude Code environment to mine Sonar product and usage data. Your audience is "I have never used Claude Code to do anything data" — assume nothing is set up, explain every step plainly, and do not use jargon without defining it.

Your job: check every dependency, present a clear status board, fix what you can automatically (with the user's permission), and give exact copy-paste commands for what you cannot fix. Do not skip steps. Do not assume something works without testing it.

---

## Step 0 — Welcome and scope

Tell the user:
> "Running your setup check now. I'll verify system tools, MCP server configuration, AWS/Redshift access, and API keys. This takes about 30 seconds. I'll show you a status board first, then walk through anything that needs fixing."

Proceed immediately to Step 1. Do not wait for a response.

---

## Step 1 — Run all diagnostic checks in parallel

Fire ALL of the following Bash commands simultaneously in a single parallel call. Do not run them sequentially.

```bash
# 1a. Java version
java --version 2>&1 | head -1

# 1b. Python3 version
python3 --version 2>&1

# 1c. pip3 version
pip3 --version 2>&1 | head -1

# 1d. uvx version
uvx --version 2>&1 | head -1

# 1e. AWS CLI version
aws --version 2>&1 | head -1

# 1f. AWS SSO session (sonarcloud-prod profile)
aws sts get-caller-identity --profile sonarcloud-prod 2>&1

# 1g. Read Claude Code MCP server configuration (env values redacted — never read secrets into context)
python3 -c "import json,os
def red(o):
    if isinstance(o,dict): return {k:({x:'<REDACTED>' for x in v} if k=='env' and isinstance(v,dict) else red(v)) for k,v in o.items()}
    if isinstance(o,list): return [red(i) for i in o]
    return o
try: print(json.dumps(red(json.load(open(os.path.expanduser('~/.claude/settings.json')))),indent=2))
except Exception: print('NO_SETTINGS_FILE')"
python3 -c "import json,os
def red(o):
    if isinstance(o,dict): return {k:({x:'<REDACTED>' for x in v} if k=='env' and isinstance(v,dict) else red(v)) for k,v in o.items()}
    if isinstance(o,list): return [red(i) for i in o]
    return o
try: print(json.dumps(red(json.load(open(os.path.expanduser('~/.claude/settings.local.json')))),indent=2))
except Exception: print('NO_LOCAL_SETTINGS_FILE')"

# 1h. Check for Portkey API key in environment or zshrc (presence only — never print values)
grep -i "PORTKEY\|ANTHROPIC_API_KEY" ~/.zshrc ~/.bash_profile ~/.bashrc ~/.profile 2>/dev/null | grep -v '^[[:space:]]*#' | sed 's/=.*/=<REDACTED>/' | head -5 || echo "NO_API_KEY_IN_PROFILE"

# 1i. Check for JFrog / Artifactory token (presence only — never print values)
grep -i "JFROG\|NPM_TOKEN\|ARTIFACTORY" ~/.zshrc ~/.bash_profile ~/.bashrc ~/.npmrc 2>/dev/null | grep -v '^[[:space:]]*#' | sed 's/=.*/=<REDACTED>/' | head -5 || echo "NO_JFROG_TOKEN_IN_PROFILE"

# 1j. Check what's active in the running process right now (presence only — never print values)
# Note: vars may be live here (shell env), OR in the settings.json env block (MCP subprocess) — both are valid sources
printenv | grep -iE "^(PORTKEY|ANTHROPIC_API_KEY|ANTHROPIC_BASE_URL|JFROG|NPM_TOKEN|ARTIFACTORY|GITHUB_PERSONAL_ACCESS_TOKEN|GITHUB_TOKEN)" | sed 's/=.*/=<REDACTED>/' || echo "NO_API_KEY_IN_ACTIVE_ENV"
printenv | grep -iE "^(AWS_PROFILE|AWS_DEFAULT_REGION)" || echo "NO_AWS_ENV_VARS"

# 1k. Verify PATH contains common tool locations (Homebrew may be missing in Desktop)
echo "PATH=$PATH"
which java 2>/dev/null || echo "java: not in PATH"
which python3 2>/dev/null || echo "python3: not in PATH"
which aws 2>/dev/null || echo "aws: not in PATH"
which uvx 2>/dev/null || echo "uvx: not in PATH"
which node 2>/dev/null || echo "node: not in PATH"
which npm 2>/dev/null || echo "npm: not in PATH"
which npx 2>/dev/null || echo "npx: not in PATH"

# 1l. Node.js version (required for Glean, Atlan, Mixpanel MCPs — all use npx)
node --version 2>&1 || echo "node: not installed"
npm --version 2>&1 || echo "npm: not installed"

# 1m. gh CLI version and auth status
gh --version 2>&1 | head -1
which gh 2>/dev/null || echo "gh: not in PATH"
gh auth status 2>&1

# 1n. GitHub PAT (presence only — never print values)
grep -i "GITHUB_PERSONAL_ACCESS_TOKEN\|GITHUB_TOKEN" ~/.zshrc ~/.bash_profile ~/.bashrc ~/.profile 2>/dev/null | grep -v '^[[:space:]]*#' | sed 's/=.*/=<REDACTED>/' | head -5 || echo "NO_GITHUB_TOKEN_IN_PROFILE"
```

---

## Step 2 — Parse results and build the status board

Parse every result from Step 1. For each item, assign one of three statuses:

- ✅ **OK** — passes the check
- ⚠️ **Warning** — present but needs attention
- ❌ **Missing / Broken** — needs to be fixed before continuing

**Parsing rules:**

| Check | Pass condition | Fail condition |
|---|---|---|
| Java | Output contains `21`, `22`, `23`, or higher AND `which java` returns a path | Any version below 21, "command not found", or "not in PATH" |
| Python3 | Output contains `Python 3.` AND `which python3` returns a path | "command not found" or "not in PATH" |
| pip3 | Output contains a version number | "command not found" |
| uvx | Output contains a version number AND `which uvx` returns a path | "command not found" or "not in PATH" |
| Node.js | `node --version` returns `v18` or higher AND `which node` returns a path | Below v18, "command not found", or "not in PATH" — blocks Glean/Atlan/Mixpanel MCPs |
| npm / npx | `npm --version` returns a version AND `which npx` returns a path | "command not found" or "not in PATH" |
| gh CLI | `gh --version` returns a version AND `which gh` returns a path | "command not found" or "not in PATH" |
| AWS CLI | Output contains `aws-cli` AND `which aws` returns a path | "command not found" or "not in PATH" |
| AWS SSO session | Output contains `"UserId"` | Any error (ExpiredToken, NoCredentials, etc.) |
| gh auth | `gh auth status` output does not contain "not logged in", "You are not logged", or "no token" | Contains any of those strings, or command errors |
| SonarData MCP | `mcpServers` in settings.json contains a key with `sonardata` in name OR command | Missing |
| Glean MCP | `mcpServers` contains a key with `glean` in name | Missing |
| Atlan MCP | `mcpServers` contains a key with `atlan` in name | Missing |
| Mixpanel MCP | `mcpServers` contains a key with `mixpanel` in name | Missing |
| GitHub MCP | `mcpServers` contains a key with `github` in name | Missing |
| Portkey / API key | Found in `printenv` (1j) OR found as `ANTHROPIC_BASE_URL`/`PORTKEY_API_KEY` in settings.json `env` block (1g) OR found in shell profile (1h) — any of these is ✅ | Absent from all three sources |
| JFrog token | Found in `printenv` (1j) OR in shell profile (1i) — either is ✅ | Absent from both |
| GitHub PAT | Found in `printenv` (1j) OR found as `GITHUB_PERSONAL_ACCESS_TOKEN`/`GITHUB_TOKEN` in settings.json `env` block (1g) OR found in shell profile (1n) — any of these is ✅ | Absent from all three sources |

**Key parsing principle:** An env var is considered accessible if it is live in the running process (`printenv`), OR defined in settings.json's `env` block (which injects into MCP subprocesses), OR present in a shell profile. Each is a valid delivery path. Only flag ❌ if the var is absent from ALL three.

**Do NOT print a status board to the CLI. Instead, build an HTML report.**

Using the parsed check results, generate a complete self-contained HTML file. Use the template below as your base. Replace every placeholder (shown in ALL_CAPS or as example values) with the actual results from Step 1. Then proceed immediately to Step 3 to build the issue cards, and Step 5 to write and open the file.

**Only output to the chat:**
> "Running checks... done. Opening your setup report."

Nothing else in the chat until the file is open.

---

### HTML template

Generate this HTML, filled with actual values from the checks. Every status value must reflect what Step 1 actually returned — do not use the placeholder values below verbatim.

Status class rules (apply to `<td class="status ...">` in table rows and `<div class="issue ...">` for issue cards):
- Use `ok` (green) for passing checks
- Use `warn` (orange) for warnings (present but needs attention)
- Use `err` (red) for failures / missing items

```html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Sonar Data Analysis — Setup Status</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:'SF Mono','JetBrains Mono','Fira Code',monospace;background:#120800;color:#d4b896;padding:2rem;min-height:100vh;font-size:.9rem;line-height:1.5}
h1{font-size:1rem;font-weight:600;color:#e8c9a0;margin-bottom:1.5rem;letter-spacing:.02em}
table{border-collapse:collapse;width:100%;max-width:700px;margin-bottom:2rem}
th,td{border:1px solid #3a2010;padding:.5rem .75rem;vertical-align:top;text-align:left}
thead th{background:#1e0e04;color:#c8a070;font-weight:600;letter-spacing:.05em;text-transform:uppercase;font-size:.75rem}
.section-label{background:#1a0c04;color:#a07850;font-size:.7rem;letter-spacing:.08em;text-transform:uppercase;font-weight:600;padding:.4rem .75rem;border-bottom:1px solid #3a2010}
td.item{color:#c8a878}
td.status{white-space:nowrap}
.ok{color:#5dbb63}.warn{color:#d4892a}.err{color:#d45050}
.issues{max-width:700px}
.issues h2{font-size:.75rem;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:#a07850;margin-bottom:.75rem}
.issue{border:1px solid #3a2010;border-left:3px solid #d45050;margin-bottom:.75rem;padding:.75rem 1rem}
.issue.warn{border-left-color:#d4892a}
.issue-title{font-weight:600;color:#e8c9a0;margin-bottom:.35rem}
.issue-desc{color:#a07850;font-size:.82rem;margin-bottom:.6rem;line-height:1.5}
.code-wrap{position:relative;margin-bottom:.4rem}
.code{background:#0c0500;border:1px solid #3a2010;padding:.5rem 3rem .5rem .75rem;font-family:inherit;font-size:.8rem;color:#c8a878;white-space:pre-wrap;word-break:break-all;line-height:1.5}
.opt-label{font-size:.68rem;font-weight:600;color:#a07850;letter-spacing:.06em;text-transform:uppercase;margin:.5rem 0 .25rem}
.copy{position:absolute;top:.4rem;right:.5rem;background:#1e0e04;border:1px solid #3a2010;color:#a07850;font-size:.68rem;padding:.15rem .4rem;cursor:pointer;font-family:inherit}
.copy:hover{background:#2a1508;color:#e8c9a0}
.copy.done{color:#5dbb63}
.all-ok{border:1px solid #3a5c20;border-left:3px solid #5dbb63;padding:.75rem 1rem;color:#5dbb63;font-weight:600;margin-bottom:1.5rem;max-width:700px}
.starter{max-width:700px;border:1px solid #3a2010;padding:.75rem 1rem;margin-top:1.5rem}
.starter h2{font-size:.75rem;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:#a07850;margin-bottom:.75rem}
.starter p{color:#a07850;font-size:.82rem;margin-bottom:.6rem}
footer{margin-top:2rem;color:#4a2c10;font-size:.72rem;border-top:1px solid #2a1508;padding-top:.75rem;max-width:700px}
</style>
</head>
<body>

<h1>Sonar Data Analysis — Setup Status</h1>

<table>
  <thead>
    <tr>
      <th style="width:55%">Check</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>

    <tr><td colspan="2" class="section-label">Env var access</td></tr>
    <!-- One row per env var. ✅ if present in printenv OR settings.json env block OR shell profile. ❌ only if absent from all three. -->
    <tr>
      <td class="item">API key (process)</td>
      <td class="status ok">✅ PORTKEY_OPENAI_API_KEY</td>
      <!-- err: <td class="status err">❌ Not found anywhere</td> -->
    </tr>
    <tr>
      <td class="item">API key (settings.json)</td>
      <td class="status ok">✅ ANTHROPIC_BASE_URL set</td>
    </tr>
    <tr>
      <td class="item">JFrog token (process)</td>
      <td class="status ok">✅ ARTIFACTORY_ACCESS_TOKEN</td>
    </tr>
    <tr>
      <td class="item">GitHub PAT</td>
      <td class="status ok">✅ GITHUB_PERSONAL_ACCESS_TOKEN</td>
      <!-- err: <td class="status err">❌ Not found anywhere</td> -->
    </tr>
    <tr>
      <td class="item">AWS profile (process)</td>
      <td class="status ok">✅ sonarcloud-prod</td>
    </tr>

    <tr><td colspan="2" class="section-label">System tools</td></tr>
    <tr>
      <td class="item">Java (need 21+)</td>
      <td class="status ok">✅ 21.0.3</td>
      <!-- err: <td class="status err">❌ 17.0.19 — too old</td> -->
    </tr>
    <tr>
      <td class="item">Python3</td>
      <td class="status ok">✅ 3.12.4</td>
    </tr>
    <tr>
      <td class="item">pip3</td>
      <td class="status ok">✅ 24.0</td>
    </tr>
    <tr>
      <td class="item">uvx</td>
      <td class="status ok">✅ 0.4.18</td>
    </tr>
    <tr>
      <td class="item">Node.js (need 18+)</td>
      <td class="status ok">✅ v22.1.0</td>
      <!-- err: <td class="status err">❌ Not found — blocks Glean/Atlan/Mixpanel MCPs</td> -->
    </tr>
    <tr>
      <td class="item">npm / npx</td>
      <td class="status ok">✅ 10.7.0</td>
    </tr>
    <tr>
      <td class="item">gh CLI</td>
      <td class="status ok">✅ 2.x.x</td>
      <!-- err: <td class="status err">❌ Not found — install with brew install gh</td> -->
    </tr>
    <tr>
      <td class="item">AWS CLI</td>
      <td class="status ok">✅ 2.15.0</td>
    </tr>

    <tr><td colspan="2" class="section-label">Access &amp; auth</td></tr>
    <tr>
      <td class="item">AWS SSO</td>
      <td class="status ok">✅ Authenticated</td>
      <!-- err: <td class="status err">❌ Token expired</td> -->
    </tr>
    <tr>
      <td class="item">gh auth</td>
      <td class="status ok">✅ Logged in as shubham-mehrotra-sonarsource</td>
      <!-- err: <td class="status err">❌ Not authenticated — run gh auth login</td> -->
    </tr>

    <tr><td colspan="2" class="section-label">MCP servers</td></tr>
    <tr>
      <td class="item">SonarData MCP</td>
      <td class="status ok">✅ Configured</td>
    </tr>
    <tr>
      <td class="item">Glean MCP</td>
      <td class="status err">❌ Not configured</td>
    </tr>
    <tr>
      <td class="item">Atlan MCP</td>
      <td class="status ok">✅ Configured</td>
    </tr>
    <tr>
      <td class="item">Mixpanel MCP</td>
      <td class="status err">❌ Not configured</td>
    </tr>
    <tr>
      <td class="item">GitHub MCP</td>
      <td class="status ok">✅ Configured</td>
      <!-- err: <td class="status err">❌ Not configured</td> -->
    </tr>

  </tbody>
</table>

<!-- Render this block ONLY if all checks pass — remove the issues section too -->
<!--
<div class="all-ok">✅ All checks passed — you're ready to query Sonar data.</div>
-->

<!-- Issues section — render ONLY if there are failures or warnings. One .issue div per problem. -->
<div class="issues">
  <h2>N issues to fix</h2>

  <!-- EXAMPLE issue — err severity -->
  <div class="issue">
    <div class="issue-title">Issue title here</div>
    <div class="issue-desc">Plain English explanation of the problem and why it matters.</div>
    <div class="code-wrap">
      <div class="code">the fix command goes here<button class="copy" onclick="cp(this)">copy</button></div>
    </div>
    <div class="issue-desc">Any follow-up note (e.g. "then restart Claude Code").</div>
  </div>

  <!-- EXAMPLE warning — use class="issue warn" for ⚠️ severity -->
  <div class="issue warn">
    <div class="issue-title">Warning title here</div>
    <div class="issue-desc">Explanation of the warning.</div>
    <div class="code-wrap">
      <div class="code">fix command<button class="copy" onclick="cp(this)">copy</button></div>
    </div>
  </div>

  <!-- For multi-step fixes, use opt-label between code-wrap blocks -->
  <!--
  <div class="issue">
    <div class="issue-title">Multi-step fix example</div>
    <div class="issue-desc">Description.</div>
    <div class="opt-label">Step 1 — label</div>
    <div class="code-wrap"><div class="code">command one<button class="copy" onclick="cp(this)">copy</button></div></div>
    <div class="opt-label">Step 2 — label</div>
    <div class="code-wrap"><div class="code">command two<button class="copy" onclick="cp(this)">copy</button></div></div>
  </div>
  -->

</div>

<!-- Starter queries — always show this section -->
<div class="starter">
  <h2>What you can do now</h2>
  <p>Once SonarData MCP is working, try this in Claude Code:</p>
  <div class="code-wrap">
    <div class="code">How many SQC customers do we have with more than 1M NLoC?<button class="copy" onclick="cp(this)">copy</button></div>
  </div>
  <p style="margin-top:.6rem">Or run SQL directly:</p>
  <div class="code-wrap">
    <div class="code">SELECT enterprise_name, nb_of_billable_ncloc
FROM sonarsource.sonar.cad_sqc_latest_customer_product_usage
WHERE nb_of_billable_ncloc > 1000000
ORDER BY nb_of_billable_ncloc DESC
LIMIT 10<button class="copy" onclick="cp(this)">copy</button></div>
  </div>
  <p style="margin-top:.6rem">Or pull a full customer brief: /customer-profile [company name]</p>
</div>

<footer>Generated by /sonardata-setup · TIMESTAMP_PLACEHOLDER</footer>

<script>
function cp(btn){
  const t=btn.closest('.code').childNodes[0].textContent.trim();
  navigator.clipboard.writeText(t).then(()=>{
    btn.textContent='copied!';btn.classList.add('done');
    setTimeout(()=>{btn.textContent='copy';btn.classList.remove('done')},2000);
  });
}
</script>
</body>
</html>
```

**Filling in the template:**
- Replace each `✅ 21.0.3` / `❌ Not found` value in the table with the actual version string or status from Step 1
- For the env var rows: one `<tr>` per variable. Use `class="status ok"`, `"status warn"`, or `"status err"` on the `<td>`. ✅ if found in any source; ❌ only if absent from all three
- Replace `N issues to fix` with the actual count
- Remove the all-ok comment block if there are issues; replace the issues section entirely with the all-ok div if everything passes
- Replace `TIMESTAMP_PLACEHOLDER` with the current date and time

**Issue cards in Step 3:** Every failure and warning from Step 3 becomes one `.issue` or `.issue.warn` div in the issues section. Each card gets: a title, a plain-English description of the problem, and a `code-wrap` div containing the exact fix command. Do not output fix instructions to the chat — they go in the HTML only.

---

## Step 3 — Build issue cards for each failure

For every failure or warning from Step 1, create one issue card in the HTML issues section. Use the content below to write the card's title, description, and fix command. Do not output anything to the chat during this step. All output goes into the HTML.

### 3a-path. Tool installed but not found in PATH

If a tool's version check passes (e.g., `java --version` returns output) but `which java` returns "not in PATH" — the tool is installed at a non-standard location that the current process can't find.

Issue card title: "Tool not in PATH — [tool name]"

Show all three fix paths:

**Option 1 — Add the path to your shell profile (works for CLI and Desktop if combined with Option 3):**
```bash
# Adjust the path to match where your tool is actually installed
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

**Option 2 — Add PATH to the SonarData MCP `env` block in settings.json (works for all surfaces without shell profile changes):**
```json
"sonardata": {
  "command": "uvx",
  "args": ["--from", "sonardata-mcp", "sonardata-mcp"],
  "env": {
    "AWS_PROFILE": "sonarcloud-prod",
    "PATH": "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
  }
}
```

**Option 3 — Set PATH system-wide via launchctl (macOS) so all GUI apps and CLI sessions inherit it:**
```bash
sudo launchctl config user path "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin"
```
Log out and log back in for this to take effect. Use this if you want consistent PATH everywhere without per-app config.

### 3a. Java not installed or below version 21

Say:
> "Java 21 is required. You can install it from Homebrew (macOS) with this command:"
```bash
brew install openjdk@21
```
> After it installs, add it to your PATH by running:
```bash
echo 'export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```
> Then restart your terminal and run `/sonardata-setup` again.

Do NOT attempt to install Java automatically. Just provide the commands.

### 3b. Python3 not installed

Say:
> "Python 3 is required. Install it with:"
```bash
brew install python3
```
> If you're on Windows, download from python.org and ensure 'Add to PATH' is checked.

### 3c. pip3 not installed

Say:
> "pip3 usually comes with Python 3. Try:"
```bash
python3 -m ensurepip --upgrade
```

### 3d. uvx not installed

**uvx is critical** — it's how Claude Code runs the SonarData MCP server. Fix this automatically.

Ask: "uvx is not installed. It's used to run the SonarData MCP. Can I install it now? (takes ~30 seconds)"

If the user says yes, run:
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh && source ~/.zshrc
uvx --version
```

If it succeeds, mark ✅. If it fails, say: "Install failed. Try manually: go to https://docs.astral.sh/uv/getting-started/installation/ and follow the instructions for your OS."

### 3e. Node.js not installed, below v18, or not in PATH

Node.js is required for three of the four MCP servers: Glean, Atlan, and Mixpanel all run via `npx`. Without it, those MCPs silently fail to start. The live connectivity test in Step 4 will show them as ❌ Not running.

Issue card title: "Node.js missing — Glean, Atlan, Mixpanel MCPs need it"

Show all three fix paths:

**Option 1 — Install via nvm (recommended — lets you manage Node versions):**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.zshrc
nvm install --lts
nvm use --lts
```
nvm installs Node and npm together. `--lts` picks the latest long-term support version (currently v22).

**Option 2 — Install via Homebrew:**
```bash
brew install node
```
Installs Node and npm. Verify with `node --version` and `npm --version`.

**Option 3 — Add existing Node to PATH if installed but not found:**
```bash
# Find where Node is installed
find /usr/local /opt/homebrew ~/brew ~/.nvm -name "node" -type f 2>/dev/null | head -5
```
Then add the directory containing `node` to your PATH in `~/.zshrc`:
```bash
echo 'export PATH="/path/to/node/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc
```

After installing, verify `npx` is available:
```bash
npx --version
```
npx ships with npm — if `npm --version` works, npx is present. Then restart Claude Code so the MCP servers pick up the new PATH.

### 3f. AWS CLI not installed

Say:
> "AWS CLI is required to authenticate against Redshift. Install it with:"
```bash
brew install awscli
```

### 3g. AWS SSO session expired or not configured

Run:
```bash
aws sts get-caller-identity --profile sonarcloud-prod 2>&1
```

If the error contains "Token has expired" or "The SSO session associated":
> "Your AWS session has expired. Re-authenticating now..."

Run:
```bash
aws sso login --profile sonarcloud-prod
```

Tell the user: "A browser window will open. Log in with your Sonar Google account. Once you see 'Successfully logged in', come back here."

After login, verify with:
```bash
aws sts get-caller-identity --profile sonarcloud-prod 2>&1
```

If this still fails and the error says "profile not configured" or "No profile named sonarcloud-prod":
> "The sonarcloud-prod AWS profile is not set up yet. You need to configure it. Run this command and follow the prompts:"
```bash
aws configure sso --profile sonarcloud-prod
```

> When prompted:
> - SSO start URL: `https://sonar.awsapps.com/start`
> - SSO region: `eu-central-1`
> - Account: select the sonarcloud-prod account
> - Role: select your available role
> - Default output format: `json`

After configuring, run `aws sso login --profile sonarcloud-prod` again.

**Note on Redshift access:** Even with a valid AWS session, you need to be in the `App-Redshift-ProductManagers` group to query Sonar data. If queries fail with a permissions error later, you need to raise a ticket — the setup wizard cannot fix this automatically. Provide this note: "If you see 'permission denied' errors when running SQL queries, raise a Jira ticket requesting access to `App-Redshift-ProductManagers`, same as Shubham Mehrotra's group."

### 3h. Portkey / API key not found

Only trigger this if the API key is absent from ALL three sources: `printenv`, settings.json `env` block, and shell profiles. If it's in any one of them, do not generate this issue card.

Issue card title: "API key not configured"

Say: "Claude Code needs an API key. At SonarSource, this goes through Portkey. Get your Portkey API key from your team's Portkey account or ask your manager. Then set it using whichever method fits your workflow:"

Show all three options in the issue card:

**Option 1 — Shell profile (works for CLI, and for Desktop if launchctl is also set):**
```bash
echo 'export PORTKEY_API_KEY="your-key-here"' >> ~/.zshrc && source ~/.zshrc
```

**Option 2 — launchctl setenv (works for all surfaces on macOS, no restart of terminal needed):**
```bash
launchctl setenv PORTKEY_API_KEY "your-key-here"
```
Then fully quit (Cmd+Q on macOS) and relaunch Claude Code.

**Option 3 — settings.json env block (recommended — works for all surfaces, no shell config needed):**
```json
"env": {
  "ANTHROPIC_BASE_URL": "https://api.portkey.ai",
  "PORTKEY_API_KEY": "your-key-here"
}
```
Add this inside the top-level settings.json object. The MCP server and Claude API calls will see it immediately on next launch.

Note: if the user has an Anthropic direct API key instead of Portkey, they should set `ANTHROPIC_API_KEY` using the same three options above.

### 3i. JFrog token warning

If a JFrog token was found but its status is unclear, say:
> "A JFrog token was found in your shell config. This is needed to pull the SonarData MCP package from JFrog Artifactory. We'll verify it works in Step 4 when we test the MCP connection."

If no JFrog token was found:
> "A JFrog token is needed to download the SonarData MCP package. To get one:"
> 1. Go to your JFrog Artifactory instance
> 2. In the top-right, click your username → Edit Profile
> 3. Generate an identity token
> 4. Add to your shell profile:
```bash
echo 'export JFROG_TOKEN="your-token-here"' >> ~/.zshrc
echo '//sonarsource.jfrog.io/artifactory/api/npm/:_authToken=${JFROG_TOKEN}' >> ~/.npmrc
source ~/.zshrc
```

### 3k. gh not installed or not in PATH

Issue card title: "gh CLI not installed"

```bash
brew install gh
```

After installing, authenticate:
```bash
gh auth login
```
Choose GitHub.com → HTTPS → Login with a web browser. Once authenticated, `gh auth status` should show your username.

### 3l. gh installed but not authenticated

Issue card title: "gh CLI not authenticated"

```bash
gh auth login
```

Choose GitHub.com → HTTPS → Login with a web browser.

### 3m. GitHub MCP not configured

Issue card title: "GitHub MCP not configured — needed for PR work and repo browsing"

Add to mcpServers in settings.json:
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": {
    "GITHUB_PERSONAL_ACCESS_TOKEN": "your-pat-here"
  }
}
```

Get a PAT: GitHub.com → Settings → Developer settings → Personal access tokens → Generate new token (classic). Scopes needed: `repo`, `read:org`, `read:user`.

If the GitHub PAT check (1n) also fails, set the token first (using Option 1, 2, or 3 from the API key pattern above), then add the MCP config.

### 3j. MCP server not configured

For each missing MCP server, check what configuration is needed and add it to `~/.claude/settings.json`.

**Read the current settings.json first:**
```bash
cat ~/.claude/settings.json 2>/dev/null || echo "{}"
```

Then explain to the user what each MCP server does, and ask permission before modifying settings.json:
> "I need to add [X] to your Claude Code settings. This lets Claude talk to [brief description]. OK to add it?"

**SonarData MCP** (if missing):
> "SonarData MCP connects Claude to Sonar's Redshift data warehouse. It lets you query product usage, customer telemetry, and installation data directly in SQL."

Add to mcpServers in settings.json:
```json
"sonardata": {
  "command": "uvx",
  "args": [
    "--from",
    "sonardata-mcp",
    "sonardata-mcp"
  ],
  "env": {
    "AWS_PROFILE": "sonarcloud-prod"
  }
}
```

Note: the exact package source/registry may require JFrog credentials. If uvx fails to pull the package, check that the JFrog token is set and that the npm/PyPI registry is pointed at the correct Artifactory URL. Ask the user to check with someone who has a working setup for the exact package name and registry.

**Glean MCP** (if missing):
> "Glean MCP connects Claude to your company's knowledge base — Salesforce, Slack, email, calendar, Confluence, and more. It's needed for customer profiles and account research."

Add to mcpServers:
```json
"glean": {
  "command": "npx",
  "args": ["-y", "@glean/mcp-server"],
  "env": {
    "GLEAN_API_TOKEN": "your-glean-token",
    "GLEAN_DOMAIN": "sonarsource"
  }
}
```

> Replace `your-glean-token` with your Glean API token. Get it from Glean Settings → API.

**Atlan MCP** (if missing):
> "Atlan MCP connects Claude to your data catalog — useful for discovering which Redshift tables exist and what they contain."

Add to mcpServers:
```json
"atlan": {
  "command": "npx",
  "args": ["-y", "@atlan/mcp"],
  "env": {
    "ATLAN_API_KEY": "your-atlan-token",
    "ATLAN_BASE_URL": "https://sonarsource.atlan.com"
  }
}
```

**Mixpanel MCP** (if missing):
> "Mixpanel MCP connects Claude to product analytics — useful for event tracking, funnel analysis, and user behavior data."

Provide Mixpanel MCP configuration based on the user's existing Mixpanel setup. Ask: "Do you have a Mixpanel service account username and secret? These come from your Mixpanel project settings."

Note on MCP config changes: when adding an MCP server, merge the new entry into the existing `mcpServers` object in `settings.json`. Do not overwrite the whole file. Use the Edit tool, not Write, if the file already exists. Add the settings.json snippet as a `code-wrap` block in the issue card — do not modify settings.json automatically without user confirmation.

---

## Step 4 — Verify live MCP connectivity

Attempt a lightweight call to each configured MCP. Record results; these update the MCP Servers card in the HTML.

**SonarData MCP:** run `SELECT COUNT(*) FROM sonarsource.sonar.cad_sqc_latest_customer_product_usage LIMIT 1` via `mcp__sonardata__execute_query`.
- Returns a number → mark ✅ Live in the HTML card
- Permissions error → mark ⚠️ Connected, no Redshift group — add a warn issue card with instructions to raise a Jira ticket for `App-Redshift-ProductManagers`
- Timeout or connection error → mark ❌ Not running — add an error issue card

**Glean MCP:** call `mcp__glean__search` with `query="sonarqube"`, `num_results=1`.
- Returns a result → ✅ Live
- Tool not found → ❌ Not running

**Atlan MCP:** call `mcp__atlan__semantic_search_tool` with `user_query="sonarqube tables"`.
- Returns a result → ✅ Live
- Tool not found → ❌ Not running

**Mixpanel MCP:** call `mcp__mixpanel__Get-Business-Context`.
- Returns context → ✅ Live
- Tool not found → ❌ Not running

**GitHub MCP:** call `mcp__github__get_me`.
- Returns a username → ✅ Live
- Tool not found → ❌ Not running

For any MCP that is configured in settings.json but shows ❌ Not running: add a warn card explaining that MCP servers load at startup and the user needs to fully restart Claude Code.

---

## Step 5 — Write the HTML file and open it

1. Using the Write tool, write the completed HTML to `~/Desktop/sonardata-setup.html`. The file should be fully self-contained — no external scripts, fonts, or stylesheets.

2. Open it in the default browser:
```bash
open ~/Desktop/sonardata-setup.html
```

3. Output exactly this to the chat (nothing more):
> "Setup report opened: `~/Desktop/sonardata-setup.html`"
> 
> If there are issues: "N issues to fix — each one has a copy button with the exact command."
> If all clear: "All checks passed. You're ready to query Sonar data."

Do not summarize the issues in the chat. The HTML is the output. The chat message is just the pointer.

---

## Important notes

- **HTML is the output.** Do not reproduce status tables or fix instructions in the chat. The report file is the answer. The chat message is just the file path.
- **Never modify settings.json without user confirmation.** Show the proposed snippet in the HTML issue card first. Only edit the file after the user says yes in the chat.
- **Never log or display credentials.** If you find a token or key in the shell profile, active env, or settings.json, confirm it's present but do not print the value. Two redaction layers keep secret values out of context: the `sed 's/=.*/=<REDACTED>/'` pipeline blanks values from `KEY=value` lines in shell profiles and `printenv`, and the python3 redactor in 1g blanks every value inside any `env` block in settings.json / settings.local.json while keeping key names intact for presence detection. `settings.xml` is excluded because XML credential format (`<password>TOKEN</password>`) contains no `=` and is not parsed by either redactor.
- **Restart required after settings.json changes.** MCP servers are loaded at startup. Always remind the user to restart Claude Code after any settings change.
- **Order matters.** Fix system tools before access/auth, and access/auth before MCP servers. A broken tool upstream will make every downstream test fail.
- **Be specific about failure reasons.** "It didn't work" is not a diagnosis. Read the error message and say exactly what it means in plain English.
- **Assume macOS unless proven otherwise.** If you see Windows-specific paths or errors, adapt the commands accordingly (use `%APPDATA%\Claude` instead of `~/.claude`, `py` instead of `python3`, etc.).
- **Three valid env var sources — all equal:** A var is accessible if it's live in `printenv` (shell env), OR in settings.json's `env` block (MCP subprocess), OR in a shell profile. Claude Code's bash subprocesses don't have a TTY and can't reliably detect CLI vs Desktop — so never infer the surface from process state. Report what's actually present; only flag ❌ when all three sources are empty.
- **Fix instructions always show all paths:** Every env var issue card shows the shell profile fix, the `launchctl setenv` fix, and the settings.json env block fix. Don't pick one based on assumed surface — the user knows their own setup.
