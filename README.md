# kei-agents-config

AI 코딩 에이전트를 위한 공통 지침서 (Single Source of Truth)

## 지원 에이전트

| 에이전트 | 설정 파일 | 연결 방식 |
|----------|----------|-----------|
| Claude Code | `CLAUDE.md` | 심볼릭 링크 |
| Gemini CLI | `AGENTS.md` | 심볼릭 링크 |
| GitHub Copilot | `.github/copilot-instructions.md` | 심볼릭 링크 |
| Cursor | `.cursorrules` | 심볼릭 링크 |
| Windsurf | `.windsurfrules` | 심볼릭 링크 |
| Cline | `.clinerules` | 심볼릭 링크 |
| Aider | `.aider.conf.yml` | `read:` 설정 |
| Continue | `.continue/config.json` | contextProviders |
| Amazon Q | `.amazon-q/instructions.md` | 심볼릭 링크 |
| Codex CLI | `.codex/instructions.md` | 심볼릭 링크 |
| OpenCode | - | 수동 참조 |

## 설치 방법

### 1. Git Submodule 추가

```bash
# 프로젝트 루트에서 실행
git submodule add https://github.com/eightynine01/kei-agents-config.git .agents
```

### 2. 심볼릭 링크 설정

```bash
# 심볼릭 링크 및 설정 파일 자동 생성
.agents/scripts/setup-agents.sh --setup
```

### 3. Git 커밋

```bash
git add .gitmodules .agents
git add AGENTS.md CLAUDE.md .cursorrules .windsurfrules .clinerules
git add .github/copilot-instructions.md .amazon-q/ .codex/
git add .aider.conf.yml .continue/
git commit -m "feat: kei-agents-config submodule 추가"
```

## 업데이트 방법

```bash
# Submodule 업데이트
cd .agents
git pull origin main
cd ..

# 변경사항 커밋
git add .agents
git commit -m "chore: kei-agents-config 업데이트"
```

또는 한 줄로:

```bash
git submodule update --remote .agents && git add .agents && git commit -m "chore: kei-agents-config 업데이트"
```

## 클론 시 Submodule 초기화

```bash
# 클론과 동시에 submodule 초기화
git clone --recurse-submodules <repo-url>

# 또는 이미 클론한 경우
git submodule update --init --recursive
```

## 스크립트 사용법

```bash
# 심볼릭 링크 설정
.agents/scripts/setup-agents.sh --setup

# 상태 확인
.agents/scripts/setup-agents.sh --status

# 심볼릭 링크 제거
.agents/scripts/setup-agents.sh --clean

# 도움말
.agents/scripts/setup-agents.sh --help
```

## 파일 구조

```
kei-agents-config/
├── AGENTS.md                 # 마스터 파일 (하이브리드: TL;DR + 상세)
├── scripts/
│   └── setup-agents.sh       # 심볼릭 링크 설정 스크립트
└── README.md                 # 이 파일
```

적용 후 프로젝트 구조:

```
MyProject/
├── .agents/                  # Git Submodule
│   ├── AGENTS.md
│   └── scripts/setup-agents.sh
├── AGENTS.md                 # -> .agents/AGENTS.md
├── CLAUDE.md                 # -> .agents/AGENTS.md
├── .cursorrules              # -> .agents/AGENTS.md
├── .windsurfrules            # -> .agents/AGENTS.md
├── .clinerules               # -> .agents/AGENTS.md
├── .github/
│   └── copilot-instructions.md  # -> ../.agents/AGENTS.md
├── .amazon-q/
│   └── instructions.md       # -> ../.agents/AGENTS.md
├── .codex/
│   └── instructions.md       # -> ../.agents/AGENTS.md
├── .aider.conf.yml           # .agents/AGENTS.md 참조
└── .continue/
    └── config.json           # .agents/AGENTS.md 참조
```

## AGENTS.md 구조

하이브리드 형식으로 두 가지 사용 패턴 지원:

### TL;DR (Quick Reference)
- 컴팩트한 규칙과 명령어
- 빠른 참조용
- 약 180줄

### 상세 지침 (Full Documentation)
- 완전한 가이드 및 예제
- 학습 및 온보딩용
- 약 450줄

## .gitignore 권장사항

로컬 설정 파일은 .gitignore에 추가할 수 있습니다:

```gitignore
# 선택적: 로컬 에이전트 설정
# .aider.conf.yml
# .continue/
```

## 문제 해결

### Submodule이 비어있는 경우

```bash
git submodule update --init --recursive
```

### 심볼릭 링크가 깨진 경우

```bash
.agents/scripts/setup-agents.sh --clean
.agents/scripts/setup-agents.sh --setup
```

### 상태 확인

```bash
.agents/scripts/setup-agents.sh --status
```

## 버전 히스토리

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 2.1.0 | 2026-01-16 | Git Submodule 기반 Single Source of Truth 전환 |
| 2.0.0 | 2026-01-16 | 11개 AI 에이전트 지원, 하이브리드 형식 |
| 1.0.0 | 2026-01-15 | 초기 버전 |

## 라이선스

MIT License
