#!/bin/bash
# setup-agents.sh - AI 에이전트 설정 파일 심볼릭 링크 관리
#
# 사용법:
#   .agents/scripts/setup-agents.sh --setup   # 심볼릭 링크 설정
#   .agents/scripts/setup-agents.sh --status  # 상태 확인
#   .agents/scripts/setup-agents.sh --clean   # 심볼릭 링크 제거
#   .agents/scripts/setup-agents.sh --help    # 도움말

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 스크립트 위치 기준으로 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_DIR="$(dirname "$SCRIPT_DIR")"
REPO_ROOT="$(dirname "$AGENTS_DIR")"
AGENTS_MD="$AGENTS_DIR/AGENTS.md"

# 심볼릭 링크 대상 정의
# 형식: "대상파일:링크소스(상대경로)"
declare -a SYMLINKS=(
    "AGENTS.md:.agents/AGENTS.md"
    "CLAUDE.md:.agents/AGENTS.md"
    ".cursorrules:.agents/AGENTS.md"
    ".windsurfrules:.agents/AGENTS.md"
    ".clinerules:.agents/AGENTS.md"
)

# 하위 디렉토리의 심볼릭 링크
declare -a DIR_SYMLINKS=(
    ".github/copilot-instructions.md:../.agents/AGENTS.md"
    ".amazon-q/instructions.md:../.agents/AGENTS.md"
    ".codex/instructions.md:../.agents/AGENTS.md"
)

# 설정 파일 템플릿
AIDER_CONFIG='# Aider configuration - reads AGENTS.md as system prompt
# https://aider.chat/docs/config/aider_conf.html

read:
  - .agents/AGENTS.md

# Git 설정
auto-commits: false
dirty-commits: false

# 코드 스타일
lint-cmd: "ruff check --fix"
'

CONTINUE_CONFIG='{
  "$schema": "https://continue.dev/config-schema.json",
  "models": [],
  "customCommands": [],
  "contextProviders": [
    {
      "name": "file",
      "params": {
        "path": ".agents/AGENTS.md"
      }
    },
    {
      "name": "code"
    },
    {
      "name": "docs"
    }
  ],
  "slashCommands": [
    {
      "name": "deploy",
      "description": "Deploy application via ArgoCD"
    },
    {
      "name": "rollback",
      "description": "Rollback to previous version"
    }
  ]
}'

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  AI 에이전트 설정 파일 관리 스크립트${NC}"
    echo -e "${BLUE}  kei-agents-config v2.1.0${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_help() {
    print_header
    echo "사용법: $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --setup   심볼릭 링크 및 설정 파일 생성"
    echo "  --status  현재 설정 상태 확인"
    echo "  --clean   심볼릭 링크 제거"
    echo "  --help    이 도움말 표시"
    echo ""
    echo "예시:"
    echo "  .agents/scripts/setup-agents.sh --setup"
    echo "  .agents/scripts/setup-agents.sh --status"
}

check_agents_dir() {
    if [[ ! -f "$AGENTS_MD" ]]; then
        echo -e "${RED}오류: AGENTS.md 파일을 찾을 수 없습니다: $AGENTS_MD${NC}"
        echo "Git submodule이 제대로 초기화되었는지 확인하세요:"
        echo "  git submodule update --init --recursive"
        exit 1
    fi
}

create_symlink() {
    local target="$1"
    local source="$2"
    local full_path="$REPO_ROOT/$target"
    local parent_dir="$(dirname "$full_path")"

    # 부모 디렉토리가 없으면 생성
    if [[ ! -d "$parent_dir" && "$parent_dir" != "$REPO_ROOT" ]]; then
        mkdir -p "$parent_dir"
        echo -e "${GREEN}  디렉토리 생성: $parent_dir${NC}"
    fi

    # 기존 파일/링크 처리
    if [[ -L "$full_path" ]]; then
        # 이미 심볼릭 링크인 경우 삭제 후 재생성
        rm "$full_path"
    elif [[ -f "$full_path" ]]; then
        # 일반 파일인 경우 백업
        local backup="${full_path}.backup.$(date +%Y%m%d%H%M%S)"
        mv "$full_path" "$backup"
        echo -e "${YELLOW}  기존 파일 백업: $backup${NC}"
    fi

    # 심볼릭 링크 생성
    ln -s "$source" "$full_path"
    echo -e "${GREEN}  링크 생성: $target -> $source${NC}"
}

setup_symlinks() {
    print_header
    echo -e "${BLUE}심볼릭 링크 설정 시작...${NC}"
    echo ""

    check_agents_dir

    # 루트 레벨 심볼릭 링크
    echo "루트 레벨 심볼릭 링크:"
    for item in "${SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        create_symlink "$target" "$source"
    done

    echo ""
    echo "하위 디렉토리 심볼릭 링크:"
    for item in "${DIR_SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        create_symlink "$target" "$source"
    done

    echo ""
    echo "설정 파일 생성:"

    # Aider 설정
    local aider_file="$REPO_ROOT/.aider.conf.yml"
    echo "$AIDER_CONFIG" > "$aider_file"
    echo -e "${GREEN}  생성: .aider.conf.yml${NC}"

    # Continue 설정
    local continue_dir="$REPO_ROOT/.continue"
    mkdir -p "$continue_dir"
    echo "$CONTINUE_CONFIG" > "$continue_dir/config.json"
    echo -e "${GREEN}  생성: .continue/config.json${NC}"

    echo ""
    echo -e "${GREEN}설정 완료!${NC}"
    echo ""
    echo "다음 파일들을 .gitignore에 추가하세요 (선택사항):"
    echo "  .aider.conf.yml"
    echo "  .continue/"
}

check_status() {
    print_header
    echo -e "${BLUE}설정 상태 확인...${NC}"
    echo ""

    local all_ok=true

    echo "루트 레벨 심볼릭 링크:"
    for item in "${SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        local full_path="$REPO_ROOT/$target"

        if [[ -L "$full_path" ]]; then
            local link_target="$(readlink "$full_path")"
            if [[ "$link_target" == "$source" ]]; then
                echo -e "  ${GREEN}[OK]${NC} $target -> $link_target"
            else
                echo -e "  ${YELLOW}[WRONG]${NC} $target -> $link_target (예상: $source)"
                all_ok=false
            fi
        elif [[ -f "$full_path" ]]; then
            echo -e "  ${YELLOW}[FILE]${NC} $target (심볼릭 링크 아님)"
            all_ok=false
        else
            echo -e "  ${RED}[MISSING]${NC} $target"
            all_ok=false
        fi
    done

    echo ""
    echo "하위 디렉토리 심볼릭 링크:"
    for item in "${DIR_SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        local full_path="$REPO_ROOT/$target"

        if [[ -L "$full_path" ]]; then
            local link_target="$(readlink "$full_path")"
            if [[ "$link_target" == "$source" ]]; then
                echo -e "  ${GREEN}[OK]${NC} $target -> $link_target"
            else
                echo -e "  ${YELLOW}[WRONG]${NC} $target -> $link_target (예상: $source)"
                all_ok=false
            fi
        elif [[ -f "$full_path" ]]; then
            echo -e "  ${YELLOW}[FILE]${NC} $target (심볼릭 링크 아님)"
            all_ok=false
        else
            echo -e "  ${RED}[MISSING]${NC} $target"
            all_ok=false
        fi
    done

    echo ""
    echo "설정 파일:"

    # Aider
    if [[ -f "$REPO_ROOT/.aider.conf.yml" ]]; then
        if grep -q ".agents/AGENTS.md" "$REPO_ROOT/.aider.conf.yml" 2>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC} .aider.conf.yml"
        else
            echo -e "  ${YELLOW}[OUTDATED]${NC} .aider.conf.yml (경로 업데이트 필요)"
            all_ok=false
        fi
    else
        echo -e "  ${RED}[MISSING]${NC} .aider.conf.yml"
        all_ok=false
    fi

    # Continue
    if [[ -f "$REPO_ROOT/.continue/config.json" ]]; then
        if grep -q ".agents/AGENTS.md" "$REPO_ROOT/.continue/config.json" 2>/dev/null; then
            echo -e "  ${GREEN}[OK]${NC} .continue/config.json"
        else
            echo -e "  ${YELLOW}[OUTDATED]${NC} .continue/config.json (경로 업데이트 필요)"
            all_ok=false
        fi
    else
        echo -e "  ${RED}[MISSING]${NC} .continue/config.json"
        all_ok=false
    fi

    echo ""
    if $all_ok; then
        echo -e "${GREEN}모든 설정이 올바르게 구성되어 있습니다.${NC}"
    else
        echo -e "${YELLOW}일부 설정이 누락되거나 잘못되어 있습니다.${NC}"
        echo "다음 명령으로 설정할 수 있습니다:"
        echo "  .agents/scripts/setup-agents.sh --setup"
    fi
}

clean_symlinks() {
    print_header
    echo -e "${BLUE}심볼릭 링크 제거 시작...${NC}"
    echo ""

    echo "루트 레벨 심볼릭 링크:"
    for item in "${SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        local full_path="$REPO_ROOT/$target"

        if [[ -L "$full_path" ]]; then
            rm "$full_path"
            echo -e "${GREEN}  제거: $target${NC}"
        elif [[ -f "$full_path" ]]; then
            echo -e "${YELLOW}  스킵: $target (심볼릭 링크 아님)${NC}"
        else
            echo -e "${YELLOW}  스킵: $target (존재하지 않음)${NC}"
        fi
    done

    echo ""
    echo "하위 디렉토리 심볼릭 링크:"
    for item in "${DIR_SYMLINKS[@]}"; do
        IFS=':' read -r target source <<< "$item"
        local full_path="$REPO_ROOT/$target"

        if [[ -L "$full_path" ]]; then
            rm "$full_path"
            echo -e "${GREEN}  제거: $target${NC}"
        elif [[ -f "$full_path" ]]; then
            echo -e "${YELLOW}  스킵: $target (심볼릭 링크 아님)${NC}"
        else
            echo -e "${YELLOW}  스킵: $target (존재하지 않음)${NC}"
        fi
    done

    echo ""
    echo -e "${GREEN}심볼릭 링크 제거 완료!${NC}"
    echo ""
    echo "참고: 설정 파일(.aider.conf.yml, .continue/)은 제거되지 않았습니다."
    echo "수동으로 제거하려면:"
    echo "  rm .aider.conf.yml"
    echo "  rm -rf .continue/"
}

# 메인 실행
case "${1:-}" in
    --setup)
        setup_symlinks
        ;;
    --status)
        check_status
        ;;
    --clean)
        clean_symlinks
        ;;
    --help|-h)
        print_help
        ;;
    *)
        print_help
        exit 1
        ;;
esac
