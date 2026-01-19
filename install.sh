#!/bin/bash
# KeiMcpInit 설치 스크립트
# 사용법: curl -fsSL https://raw.githubusercontent.com/eightynine01/KeiMcpInit/main/install.sh | bash

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  KeiMcpInit 설치${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 현재 디렉토리가 git repo인지 확인
if [ ! -d ".git" ]; then
    echo -e "${RED}오류: 현재 디렉토리가 git 저장소가 아닙니다.${NC}"
    echo "git 저장소 루트에서 실행해주세요."
    exit 1
fi

# ========================================
# 플랫폼 및 MCP 설정 관련 함수
# ========================================

# 플랫폼별 설정 파일 경로
CLAUDE_DESKTOP_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
CODEX_CONFIG="$HOME/.codex/config.toml"
CURSOR_CONFIG="$HOME/Library/Application Support/Cursor/User/mcp.json"
GEMINI_CONFIG="$HOME/.gemini-cli/settings.json"

# 플랫폼 감지 함수
detect_platforms() {
    local platforms=()

    # Claude Desktop
    if [ -f "$CLAUDE_DESKTOP_CONFIG" ]; then
        platforms+=("claude-desktop")
    fi

    # Claude Code
    if command -v claude &> /dev/null; then
        platforms+=("claude-code")
    fi

    # Cursor
    if [ -f "$CURSOR_CONFIG" ] || command -v cursor &> /dev/null; then
        platforms+=("cursor")
    fi

    # Codex
    if [ -f "$CODEX_CONFIG" ] || command -v codex &> /dev/null; then
        platforms+=("codex")
    fi

    # Gemini CLI
    if [ -f "$GEMINI_CONFIG" ] || command -v gemini &> /dev/null; then
        platforms+=("gemini")
    fi

    # OpenCode (현재 실행 중)
    if [ -n "$OPENCODE_SESSION_ID" ] || env | grep -q "OPENCODE"; then
        platforms+=("opencode")
    fi

    echo "${platforms[@]}"
}

# Claude Desktop용 MCP 추가
add_claude_desktop_mcp() {
    local server_name=$1
    local server_config=$2

    if ! check_claude_desktop_mcp "$server_name"; then
        echo -e "  ${GREEN}[Claude Desktop]${NC} 설정 파일에 추가 중..."

        if [ ! -f "$CLAUDE_DESKTOP_CONFIG" ]; then
            mkdir -p "$(dirname "$CLAUDE_DESKTOP_CONFIG")"
            echo '{"mcpServers":{}}' > "$CLAUDE_DESKTOP_CONFIG"
        fi

        python3 <<PYTHON_SCRIPT
import json

config_path = "$CLAUDE_DESKTOP_CONFIG"
with open(config_path, 'r') as f:
    config = json.load(f)

if 'mcpServers' not in config:
    config['mcpServers'] = {}

server_name = "$server_name"
server_config = json.loads('''$server_config''')
config['mcpServers'][server_name] = server_config

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ 추가 완료")
PYTHON_SCRIPT

        echo -e "  ${GREEN}✓ $server_name 추가 완료${NC}"
    else
        echo -e "  ${GREEN}[Claude Desktop]${NC} 이미 설치됨"
    fi
}

# Claude Code용 MCP 추가
add_claude_code_mcp() {
    local server_name=$1
    local install_cmd=$2

    if ! check_claude_code_mcp "$server_name"; then
        echo -e "  ${GREEN}[Claude Code]${NC} $server_name 설치 중..."
        if eval "$install_cmd"; then
            echo -e "  ${GREEN}✓ $server_name 설치 완료${NC}"
        else
            echo -e "  ${YELLOW}⚠️  $server_name 설치 실패${NC}"
        fi
    else
        echo -e "  ${GREEN}[Claude Code]${NC} 이미 설치됨"
    fi
}

# Codex용 MCP 추가 (TOML)
add_codex_mcp() {
    local server_name=$1
    local server_config=$2

    if ! check_codex_mcp "$server_name"; then
        echo -e "  ${GREEN}[Codex]${NC} 설정 파일에 추가 중..."

        mkdir -p "$(dirname "$CODEX_CONFIG")"

        cat >> "$CODEX_CONFIG" <<EOF
$server_config
EOF

        echo -e "  ${GREEN}✓ $server_name 추가 완료${NC}"
    else
        echo -e "  ${GREEN}[Codex]${NC} 이미 설치됨"
    fi
}

# Cursor용 MCP 추가
add_cursor_mcp() {
    local server_name=$1
    local server_config=$2

    if ! check_cursor_mcp "$server_name"; then
        echo -e "  ${GREEN}[Cursor]${NC} 설정 파일에 추가 중..."

        mkdir -p "$(dirname "$CURSOR_CONFIG")"

        if [ ! -f "$CURSOR_CONFIG" ]; then
            echo '{"mcpServers":{}}' > "$CURSOR_CONFIG"
        fi

        python3 <<PYTHON_SCRIPT
import json

config_path = "$CURSOR_CONFIG"
with open(config_path, 'r') as f:
    config = json.load(f)

if 'mcpServers' not in config:
    config['mcpServers'] = {}

server_name = "$server_name"
server_config = json.loads('''$server_config''')
config['mcpServers'][server_name] = server_config

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ 추가 완료")
PYTHON_SCRIPT

        echo -e "  ${GREEN}✓ $server_name 추가 완료${NC}"
    else
        echo -e "  ${GREEN}[Cursor]${NC} 이미 설치됨"
    fi
}

# Gemini CLI용 MCP 추가
add_gemini_mcp() {
    local server_name=$1
    local server_config=$2

    if ! check_gemini_mcp "$server_name"; then
        echo -e "  ${GREEN}[Gemini CLI]${NC} 설정 파일에 추가 중..."

        mkdir -p "$(dirname "$GEMINI_CONFIG")"

        if [ ! -f "$GEMINI_CONFIG" ]; then
            echo '{"mcpServers":{}}' > "$GEMINI_CONFIG"
        fi

        python3 <<PYTHON_SCRIPT
import json

config_path = "$GEMINI_CONFIG"
with open(config_path, 'r') as f:
    config = json.load(f)

if 'mcpServers' not in config:
    config['mcpServers'] = {}

server_name = "$server_name"
server_config = json.loads('''$server_config''')
config['mcpServers'][server_name] = server_config

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✓ 추가 완료")
PYTHON_SCRIPT

        echo -e "  ${GREEN}✓ $server_name 추가 완료${NC}"
    else
        echo -e "  ${GREEN}[Gemini CLI]${NC} 이미 설치됨"
    fi
}

# MCP 확인 함수들
check_claude_desktop_mcp() {
    local server_name=$1
    if [ -f "$CLAUDE_DESKTOP_CONFIG" ] && python3 -c "import json; f=json.load(open('$CLAUDE_DESKTOP_CONFIG')); print('$server_name' in f.get('mcpServers', {}))" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_claude_code_mcp() {
    local server_name=$1
    if claude mcp list 2>/dev/null | grep -q "^$server_name:"; then
        return 0
    fi
    return 1
}

check_codex_mcp() {
    local server_name=$1
    if [ -f "$CODEX_CONFIG" ] && grep -q "\[mcp_servers\.$server_name\]" "$CODEX_CONFIG" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_cursor_mcp() {
    local server_name=$1
    if [ -f "$CURSOR_CONFIG" ] && python3 -c "import json; f=json.load(open('$CURSOR_CONFIG')); print('$server_name' in f.get('mcpServers', {}))" 2>/dev/null; then
        return 0
    fi
    return 1
}

check_gemini_mcp() {
    local server_name=$1
    if [ -f "$GEMINI_CONFIG" ] && python3 -c "import json; f=json.load(open('$GEMINI_CONFIG')); print('$server_name' in f.get('mcpServers', {}))" 2>/dev/null; then
        return 0
    fi
    return 1
}

# context7 설치 상태 확인 및 자동 설치
check_context7() {
    local platforms=($(detect_platforms))
    local installed=false

    echo ""
    echo -e "${CYAN}📦 context7 설치 상태 확인 및 자동 설치${NC}"

    for platform in "${platforms[@]}"; do
        case $platform in
            claude-desktop)
                local config='{"command":"npx","args":["-y","@upstash/context7-mcp"]}'
                add_claude_desktop_mcp "context7" "$config"
                ;;
            claude-code)
                add_claude_code_mcp "context7" 'claude mcp add context7 -- npx -y @upstash/context7-mcp'
                ;;
            cursor)
                local config='{"command":"npx","args":["-y","@upstash/context7-mcp"]}'
                add_cursor_mcp "context7" "$config"
                ;;
            codex)
                local config='[mcp_servers.context7]
command = "npx"
args = ["-y", "@upstash/context7-mcp"]'
                add_codex_mcp "context7" "$config"
                ;;
            gemini)
                local config='{"command":"npx","args":["-y","@upstash/context7-mcp"]}'
                add_gemini_mcp "context7" "$config"
                ;;
            opencode)
                echo -e "  ${GREEN}[OpenCode]${NC} ⚡ 현재 실행 중"
                ;;
        esac
    done

    return 0
}

# keimcp 설치 상태 확인 및 자동 설치 (토큰 필요)
check_keimcp() {
    local platforms=($(detect_platforms))
    local installed=false

    echo ""
    echo -e "${CYAN}🔧 keimcp 설치 상태 확인${NC}"
    echo -e "${YELLOW}  ⚠️  keimcp는 인증 토큰이 필요합니다${NC}"
    echo -e "${YELLOW}  ℹ️  LLM에게 다음을 요청하세요:${NC}"
    echo -e "${YELLOW}     \"현재 사용 중인 플랫폼의 설정 파일에 keimcp를 추가해줘.\"${NC}"
    echo ""

    for platform in "${platforms[@]}"; do
        case $platform in
            claude-desktop)
                if ! check_claude_desktop_mcp "keimcp"; then
                    echo -e "  ${YELLOW}[Claude Desktop]${NC} 미설치"
                    echo -e "  ${BLUE}    파일: $CLAUDE_DESKTOP_CONFIG${NC}"
                    echo -e "  ${BLUE}    다음을 추가하세요:${NC}"
                    echo -e '    {'
                    echo -e '      "mcpServers": {'
                    echo -e '        "keimcp": {'
                    echo -e '          "url": "https://mcp.keiailab.dev/sse",'
                    echo -e '          "headers": {'
                    echo -e '            "Authorization": "Bearer <YOUR_TOKEN>"'
                    echo -e '          }'
                    echo -e '        }'
                    echo -e '      }'
                    echo -e '    }'
                fi
                ;;
            claude-code)
                if ! check_claude_code_mcp "keimcp"; then
                    echo -e "  ${YELLOW}[Claude Code]${NC} 미설치"
                    echo -e "  ${BLUE}    다음 명령을 실행하세요:${NC}"
                    echo -e "    claude mcp add keimcp --transport sse \\"
                    echo -e "      --url https://mcp.keiailab.dev/sse \\"
                    echo -e '      --header \"Authorization: Bearer <YOUR_TOKEN>\"'
                fi
                ;;
            cursor)
                if ! check_cursor_mcp "keimcp"; then
                    echo -e "  ${YELLOW}[Cursor]${NC} 미설치"
                    echo -e "  ${BLUE}    파일: $CURSOR_CONFIG${NC}"
                    echo -e "  ${BLUE}    다음을 추가하세요:${NC}"
                    echo -e '    {'
                    echo -e '      "mcpServers": {'
                    echo -e '        "keimcp": {'
                    echo -e '          "type": "sse",'
                    echo -e '          "url": "https://mcp.keiailab.dev/sse",'
                    echo -e '          "headers": {'
                    echo -e '            "Authorization": "Bearer <YOUR_TOKEN>"'
                    echo -e '          }'
                    echo -e '        }'
                    echo -e '      }'
                    echo -e '    }'
                fi
                ;;
            codex)
                if ! check_codex_mcp "keimcp"; then
                    echo -e "  ${YELLOW}[Codex]${NC} 미설치"
                    echo -e "  ${BLUE}    파일: $CODEX_CONFIG${NC}"
                    echo -e "  ${BLUE}    다음을 추가하세요:${NC}"
                    echo -e '    [mcp_servers.keimcp]'
                    echo -e '    type = "sse"'
                    echo -e '    url = "https://mcp.keiailab.dev/sse"'
                    echo -e '    env = {AUTHORIZATION = "Bearer <YOUR_TOKEN>"}'
                fi
                ;;
            gemini)
                if ! check_gemini_mcp "keimcp"; then
                    echo -e "  ${YELLOW}[Gemini CLI]${NC} 미설치"
                    echo -e "  ${BLUE}    파일: $GEMINI_CONFIG${NC}"
                    echo -e "  ${BLUE}    다음을 추가하세요:${NC}"
                    echo -e '    {'
                    echo -e '      "mcpServers": {'
                    echo -e '        "keimcp": {'
                    echo -e '          "type": "sse",'
                    echo -e '          "url": "https://mcp.keiailab.dev/sse",'
                    echo -e '          "headers": {'
                    echo -e '            "Authorization": "Bearer <YOUR_TOKEN>"'
                    echo -e '          }'
                    echo -e '        }'
                    echo -e '      }'
                    echo -e '    }'
                fi
                ;;
            opencode)
                echo -e "  ${GREEN}[OpenCode]${NC} ⚡ 현재 실행 중"
                ;;
        esac
    done

    echo ""
    echo -e "${YELLOW}💡 LLM에게 다음처럼 요청하세요:${NC}"
    echo -e "${CYAN}   \"현재 사용 중인 ${platforms[0]}의 설정 파일에 위에서 안내한 keimcp 설정을 <YOUR_TOKEN>을 실제 토큰으로 교체하여 추가해줘.\"${NC}"

    return 0
}

# 1. Submodule 추가
echo -e "${BLUE}[1/4] Submodule 추가...${NC}"
if [ -d ".agents" ]; then
    echo -e "${YELLOW}  .agents 디렉토리가 이미 존재합니다. 업데이트합니다.${NC}"
    cd .agents && git pull origin main && cd ..
else
    git submodule add git@github.com:eightynine01/KeiMcpInit.git .agents 2>/dev/null || \
    git submodule add https://github.com/eightynine01/KeiMcpInit.git .agents
fi
echo -e "${GREEN}  완료${NC}"

# 2. 심볼릭 링크 설정
echo -e "${BLUE}[2/4] 심볼릭 링크 설정...${NC}"
.agents/scripts/setup-agents.sh --setup
echo -e "${GREEN}  완료${NC}"

# 3. MCP 도구 확인 (모든 플랫폼)
echo -e "${BLUE}[3/4] MCP 도구 확인...${NC}"

# 감지된 플랫폼 표시
platforms=($(detect_platforms))
if [ ${#platforms[@]} -eq 0 ]; then
    echo -e "${YELLOW}  ⚠️  지원되는 플랫폼이 감지되지 않았습니다.${NC}"
    echo -e "${YELLOW}     지원 플랫폼: Claude Desktop, Claude Code, Cursor, Codex, Gemini CLI, OpenCode${NC}"
else
    echo -e "${GREEN}  ✓ 감지된 플랫폼: ${platforms[*]}${NC}"
fi

# context7 확인
check_context7

# keimcp 확인
check_keimcp

# 4. 완료 메시지
echo ""
echo -e "${BLUE}[4/4] 설치 완료!${NC}"
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  KeiMcpInit 설치 완료${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "다음 명령으로 커밋하세요:"
echo -e "${BLUE}  git add .gitmodules .agents AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules${NC}"
echo -e "${BLUE}  git add .github/copilot-instructions.md .amazon-q/ .codex/ .aider.conf.yml .continue/${NC}"
echo -e "${BLUE}  git commit -m \"feat: KeiMcpInit 추가\"${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  📝 다음 작업${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✓${NC} context7는 자동으로 추가되었습니다"
echo -e "${YELLOW}⚠️${NC} keimcp는 위에서 안내한 대로 LLM에게 추가 요청하세요"
echo ""
