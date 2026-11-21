#!/bin/bash

echo "🚀 Booting Modular AI God-Mode (OmniRoute Edition)..."

# ==========================================
# Fix global npm PATH
# ==========================================
export PATH="$(npm prefix -g)/bin:$PATH"

grep -qxF 'export PATH="$(npm prefix -g)/bin:$PATH"' ~/.bashrc || \
echo 'export PATH="$(npm prefix -g)/bin:$PATH"' >> ~/.bashrc

# ==========================================
# Install Core Dependencies
# ==========================================
echo "📦 Installing Claude Code & OmniRoute..."

npm install -g @anthropic-ai/claude-code omniroute

# Verify both commands are available
command -v claude >/dev/null 2>&1 || { echo "❌ claude not found after npm install"; exit 1; }
command -v omniroute >/dev/null 2>&1 || { echo "❌ omniroute not found after npm install"; exit 1; }

# ==========================================
# Install Persistent Project Skills
# ==========================================
echo "🧠 Installing requested Claude Skills into persistent workspace..."

# Core & Setup
npx -y skills add usestrix/strix -y
npx -y skills add Panniantong/agent-reach -y
npx -y skills add https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup -y

# Design & Frontend
npx -y skills add https://www.tasteskill.dev/ -y
npx -y skills add https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines -y
npx -y skills add https://github.com/Leonxlnx/taste-skill/tree/main/skills/image-to-code-skill -y
npx -y skills add VoltAgent/awesome-design-md -y

# Workflow & Orchestration
npx -y skills add vercel-labs/skills -y
npx -y skills add obra/superpowers -y
npx -y skills add rebelytics/one-skill-to-rule-them-all -y
npx -y skills add latent-spaces/brag -y
npx -y skills add cosmix/loom -y

echo "✅ All skills installed to local .claude/skills directory"

# Auto-unzip local skill zips
mkdir -p .claude/skills
for f in *.zip; do
    [ -f "$f" ] && unzip -o "$f" -d .claude/skills/
done

# ==========================================
# Configure Environment for OmniRoute
# ==========================================
export ANTHROPIC_BASE_URL="http://127.0.0.1:20128"
export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"

grep -qxF 'export ANTHROPIC_BASE_URL="http://127.0.0.1:20128"' ~/.bashrc || \
echo 'export ANTHROPIC_BASE_URL="http://127.0.0.1:20128"' >> ~/.bashrc

grep -qxF 'export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"' ~/.bashrc || \
echo 'export CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY="1"' >> ~/.bashrc

# ==========================================
# Load Local Environment Variables
# ==========================================
if [ -f .env ]; then
    echo "📂 Loading .env variables..."
    set -a
    source .env
    set +a
fi

# ==========================================
# Start OmniRoute Gateway in Background
# ==========================================
echo "⚡ Starting OmniRoute gateway on port 20128..."

pkill -f "omniroute serve" 2>/dev/null || true
omniroute serve > omniroute.log 2>&1 &
sleep 5

# ==========================================
# Health Check
# ==========================================
if curl -s http://127.0.0.1:20128 >/dev/null; then
    echo "✅ OmniRoute running at http://127.0.0.1:20128"
    echo "📊 Open the forwarded port 20128 in Codespaces to manage keys & models."
else
    echo "❌ OmniRoute startup failed. Check omniroute.log:"
    cat omniroute.log
fi

# ==========================================
# Launch Claude Code
# ==========================================
echo "🚀 Launching Claude Code..."

claude --model nvidia/nvidia/nemotron-3.5-super-vl-120b-a12b --dangerously-skip-permissions
